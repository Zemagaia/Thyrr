﻿using System.Xml.Linq;
using Shared;
using GameServer.realm;
using GameServer.realm.entities;

namespace GameServer.logic.transitions
{
    class EntityHpLessTransition : Transition
    {
        //State storage: none

        private readonly double _dist;
        private readonly string _entity;
        private readonly double _threshold;

        public EntityHpLessTransition(XElement e)
            : base(e.ParseString("@targetState", "root"))
        {
            _dist = e.ParseFloat("@dist");
            _entity = e.ParseString("@entity");
            _threshold = e.ParseFloat("@threshold");
        }

        public EntityHpLessTransition(double dist, string entity, double threshold, string targetState) : base(targetState)
        {
            _dist = dist;
            _entity = entity;
            _threshold = threshold;
        }

        protected override bool TickCore(Entity host, RealmTime time, ref object state)
        {
            var entity = host.GetNearestEntityByName(_dist, _entity);

            if (entity == null)
                return false;

            return ((double)((Enemy)entity).HP / ((Enemy)entity).MaximumHP) < _threshold;
        }
    }
}