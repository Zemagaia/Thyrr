package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.util.ConditionEffect;

import flash.utils.ByteArray;

import flash.utils.Dictionary;

import thyrr.utils.DamageTypes;

public class ProjectileProperties {

    public var bulletType_:int;
    public var objectId_:String;
    public var lifetime_:int;
    public var speed_:int;
    public var size_:int;
    public var minDamage_:int;
    public var maxDamage_:int;
    public var effects_:Vector.<uint> = null;
    public var multiHit_:Boolean;
    public var passesCover_:Boolean;
    public var particleTrail_:Boolean;
    public var particleTrailIntensity_:int = -1;
    public var particleTrailLifetimeMS:int = -1;
    public var particleTrailColor_:int = 0xFF00FF;
    public var wavy_:Boolean;
    public var parametric_:Boolean;
    public var boomerang_:Boolean;
    public var amplitude_:Number;
    public var frequency_:Number;
    public var magnitude_:Number;
    public var isPetEffect_:Dictionary;
    public var damageType_:int;
    public var acceleration_:Number;
    public var msPerAcceleration_:Number;
    public var speedCap_:Number;
    public var root:XML;


    private const NUM_PROPS:int = 15;
    public var key:uint;
    public var arcGap_:Number = 0;
    public var projCount_:int;
    public var numProjectiles_:int;

    public function ProjectileProperties(_arg1:XML = null) {
        this.root = _arg1;
        super();
        if (_arg1 == null) return;
        var _local2:XML;
        this.bulletType_ = int(_arg1.@id);
        this.objectId_ = _arg1.ObjectId;
        this.lifetime_ = int(_arg1.LifetimeMS);
        this.speed_ = int(_arg1.Speed);
        this.size_ = ((_arg1.hasOwnProperty("Size")) ? Number(_arg1.Size) : -1);
        if (_arg1.hasOwnProperty("Damage")) {
            this.minDamage_ = (this.maxDamage_ = int(_arg1.Damage));
        }
        else {
            this.minDamage_ = int(_arg1.MinDamage);
            this.maxDamage_ = int(_arg1.MaxDamage);
        }
        switch (String(_arg1.DamageType).toLowerCase())
        {
            case "true": this.damageType_ = DamageTypes.True; break;
            case "earth": this.damageType_ = DamageTypes.Earth; break;
            case "air": this.damageType_ = DamageTypes.Air; break;
            case "profane": this.damageType_ = DamageTypes.Profane; break;
            case "magical": this.damageType_ = DamageTypes.Magical; break;
            case "water": this.damageType_ = DamageTypes.Water; break;
            case "fire": this.damageType_ = DamageTypes.Fire; break;
            default: this.damageType_ = DamageTypes.Physical; break;
        }
        for each (_local2 in _arg1.ConditionEffect) {
            if (this.effects_ == null) {
                this.effects_ = new Vector.<uint>();
            }
            this.effects_.push(ConditionEffect.getConditionEffectFromName(String(_local2)));
            if (_local2.attribute("target") == "1") {
                if (this.isPetEffect_ == null) {
                    this.isPetEffect_ = new Dictionary();
                }
                this.isPetEffect_[ConditionEffect.getConditionEffectFromName(String(_local2))] = true;
            }
        }
        this.multiHit_ = _arg1.hasOwnProperty("MultiHit");
        this.passesCover_ = _arg1.hasOwnProperty("PassesCover");
        this.particleTrail_ = _arg1.hasOwnProperty("ParticleTrail");
        if (_arg1.ParticleTrail.hasOwnProperty("@intensity")) {
            this.particleTrailIntensity_ = (Number(_arg1.ParticleTrail.@intensity) * 100);
        }
        if (_arg1.ParticleTrail.hasOwnProperty("@lifetimeMS")) {
            this.particleTrailLifetimeMS = Number(_arg1.ParticleTrail.@lifetimeMS);
        }
        this.particleTrailColor_ = ((this.particleTrail_) ? Number(_arg1.ParticleTrail) : Number(0xFF00FF));
        if (this.particleTrailColor_ == 0) {
            this.particleTrailColor_ = 0xFF00FF;
        }
        this.wavy_ = _arg1.hasOwnProperty("Wavy");
        this.parametric_ = _arg1.hasOwnProperty("Parametric");
        this.boomerang_ = _arg1.hasOwnProperty("Boomerang");
        this.amplitude_ = ((_arg1.hasOwnProperty("Amplitude")) ? Number(_arg1.Amplitude) : 0);
        this.frequency_ = ((_arg1.hasOwnProperty("Frequency")) ? Number(_arg1.Frequency) : 1);
        this.magnitude_ = ((_arg1.hasOwnProperty("Magnitude")) ? Number(_arg1.Magnitude) : 3);
        this.acceleration_ = ((_arg1.hasOwnProperty("Acceleration")) ? Number(_arg1.Acceleration) : 0);
        this.msPerAcceleration_ = ((_arg1.hasOwnProperty("MSPerAcceleration")) ? Number(_arg1.MSPerAcceleration) : 50);
        this.speedCap_ = ((_arg1.hasOwnProperty("SpeedCap")) ? Number(_arg1.SpeedCap) : this.speed_ + this.acceleration_ * 10);
    }

    public function Import(data:ByteArray):ProjectileProperties {
        if (data == null || data == new ByteArray()) return null;
        data.endian = "littleEndian";
        this.key = data.readUnsignedInt();
        for (var i:int = 0; i < NUM_PROPS; i++)
        {
            if ((this.key & 1 << i) == 0) continue;
            switch (i)
            {
                case 0:
                    damageType_ = data.readByte();
                    break;
                case 1:
                    lifetime_ += data.readFloat();
                    break;
                case 2:
                    speed_ += data.readFloat();
                    break;
                case 3:
                    minDamage_ += data.readInt();
                    break;
                case 4:
                    maxDamage_ += data.readInt();
                    break;
                case 5:
                    var len:int = data.readShort();
                    effects_ = new Vector.<uint>(len);
                    for (var j:int = 0; j < len; j++)
                    {
                        effects_[j] = data.readByte();
                        data.readInt(); // irrelevant
                    }
                    break;
                case 6:
                    amplitude_ += data.readFloat();
                    break;
                case 7:
                    frequency_ += data.readFloat();
                    break;
                case 8:
                    objectId_ = data.readUTF();
                    break;
                case 9:
                    boomerang_ = data.readBoolean();
                    break;
                case 10:
                    wavy_ = data.readBoolean();
                    break;
                case 11:
                    parametric_ = data.readBoolean();
                    break;
                case 12:
                    arcGap_ = data.readFloat();
                    break;
                case 13:
                    projCount_ = data.readByte();
                    break;
                case 14:
                    numProjectiles_ = data.readByte();
                    break;
            }
        }
        return this;
    }

    public function importFromProps(data:ProjectileProperties):ProjectileProperties {
        this.key = data.key;
        for (var i:int = 0; i < NUM_PROPS; i++)
        {
            if ((this.key & 1 << i) == 0) continue;
            switch (i)
            {
                case 0:
                    damageType_ = data.damageType_;
                    break;
                case 1:
                    lifetime_ += data.lifetime_;
                    break;
                case 2:
                    speed_ += data.speed_;
                    break;
                case 3:
                    minDamage_ += data.minDamage_;
                    break;
                case 4:
                    maxDamage_ += data.maxDamage_;
                    break;
                case 5:
                    effects_ = data.effects_;
                    break;
                case 6:
                    amplitude_ += data.amplitude_;
                    break;
                case 7:
                    frequency_ += data.frequency_;
                    break;
                case 8:
                    objectId_ = data.objectId_;
                    break;
                case 9:
                    boomerang_ = data.boomerang_;
                    break;
                case 10:
                    wavy_ = data.wavy_;
                    break;
                case 11:
                    parametric_ = data.parametric_;
                    break;
                case 12:
                    arcGap_ = data.arcGap_;
                    break;
                case 13:
                    projCount_ = data.projCount_;
                    break;
                case 14:
                    numProjectiles_ = data.numProjectiles_;
                    break;
            }
        }
        return this;
    }

}
}
