package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.engine3d.Point3D;
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.map.Square;
import com.company.assembleegameclient.objects.particles.HitEffect;
import com.company.assembleegameclient.objects.particles.SparkParticle;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.BloodComposition;
import com.company.assembleegameclient.util.FreeList;
import com.company.assembleegameclient.util.RandomUtil;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.GraphicsUtil;
import com.company.util.Trig;

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.GraphicsGradientFill;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.utils.Dictionary;

import thyrr.utils.DamageTypes;

import thyrr.utils.ItemData;

public class Projectile extends BasicObject {

    private static var objBullIdToObjId_:Dictionary = new Dictionary();

    public var props_:ObjectProperties;
    public var containerProps_:ObjectProperties;
    public var projProps_:ProjectileProperties;
    public var texture_:BitmapData;
    public var bulletId_:uint;
    public var projectileId_:int;
    public var ownerId_:int;
    public var containerType_:int;
    public var bulletType_:uint;
    public var damagesEnemies_:Boolean;
    public var damagesPlayers_:Boolean;
    public var damage_:int;
    public var damageType_:int;
    public var sound_:String;
    public var startX_:Number;
    public var startY_:Number;
    public var startTime_:int;
    public var angle_:Number = 0;
    public var multiHitDict_:Dictionary;
    public var p_:Point3D;
    public var isCrit_:Boolean;
    private var staticPoint_:Point;
    private var staticVector3D_:Vector3D;
    protected var shadowGradientFill_:GraphicsGradientFill;
    protected var shadowPath_:GraphicsPath;

    public function Projectile() {
        this.p_ = new Point3D(100);
        this.staticPoint_ = new Point();
        this.staticVector3D_ = new Vector3D();
        this.shadowGradientFill_ = new GraphicsGradientFill(GradientType.RADIAL, [0, 0], [0.5, 0], null, new Matrix());
        this.shadowPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        super();
    }

    public static function findObjId(_arg1:int, _arg2:uint):int {
        return (objBullIdToObjId_[((_arg2 << 24) | _arg1)]);
    }

    public static function getNewObjId(_arg1:int, _arg2:uint):int {
        var _local3:int = getNextFakeObjectId();
        objBullIdToObjId_[((_arg2 << 24) | _arg1)] = _local3;
        return (_local3);
    }

    public static function removeObjId(_arg1:int, _arg2:uint):void {
        delete objBullIdToObjId_[((_arg2 << 24) | _arg1)];
    }

    public static function dispose():void {
        objBullIdToObjId_ = new Dictionary();
    }


    public function reset(_arg1:int, _arg2:int, _arg3:int, _arg4:int, projectileId:int, _arg5:Number, _arg6:int,
                          _arg7:String = "", _arg8:String = ""):void {
        var _local11:Number;
        clear();
        this.containerType_ = _arg1;
        this.bulletType_ = _arg2;
        this.ownerId_ = _arg3;
        this.bulletId_ = _arg4;
        this.projectileId_ = projectileId;
        this.angle_ = Trig.boundToPI(_arg5);
        this.startTime_ = _arg6;
        objectId_ = getNewObjId(this.ownerId_, this.bulletId_);
        z_ = 0.5;
        this.containerProps_ = ObjectLibrary.propsLibrary_[this.containerType_];
        this.projProps_ = this.containerProps_.projectiles_[_arg2];
        var _local9:String = ((((!((_arg7 == ""))) && ((this.projProps_.objectId_ == _arg8)))) ? _arg7 : this.projProps_.objectId_);
        this.props_ = ObjectLibrary.getPropsFromId(_local9);
        hasShadow_ = (this.props_.shadowSize_ > 0);
        var _local10:TextureData = ObjectLibrary.typeToTextureData_[this.props_.type_];
        this.texture_ = _local10.getTexture(objectId_);
        if (Parameters.data_.outlineProj)
        {
            var size:Number = (this.projProps_.size_ >= 0 ? this.projProps_.size_
                    : ObjectLibrary.getSizeFromType(this.containerType_)) * 8;
            this.texture_ = TextureRedrawer.glowRedraw(this.texture_, size, true, 0, true, 5, 18 * (size / Main.DefaultWidth));
        }
        this.damagesPlayers_ = this.containerProps_.isEnemy_;
        this.damagesEnemies_ = !(this.damagesPlayers_);
        this.sound_ = this.containerProps_.oldSound_;
        this.multiHitDict_ = ((this.projProps_.multiHit_) ? new Dictionary() : null);
        if (this.projProps_.size_ >= 0) {
            _local11 = this.projProps_.size_;
        }
        else {
            _local11 = ObjectLibrary.getSizeFromType(this.containerType_);
        }
        this.p_.setSize((8 * (_local11 / 100)));
        this.damage_ = 0;
        this.damageType_ = DamageTypes.True;
    }

    public function setDamage(dmg:int):void {
        this.damage_ = dmg;
    }

    override public function addTo(_arg1:Map, _arg2:Number, _arg3:Number):Boolean {
        var _local4:Player;
        this.startX_ = _arg2;
        this.startY_ = _arg3;
        if (!super.addTo(_arg1, _arg2, _arg3)) {
            return (false);
        }
        if (((!(this.containerProps_.flying_)) && (square_.sink_))) {
            z_ = 0.1;
        }
        else {
            _local4 = (_arg1.goDict_[this.ownerId_] as Player);
            if (((!((_local4 == null))) && ((_local4.sinkLevel_ > 0)))) {
                z_ = (0.5 - (0.4 * (_local4.sinkLevel_ / Parameters.MAX_SINK_LEVEL)));
            }
        }
        return (true);
    }

    public function moveTo(_arg1:Number, _arg2:Number):Boolean {
        var _local3:Square = map_.getSquare(_arg1, _arg2);
        if (_local3 == null) {
            return (false);
        }
        x_ = _arg1;
        y_ = _arg2;
        square_ = _local3;
        return (true);
    }

    override public function removeFromMap():void {
        super.removeFromMap();
        removeObjId(this.ownerId_, this.bulletId_);
        this.multiHitDict_ = null;
        FreeList.deleteObject(this);
    }

    private function positionAt(elapsed:int, p:Point):void
    {
        var periodFactor:Number;
        var amplitudeFactor:Number;
        var theta:Number;
        var t:Number;
        var x:Number;
        var y:Number;
        var sin:Number;
        var cos:Number;
        var halfway:Number;
        var deflection:Number;
        p.x = this.startX_;
        p.y = this.startY_;
        var speed:Number = this.projProps_.speed_;
        if (this.projProps_.acceleration_ != 0)
        {
            speed += this.projProps_.acceleration_ * (elapsed / this.projProps_.msPerAcceleration_);
            if (this.projProps_.acceleration_ < 0 && speed < this.projProps_.speedCap_ ||
                    this.projProps_.acceleration_ > 0 && speed > this.projProps_.speedCap_)
                speed = this.projProps_.speedCap_;
        }

        var dist:Number = elapsed * (speed / 10000);
        var phase:Number = this.projectileId_ % 2 == 1 ? 0 : Math.PI;
        if (this.projProps_.wavy_)
        {
            periodFactor = 6 * Math.PI;
            amplitudeFactor = Math.PI / 64;
            theta = this.angle_ + amplitudeFactor * Math.sin(phase + periodFactor * elapsed / 1000);
            p.x += dist * Math.cos(theta);
            p.y += dist * Math.sin(theta);
        }
        else
        {
            if (this.projProps_.parametric_)
            {
                t = elapsed / this.projProps_.lifetime_ * 2 * Math.PI;
                x = Math.sin(t) * (this.projectileId_ % 2 == 1 ? 1 : -1);
                y = Math.sin(2 * t) * (this.projectileId_ % 4 < 2 ? 1 : -1);
                sin = Math.sin(this.angle_);
                cos = Math.cos(this.angle_);
                p.x += (x * cos - y * sin) * this.projProps_.magnitude_;
                p.y += (x * sin + y * cos) * this.projProps_.magnitude_;
            }
            else
            {
                if (this.projProps_.boomerang_)
                {
                    halfway = this.projProps_.lifetime_ * (this.projProps_.speed_ / 10000) / 2;
                    if (dist > halfway)
                    {
                        dist = halfway - (dist - halfway);
                    }
                }
                p.x += dist * Math.cos(this.angle_);
                p.y += dist * Math.sin(this.angle_);
                if (this.projProps_.amplitude_ != 0)
                {
                    deflection = this.projProps_.amplitude_ * Math.sin(phase + elapsed / this.projProps_.lifetime_ * this.projProps_.frequency_ * 2 * Math.PI);
                    p.x += deflection * Math.cos(this.angle_ + Math.PI / 2);
                    p.y += deflection * Math.sin(this.angle_ + Math.PI / 2);
                }
            }
        }
    }

    override public function update(currentTime:int, msDelta:int):Boolean {
        var blood:Vector.<uint>;

        var lifetime:int = currentTime - this.startTime_;
        if (lifetime > this.projProps_.lifetime_) {
            return false;
        }

        var pnt:Point = this.staticPoint_;
        this.positionAt(lifetime, pnt);

        if (!this.moveTo(pnt.x, pnt.y) || square_.tileType_ == 0xFFFF) {
            if (this.damagesPlayers_) {
                map_.gs_.gsc_.squareHit(currentTime, this.bulletId_, this.ownerId_);
            }
            else {
                if (square_.obj_ != null) {
                    blood = BloodComposition.getColors(this.texture_);
                    map_.addObj(new HitEffect(blood, 100, 3, this.angle_, this.projProps_.speed_), pnt.x, pnt.y);
                }
            }
            return false;
        }

        if (square_.obj_ != null &&
                (!square_.obj_.props_.isEnemy_ || !this.damagesEnemies_) &&
                (square_.obj_.props_.enemyOccupySquare_ || !this.projProps_.passesCover_ && square_.obj_.props_.occupySquare_)) {
            if (this.damagesPlayers_) {
                map_.gs_.gsc_.otherHit(currentTime, this.bulletId_, this.ownerId_, square_.obj_.objectId_);
            }
            else {
                blood = BloodComposition.getColors(this.texture_);
                map_.addObj(new HitEffect(blood, 100, 3, this.angle_, this.projProps_.speed_), pnt.x, pnt.y);
            }
            return false;
        }
        
        var go:GameObject = this.getHit(pnt.x, pnt.y);
        if (go != null) {
            var player:Player = map_.player_;
            var goIsEnemy:Boolean = go.props_.isEnemy_;
            var goHit:Boolean = player != null &&
                    !player.isPaused() &&
                    !player.isHidden() &&
                    (this.damagesPlayers_ || goIsEnemy && this.ownerId_ == player.objectId_);

            if (goHit) {
                var dmg:int = GameObject.damageWithArmor(this.damage_, go, go.condition_, this.damageType_);
                var dmg2:int = GameObject.dmgPostCalcs(this.damage_, go.condition_);

                if (go == player) {
                    map_.gs_.gsc_.playerHit(this.bulletId_, this.ownerId_);
                    if(player.shieldPoints_ > 0)
                        go.damage(dmg2, this.projProps_.effects_, false, this);
                    else
                        go.damage(dmg, this.projProps_.effects_, false, this);
                }
                else {
                    var dmgTypes:Vector.<int> = new <int>[
                            DamageTypes.Physical, DamageTypes.Magical, DamageTypes.Earth, DamageTypes.Air,
                            DamageTypes.Profane, DamageTypes.Fire, DamageTypes.Water, DamageTypes.Holy
                    ];
                    if (goIsEnemy) {
                        var fDmg:int = dmg;
                        var i:int = 0;
                        while (i < 4) {
                            if (player.equipment_[i].ObjectType <= 0)
                            {
                                i++;
                                continue;
                            }
                            var itemData:ItemData = player.equipment_[i];
                            if (itemData.DamageBoosts == null)
                            {
                                i++;
                                continue;
                            }
                            var j:int = 0;
                            while (j < itemData.DamageBoosts.length) {
                                if (itemData.DamageBoosts[j] == 0) {
                                    j++;
                                    continue;
                                }
                                var dmgn:int = GameObject.noLimitDamageWithArmor(itemData.DamageBoosts[j], go, go.condition_, dmgTypes[j]);
                                fDmg += dmgn;
                                j++;
                            }
                            i++;
                        }
                        fDmg = GameObject.dmgPostCalcs(fDmg, go.condition_);
                        if (go.isQuest_)
                            player._lastHitQuest = go.objectId_;
                        map_.gs_.gsc_.enemyHit(currentTime, this.bulletId_, go.objectId_);
                        go.damage(fDmg, this.projProps_.effects_, go.hp_ < 0, this, isCrit_);
                    }
                    else {
                        if (!this.projProps_.multiHit_) {
                            map_.gs_.gsc_.otherHit(currentTime, this.bulletId_, this.ownerId_, go.objectId_);
                        }
                    }
                }
            }

            if (this.projProps_.multiHit_) {
                this.multiHitDict_[go] = true;
            }
            else {
                return false;
            }
        }
        return true;
    }

    public function getHit(_arg_1:Number, _arg_2:Number):GameObject {
        var _local_5:GameObject;
        var _local_6:Number;
        var _local_7:Number;
        var _local_8:Number;
        var _local_9:Number;
        var _local_3:Number = Number.MAX_VALUE;
        var _local_4:GameObject;
        for each (_local_5 in map_.goDict_) {
            if (!_local_5.isInvincible()) {
                if (!_local_5.isStasis()) {
                    if (((((this.damagesEnemies_) && (_local_5.props_.isEnemy_))) || (((this.damagesPlayers_) && (_local_5.props_.isPlayer_))))) {
                        if (!((_local_5.dead_) || (_local_5.isPaused()))) {
                            _local_6 = (((_local_5.x_ > _arg_1)) ? (_local_5.x_ - _arg_1) : (_arg_1 - _local_5.x_));
                            _local_7 = (((_local_5.y_ > _arg_2)) ? (_local_5.y_ - _arg_2) : (_arg_2 - _local_5.y_));
                            if (!(((_local_6 > _local_5.radius_)) || ((_local_7 > _local_5.radius_)))) {
                                if (!((this.projProps_.multiHit_) && (!((this.multiHitDict_[_local_5] == null))))) {
                                    if (_local_5 == map_.player_) {
                                        return (_local_5);
                                    }
                                    _local_8 = Math.sqrt(((_local_6 * _local_6) + (_local_7 * _local_7)));
                                    _local_9 = ((_local_6 * _local_6) + (_local_7 * _local_7));
                                    if (_local_9 < _local_3) {
                                        _local_3 = _local_9;
                                        _local_4 = _local_5;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return (_local_4);
    }

    override public function draw(data:Vector.<IGraphicsData>, camera:Camera, time:int):void {
        var glowColor:uint;
        var duration:int;
        var i:int;
        if (!Parameters.drawProj_) {
            return;
        }
        var tex:BitmapData = this.texture_;
        if (Parameters.projColorType_ != 0) {
            switch (Parameters.projColorType_) {
                case 1:
                    glowColor = 0xFFFFFF;
                    break;
                case 2:
                    glowColor = 16777100;
                    break;
                case 3:
                    glowColor = 0xFF0000;
                    break;
                case 4:
                    glowColor = 0xFF;
                    break;
                case 5:
                    glowColor = 0xFFFFFF;
                    break;
                case 6:
                    glowColor = 0;
                    break;
            }
            tex = TextureRedrawer.redraw(tex, 120, true, glowColor);
        }
        var rotation:Number = (((this.props_.rotation_ == 0)) ? 0 : (time / this.props_.rotation_));
        this.staticVector3D_.x = x_;
        this.staticVector3D_.y = y_;
        this.staticVector3D_.z = z_;
        this.p_.draw(data, this.staticVector3D_, (((this.angle_ - camera.angleRad_) + this.props_.angleCorrection_) + rotation), camera.wToS_, camera, tex);
        if (this.projProps_.particleTrail_) {
            duration = (((this.projProps_.particleTrailLifetimeMS) != -1) ? this.projProps_.particleTrailLifetimeMS : 600);
            i = 0;
            while (i < 3) {
                if (((!((map_ == null))) && (!((map_.player_.objectId_ == this.ownerId_))))) {
                    if ((((this.projProps_.particleTrailIntensity_ == -1)) && (((Math.random() * 100) > this.projProps_.particleTrailIntensity_))))
                    {
                        i++;
                        continue;
                    }
                }
                map_.addObj(new SparkParticle(100, this.projProps_.particleTrailColor_, duration, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
                i++;
            }
        }
    }

    override public function drawShadow(_arg1:Vector.<IGraphicsData>, _arg2:Camera, _arg3:int):void {
        if (!Parameters.drawProj_) {
            return;
        }
        var _local4:Number = (this.props_.shadowSize_ / 400);
        var _local5:Number = (30 * _local4);
        var _local6:Number = (15 * _local4);
        this.shadowGradientFill_.matrix.createGradientBox((_local5 * 2), (_local6 * 2), 0, (posS_[0] - _local5), (posS_[1] - _local6));
        _arg1.push(this.shadowGradientFill_);
        this.shadowPath_.data.length = 0;
        Vector.<Number>(this.shadowPath_.data).push((posS_[0] - _local5), (posS_[1] - _local6), (posS_[0] + _local5), (posS_[1] - _local6), (posS_[0] + _local5), (posS_[1] + _local6), (posS_[0] - _local5), (posS_[1] + _local6));
        _arg1.push(this.shadowPath_);
        _arg1.push(GraphicsUtil.END_FILL);
    }


}
}
