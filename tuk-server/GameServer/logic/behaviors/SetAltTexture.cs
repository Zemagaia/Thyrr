﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Shared;
using GameServer.realm;
using GameServer.realm.entities;
using Mono.Game;

namespace GameServer.logic.behaviors
{
    class SetAltTexture : Behavior
    {
        //State storage: none
        class TextureState
        {
            public int currentTexture;
            public int remainingTime;
        }
        private readonly int _indexMin;
        private readonly int _indexMax;
        private Cooldown _cooldown;
        private readonly bool _loop;
        
        public SetAltTexture(XElement e)
        {
            _indexMin = e.ParseInt("@minValue");
            _indexMax = e.ParseInt("@maxValue", -1);            
            _cooldown = new Cooldown().Normalize(e.ParseInt("@coolDown", 1000));
            _loop = e.ParseBool("@loop");
        }

        public SetAltTexture(int minValue, int maxValue = -1, Cooldown cooldown = new Cooldown(), bool loop = false)
        {
            _indexMin = minValue;
            _indexMax = maxValue;
            _cooldown = cooldown.Normalize(0);
            _loop = loop;
        }

        protected override void OnStateEntry(Entity host, RealmTime time, ref object state)
        {
            state = new TextureState()
            {
                currentTexture = host.AltTextureIndex,
                remainingTime = _cooldown.Next(Random)
            };
            if (host.AltTextureIndex != _indexMin)
            {
                host.AltTextureIndex = _indexMin;
                (state as TextureState).currentTexture = _indexMin;
            }
        }
        
        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            var textState = state as TextureState;

            if (_indexMax == -1 || textState.currentTexture == _indexMax && !_loop)
                return;

            if (textState.remainingTime <= 0)
            {
                var newTexture = textState.currentTexture > _indexMax ? _indexMin : textState.currentTexture + 1;
                host.AltTextureIndex = newTexture;
                textState.currentTexture = newTexture;
                textState.remainingTime = _cooldown.Next(Random);
            }
            else
            {
                textState.remainingTime -= time.ElapsedMsDelta;
            }
        }
    }
}