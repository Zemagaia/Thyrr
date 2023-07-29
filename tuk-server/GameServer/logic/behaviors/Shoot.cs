﻿using System;
using System.Linq;
using System.Xml.Linq;
using Shared;
using Shared.resources;
using Mono.Game;
using GameServer.networking.packets.outgoing;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.behaviors
{
    class Shoot : CycleBehavior
    {
        //State storage: cooldown timer

        private readonly float _radius;
        private readonly int _count;
        private readonly float _shootAngle;
        private readonly float? _fixedAngle;
        private readonly float? _rotateAngle;
        private readonly float _angleOffset;
        private readonly float? _defaultAngle;
        private readonly float _predictive;
        private readonly int _projectileIndex;
        private readonly int _coolDownOffset;
        private Cooldown _coolDown;
        private readonly bool _shootLowHp;
        private readonly ushort? _target;

        private int _rotateCount;

        public Shoot(XElement e)
        {
            _radius = e.ParseFloat("@radius", 5);
            _count = e.ParseInt("@count", 1);
            _shootAngle = _count == 1 ? 0 : (float)((e.ParseNFloat("@shootAngle") ?? 360.0 / _count) * Math.PI / 180);
            _projectileIndex = e.ParseInt("@projectileIndex");
            _fixedAngle = (float?)(e.ParseNFloat("@fixedAngle") * Math.PI / 180);
            _rotateAngle = (float?)(e.ParseNFloat("@rotateAngle") * Math.PI / 180);
            _angleOffset = (float)(e.ParseFloat("@angleOffset") * Math.PI / 180);
            _defaultAngle = (float?)(e.ParseNFloat("@defaultAngle") * Math.PI / 180);
            _predictive = e.ParseFloat("@predictive");
            _coolDownOffset = e.ParseInt("@coolDownOffset");
            _coolDown = new Cooldown().Normalize(e.ParseInt("@coolDown", 1000));
            _shootLowHp = e.ParseBool("@shootLowHp");
            _target = e.ParseString("@target") == null ? null : GetObjType(e.ParseString("@target"));
        }

        public Shoot(
            double radius,
            int count = 1,
            double? shootAngle = null,
            int projectileIndex = 0,
            double? fixedAngle = null,
            double? rotateAngle = null,
            double angleOffset = 0,
            double? defaultAngle = null,
            double predictive = 0,
            int coolDownOffset = 0,
            Cooldown coolDown = new(),
            bool shootLowHp = false,
            string target = null)
        {
            _radius = (float)radius;
            _count = count;
            _shootAngle = count == 1 ? 0 : (float)((shootAngle ?? 360.0 / count) * Math.PI / 180);
            _projectileIndex = projectileIndex;
            _fixedAngle = (float?)(fixedAngle * Math.PI / 180);
            _rotateAngle = (float?)(rotateAngle * Math.PI / 180);
            _angleOffset = (float)(angleOffset * Math.PI / 180);
            _defaultAngle = (float?)(defaultAngle * Math.PI / 180);
            _predictive = (float)predictive;
            _coolDownOffset = coolDownOffset;
            _coolDown = coolDown.Normalize();
            _shootLowHp = shootLowHp;
            _target = target == null ? null : GetObjType(target);
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            state = _coolDownOffset;
        }

        private static float Predict(Entity host, Entity target, ProjectileDesc desc)
        {
            // trying prod prediction

            const int PREDICT_NUM_TICKS = 4; // magic determined by experiement
            var history = target.TryGetHistory(1);

            if (history == null)
            {
                return (float)Math.Atan2(target.Y - host.Y, target.X - host.X);
            }

            var targetX = target.X + PREDICT_NUM_TICKS *
                (target.X - history.Value.X);
            var targetY = target.Y + PREDICT_NUM_TICKS *
                (target.Y - history.Value.Y);

            float angle = (float)Math.Atan2(targetY - host.Y, targetX - host.X);

            return angle;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            int cool = (int?)state ??
                       -1; // <-- crashes server due to state being null... patched now but should be looked at.
            Status = CycleStatus.NotStarted;

            if (cool <= 0)
            {
                if (host.HasConditionEffect(ConditionEffects.Stunned))
                    return;

                var count = _count;
                if (host.HasConditionEffect(ConditionEffects.Crippled))
                    count = (int)Math.Ceiling(_count / 2.0);

                Entity player;
                if (host.AttackTarget != null)
                    player = host.AttackTarget;
                else
                    player = _shootLowHp
                        ? host.GetLowestHpEntity(_radius, _target)
                        : host.GetNearestEntity(_radius, _target);

                if (host.TauntedPlayerNearby(_radius))
                    player = host.GetNearestTauntedPlayer(_radius);

                if (player != null || _defaultAngle != null || _fixedAngle != null)
                {
                    var desc = host.ObjectDesc.Projectiles[_projectileIndex];

                    float a;

                    if (_fixedAngle != null)
                    {
                        a = (float)_fixedAngle;
                    }
                    else if (player != null)
                    {
                        if (_predictive != 0 && _predictive > Random.NextDouble())
                        {
                            a = Predict(host, player, desc);
                        }
                        else
                        {
                            a = (float)Math.Atan2(player.Y - host.Y, player.X - host.X);
                        }
                    }
                    else if (_defaultAngle != null)
                    {
                        a = (float)_defaultAngle;
                    }
                    else
                    {
                        a = 0;
                    }

                    a += _angleOffset + ((_rotateAngle != null) ? (float)_rotateAngle * _rotateCount : 0);
                    _rotateCount++;

                    int dmg;
                    if (host is Character)
                        dmg = (host as Character).Random.Next(desc.MinDamage, desc.MaxDamage);
                    else
                        dmg = Random.Next(desc.MinDamage, desc.MaxDamage);

                    var startAngle = a - _shootAngle * (count - 1) / 2;
                    byte prjId = 0;
                    Position prjPos = new Position() { X = host.X, Y = host.Y };
                    var prjs = new Projectile[count];
                    for (int i = 0; i < count; i++)
                    {
                        var prj = host.CreateProjectile(
                            desc, host.ObjectType, dmg, time.TotalElapsedMs,
                            prjPos, (startAngle + _shootAngle * i), i);
                        host.Owner.EnterWorld(prj);

                        if (i == 0)
                            prjId = prj.BulletId;

                        prjs[i] = prj;
                    }

                    var pkt = new EnemyShoot()
                    {
                        BulletId = prjId,
                        OwnerId = host.Id,
                        StartingPos = prjPos,
                        Angle = startAngle,
                        Damage = (short)dmg,
                        BulletType = (byte)(desc.BulletType),
                        AngleInc = _shootAngle,
                        NumShots = (byte)count,
                        DamageType = desc.DamageType
                    };
                    foreach (var plr in host.Owner.Players
                        .Where(p => p.Value.DistSqr(host) < 1200)) // 40 sqrs
                    {
                        plr.Value.Client.SendPacket(pkt);
                    }
                }

                cool = _coolDown.Next(Random);
                Status = CycleStatus.Completed;
            }
            else
            {
                cool -= time.ElapsedMsDelta;
                Status = CycleStatus.InProgress;
            }

            state = cool;
        }
    }
}