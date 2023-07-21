﻿using common;
using common.resources;

namespace wServer.networking.packets.outgoing
{
    public class EnemyShoot : OutgoingMessage
    {
        public byte BulletId { get; set; }
        public int OwnerId { get; set; }
        public byte BulletType { get; set; }
        public Position StartingPos { get; set; }
        public float Angle { get; set; }
        public short Damage { get; set; }
        public byte NumShots { get; set; }
        public float AngleInc { get; set; }
        public DamageTypes DamageType { get; set; }

        public override PacketId ID => PacketId.ENEMYSHOOT;

        public override Packet CreateInstance()
        {
            return new EnemyShoot();
        }


        protected override void Write(NWriter wtr)
        {
            wtr.Write(BulletId);
            wtr.Write(OwnerId);
            wtr.Write(BulletType);
            StartingPos.Write(wtr);
            wtr.Write(Angle);
            wtr.Write(Damage);
            wtr.Write(NumShots);
            wtr.Write(AngleInc);
            wtr.Write((byte)DamageType);
        }
    }
}