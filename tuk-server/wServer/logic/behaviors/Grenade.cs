﻿using System;
using System.Linq;
using System.Xml.Linq;
using common;
using common.resources;
using wServer.networking.packets.outgoing;
using wServer.realm;
using wServer.realm.entities;

namespace wServer.logic.behaviors
{
    class Grenade : Behavior
    {
        //State storage: cooldown timer

        double range;
        float radius;
        double? fixedAngle;
        int damage;
        Cooldown coolDown;
        ConditionEffectIndex effect;
        int effectDuration;
        uint color;
        private bool noDef;

        public Grenade(XElement e)
        {
            radius = e.ParseFloat("@radius");
            damage = e.ParseInt("@damage");
            range = e.ParseInt("@range", 5);
            fixedAngle = (float?)(e.ParseNFloat("@fixedAngle") * Math.PI / 180);
            coolDown = new Cooldown().Normalize(e.ParseInt("@coolDown", 1000));
            effect = e.ParseConditionEffect("@effect");
            effectDuration = e.ParseInt("@effectDuration");
            color = e.ParseUInt("@color", true, 0xffff0000);
            noDef = e.ParseBool("@noDef");
        }
        
        public Grenade(double radius, int damage, double range = 5, double? fixedAngle = null, Cooldown coolDown = new(),
            ConditionEffectIndex effect = 0, int effectDuration = 0, uint color = 0xffff0000, bool noDef = false)
        {
            this.radius = (float)radius;
            this.damage = damage;
            this.range = range;
            this.fixedAngle = fixedAngle * Math.PI / 180;
            this.coolDown = coolDown.Normalize();
            this.effect = effect;
            this.effectDuration = effectDuration;
            this.color = color;
            this.noDef = noDef;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            state = 0;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            int cool = (int)state;

            if (cool <= 0)
            {
                if (host.HasConditionEffect(ConditionEffects.Stunned))
                    return;

                var player = host.AttackTarget ?? host.GetNearestEntity(range, true);

                if (host.TauntedPlayerNearby(range))
                    player = host.GetNearestTauntedPlayer(range);

                if (player != null || fixedAngle != null)
                {
                    Position target;
                    if (fixedAngle != null)
                        target = new Position()
                        {
                            X = (float)(range * Math.Cos(fixedAngle.Value)) + host.X,
                            Y = (float)(range * Math.Sin(fixedAngle.Value)) + host.Y,
                        };
                    else
                        target = new Position()
                        {
                            X = player.X,
                            Y = player.Y,
                        };
                    host.Owner.BroadcastPacketNearby(new ShowEffect()
                    {
                        EffectType = EffectType.Throw,
                        Color = new ARGB(color),
                        TargetObjectId = host.Id,
                        Pos1 = target
                    }, host, null);
                    host.Owner.Timers.Add(new WorldTimer(1500, (world, t) =>
                    {
                        world.BroadcastPacketNearby(new Aoe()
                        {
                            Pos = target,
                            Radius = radius,
                            Damage = (ushort)damage,
                            Duration = 0,
                            Effect = 0,
                            Color = new ARGB(color),
                            OrigType = host.ObjectType
                        }, host, null);
                        world.AOE(target, radius, true, p =>
                        {
                            if (p == null) return;
                            var tenacity = Constants.NegativeEffsIdx.Contains(effect)
                                ? (1d - (double)((Player)p).Stats[13] / 100)
                                : 1d;
                            ((IPlayer)p).Damage(damage, host, noDef);
                            if (!p.HasConditionEffect(ConditionEffects.Invincible) &&
                                !p.HasConditionEffect(ConditionEffects.Stasis))
                                p.ApplyConditionEffect(effect, (int)(Math.Max(1, effectDuration * tenacity)));
                        });
                    }));
                }

                cool = coolDown.Next(Random);
            }
            else
                cool -= time.ElapsedMsDelta;

            state = cool;
        }
    }
}