﻿using System;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Shared;
using Shared.resources;
using GameServer.networking;
using GameServer.realm.entities;
using GameServer.realm.worlds;
using GameServer.realm.worlds.logic;
using System.Collections.Generic;
using GameServer.networking.packets;
using GameServer.networking.packets.incoming;
using GameServer.networking.packets.outgoing;

namespace GameServer.realm.commands
{
    class HelpCommand : Command
    {
        public HelpCommand() : base("help")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            // newline (\n) does not work.
            player.SendHelp("Help:" +
                            "\n[/pause]: pause the game (until you [/pause] again)" +
                            "\n[/who]: list players in your world" +
                            "\n[/tutorial]: enter the tutorial" +
                            "\n[/tell <player name> <message>]: send a private message to a player" +
                            "\n[/guild <message>]: send a message to your guild" +
                            "\n[/ignore <player name>]: don't show chat messages from player" +
                            "\n[/unignore <player name>]: stop ignoring a player" +
                            "\n[/teleport <player name>]: teleport to a player" +
                            "\n[/trade <player name>]: request a trade with a player" +
                            "\n[/invite <player name>]: invite a player to your guild" +
                            "\n[/join <guild name>]: join a guild (invite necessary)" +
                            "\n[/lock <player name>]: lock a player to the player grid" +
                            "\n[/unlock <player name>]: unlock a player from the player grid" +
                            "\n[/mscale <number>]: scale map view" +
                            "\n[/uiscale]: toggle whether to scale ui to game resolution" +
                            "\n[/vault]: reconnect to vault" +
                            "\n[/realm]: go back to spawn if in realm or reconnect to realm" +
                            "\n[/ghall]: reconnect to guild hall (guild necessary)" +
                            "\n[/commands]: show all commands" +
                            "\n[/help]: go for another round");
            return true;
        }
    }

    class JoinGuildCommand : Command
    {
        public JoinGuildCommand() : base("join")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.ProcessPacket(new JoinGuild()
            {
                GuildName = args
            });
            return true;
        }
    }

    class TutorialCommand : Command
    {
        public TutorialCommand() : base("tutorial")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.Tutorial,
                Name = "Tutorial"
            });
            return true;
        }
    }

    class ServerCommand : Command
    {
        public ServerCommand() : base("world")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.SendInfo(
                $"[{player.Owner.Id}] {player.Owner.GetDisplayName()} ({player.Owner.Players.Count} players)");
            return true;
        }
    }

    class PauseCommand : Command
    {
        public PauseCommand() : base("pause")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player.SpectateTarget != null)
            {
                player.SendError("The use of pause is disabled while spectating.");
                return false;
            }

            if (player.HasConditionEffect(ConditionEffects.Paused))
            {
                player.ApplyConditionEffect(new ConditionEffect()
                {
                    Effect = ConditionEffectIndex.Paused,
                    DurationMS = 0
                });
                player.SendInfo("Game resumed.");
                return true;
            }

            var owner = player.Owner;

            if (player.Owner.EnemiesCollision.HitTest(player.X, player.Y, 8).OfType<Enemy>().Any())
            {
                player.SendError("Not safe to pause.");
                return false;
            }

            player.ApplyConditionEffect(new ConditionEffect()
            {
                Effect = ConditionEffectIndex.Paused,
                DurationMS = -1
            });
            player.SendInfo("Game paused.");
            return true;
        }
    }

    /// <summary>
    /// This introduces a subtle bug, since the client UI is not notified when a /teleport is typed, it's cooldown does not reset.
    /// This leads to the unfortunate situation where the cooldown has been not been reached, but the UI doesn't know. The graphical TP will fail
    /// and cause it's timer to reset. NB: typing /teleport will workaround this timeout issue.
    /// </summary>
    class TeleportCommand : Command
    {
        public TeleportCommand() : base("tp", aliases: "teleport")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            foreach (var i in player.Owner.Players.Values)
            {
                if (!i.Name.EqualsIgnoreCase(args))
                    continue;

                if (!i.CanBeSeenBy(player))
                    break;

                player.Teleport(time, i.Id);
                return true;
            }

            player.SendError($"Unable to find player: {args}");
            return false;
        }
    }

    class DungeonAccept : Command
    {
        public DungeonAccept() : base("daccept", aliases: "da")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            int id;
            try
            {
                id = int.Parse(args);
            }
            catch (Exception)
            {
                player.SendError("ID must be a number.");
                return false;
            }

            var world = player.Manager.GetWorld(id);
            if (world != null)
            {
                if (player.Owner.Id == world.Id)
                {
                    player.SendError("You're already at your destination.");
                    return false;
                }

                var adminInvite = false;
                foreach (var inviteDict in world.InviteDict)
                    if (inviteDict.Key != null && inviteDict.Value.Rank >= 100 &&
                        inviteDict.Key.Contains(player.Name.ToLower()))
                    {
                        adminInvite = true;
                        break;
                    }

                if (!adminInvite)
                {
                    if (world.PlayerDungeon && world.Invites.Contains(player.Name.ToLower()))
                    {
                        if (world.GetAge() > 90000)
                        {
                            player.SendError("The invite has expired.");
                            return false;
                        }
                        else
                        {
                            world.Invites.Remove(player.Name.ToLower());
                            player.Client.Reconnect(new Reconnect()
                            {
                                Host = "",
                                Port = 2050,
                                GameId = world.Id,
                                Name = world.SBName != null ? world.SBName : world.Name,
                            });
                            return true;
                        }
                    }
                    else if (world.PlayerDungeon && world.InviteDict.Keys.Contains(player.Name.ToLower()))
                    {
                        player.SendError("You have already entered " + world.GetDisplayName() + ".");
                        return false;
                    }
                    else
                    {
                        player.SendError("You were not invited to join " + world.GetDisplayName() + ".");
                        return false;
                    }
                }
                else
                {
                    if (world.Invites.Contains(player.Name.ToLower()))
                    {
                        world.Invites.Remove(player.Name.ToLower());
                        if (world.InviteDict.ContainsKey(player.Name.ToLower()))
                            world.InviteDict.Remove(player.Name.ToLower());
                        player.Client.Reconnect(new Reconnect()
                        {
                            Host = "",
                            Port = 2050,
                            GameId = world.Id,
                            Name = world.SBName != null ? world.SBName : world.Name,
                        });
                        return true;
                    }
                    else if (world.InviteDict.Keys.Contains(player.Name.ToLower()))
                    {
                        player.SendError("You have already entered " + world.GetDisplayName() + ".");
                        return false;
                    }
                    else
                    {
                        player.SendError("You were not invited to join " + world.GetDisplayName() + ".");
                        return false;
                    }
                }
            }
            else
            {
                player.SendError("The world was not found.");
                return false;
            }
        }
    }

    class DungeonInvite : Command
    {
        public DungeonInvite() : base("dinvite", aliases: "di")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!(player.Owner.PlayerDungeon && player.Owner.Opener.Equals(player.Name)))
            {
                player.SendError("This is not your dungeon!");
                return false;
            }
            else if (player.Owner.GetAge() > 90000)
            {
                player.SendError("It's too late to invite players!");
                return false;
            }

            HashSet<string> invited = new HashSet<string>();
            HashSet<string> missed = new HashSet<string>();
            HashSet<string> unable = new HashSet<string>();

            if (args.Contains("-g"))
            {
                foreach (var i in player.Manager.Clients.Keys
                    .Where(x => x.Player != null)
                    .Where(x => !x.Account.IgnoreList.Contains(player.AccountId))
                    .Where(x => x.Account.GuildId > 0)
                    .Where(x => x.Account.GuildId == player.Client.Account.GuildId)
                    .Select(x => x.Player))
                {
                    if (i.Name.EqualsIgnoreCase(player.Name)) continue;

                    // already in the dungeon
                    if (i.Owner.Id == player.Owner.Id)
                    {
                        unable.Add(i.Name);
                        player.Owner.InviteDict.Add(i.Name.ToLower(), player);
                        continue;
                    }

                    if (player.Owner.InviteDict.Keys.Contains(i.Name.ToLower()))
                    {
                        unable.Add(i.Name);
                    }
                    else if (player.Manager.Chat.Invite(player, i.Name, player.Owner.GetDisplayName(), player.Owner.Id))
                    {
                        player.Owner.InviteDict.Add(i.Name.ToLower(), player);
                        player.Owner.Invites.Add(i.Name.ToLower());
                        invited.Add(i.Name);
                    }
                    else
                    {
                        missed.Add(i.Name);
                    }
                }

                if (invited.Count > 0)
                {
                    player.SendInfo("Invited: " + string.Join(", ", invited));
                }

                if (unable.Count > 0)
                {
                    player.SendInfo("Already invited: " + string.Join(", ", unable));
                }

                if (missed.Count > 0)
                {
                    player.SendInfo("Not found: " + string.Join(", ", missed));
                }

                return true;
            }

            var players = args.Split(' ').Where(n => !n.Equals("")).ToArray();

            if (players.Length > 0)
            {
                foreach (string p in players)
                {
                    if (p.EqualsIgnoreCase(player.Name)) continue;

                    if (player.Owner.InviteDict.Keys.Contains(p.ToLower()))
                    {
                        unable.Add(p);
                    }
                    else if (player.Manager.Chat.Invite(player, p, player.Owner.GetDisplayName(), player.Owner.Id))
                    {
                        player.Owner.InviteDict.Add(p.ToLower(), player);
                        player.Owner.Invites.Add(p.ToLower());
                        invited.Add(p);
                    }
                    else
                    {
                        missed.Add(p);
                    }
                }

                if (invited.Count > 0)
                {
                    player.SendInfo("Invited: " + string.Join(", ", invited));
                }

                if (unable.Count > 0)
                {
                    player.SendInfo("Already invited: " + string.Join(", ", unable));
                }

                if (missed.Count > 0)
                {
                    player.SendInfo("Not found: " + string.Join(", ", missed));
                }

                return true;
            }
            else
            {
                player.SendError("Specify some players to invite!");
                return false;
            }
        }
    }

    class TellCommand : Command
    {
        public TellCommand() : base("tell", aliases: "t")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.NameChosen)
            {
                player.SendError("Choose a name!");
                return false;
            }

            if (player.Muted)
            {
                player.SendError("Muted. You can not tell at this time.");
                return false;
            }

            int index = args.IndexOf(' ');
            if (index == -1)
            {
                player.SendError("Usage: /tell <player name> <text>");
                return false;
            }

            string playername = args.Substring(0, index);
            string msg = args.Substring(index + 1);

            if (player.Name.ToLower() == playername.ToLower())
            {
                player.SendInfo("Quit telling yourself!");
                return false;
            }

            if (!player.Manager.Chat.Tell(player, playername, msg))
            {
                player.SendError(string.Format("{0} not found.", playername));
                return false;
            }

            return true;
        }
    }

    class GCommand : Command
    {
        public GCommand() : base("g", aliases: "guild")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.NameChosen)
            {
                player.SendError("Choose a name!");
                return false;
            }

            if (player.Muted)
            {
                player.SendError("Muted. You can not guild chat at this time.");
                return false;
            }

            if (String.IsNullOrEmpty(player.Guild))
            {
                player.SendError("You need to be in a guild to guild chat.");
                return false;
            }

            return player.Manager.Chat.Guild(player, args);
        }
    }

    class LocalCommand : Command
    {
        public LocalCommand() : base("l")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (!player.NameChosen)
            {
                player.SendError("Choose a name!");
                return false;
            }

            if (player.Muted)
            {
                player.SendError("Muted. You can not local chat at this time.");
                return false;
            }

            if (player.CompareAndCheckSpam(args, time.TotalElapsedMs))
            {
                return false;
            }

            var sent = player.Manager.Chat.Local(player, args);
            if (!sent)
            {
                player.SendError(
                    "Failed to send message. Use of extended ascii characters and ascii whitespace (other than space) is not allowed.");
            }
            else
            {
                player.Owner.ChatReceived(player, args);
            }


            return sent;
        }
    }

    class ListCommands : Command
    {
        public ListCommands() : base("commands")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            StringBuilder sb = new StringBuilder("Available commands: ");
            var cmds = player.Manager.Commands.Commands.Values.Distinct()
                .Where(x => x.HasPermission(player) && x.ListCommand)
                .ToArray();
            Array.Sort(cmds, (c1, c2) => c1.CommandName.CompareTo(c2.CommandName));
            for (int i = 0; i < cmds.Length; i++)
            {
                if (i != 0) sb.Append(", ");
                sb.Append(cmds[i].CommandName);
            }

            player.SendInfo(sb.ToString());
            return true;
        }
    }

    class IgnoreCommand : Command
    {
        public IgnoreCommand() : base("ignore", aliases: "block")
        {
        }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (String.IsNullOrEmpty(playerName))
            {
                player.SendError("Usage: /ignore <player name>");
                return false;
            }

            if (player.Name.ToLower() == playerName.ToLower())
            {
                player.SendInfo("Can't ignore yourself!");
                return false;
            }

            var target = player.Manager.Database.ResolveId(playerName);
            var targetAccount = player.Manager.Database.GetAccount(target);
            var srcAccount = player.Client.Account;

            if (target == 0 || targetAccount == null || targetAccount.Hidden && player.Admin == 0)
            {
                player.SendError("Player not found.");
                return false;
            }

            player.Manager.Database.IgnoreAccount(srcAccount, targetAccount, true);

            player.Client.SendPacket(new AccountList()
            {
                AccountListId = 1, // ignore list
                AccountIds = srcAccount.IgnoreList
                    .Select(i => i.ToString())
                    .ToArray()
            });

            player.SendInfo(playerName + " has been added to your ignore list.");
            return true;
        }
    }

    class UnignoreCommand : Command
    {
        public UnignoreCommand() : base("unignore", aliases: "unblock")
        {
        }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (String.IsNullOrEmpty(playerName))
            {
                player.SendError("Usage: /unignore <player name>");
                return false;
            }

            if (player.Name.ToLower() == playerName.ToLower())
            {
                player.SendInfo("You are no longer ignoring yourself. Good job.");
                return false;
            }

            var target = player.Manager.Database.ResolveId(playerName);
            var targetAccount = player.Manager.Database.GetAccount(target);
            var srcAccount = player.Client.Account;

            if (target == 0 || targetAccount == null || targetAccount.Hidden && player.Admin == 0)
            {
                player.SendError("Player not found.");
                return false;
            }

            player.Manager.Database.IgnoreAccount(srcAccount, targetAccount, false);

            player.Client.SendPacket(new AccountList()
            {
                AccountListId = 1, // ignore list
                AccountIds = srcAccount.IgnoreList
                    .Select(i => i.ToString())
                    .ToArray()
            });

            player.SendInfo(playerName + " no longer ignored.");
            return true;
        }
    }

    class LockCommand : Command
    {
        public LockCommand() : base("lock")
        {
        }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (String.IsNullOrEmpty(playerName))
            {
                player.SendError("Usage: /lock <player name>");
                return false;
            }

            if (player.Name.ToLower() == playerName.ToLower())
            {
                player.SendInfo("Can't lock yourself!");
                return false;
            }

            var target = player.Manager.Database.ResolveId(playerName);
            var targetAccount = player.Manager.Database.GetAccount(target);
            var srcAccount = player.Client.Account;

            if (target == 0 || targetAccount == null || targetAccount.Hidden && player.Admin == 0)
            {
                player.SendError("Player not found.");
                return false;
            }

            player.Manager.Database.LockAccount(srcAccount, targetAccount, true);

            player.Client.SendPacket(new AccountList()
            {
                AccountListId = 0, // locked list
                AccountIds = player.Client.Account.LockList
                    .Select(i => i.ToString())
                    .ToArray(),
                LockAction = 1
            });

            player.SendInfo(playerName + " has been locked.");
            return true;
        }
    }

    class UnlockCommand : Command
    {
        public UnlockCommand() : base("unlock")
        {
        }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (String.IsNullOrEmpty(playerName))
            {
                player.SendError("Usage: /unlock <player name>");
                return false;
            }

            if (player.Name.ToLower() == playerName.ToLower())
            {
                player.SendInfo("You are no longer locking yourself. Nice!");
                return false;
            }

            var target = player.Manager.Database.ResolveId(playerName);
            var targetAccount = player.Manager.Database.GetAccount(target);
            var srcAccount = player.Client.Account;

            if (target == 0 || targetAccount == null || targetAccount.Hidden && player.Admin == 0)
            {
                player.SendError("Player not found.");
                return false;
            }

            player.Manager.Database.LockAccount(srcAccount, targetAccount, false);

            player.Client.SendPacket(new AccountList()
            {
                AccountListId = 0, // locked list
                AccountIds = player.Client.Account.LockList
                    .Select(i => i.ToString())
                    .ToArray(),
                LockAction = 0
            });

            player.SendInfo(playerName + " no longer locked.");
            return true;
        }
    }

    class UptimeCommand : Command
    {
        public UptimeCommand() : base("uptime")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            TimeSpan t = TimeSpan.FromMilliseconds(time.TotalElapsedMs);

            string answer = (t.Days > 0 ? t.Days + "d:" : "") +
                            string.Format("{0:D2}h:{1:D2}m:{2:D2}s", t.Hours, t.Minutes, t.Seconds);

            player.SendInfo("The server has been up for " + answer + ".");
            return true;
        }
    }

    /*  class NpeCommand : Command
      {
          public NpeCommand() : base("npe") { }
  
          protected override bool Process(Player player, RealmTime time, string args)
          {
              player.Stats[0] = 100;
              player.Stats[1] = 100;
              player.Stats[2] = 10;
              player.Stats[3] = 0;
              player.Stats[4] = 10;
              player.Stats[5] = 10;
              player.Stats[6] = 10;
              player.Stats[7] = 10;
              player.Level = 1;
              player.Experience = 0;
              
              player.SendInfo("You character stats, level, and experience has be npe'ified.");
              return true;
          }
      }
      */
    class PositionCommand : Command
    {
        public PositionCommand() : base("pos", aliases: "position")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.SendInfo("Current Position: " + (int)player.X + ", " + (int)player.Y);
            return true;
        }
    }

    class TradeCommand : Command
    {
        public TradeCommand() : base("trade")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (String.IsNullOrWhiteSpace(args))
            {
                player.SendError("Usage: /trade <player name>");
                return false;
            }

            player.RequestTrade(args);
            return true;
        }
    }

    class TimeCommand : Command
    {
        public TimeCommand() : base("time")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.SendInfo("Time for you to get a watch!");
            return true;
        }
    }

    /*
    class ArenaCommand : Command
    {
        public ArenaCommand() : base("arena") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.Arena,
                Name = "Arena"
            });
            return true;
        }
    }

    class DeathArenaCommand : Command
    {
        public DeathArenaCommand() : base("oa") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.DeathArena,
                Name = "Oryx's Arena"
            });
            return true;
        }
    }
    */

    class DailyQuestCommand : Command
    {
        public DailyQuestCommand() : base("dailyquest", aliases: "dq")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.Tinker,
                Name = "Quest Room"
            });
            return true;
        }
    }

    class VaultCommand : Command
    {
        public VaultCommand() : base("vault")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.Vault,
                Name = "Vault"
            });
            return true;
        }
    }

    /*class SoloArenaCommand : Command
    {
        public SoloArenaCommand() : base("sa") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.ArenaSolo,
                Name = "Arena Solo"
            });
            return true;
        }
    }*/

    class GhallCommand : Command
    {
        public GhallCommand() : base("ghall")
        {
        }


        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player.GuildRank < 0)
            {
                player.SendError("You need to be in a guild.");
                return false;
            }

            var proto = player.Manager.Resources.Worlds["GuildHall"];
            var world = player.Manager.GetWorld(proto.id);
            player.Reconnect(world.GetInstance(player.Client));
            return true;
        }
    }

    class LefttoMaxCommand : Command
    {
        public LefttoMaxCommand() : base("lefttomax")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var pd = player.Manager.Resources.GameData.Classes[player.ObjectType];

            player.SendInfo($"HP: {pd.Stats[0].MaxValue - player.Stats.Base[0]}");
            player.SendInfo($"MP: {pd.Stats[1].MaxValue - player.Stats.Base[1]}");
            player.SendInfo($"Strength: {pd.Stats[2].MaxValue - player.Stats.Base[2]}");
            player.SendInfo($"Armor: {pd.Stats[3].MaxValue - player.Stats.Base[3]}");
            player.SendInfo($"Agility: {pd.Stats[4].MaxValue - player.Stats.Base[4]}");
            player.SendInfo($"Dexterity: {pd.Stats[5].MaxValue - player.Stats.Base[5]}");
            player.SendInfo($"Stamina: {pd.Stats[6].MaxValue - player.Stats.Base[6]}");
            player.SendInfo($"Intelligence: {pd.Stats[7].MaxValue - player.Stats.Base[7]}");
            player.SendInfo($"Resistance: {pd.Stats[19].MaxValue - player.Stats.Base[19]}");
            player.SendInfo($"Wit: {pd.Stats[20].MaxValue - player.Stats.Base[20]}");

            return true;
        }
    }

    class WhoCommand : Command
    {
        public WhoCommand() : base("who")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var owner = player.Owner;
            var players = owner.Players.Values
                .Where(p => p.Client != null && p.CanBeSeenBy(player))
                .ToArray();

            var sb = new StringBuilder($"Players in current area ({owner.Players.Count}): ");
            for (var i = 0; i < players.Length; i++)
            {
                if (i != 0)
                    sb.Append(", ");
                sb.Append(players[i].Name);
            }

            player.SendInfo(sb.ToString());
            return true;
        }
    }

    class OnlineCommand : Command
    {
        public OnlineCommand() : base("online")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var servers = player.Manager.InterServer.GetServerList();
            var players =
                (from server in servers
                    from plr in server.playerList
                    where !plr.Hidden || player.Client.Account.Admin
                    select plr.Name)
                .ToArray();

            var sb = new StringBuilder($"Players online ({players.Length}): ");
            for (var i = 0; i < players.Length; i++)
            {
                if (i != 0)
                    sb.Append(", ");

                sb.Append(players[i]);
            }

            player.SendInfo(sb.ToString());
            return true;
        }
    }

    class WhereCommand : Command
    {
        public WhereCommand() : base("where")
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendInfo("Usage: /where <player name>");
                return true;
            }

            var servers = player.Manager.InterServer.GetServerList();

            foreach (var server in servers)
            foreach (PlayerInfo plr in server.playerList)
            {
                if (!plr.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase) ||
                    plr.Hidden && !player.Client.Account.Admin)
                    continue;

                player.SendInfo($"{plr.Name} is playing on {server.name} at [{plr.WorldInstance}]{plr.WorldName}.");
                return true;
            }

            var pId = player.Manager.Database.ResolveId(name);
            if (pId == 0)
            {
                player.SendInfo($"No player with the name {name}.");
                return true;
            }

            var acc = player.Manager.Database.GetAccount(pId, "lastSeen");
            if (acc.LastSeen == 0)
            {
                player.SendInfo($"{name} not online. Has not been seen since the dawn of time.");
                return true;
            }

            var dt = Utils.FromUnixTimestamp(acc.LastSeen);
            player.SendInfo($"{name} not online. Player last seen {Utils.TimeAgo(dt)}.");
            return true;
        }
    }

    class MarketplaceCommand : Command
    {
        public MarketplaceCommand() : base("market", aliases: "marketplace")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.MarketPlace,
                Name = "Marketplace"
            });
            return true;
        }
    }

    class RemoveAccountOverrideCommand : Command
    {
        public RemoveAccountOverrideCommand() : base("removeOverride", 0, listCommand: false)
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var acc = player.Client.Account;
            if (acc.AccountIdOverrider == 0)
            {
                player.SendError("Account isn't overridden.");
                return false;
            }

            var overriderAcc = player.Manager.Database.GetAccount(acc.AccountIdOverrider);
            if (overriderAcc == null)
            {
                player.SendError("Account not found!");
                return false;
            }

            overriderAcc.AccountIdOverride = 0;
            overriderAcc.FlushAsync();
            player.SendInfo("Account override removed.");
            return true;
        }
    }

    class CurrentSongCommand : Command
    {
        public CurrentSongCommand() : base("currentsong", aliases: "song")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var properName = player.Owner.Music;
            var title = $"{properName}";

            if (!string.IsNullOrWhiteSpace(properName))
                player.SendInfo($"Current Song: {title}.");
            else
                player.SendInfo("There is no music being played currently. You're all by yourself.");
            return true;
        }
    }

    class GuildKickCommand : Command
    {
        public GuildKickCommand() : base("gkick")
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (player.Owner is Test)
                return false;

            var manager = player.Client.Manager;

            // if resigning
            if (player.Name.Equals(name))
            {
                // chat needs to be done before removal so we can use
                // srcPlayer as a source for guild info
                manager.Chat.Guild(player, player.Name + " has left the guild.", true);

                if (!manager.Database.RemoveFromGuild(player.Client.Account))
                {
                    player.SendError("Guild not found.");
                    return false;
                }

                player.Guild = "";
                player.GuildRank = 0;

                return true;
            }

            // get target account id
            var targetAccId = manager.Database.ResolveId(name);
            if (targetAccId == 0)
            {
                player.SendError("Player not found");
                return false;
            }

            // find target player (if connected)
            var targetClient = (from client in manager.Clients.Keys
                    where client.Account != null
                    where client.Account.AccountId == targetAccId
                    select client)
                .FirstOrDefault();

            // try to remove connected member
            if (targetClient != null)
            {
                if (player.Client.Account.GuildRank >= 20 &&
                    player.Client.Account.GuildId == targetClient.Account.GuildId &&
                    player.Client.Account.GuildRank > targetClient.Account.GuildRank)
                {
                    var targetPlayer = targetClient.Player;

                    if (!manager.Database.RemoveFromGuild(targetClient.Account))
                    {
                        player.SendError("Guild not found.");
                        return false;
                    }

                    targetPlayer.Guild = "";
                    targetPlayer.GuildRank = 0;

                    manager.Chat.Guild(player,
                        targetPlayer.Name + " has been kicked from the guild by " + player.Name, true);
                    targetPlayer.SendInfo("You have been kicked from the guild.");
                    return true;
                }

                player.SendError("Can't remove member. Insufficient privileges.");
                return false;
            }

            // try to remove member via database
            var targetAccount = manager.Database.GetAccount(targetAccId);

            if (player.Client.Account.GuildRank >= 20 &&
                player.Client.Account.GuildId == targetAccount.GuildId &&
                player.Client.Account.GuildRank > targetAccount.GuildRank)
            {
                if (!manager.Database.RemoveFromGuild(targetAccount))
                {
                    player.SendError("Guild not found.");
                    return false;
                }

                manager.Chat.Guild(player,
                    targetAccount.Name + " has been kicked from the guild by " + player.Name, true);
                return true;
            }

            player.SendError("Can't remove member. Insufficient privileges.");
            return false;
        }
    }

    class GuildInviteCommand : Command
    {
        public GuildInviteCommand() : base("invite", aliases: "ginvite")
        {
        }

        protected override bool Process(Player player, RealmTime time, string playerName)
        {
            if (player.Owner is Test)
                return false;

            if (player.Client.Account.GuildRank < 20)
            {
                player.SendError("Insufficient privileges.");
                return false;
            }

            var targetAccId = player.Client.Manager.Database.ResolveId(playerName);
            if (targetAccId == 0)
            {
                player.SendError("Player not found");
                return false;
            }

            var targetClient = (from client in player.Client.Manager.Clients.Keys
                    where client.Account != null
                    where client.Account.AccountId == targetAccId
                    select client)
                .FirstOrDefault();

            if (targetClient != null)
            {
                if (targetClient.Player == null ||
                    targetClient.Account == null ||
                    !targetClient.Account.Name.Equals(playerName))
                {
                    player.SendError("Could not find the player to invite.");
                    return false;
                }

                if (!targetClient.Account.NameChosen)
                {
                    player.SendError("Player needs to choose a name first.");
                    return false;
                }

                if (targetClient.Account.GuildId > 0)
                {
                    player.SendError("Player is already in a guild.");
                    return false;
                }

                targetClient.Player.GuildInvite = player.Client.Account.GuildId;

                targetClient.SendPacket(new InvitedToGuild()
                {
                    Name = player.Name,
                    GuildName = player.Guild
                });
                return true;
            }

            player.SendError("Could not find the player to invite.");
            return false;
        }
    }

    class GuildWhoCommand : Command
    {
        public GuildWhoCommand() : base("gwho", aliases: "mates")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            if (player.Client.Account.GuildId == 0)
            {
                player.SendError("You are not in a guild!");
                return false;
            }

            var pServer = player.Manager.Config.serverInfo.name;
            var pGuild = player.Client.Account.GuildId;
            var servers = player.Manager.InterServer.GetServerList();
            var result =
                (from server in servers
                    from plr in server.playerList
                    where plr.GuildId == pGuild
                    group plr by server);


            player.SendInfo("Guild members online:");

            foreach (var group in result)
            {
                var server = (pServer == group.Key.name) ? $"[{group.Key.name}]" : group.Key.name;
                var players = group.ToArray();
                var sb = new StringBuilder($"{server}: ");
                for (var i = 0; i < players.Length; i++)
                {
                    if (i != 0)
                        sb.Append(", ");

                    sb.Append(players[i].Name);
                }

                player.SendInfo(sb.ToString());
            }

            return true;
        }
    }

    class SpectateCommand : Command
    {
        public SpectateCommand() : base("spectate")
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                player.SendError("Usage: /spectate <player name>");
                return false;
            }


            var target = player.Owner.Players.Values
                .SingleOrDefault(p =>
                    p.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase) && p.CanBeSeenBy(player));

            if (target == null)
            {
                player.SendError("Player not found. Note: Target player must be on the same map.");
                return false;
            }

            if (!player.Client.Account.Admin &&
                player.Owner.EnemiesCollision.HitTest(player.X, player.Y, 8).OfType<Enemy>().Any())
            {
                player.SendError("Enemies cannot be nearby when initiating spectator mode.");
                return false;
            }

            if (player.SpectateTarget != null)
            {
                player.SpectateTarget.FocusLost -= player.ResetFocus;
                player.SpectateTarget.Controller = null;
            }

            if (player != target)
            {
                player.ApplyConditionEffect(ConditionEffectIndex.Paused);
                target.FocusLost += player.ResetFocus;
                player.SpectateTarget = target;
            }
            else
            {
                player.SpectateTarget = null;
                player.Owner.Timers.Add(new WorldTimer(1500, (w, t) =>
                {
                    if (player.SpectateTarget == null)
                        player.ApplyConditionEffect(ConditionEffectIndex.Paused, 0);
                }));
            }

            player.Client.SendPacket(new SetFocus()
            {
                ObjectId = target.Id
            });

            player.SendInfo($"Now spectating {target.Name}. Use the /self command to exit.");
            return true;
        }
    }

    class SelfCommand : Command
    {
        public SelfCommand() : base("self")
        {
        }

        protected override bool Process(Player player, RealmTime time, string name)
        {
            if (player.SpectateTarget != null)
            {
                player.SpectateTarget.FocusLost -= player.ResetFocus;
                player.SpectateTarget.Controller = null;
            }

            player.SpectateTarget = null;
            player.Sight.UpdateCount++;
            player.Owner.Timers.Add(new WorldTimer(1500, (w, t) =>
            {
                if (player.SpectateTarget == null)
                    player.ApplyConditionEffect(ConditionEffectIndex.Paused, 0);
            }));
            player.Client.SendPacket(new SetFocus()
            {
                ObjectId = player.Id
            });
            return true;
        }
    }

    class BazaarCommand : Command
    {
        public BazaarCommand() : base("bazaar")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            player.Client.Reconnect(new Reconnect()
            {
                Host = "",
                Port = 2050,
                GameId = World.ClothBazaar,
                Name = "Cloth Bazaar"
            });
            return true;
        }
    }

    class ServersCommand : Command
    {
        public ServersCommand() : base("servers", aliases: "svrs")
        {
        }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            var playerSvr = player.Manager.Config.serverInfo.name;
            var servers = player.Manager.InterServer
                .GetServerList()
                .Where(s => s.type == ServerType.World)
                .ToArray();

            var sb = new StringBuilder($"Servers online ({servers.Length}):\n");
            foreach (var server in servers)
            {
                var currentSvr = server.name.Equals(playerSvr);
                if (currentSvr)
                {
                    sb.Append("[");
                }

                sb.Append(server.name);
                if (currentSvr)
                {
                    sb.Append("]");
                }

                sb.Append($" ({server.players}/{server.maxPlayers}");
                if (server.queueLength > 0)
                {
                    sb.Append($" + {server.queueLength} queued");
                }

                sb.Append(")");
                if (server.adminOnly)
                {
                    sb.Append(" Admin only");
                }

                sb.Append("\n");
            }

            player.SendInfo(sb.ToString());
            return true;
        }
    }
}