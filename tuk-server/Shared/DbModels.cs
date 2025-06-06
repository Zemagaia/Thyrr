﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Shared.resources;
using NLog;
using Newtonsoft.Json;
using StackExchange.Redis;

namespace Shared
{
    public abstract class RedisObject
    {
        private static readonly Logger Log = LogUtil.GetLogger(typeof(RedisObject));

        //Note do not modify returning buffer
        private Dictionary<RedisValue, KeyValuePair<byte[], bool>> _entries;

        protected void Init(IDatabase db, string key, string field = null)
        {
            Key = key;
            Database = db;

            if (field == null)
                _entries = db.HashGetAll(key)
                    .ToDictionary(
                        x => x.Name,
                        x => new KeyValuePair<byte[], bool>(x.Value, false));
            else
            {
                var entry = new[] { new HashEntry(field, db.HashGet(key, field)) };
                _entries = entry.ToDictionary(x => x.Name,
                    x => new KeyValuePair<byte[], bool>(x.Value, false));
            }
        }

        public IDatabase Database { get; private set; }
        public string Key { get; private set; }

        public IEnumerable<RedisValue> AllKeys => _entries.Keys;

        public bool IsNull => _entries.Count == 0;

        protected byte[] GetValueRaw(RedisValue key)
        {
            KeyValuePair<byte[], bool> val;
            if (!_entries.TryGetValue(key, out val))
                return null;

            if (val.Key == null)
                return null;

            return (byte[])val.Key.Clone();
        }

        protected T GetValue<T>(RedisValue key, T def = default)
        {
            KeyValuePair<byte[], bool> val;
            if (!_entries.TryGetValue(key, out val) || val.Key == null)
                return def;

            if (typeof(T) == typeof(int))
                return (T)(object)int.Parse(Encoding.UTF8.GetString(val.Key));

            if (typeof(T) == typeof(uint))
                return (T)(object)uint.Parse(Encoding.UTF8.GetString(val.Key));

            if (typeof(T) == typeof(ushort))
                return (T)(object)ushort.Parse(Encoding.UTF8.GetString(val.Key));

            if (typeof(T) == typeof(bool))
                return (T)(object)(val.Key[0] != 0);

            if (typeof(T) == typeof(DateTime))
                return (T)(object)DateTime.FromBinary(BitConverter.ToInt64(val.Key, 0));

            if (typeof(T) == typeof(byte[]))
                return (T)(object)val.Key;

            if (typeof(T) == typeof(ushort[]))
            {
                var ret = new ushort[val.Key.Length / 2];
                Buffer.BlockCopy(val.Key, 0, ret, 0, val.Key.Length);
                return (T)(object)ret;
            }

            if (typeof(T) == typeof(int[]) ||
                typeof(T) == typeof(uint[]))
            {
                var ret = new int[val.Key.Length / 4];
                Buffer.BlockCopy(val.Key, 0, ret, 0, val.Key.Length);
                return (T)(object)ret;
            }
            
            if (typeof(T) == typeof(HashSet<int>))
            {
                var ret = new HashSet<int>();
                var arr = new int[val.Key.Length / 4];
                Buffer.BlockCopy(val.Key, 0, arr, 0, val.Key.Length);
                for (var i = 0; i < arr.Length; i++)
                    ret.Add(arr[i]);
                return (T)(object)ret;
            }

            if (typeof(T) == typeof(string))
                return (T)(object)Encoding.UTF8.GetString(val.Key);

            if (typeof(T) == typeof(ItemData[]))
                return (T)val.Key.FromBytes(typeof(ItemData[]));

            if (typeof(T) == typeof(PetData[]))
                return (T)val.Key.FromBytes(typeof(PetData[]));

            if (typeof(T) == typeof(PetData))
                return (T)(object)new PetData(val.Key);

            if (typeof(T) == typeof(QuestData[]))
                return (T)val.Key.FromBytes(typeof(QuestData[]));

            if (typeof(T) == typeof(AcceptedQuestData[]))
                return (T)val.Key.FromBytes(typeof(AcceptedQuestData[]));

            throw new NotSupportedException();
        }

        protected void SetValue<T>(RedisValue key, T val)
        {
            byte[] buff;
            if (typeof(T) == typeof(int) || typeof(T) == typeof(uint) ||
                typeof(T) == typeof(ushort) || typeof(T) == typeof(string))
                buff = Encoding.UTF8.GetBytes(val.ToString());

            else if (typeof(T) == typeof(bool))
                buff = new[] { (byte)((bool)(object)val ? 1 : 0) };

            else if (typeof(T) == typeof(DateTime))
                buff = BitConverter.GetBytes(((DateTime)(object)val).ToBinary());

            else if (typeof(T) == typeof(byte[]))
                buff = (byte[])(object)val;

            else if (typeof(T) == typeof(ushort[]))
            {
                var v = (ushort[])(object)val;
                buff = new byte[v.Length * 2];
                Buffer.BlockCopy(v, 0, buff, 0, buff.Length);
            }

            else if (typeof(T) == typeof(int[]) ||
                     typeof(T) == typeof(uint[]))
            {
                var v = (int[])(object)val;
                buff = new byte[v.Length * 4];
                Buffer.BlockCopy(v, 0, buff, 0, buff.Length);
            }

            else if (typeof(T) == typeof(HashSet<int>))
            {
                var v = (HashSet<int>)(object)val;
                var arr = new int[v.Count];
                var i = 0;
                foreach (var n in v)
                {
                    arr[i] = n;
                    i++;
                }
                buff = new byte[arr.Length * 4];
                Buffer.BlockCopy(arr, 0, buff, 0, buff.Length);
            }
            
            else if (typeof(T) == typeof(ItemData[]))
                buff = ((ItemData[])(object)val).ToBytes(true);
            
            else if (typeof(T) == typeof(PetData[]))
                buff = ((PetData[])(object)val).ToBytes(true);
            
            else if (typeof(T) == typeof(PetData))
                buff = ((PetData)(object)val).Export();
            
            else if (typeof(T) == typeof(QuestData[]))
                buff = ((QuestData[])(object)val).ToBytes(true);
            
            else if (typeof(T) == typeof(AcceptedQuestData[]))
                buff = ((AcceptedQuestData[])(object)val).ToBytes(true);

            else
                throw new NotSupportedException();

            if (!_entries.ContainsKey(Key) || _entries[Key].Key == null || !buff.SequenceEqual(_entries[Key].Key))
                _entries[key] = new KeyValuePair<byte[], bool>(buff, true);
        }

        private List<HashEntry> _update;

        public Task FlushAsync(ITransaction transaction = null)
        {
            ReadyFlush();
            return transaction == null
                ? Database.HashSetAsync(Key, _update.ToArray())
                : transaction.HashSetAsync(Key, _update.ToArray());
        }

        private void ReadyFlush()
        {
            if (_update == null)
                _update = new List<HashEntry>();
            _update.Clear();

            foreach (var name in _entries.Keys)
                if (_entries[name].Value)
                    _update.Add(new HashEntry(name, _entries[name].Key));

            foreach (var update in _update)
                _entries[update.Name] = new KeyValuePair<byte[], bool>(_entries[update.Name].Key, false);
        }

        public async Task ReloadAsync(ITransaction trans = null, string field = null)
        {
            if (field != null && _entries != null)
            {
                var tf = trans != null ? trans.HashGetAsync(Key, field) : Database.HashGetAsync(Key, field);

                try
                {
                    await tf;
                    _entries[field] = new KeyValuePair<byte[], bool>(
                        tf.Result, false);
                }
                catch
                {
                }

                return;
            }

            var t = trans != null ? trans.HashGetAllAsync(Key) : Database.HashGetAllAsync(Key);

            try
            {
                await t;
                _entries = t.Result.ToDictionary(
                    x => x.Name, x => new KeyValuePair<byte[], bool>(x.Value, false));
            }
            catch
            {
            }
        }

        public void Reload(string field = null)
        {
            if (field != null && _entries != null)
            {
                _entries[field] = new KeyValuePair<byte[], bool>(
                    Database.HashGet(Key, field), false);
                return;
            }

            _entries = Database.HashGetAll(Key)
                .ToDictionary(
                    x => x.Name,
                    x => new KeyValuePair<byte[], bool>(x.Value, false));
        }
    }

    public class DbLoginInfo
    {
        private IDatabase db;

        internal DbLoginInfo(IDatabase db, string uuid)
        {
            this.db = db;
            UUID = uuid;
            var json = (string)db.HashGet("logins", uuid.ToUpperInvariant());
            if (json == null)
                IsNull = true;
            else
                JsonConvert.PopulateObject(json, this);
        }

        [JsonIgnore] public string UUID { get; private set; }

        [JsonIgnore] public bool IsNull { get; private set; }

        public string Salt { get; set; }
        public string HashedPassword { get; set; }
        public int AccountId { get; set; }

        public void Flush()
        {
            db.HashSet("logins", UUID.ToUpperInvariant(), JsonConvert.SerializeObject(this));
        }
    }

    public class DbMarketData
    {
        private IDatabase _db;

        public DbMarketData() // empty for deserialization.
        {
        }

        internal DbMarketData(IDatabase db, int id)
        {
            _db = db;

            Id = id;
            var json = (string)db.HashGet("market", id);
            if (json == null)
            {
                IsNull = true;
            }
            else
            {
                JsonConvert.PopulateObject(json, this);
            }
        }

        private static readonly Random _rand = new();

        public static int NextId(IDatabase db)
        {
            int id;
            do
            {
                id = _rand.Next(int.MaxValue);
            } while ((string)db.HashGet("market", id) != null);

            return id;
        }

        [JsonProperty("marketId")] public int Id;

        [JsonProperty("itemData")] public ItemData ItemData;

        [JsonProperty("sellerName")] public string SellerName;

        [JsonProperty("sellerId")] public int SellerId;

        [JsonProperty("currency")] public CurrencyType Currency;

        [JsonProperty("price")] public int Price;

        [JsonProperty("startTime")] public int StartTime;

        [JsonProperty("timeLeft")] public int TimeLeft;

        [JsonIgnore] public bool IsNull { get; private set; }

        public void Flush()
        {
            _db.HashSet("market", Id, JsonConvert.SerializeObject(this));
        }

        public static DbMarketData[] Get(IDatabase db, ushort itemType)
        {
            List<DbMarketData> ret = new List<DbMarketData>();
            var allOffers = db.HashGetAll("market");
            foreach (var i in allOffers)
            {
                DbMarketData l = JsonConvert.DeserializeObject<DbMarketData>(i.Value);
                if (l.ItemData.ObjectType == itemType)
                {
                    ret.Add(l);
                }
            }

            return ret.ToArray();
        }

        public static void CleanMarket(Database db)
        {
            var allOffers = db.Conn.HashGetAll("market");
            foreach (var i in allOffers)
            {
                DbMarketData l = JsonConvert.DeserializeObject<DbMarketData>(i.Value);
                if (l.TimeLeft <
                    DateTime.UtcNow.ToUnixTimestamp()) // Market has been up its max time, remove it from marketplace.
                {
                    DbAccount
                        owner = db.GetAccount(l
                            .SellerId); // Owner should never be null, as SellerId should ALWAYS be a valid account id.
                    db.RemoveMarketData(owner, l.Id);
                    db.AddGift(owner, l.ItemData);
                }
            }
        }
    }

    public class DbAccount : RedisObject
    {
        public DbAccount(IDatabase db, int accId, string field = null)
        {
            AccountId = accId;
            Init(db, "account." + accId, field);

            if (field != null)
                return;

            if (DiscordId != null)
                DiscordRank = (int)db.HashGet("discordRank", DiscordId);

            var time = Utils.FromUnixTimestamp(BanLiftTime);
            if (!Banned || BanLiftTime <= -1 || time > DateTime.UtcNow) return;
            Banned = false;
            BanLiftTime = 0;
            FlushAsync();
        }

        public int AccountId { get; private set; }
        public int DiscordRank { get; private set; }

        public int AccountIdOverride
        {
            get => GetValue<int>("accountIdOverride");
            set => SetValue("accountIdOverride", value);
        }

        public int AccountIdOverrider { get; set; }

        internal string LockToken { get; set; }

        public string UUID
        {
            get => GetValue<string>("uuid");
            set => SetValue("uuid", value);
        }

        public string Name
        {
            get => GetValue<string>("name");
            set => SetValue("name", value);
        }

        public bool Admin
        {
            get => GetValue<bool>("admin");
            set => SetValue("admin", value);
        }

        public bool NameChosen
        {
            get => GetValue<bool>("nameChosen");
            set => SetValue("nameChosen", value);
        }

        public bool Verified
        {
            get => GetValue<bool>("verified");
            set => SetValue("verified", value);
        }

        public bool AgeVerified
        {
            get => GetValue<bool>("ageVerified");
            set => SetValue("ageVerified", value);
        }

        public bool FirstDeath
        {
            get => GetValue<bool>("firstDeath");
            set => SetValue("firstDeath", value);
        }

        public int PetYardType
        {
            get => GetValue<int>("petYardType");
            set => SetValue("petYardType", value);
        }

        public int GuildId
        {
            get => GetValue<int>("guildId");
            set => SetValue("guildId", value);
        }

        public int GuildRank
        {
            get => GetValue<int>("guildRank");
            set => SetValue("guildRank", value);
        }

        public int GuildFame
        {
            get => GetValue<int>("guildFame");
            set => SetValue("guildFame", value);
        }

        public int VaultCount
        {
            get => GetValue<int>("vaultCount");
            set => SetValue("vaultCount", value);
        }

        public int NextGiftId
        {
            get => GetValue<int>("nextGiftId");
            set => SetValue("nextGiftId", value);
        }

        public HashSet<int> ActiveGiftChests
        {
            get => GetValue("activeGiftChests", new HashSet<int>());
            set => SetValue("activeGiftChests", value);
        }

        // Market
        public int[] MarketOffers
        {
            get => GetValue<int[]>("marketOffers") ?? new int[0];
            set => SetValue("marketOffers", value);
        }

        public int MaxCharSlot
        {
            get => GetValue<int>("maxCharSlot");
            set => SetValue("maxCharSlot", value);
        }

        public DateTime RegTime
        {
            get => GetValue<DateTime>("regTime");
            set => SetValue("regTime", value);
        }

        public bool Guest
        {
            get => GetValue<bool>("guest");
            set => SetValue("guest", value);
        }

        public int Credits
        {
            get => GetValue<int>("credits");
            set => SetValue("credits", value);
        }

        public int TotalCredits
        {
            get => GetValue<int>("totalCredits");
            set => SetValue("totalCredits", value);
        }

        public int Fame
        {
            get => GetValue<int>("fame");
            set => SetValue("fame", value);
        }

        public int TotalFame
        {
            get => GetValue<int>("totalFame");
            set => SetValue("totalFame", value);
        }

        public int Tokens
        {
            get => GetValue<int>("tokens");
            set => SetValue("tokens", value);
        }

        public int TotalTokens
        {
            get => GetValue<int>("totalTokens");
            set => SetValue("totalTokens", value);
        }

        public int UnholyEssence
        {
            get => GetValue<int>("unholyEssence");
            set => SetValue("unholyEssence", value);
        }

        public int TotalUnholyEssence
        {
            get => GetValue<int>("totalUnholyEssence");
            set => SetValue("totalUnholyEssence", value);
        }

        public int DivineEssence
        {
            get => GetValue<int>("divineEssence");
            set => SetValue("divineEssence", value);
        }

        public int TotalDivineEssence
        {
            get => GetValue<int>("totalDivineEssence");
            set => SetValue("totalDivineEssence", value);
        }

        public int NextCharId
        {
            get => GetValue<int>("nextCharId");
            set => SetValue("nextCharId", value);
        }

        public int LegacyRank
        {
            get => GetValue<int>("rank");
            set => SetValue("rank", value);
        }

        public ushort[] Skins
        {
            get => GetValue<ushort[]>("skins") ?? new ushort[0];
            set => SetValue("skins", value);
        }

        public int[] LockList
        {
            get => GetValue<int[]>("lockList") ?? new int[0];
            set => SetValue("lockList", value);
        }

        public int[] IgnoreList
        {
            get => GetValue<int[]>("ignoreList") ?? new int[0];
            set => SetValue("ignoreList", value);
        }

        public bool Banned
        {
            get => GetValue<bool>("banned");
            set => SetValue("banned", value);
        }

        public string Notes
        {
            get => GetValue<string>("notes");
            set => SetValue("notes", value);
        }

        public bool Hidden
        {
            get => GetValue<bool>("hidden");
            set => SetValue("hidden", value);
        }

        public int GlowColor
        {
            get => GetValue<int>("glow");
            set => SetValue("glow", value);
        }

        public string PassResetToken
        {
            get => GetValue<string>("passResetToken");
            set => SetValue("passResetToken", value);
        }

        public string IP
        {
            get => GetValue<string>("ip");
            set => SetValue("ip", value);
        }

        public int BanLiftTime
        {
            get => GetValue<int>("banLiftTime");
            set => SetValue("banLiftTime", value);
        }

        public List<string> Emotes
        {
            get => GetValue<string>("emotes")?.CommaToArray<string>()?.ToList() ?? new List<string>();
            set => SetValue("emotes", value?.ToArray().ToCommaSepString() ?? string.Empty);
        }

        public int LastSeen
        {
            get => GetValue<int>("lastSeen");
            set => SetValue("lastSeen", value);
        }

        public int Size
        {
            get => GetValue<int>("size");
            set => SetValue("size", value);
        }

        public bool RankManager
        {
            get => GetValue<bool>("rankManager");
            set => SetValue("rankManager", value);
        }

        public string DiscordId
        {
            get => GetValue<string>("discordId");
            set => SetValue("discordId", value);
        }

        public int Rank => DiscordRank > LegacyRank ? DiscordRank : LegacyRank;

        public List<AccountMail> AccountMails
        {
            get
            {
                try
                {
                    return JsonConvert.DeserializeObject<List<AccountMail>>(GetValue<string>("mail"));
                }
                catch
                {
                    return null;
                }
            }
            set => SetValue("mail", JsonConvert.SerializeObject(value, Utils.SerializerSettings()));
        }

        public AcceptedQuestData[] AccountQuests
        {
            get => GetValue<AcceptedQuestData[]>("quests");
            set => SetValue("quests", value);
        }

        // by unix datetime
        public int[] DailyQuestsCompleted
        {
            get => GetValue<int[]>("dailyQuestsCompleted") ?? new int[0];
            set => SetValue("dailyQuestsCompleted", value);
        }

        public PetData[] PetDatas
        {
            get => GetValue<PetData[]>("petDatas");
            set => SetValue("petDatas", value);
        }

        public void RefreshLastSeen()
        {
            LastSeen = (int)DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1)).TotalSeconds;
        }
    }

    public struct DbClassStatsEntry
    {
        public int BestLevel;
        public int BestFame;
    }

    public class PetData
    {
        public int Id;
        public ushort ObjectType;

        public PetData()
        {
        }

        public static PetData Read(NReader rdr)
        {
            return new PetData()
            {
                Id = rdr.ReadInt32(),
                ObjectType = rdr.ReadUInt16()
            };
        }
        
        public PetData(byte[] data)
        {
            using (var ms = new MemoryStream(data))
            using (var rdr = new NReader(ms))
            {
                Id = rdr.ReadInt32();
                ObjectType = rdr.ReadUInt16();
            }
        }
        
        public byte[] Export()
        {
            using (var ms = new MemoryStream())
            using (var wtr = new NWriter(ms))
            {
                wtr.Write(Id);
                wtr.Write(ObjectType);
                return ms.ToArray();
            }
        }
    }

    public class DbClassStats : RedisObject
    {
        public DbAccount Account { get; private set; }

        public DbClassStats(DbAccount acc, ushort? type = null)
        {
            Account = acc;
            Init(acc.Database, "classStats." + acc.AccountId, type?.ToString());
        }

        public void Unlock(ushort type)
        {
            var field = type.ToString();
            string json = GetValue<string>(field);
            if (json == null)
                SetValue(field, JsonConvert.SerializeObject(new DbClassStatsEntry
                {
                    BestLevel = 0,
                    BestFame = 0
                }));
        }

        public void Update(DbChar character)
        {
            var field = character.ObjectType.ToString();
            var finalFame = Math.Max(character.Fame, character.FinalFame);
            string json = GetValue<string>(field);
            if (json == null)
                SetValue(field, JsonConvert.SerializeObject(new DbClassStatsEntry
                {
                    BestLevel = character.Level,
                    BestFame = finalFame
                }));
            else
            {
                var entry = JsonConvert.DeserializeObject<DbClassStatsEntry>(json);
                if (character.Level > entry.BestLevel)
                    entry.BestLevel = character.Level;
                if (finalFame > entry.BestFame)
                    entry.BestFame = finalFame;
                SetValue(field, JsonConvert.SerializeObject(entry));
            }
        }

        public DbClassStatsEntry this[ushort type]
        {
            get
            {
                string v = GetValue<string>(type.ToString());
                if (v != null) return JsonConvert.DeserializeObject<DbClassStatsEntry>(v);
                return default;
            }
            set => SetValue(type.ToString(), JsonConvert.SerializeObject(value));
        }
    }

    public class DbChar : RedisObject
    {
        public DbAccount Account { get; private set; }
        public int CharId { get; private set; }

        public DbChar(DbAccount acc, int charId)
        {
            Account = acc;
            CharId = charId;
            Init(acc.Database, "char." + acc.AccountId + "." + charId);
        }

        public QuestData[] AvailableQuests
        {
            get => GetValue<QuestData[]>("availableQuests");
            set => SetValue("availableQuests", value);
        }

        public AcceptedQuestData[] CharacterQuests
        {
            get => GetValue<AcceptedQuestData[]>("quests");
            set => SetValue("quests", value);
        }

        public ushort ObjectType
        {
            get => GetValue<ushort>("charType");
            set => SetValue("charType", value);
        }

        public int Level
        {
            get => GetValue<int>("level");
            set => SetValue("level", value);
        }

        public int Experience
        {
            get => GetValue<int>("exp");
            set => SetValue("exp", value);
        }

        public int Fame
        {
            get => GetValue<int>("fame");
            set => SetValue("fame", value);
        }

        public int FinalFame
        {
            get => GetValue<int>("finalFame");
            set => SetValue("finalFame", value);
        }

        public ItemData[] Items
        {
            get => GetValue("items", new ItemData[20].Select(_ => new ItemData()).ToArray());
            set => SetValue("items", value);
        }

        public int HP
        {
            get => GetValue<int>("hp");
            set => SetValue("hp", value);
        }

        public int MP
        {
            get => GetValue<int>("mp");
            set => SetValue("mp", value);
        }

        public int[] Stats
        {
            get => GetValue<int[]>("stats");
            set => SetValue("stats", value);
        }

        public int Tex1
        {
            get => GetValue<int>("tex1");
            set => SetValue("tex1", value);
        }

        public int Tex2
        {
            get => GetValue<int>("tex2");
            set => SetValue("tex2", value);
        }

        public int Skin
        {
            get => GetValue<int>("skin");
            set => SetValue("skin", value);
        }

        public PetData PetData
        {
            get => GetValue<PetData>("petData");
            set => SetValue("petData", value);
        }

        public byte[] FameStats
        {
            get => GetValue<byte[]>("fameStats");
            set => SetValue("fameStats", value);
        }

        public DateTime CreateTime
        {
            get => GetValue<DateTime>("createTime");
            set => SetValue("createTime", value);
        }

        public DateTime LastSeen
        {
            get => GetValue<DateTime>("lastSeen");
            set => SetValue("lastSeen", value);
        }

        public bool Dead
        {
            get => GetValue<bool>("dead");
            set => SetValue("dead", value);
        }

        public int HealthStackCount
        {
            get => GetValue<int>("hpPotCount");
            set => SetValue("hpPotCount", value);
        }

        public int MagicStackCount
        {
            get => GetValue<int>("mpPotCount");
            set => SetValue("mpPotCount", value);
        }

        public bool HasBackpack
        {
            get => GetValue<bool>("hasBackpack");
            set => SetValue("hasBackpack", value);
        }

        public int XPBoostTime
        {
            get => GetValue<int>("xpBoost");
            set => SetValue("xpBoost", value);
        }

        public int LDBoostTime
        {
            get => GetValue<int>("ldBoost");
            set => SetValue("ldBoost", value);
        }

        public int LTBoostTime
        {
            get => GetValue<int>("ltBoost");
            set => SetValue("ltBoost", value);
        }

        public int Light
        {
            get => GetValue<int>("light");
            set => SetValue("light", value);
        }

        public int OffensiveAbility
        {
            get => GetValue<int>("offensiveAbility");
            set => SetValue("offensiveAbility", value);
        }

        public int DefensiveAbility
        {
            get => GetValue<int>("defensiveAbility");
            set => SetValue("defensiveAbility", value);
        }
    }

    public class DbDeath : RedisObject
    {
        public DbAccount Account { get; private set; }
        public int CharId { get; private set; }

        public DbDeath(DbAccount acc, int charId)
        {
            Account = acc;
            CharId = charId;
            Init(acc.Database, "death." + acc.AccountId + "." + charId);
        }

        public ushort ObjectType
        {
            get => GetValue<ushort>("objType");
            set => SetValue("objType", value);
        }

        public int Level
        {
            get => GetValue<int>("level");
            set => SetValue("level", value);
        }

        public int TotalFame
        {
            get => GetValue<int>("totalFame");
            set => SetValue("totalFame", value);
        }

        public string Killer
        {
            get => GetValue<string>("killer");
            set => SetValue("killer", value);
        }

        public bool FirstBorn
        {
            get => GetValue<bool>("firstBorn");
            set => SetValue("firstBorn", value);
        }

        public DateTime DeathTime
        {
            get => GetValue<DateTime>("deathTime");
            set => SetValue("deathTime", value);
        }
    }

    public struct DbNewsEntry
    {
        [JsonIgnore] public DateTime Date;
        public string Icon;
        public string Title;
        public string Text;
        public string Link;
    }

    public class DbNews // TODO. Check later, range results might be bugged...
    {
        public DbNews(IDatabase db, int count)
        {
            news = db.SortedSetRangeByRankWithScores("news", 0, count)
                .Select(x =>
                {
                    DbNewsEntry ret = JsonConvert.DeserializeObject<DbNewsEntry>(
                        Encoding.UTF8.GetString(x.Element));
                    ret.Date = new DateTime(1970, 1, 1, 0, 0, 0).AddSeconds(x.Score);
                    return ret;
                }).ToArray();
        }

        private DbNewsEntry[] news;

        public DbNewsEntry[] Entries => news;
    }

    public abstract class RInventory : RedisObject
    {
        public string Field { get; protected set; }

        public ItemData[] Items
        {
            get => GetValue(Field, new ItemData[18].Select(_ => new ItemData()).ToArray());
            set => SetValue(Field, value);
        }
    }

    public class DbVaultSingle : RInventory
    {
        public DbVaultSingle(DbAccount acc, int vaultIndex)
        {
            Field = "vault." + vaultIndex;
            Init(acc.Database, "vault." + acc.AccountId, Field);

            var items = GetValue<ItemData[]>(Field);
            if (items != null)
                return;

            var trans = Database.CreateTransaction();
            SetValue(Field, Utils.ResizeArray(Items, 36).Select(_ => new ItemData()).ToArray());
            FlushAsync(trans);
            trans.Execute(CommandFlags.FireAndForget);
        }
    }

    public class DbGiftSingle : RInventory
    {
        public DbGiftSingle(DbAccount acc, int giftIndex)
        {
            Field = "gift." + giftIndex;
            Init(acc.Database, "vault." + acc.AccountId, Field);

            var items = GetValue<ItemData[]>(Field);
            if (items != null)
                return;

            var trans = Database.CreateTransaction();
            SetValue(Field, Utils.ResizeArray(Items, 0));
            FlushAsync(trans);
            trans.Execute(CommandFlags.FireAndForget);
        }
    }

    public class DbCharInv : RInventory
    {
        public DbCharInv(DbAccount acc, int charId)
        {
            Field = "items";
            Init(acc.Database, "char." + acc.AccountId + "." + charId, Field);
        }
    }

    public struct DbLegendEntry
    {
        public readonly int AccId;
        public readonly int ChrId;

        public DbLegendEntry(int accId, int chrId)
        {
            AccId = accId;
            ChrId = chrId;
        }
    }

    public static class DbLegend
    {
        private const int MaxListings = 20;
        private const int MaxGlowingRank = 10;

        private static readonly Dictionary<string, TimeSpan> TimeSpans = new()
        {
            { "week", TimeSpan.FromDays(7) },
            { "month", TimeSpan.FromDays(30) },
            { "all", TimeSpan.MaxValue }
        };

        public static void Clean(IDatabase db)
        {
            // remove legend entries that expired
            foreach (var span in TimeSpans)
            {
                if (span.Value == TimeSpan.MaxValue)
                {
                    // bound legend by count
                    db.SortedSetRemoveRangeByRankAsync($"legends:{span.Key}:byFame",
                        0, -MaxListings - 1, CommandFlags.FireAndForget);
                    continue;
                }

                // bound legend by time
                var outdated = db.SortedSetRangeByScore(
                    $"legends:{span.Key}:byTimeOfDeath", 0,
                    DateTime.UtcNow.ToUnixTimestamp());

                var trans = db.CreateTransaction();
                trans.SortedSetRemoveAsync($"legends:{span.Key}:byFame", outdated, CommandFlags.FireAndForget);
                trans.SortedSetRemoveAsync($"legends:{span.Key}:byTimeOfDeath", outdated, CommandFlags.FireAndForget);
                trans.ExecuteAsync(CommandFlags.FireAndForget);
            }

            // refresh legend hash
            db.KeyDeleteAsync("legend", CommandFlags.FireAndForget);
            foreach (var span in TimeSpans)
            {
                var legendTask = db.SortedSetRangeByRankAsync($"legends:{span.Key}:byFame",
                    0, MaxGlowingRank - 1, Order.Descending);
                legendTask.ContinueWith(r =>
                {
                    var trans = db.CreateTransaction();
                    foreach (var e in r.Result)
                    {
                        var accId = BitConverter.ToInt32(e, 0);
                        trans.HashSetAsync("legend", accId, "",
                            flags: CommandFlags.FireAndForget);
                    }

                    trans.ExecuteAsync(CommandFlags.FireAndForget);
                });
            }

            db.StringSetAsync("legends:updateTime", DateTime.UtcNow.ToUnixTimestamp(),
                flags: CommandFlags.FireAndForget);
        }

        public static void Insert(IDatabase db,
            int accId, int chrId, int totalFame)
        {
            var buff = new byte[8];
            Buffer.BlockCopy(BitConverter.GetBytes(accId), 0, buff, 0, 4);
            Buffer.BlockCopy(BitConverter.GetBytes(chrId), 0, buff, 4, 4);

            // add entry to each legends list
            var trans = db.CreateTransaction();
            foreach (var span in TimeSpans)
            {
                trans.SortedSetAddAsync($"legends:{span.Key}:byFame",
                    buff, totalFame, CommandFlags.FireAndForget);

                if (span.Value == TimeSpan.MaxValue)
                    continue;

                double t = DateTime.UtcNow.Add(span.Value).ToUnixTimestamp();
                trans.SortedSetAddAsync($"legends:{span.Key}:byTimeOfDeath",
                    buff, t, CommandFlags.FireAndForget);
            }

            trans.ExecuteAsync();

            // add legend if character falls within MaxGlowingRank
            foreach (var span in TimeSpans)
            {
                db.SortedSetRankAsync($"legends:{span.Key}:byFame", buff, Order.Descending)
                    .ContinueWith(r =>
                    {
                        if (r.Result >= MaxGlowingRank)
                            return;

                        db.HashSetAsync("legend", accId, "",
                            flags: CommandFlags.FireAndForget);
                    });
            }

            db.StringSetAsync("legends:updateTime", DateTime.UtcNow.ToUnixTimestamp(),
                flags: CommandFlags.FireAndForget);
        }

        public static DbLegendEntry[] Get(IDatabase db, string timeSpan)
        {
            if (!TimeSpans.ContainsKey(timeSpan))
                return new DbLegendEntry[0];

            var listings = db.SortedSetRangeByRank(
                $"legends:{timeSpan}:byFame",
                0, MaxListings - 1, Order.Descending);

            return listings
                .Select(e => new DbLegendEntry(
                    BitConverter.ToInt32(e, 0),
                    BitConverter.ToInt32(e, 4)))
                .ToArray();
        }
    }

    public class DbGuild : RedisObject
    {
        internal readonly object MemberLock; // maybe use redis locking?

        internal DbGuild(IDatabase db, int id)
        {
            MemberLock = new object();

            Id = id;
            Init(db, "guild." + id);
        }

        public DbGuild(DbAccount acc)
        {
            MemberLock = new object();

            Id = acc.GuildId;
            Init(acc.Database, "guild." + Id);
        }

        public int Id { get; private set; }

        public string Name
        {
            get => GetValue<string>("name");
            set => SetValue("name", value);
        }

        public int Level
        {
            get => GetValue<int>("level");
            set => SetValue("level", value);
        }

        public int Fame
        {
            get => GetValue<int>("fame");
            set => SetValue("fame", value);
        }

        public int TotalFame
        {
            get => GetValue<int>("totalFame");
            set => SetValue("totalFame", value);
        }

        public int[] Members // list of member account id's
        {
            get => GetValue<int[]>("members") ?? new int[0];
            set => SetValue("members", value);
        }

        public int[] Allies // list of ally guild id's UNIMPLEMENTED
        {
            get => GetValue<int[]>("allies") ?? new int[0];
            set => SetValue("allies", value);
        }

        public string Board
        {
            get => GetValue<string>("board") ?? "";
            set => SetValue("board", value);
        }
    }

    public class DbIpInfo
    {
        private readonly IDatabase _db;

        internal DbIpInfo(IDatabase db, string ip)
        {
            _db = db;
            IP = ip;
            var json = (string)db.HashGet("ips", ip);
            if (json == null)
                IsNull = true;
            else
                JsonConvert.PopulateObject(json, this);
        }

        [JsonIgnore] public string IP { get; private set; }

        [JsonIgnore] public bool IsNull { get; private set; }

        public HashSet<int> Accounts { get; set; }
        public bool Banned { get; set; }
        public string Notes { get; set; }

        public void Flush()
        {
            _db.HashSetAsync("ips", IP, JsonConvert.SerializeObject(this));
        }
    }

    public class AccountMail
    {
        [JsonProperty("id", DefaultValueHandling = DefaultValueHandling.Include)]
        public int Id;

        [JsonProperty("add", DefaultValueHandling = DefaultValueHandling.Include)]
        public int AddTime;

        [JsonProperty("ends", DefaultValueHandling = DefaultValueHandling.Include)]
        public int EndTime;

        [JsonProperty("charId", DefaultValueHandling = DefaultValueHandling.Include)]
        public int CharacterId;

        [JsonProperty("priority")] public int Priority;
        [JsonProperty("content")] public string Content;

        public static AccountMail Read(NReader rdr)
        {
            var ret = new AccountMail();
            ret.Id = rdr.ReadInt32();
            ret.AddTime = rdr.ReadInt32();
            ret.EndTime = rdr.ReadInt32();
            ret.CharacterId = rdr.ReadInt32();
            ret.Priority = rdr.ReadInt32();
            ret.Content = rdr.ReadUTF();
            return ret;
        }

        public void Write(NWriter wtr)
        {
            wtr.Write(Id);
            wtr.Write(AddTime);
            wtr.Write(EndTime);
            wtr.Write(CharacterId);
            wtr.Write(Priority);
            wtr.WriteUTF(Content);
        }
    }
}