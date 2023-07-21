﻿using System.Xml.Linq;
using common;
using wServer.realm;
using wServer.realm.worlds.logic;

namespace wServer.logic.behaviors
{
    class OrderOn : Behavior
    {
        //State storage: none

        private readonly string _condition;
        private readonly double _range;
        private readonly ushort _children;
        private readonly string _targetStateName;
        private State _targetState;

        public OrderOn(XElement e)
        {
            _condition = e.ParseString("@condition");
            _range = e.ParseFloat("@range");
            _children = GetObjType(e.ParseString("@children"));
            _targetStateName = e.ParseString("@targetState");
        }

        public OrderOn(string condition, double range, string children, string targetState)
        {
            _condition = condition;
            _range = range;
            _children = GetObjType(children);
            _targetStateName = targetState;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            switch (_condition.ToLower())
            {
                case "closedrealm":
                case "realmclosed":
                case "realm closed":
                case "closed realm":
                    var owner = host.Owner;

                    if (owner.Closed && owner is Realm)
                    {
                        if (_targetState == null)
                            _targetState = Order.FindState(host.Manager.Behaviors.Definitions[_children].Item1,
                                _targetStateName);

                        foreach (var i in host.GetNearestEntities(_range, _children))
                            if (!i.CurrentState.Is(_targetState))
                                i.SwitchTo(_targetState);
                    }

                    break;
                default:
                    if (_targetState == null)
                        _targetState = Order.FindState(host.Manager.Behaviors.Definitions[_children].Item1,
                            _targetStateName);

                    foreach (var i in host.GetNearestEntities(_range, _children))
                        if (!i.CurrentState.Is(_targetState))
                            i.SwitchTo(_targetState);
                    break;
            }
        }
    }
}