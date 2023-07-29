﻿using System;
using System.Collections.Generic;
using Shared;
using Shared.resources;

namespace GameServer.realm.entities
{
    public interface IProjectileOwner
    {
        Projectile[] Projectiles { get; }
        Entity Self { get; }
    }

    public class Projectile : Entity
    {
        public IProjectileOwner ProjectileOwner { get; set; }
        public ushort Container { get; set; }
        public ProjectileDesc ProjDesc { get; }
        public long CreationTime { get; set; }
        public long ServerCreationTime { get; set; }
        private int _elapsed;

        public byte BulletId { get; set; }
        public byte ProjectileId { get; set; }
        public Position StartPos { get; set; }
        public float Angle { get; set; }
        public int Damage { get; set; }
        public DamageTypes DamageType { get; set; }

        private readonly HashSet<Entity> _hit = new();

        public Projectile(RealmManager manager, ProjectileDesc desc)
            : base(manager, manager.Resources.GameData.IdToObjectType[desc.ObjectId])
        {
            ProjDesc = desc;
        }

        public void Destroy()
        {
            Owner?.LeaveWorld(this);
        }

        public override void Dispose()
        {
            base.Dispose();
            ProjectileOwner.Projectiles[BulletId] = null;
            //ProjectileOwner = null;
        }

        public override void Tick(RealmTime time)
        {
            _elapsed += time.ElapsedMsDelta;
            // if (ProjectileOwner is Player) Console.WriteLine(_elapsed + " " + ProjDesc.LifetimeMS);
            if (_elapsed >= ProjDesc.LifetimeMS + 100)
            {
                Destroy();
                return;
            }

            base.Tick(time);
        }

        public Position GetPosition(long elapsed)
        {
            var p = new Position() { X = StartPos.X, Y = StartPos.Y };
            float periodFactor;
            float amplitudeFactor;
            float theta;
            float t;
            float x;
            float y;
            float sin;
            float cos;
            float halfway;
            float deflection;
            var speed = ProjDesc.Speed;
            if (ProjDesc.Acceleration != 0)
            {
                speed += ProjDesc.Acceleration * (elapsed / ProjDesc.MSPerAcceleration);
                if (ProjDesc.Acceleration < 0 && speed < ProjDesc.SpeedCap || 
                    ProjDesc.Acceleration > 0 && speed > ProjDesc.SpeedCap)
                    speed = ProjDesc.SpeedCap;
            }
            
            var dist = elapsed * (speed / 10000);
            var phase = ProjectileId % 2 == 1 ? 0 : Math.PI;
            if (ProjDesc.Wavy)
            {
                periodFactor = (float)(6 * Math.PI);
                amplitudeFactor = (float)(Math.PI / 64);
                theta = (float)(Angle + amplitudeFactor * Math.Sin(phase + periodFactor * elapsed / 1000));
                p.X += dist * (float)Math.Cos(theta);
                p.Y += dist * (float)Math.Sin(theta);
            }
            else if (ProjDesc.Parametric)
            {
                t = elapsed / ProjDesc.LifetimeMS * 2 * (float)Math.PI;
                x = (float)Math.Sin(t) * (ProjectileId % 2 == 1 ? 1 : -1);
                y = (float)Math.Sin(2 * t) * (ProjectileId % 4 < 2 ? 1 : -1);
                sin = (float)Math.Sin(Angle);
                cos = (float)Math.Cos(Angle);
                p.X = p.X + (x * cos - y * sin) * ProjDesc.Magnitude;
                p.Y = p.Y + (x * sin + y * cos) * ProjDesc.Magnitude;
            }
            else
            {
                if (ProjDesc.Boomerang)
                {
                    halfway = ProjDesc.LifetimeMS * (ProjDesc.Speed / 10000) / 2;
                    if (dist > halfway)
                    {
                        dist = halfway - (dist - halfway);
                    }
                }

                p.X = p.X + dist * (float)Math.Cos(Angle);
                p.Y = p.Y + dist * (float)Math.Sin(Angle);
                if (ProjDesc.Amplitude != 0)
                {
                    deflection = ProjDesc.Amplitude * (float)Math.Sin(phase + elapsed / ProjDesc.LifetimeMS * ProjDesc.Frequency * 2 * Math.PI);
                    p.X = p.X + deflection * (float)Math.Cos(Angle + Math.PI / 2);
                    p.Y = p.Y + deflection * (float)Math.Sin(Angle + Math.PI / 2);
                }
            }

            return p;
        }

        public void ForceHit(Entity entity, RealmTime time, int cTime = -1)
        {
            if (cTime > CreationTime)
            {
                var elapsed = cTime - CreationTime;
                if (elapsed > ProjDesc.LifetimeMS)
                {
                    return;
                }
                
                var pos = GetPosition(elapsed);
                var dist = MathsUtils.DistSqr(pos.X, pos.Y, entity.X, entity.Y);
                // Console.WriteLine($"Times: {cTime}  {CreationTime}  |   {dist}");
                if (dist > 4)
                {
                    return;
                }
            }

            if (_hit.Add(entity))
                entity.HitByProjectile(this, time);

            if (!ProjDesc.MultiHit)
                Destroy();
        }

        public void OverrideCreationTime(int time)
        {
            ServerCreationTime = CreationTime;
            CreationTime = time;
        }
    }
}