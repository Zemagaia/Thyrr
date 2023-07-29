﻿using System.Collections.Generic;
using System.Xml.Linq;
using Shared;
using Shared.resources;
using GameServer.networking.packets.outgoing;

namespace GameServer.realm.entities
{
    public class StaticObject : Entity
    {
        //Stats
        public bool Vulnerable { get; private set; }
        public bool Static { get; private set; }
        public bool Hittestable { get; private set; }
        public bool Dying { get; private set; }

        private readonly SV<int> _hp;

        public int HP
        {
            get => _hp.GetValue();
            set => _hp.SetValue(value);
        }

        public static int? GetHP(XElement elem)
        {
            var n = elem.Element("MaxHitPoints");
            if (n != null)
                return Utils.FromString(n.Value);
            else
                return null;
        }

        public StaticObject(RealmManager manager, ushort objType, int? life, bool stat, bool dying, bool hittestable)
            : base(manager, objType)
        {
            _hp = new SV<int>(this, StatsType.HP, 0, dying);
            if (Vulnerable = life.HasValue)
                HP = life.Value;
            Dying = dying;
            Static = stat;
            Hittestable = hittestable;
        }

        protected override void ExportStats(IDictionary<StatsType, object> stats)
        {
            stats[StatsType.HP] = (!Vulnerable) ? int.MaxValue : HP;
            base.ExportStats(stats);
        }

        public override bool HitByProjectile(Projectile projectile, RealmTime time)
        {
            if (Vulnerable && projectile.ProjectileOwner is Player p)
            {
                int[] fDamages = null;
                for (var i = 0; i < 6; i++)
                {
                    if (p.Inventory[i].Item is null) continue;
                    if (p.Inventory[i].DamageBoosts is null) continue;
                    if (fDamages is null)
                        fDamages = p.Inventory[i].DamageBoosts;
                    else
                        fDamages = StatsManager.DamageUtils.Add(fDamages, p.Inventory[i].DamageBoosts);
                }

                int dmg;

                if (fDamages is null)
                    dmg = (int)StatsManager.GetDefenseDamage(this, projectile.Damage, projectile.DamageType, p);
                else
                {
                    dmg = (int)StatsManager.GetDefenseDamage(this,
                        new[]
                        {
                            projectile.Damage, fDamages[0], fDamages[1], fDamages[2],
                            fDamages[3], fDamages[4], fDamages[5], fDamages[6], fDamages[7]
                        },
                        new[]
                        {
                            projectile.DamageType, DamageTypes.Physical, DamageTypes.Magical, DamageTypes.Earth,
                            DamageTypes.Air, DamageTypes.Profane, DamageTypes.Fire, DamageTypes.Water, DamageTypes.Holy
                        }, p);
                }

                HP -= dmg;
                Owner.BroadcastPacketNearby(new Damage()
                {
                    TargetId = this.Id,
                    Effects = 0,
                    DamageAmount = (ushort)dmg,
                    Kill = !CheckHP(),
                    BulletId = projectile.BulletId,
                    ObjectId = projectile.ProjectileOwner.Self.Id
                }, this, p);
            }

            return true;
        }

        protected bool CheckHP()
        {
            if (HP <= 0)
            {
                var x = (int)(X - 0.5);
                var y = (int)(Y - 0.5);
                if (Owner.Map.Contains(new IntPoint(x, y)))
                    if (ObjectDesc != null &&
                        Owner.Map[x, y].ObjType == ObjectType)
                    {
                        var tile = Owner.Map[x, y];
                        tile.ObjType = 0;
                        tile.UpdateCount++;
                    }

                Owner.LeaveWorld(this);
                return false;
            }

            return true;
        }

        public override void Tick(RealmTime time)
        {
            if (Vulnerable)
            {
                if (Dying)
                    HP -= time.ElapsedMsDelta;

                CheckHP();
            }

            base.Tick(time);
        }
    }
}