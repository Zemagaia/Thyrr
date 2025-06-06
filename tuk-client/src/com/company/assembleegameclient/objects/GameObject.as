﻿package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.engine3d.Model3D;
import com.company.assembleegameclient.engine3d.Object3D;
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.map.Square;
import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
import com.company.assembleegameclient.objects.animation.Animations;
import com.company.assembleegameclient.objects.animation.AnimationsData;
import com.company.assembleegameclient.objects.particles.ExplosionEffect;
import com.company.assembleegameclient.objects.particles.HitEffect;
import com.company.assembleegameclient.objects.particles.ParticleEffect;
import com.company.assembleegameclient.objects.particles.ShockerEffect;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.company.assembleegameclient.util.AnimatedChar;
import com.company.assembleegameclient.util.BloodComposition;
import com.company.assembleegameclient.util.ConditionEffect;
import com.company.assembleegameclient.util.MaskedImage;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;
import com.company.util.CachingColorTransformer;
import com.company.util.ConversionUtil;
import com.company.util.GraphicsUtil;
import com.company.util.MoreColorUtil;

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsGradientFill;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

import kabam.rotmg.constants.ItemConstants;

import kabam.rotmg.messaging.impl.data.WorldPosData;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.stage3D.Object3D.Object3DStage3D;

import kabam.rotmg.text.view.BitmapTextFactory;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;

import thyrr.utils.DamageTypes;

import thyrr.utils.ItemData;
import thyrr.pets.data.PetData;

public class GameObject extends BasicObject {

    protected static const PAUSED_FILTER:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix);
    protected static const CURSED_FILTER:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.redFilterMatrix);
    protected static const SHOCKED_FILTER:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix);
    protected static const IDENTITY_MATRIX:Matrix = new Matrix();
    private static const MOVE_THRESHOLD:Number = 0.4;
    private static const ZERO_LIMIT:Number = 1E-5;
    private static const NEGATIVE_ZERO_LIMIT:Number = -(ZERO_LIMIT);
    public static const ATTACK_PERIOD:int = 300;
    private static var newP:Point = new Point();
    private static const DEFAULT_HP_BAR_Y_OFFSET:int = 6;

    public var nameBitmapData_:BitmapData = null;
    private var nameFill_:GraphicsBitmapFill = null;
    private var namePath_:GraphicsPath = null;
    public var shockEffect:ShockerEffect;
    private var isShocked:Boolean;
    private var isShockedTransformSet:Boolean = false;
    private var isCharging:Boolean;
    private var isChargingTransformSet:Boolean = false;
    public var props_:ObjectProperties;
    public var name_:String;
    public var radius_:Number = 0.5;
    public var facing_:Number = 0;
    public var flying_:Boolean = false;
    public var attackAngle_:Number = 0;
    public var attackStart_:int = 0;
    public var animatedChar_:AnimatedChar = null;
    public var texture_:BitmapData = null;
    public var mask_:BitmapData = null;
    public var randomTextureData_:Vector.<TextureData> = null;
    public var obj3D_:Object3D = null;
    public var object3d_:Object3DStage3D = null;
    public var effect_:ParticleEffect = null;
    public var animations_:Animations = null;
    public var dead_:Boolean = false;
    protected var portrait_:BitmapData = null;
    protected var texturingCache_:Dictionary = null;
    public var maxHP_:int = 200;
    public var hp_:int = 200;
    public var size_:int = 100;
    public var level_:int = -1;
    public var armor_:int = 0;
    public var resistance_:int = 0;
    public var slotTypes_:Vector.<int> = null;
    public var equipment_:Vector.<ItemData> = null;
    public var lockedSlot:Vector.<int> = null;
    public var condition_:Vector.<uint>;
    protected var tex1Id_:int = 0;
    protected var tex2Id_:int = 0;
    public var isInteractive_:Boolean = false;
    public var objectType_:int;
    private var nextBulletId_:uint = 1;
    private var sizeMult_:Number = 1;
    public var sinkLevel_:int = 0;
    public var hallucinatingTexture_:BitmapData = null;
    public var flash_:FlashDescription = null;
    public var connectType_:int = -1;
    private var ishpScaleSet:Boolean = false;
    public var movDir:Point = null;
    public var rotateDir:Number = 0;
    protected var lastTickUpdateTime_:int = 0;
    protected var myLastTickId_:int = -1;
    protected var posAtTick_:Point;
    protected var tickPosition_:Point;
    protected var moveVec_:Vector3D;
    protected var bitmapFill_:GraphicsBitmapFill;
    protected var path_:GraphicsPath;
    protected var vS_:Vector.<Number>;
    protected var uvt_:Vector.<Number>;
    protected var fillMatrix_:Matrix;
    private var hpbarBackFill_:GraphicsSolidFill = null;
    private var hpbarBackPath_:GraphicsPath = null;
    private var hpbarFill_:GraphicsSolidFill = null;
    private var hpbarPath_:GraphicsPath = null;
    private var shieldBarFill_:GraphicsSolidFill = null;
    private var shieldBarFillPath_:GraphicsPath = null;
    private var icons_:Vector.<BitmapData> = null;
    private var iconFills_:Vector.<GraphicsBitmapFill> = null;
    private var iconPaths_:Vector.<GraphicsPath> = null;
    private var slideVec_:Vector3D;
    protected var shadowGradientFill_:GraphicsGradientFill = null;
    protected var shadowPath_:GraphicsPath = null;
    protected var glowColor_:int = 0;
    public var damageDealt:int = 0;
    public var isQuest_:Boolean;
    public var earthResistance_:int = 0;
    public var airResistance_:int = 0;
    public var profaneResistance_:int = 0;
    public var waterResistance_:int = 0;
    public var fireResistance_:int = 0;
    public var holyResistance_:int = 0;
    public var lethality_:int = 0;
    public var lethalityBoost_:int = 0;
    public var piercing_:int = 0;
    public var piercingBoost_:int = 0;
    public var petData_:PetData = null;
    public var immunities_:Vector.<int> = new Vector.<int>(8);

    public function GameObject(_arg1:XML) {
        var _local4:int;
        this.props_ = ObjectLibrary.defaultProps_;
        this.condition_ = new <uint>[0, 0];
        this.posAtTick_ = new Point();
        this.tickPosition_ = new Point();
        this.moveVec_ = new Vector3D();
        this.bitmapFill_ = new GraphicsBitmapFill(null, null, false, false);
        this.path_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, null);
        this.vS_ = new Vector.<Number>();
        this.uvt_ = new Vector.<Number>();
        this.fillMatrix_ = new Matrix();
        this.slideVec_ = new Vector3D();
        super();
        if (_arg1 == null) {
            return;
        }
        this.objectType_ = int(_arg1.@type);
        this.props_ = ObjectLibrary.propsLibrary_[this.objectType_];
        hasShadow_ = (this.props_.shadowSize_ > 0);
        var _local2:TextureData = ObjectLibrary.typeToTextureData_[this.objectType_];
        this.texture_ = _local2.texture_;
        this.mask_ = _local2.mask_;
        this.animatedChar_ = _local2.animatedChar_;
        this.randomTextureData_ = _local2.randomTextureData_;
        if (_local2.effectProps_ != null) {
            this.effect_ = ParticleEffect.fromProps(_local2.effectProps_, this);
        }
        if (this.texture_ != null) {
            this.sizeMult_ = (this.texture_.height / 8);
        }
        if (_arg1.hasOwnProperty("Model")) {
            this.obj3D_ = Model3D.getObject3D(String(_arg1.Model));
            this.object3d_ = Model3D.getStage3dObject3D(String(_arg1.Model));
            if (this.texture_ != null) {
                this.object3d_.setBitMapData(this.texture_);
            }
        }
        var _local3:AnimationsData = ObjectLibrary.typeToAnimationsData_[this.objectType_];
        if (_local3 != null) {
            this.animations_ = new Animations(_local3);
        }
        z_ = this.props_.z_;
        this.flying_ = this.props_.flying_;
        this.immunities_ = new Vector.<int>(8);
        if (_arg1.hasOwnProperty("MaxHitPoints")) {
            this.hp_ = (this.maxHP_ = int(_arg1.MaxHitPoints));
        }
        if (_arg1.hasOwnProperty("Armor")) {
            this.armor_ = int(_arg1.Armor);
        }
        if (_arg1.hasOwnProperty("Resistance")) {
            this.resistance_ = int(_arg1.Resistance);
        }
        if (_arg1.hasOwnProperty("EarthResistance")) {
            this.earthResistance_ = int(_arg1.EarthResistance);
        }
        if (_arg1.hasOwnProperty("AirResistance")) {
            this.airResistance_ = int(_arg1.AirResistance);
        }
        if (_arg1.hasOwnProperty("ProfaneResistance")) {
            this.profaneResistance_ = int(_arg1.ProfaneResistance);
        }
        if (_arg1.hasOwnProperty("WaterResistance")) {
            this.waterResistance_ = int(_arg1.WaterResistance);
        }
        if (_arg1.hasOwnProperty("FireResistance")) {
            this.fireResistance_ = int(_arg1.FireResistance);
        }
        if (_arg1.hasOwnProperty("HolyResistance")) {
            this.holyResistance_ = int(_arg1.HolyResistance);
        }
        if (_arg1.hasOwnProperty("SlotTypes")) {
            this.slotTypes_ = ConversionUtil.toIntVector(_arg1.SlotTypes);
            this.equipment_ = new Vector.<ItemData>(this.slotTypes_.length);
            _local4 = 0;
            while (_local4 < this.equipment_.length) {
                this.equipment_[_local4] = new ItemData(null);
                _local4++;
            }
            this.lockedSlot = new Vector.<int>(this.slotTypes_.length);
        }
        if (_arg1.hasOwnProperty("Tex1")) {
            this.tex1Id_ = int(_arg1.Tex1);
        }
        if (_arg1.hasOwnProperty("Tex2")) {
            this.tex2Id_ = int(_arg1.Tex2);
        }
        if (_arg1.hasOwnProperty("SlowImmune"))
            immunities_[0] = -1;
        if (_arg1.hasOwnProperty("StunImmune"))
            immunities_[1] = -1;
        if (_arg1.hasOwnProperty("UnarmoredImmune"))
            immunities_[2] = -1;
        if (_arg1.hasOwnProperty("StasisImmune"))
            immunities_[3] = -1;
        if (_arg1.hasOwnProperty("ParalyzeImmune"))
            immunities_[4] = -1;
        if (_arg1.hasOwnProperty("CurseImmune"))
            immunities_[5] = -1;
        if (_arg1.hasOwnProperty("PetrifyImmune"))
            immunities_[6] = -1;
        if (_arg1.hasOwnProperty("CrippledImmune"))
            immunities_[7] = -1;
        if (_arg1.hasOwnProperty("Quest"))
            this.isQuest_ = true;
        this.props_.loadSounds();
    }

    public static function damageWithArmor(damage:int, go:GameObject, conditions:Vector.<uint>, damageType:int):int {
        var ret:int;
        var limit:int = (damage * 3) / 12; // * 0.25

        ret = noLimitDamageWithArmor(damage, go, conditions, damageType);

        if (ret < limit)
            ret = limit;

        ret = dmgPostCalcs(ret, conditions);

        return (ret);
    }

    public static function noLimitDamageWithArmor(damage:int, go:GameObject, conditions:Vector.<uint>, damageType:int):int {
        var arm:int = go is Player && go.armor_ >= 384 ? 384 : go.armor_;
        var res:int = go is Player && go.resistance_ >= 384 ? 384 : go.resistance_;
        var lethality:int = go is Player && go.lethality_ >= 384 ? 384 : go.lethality_;
        var piercing:int = go is Player && go.piercing_ >= 384 ? 384 : go.piercing_;
        var ret:int = damage;

        if ((conditions[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.ARMORED_BIT) != 0)
            arm *= 2;
        if ((conditions[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.UNARMORED_BIT) != 0)
            arm = 0;

        switch (damageType) {
            default:
            case "Physical":
                ret -= Math.max(0, arm - lethality);
                break;
            case "Earth":
                ret -= Math.max(0, (arm + go.earthResistance_ - go.airResistance_ + go.fireResistance_) - lethality);
                break;
            case "Air":
                ret -= Math.max(0, (arm + go.airResistance_ + go.earthResistance_ - go.waterResistance_) - lethality);
                break;
            case "Profane":
                ret -= Math.max(0, (arm + go.profaneResistance_ - go.holyResistance_) - lethality);
                break;
            case "Magical":
                ret -= Math.max(0, res - piercing);
                break;
            case "Water":
                ret -= Math.max(0, (res + go.waterResistance_ - go.fireResistance_) - piercing);
                break;
            case "Fire":
                ret -= Math.max(0, (res + go.fireResistance_ + go.waterResistance_ - go.earthResistance_) - piercing);
                break;
            case "Holy":
                ret -= Math.max(0, (res + go.holyResistance_ - go.profaneResistance_) - piercing);
                break;
            case "True":
                break;
        }

        return ret;
    }

    public static function dmgPostCalcs(dmg:int, conditions:Vector.<uint>):int {
        var ret:int = dmg;
        if ((conditions[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.INVULNERABLE_BIT) != 0) {
            ret = 0;
        }
        if ((conditions[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.PETRIFIED_BIT) != 0) {
            ret = (ret * 0.9);
        }
        if ((conditions[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.CURSE_BIT) != 0) {
            ret = (ret * 1.2);
        }
        return ret;
    }


    public function setObjectId(_arg1:int):void {
        var _local2:TextureData;
        objectId_ = _arg1;
        if (this.randomTextureData_ != null) {
            _local2 = this.randomTextureData_[(objectId_ % this.randomTextureData_.length)];
            this.texture_ = _local2.texture_;
            this.mask_ = _local2.mask_;
            this.animatedChar_ = _local2.animatedChar_;
            if (this.object3d_ != null) {
                this.object3d_.setBitMapData(this.texture_);
            }
        }
    }

    public function setAltTexture(_arg1:int):void {
        var _local3:TextureData;
        var _local2:TextureData = ObjectLibrary.typeToTextureData_[this.objectType_];
        if (_arg1 == 0) {
            _local3 = _local2;
        }
        else {
            _local3 = _local2.getAltTextureData(_arg1);
            if (_local3 == null) {
                return;
            }
        }
        this.texture_ = _local3.texture_;
        this.mask_ = _local3.mask_;
        this.animatedChar_ = _local3.animatedChar_;
        if (this.effect_ != null) {
            map_.removeObj(this.effect_.objectId_);
            this.effect_ = null;
        }
        if (_local3.effectProps_ != null && !Parameters.data_.noParticlesMaster) {
            this.effect_ = ParticleEffect.fromProps(_local3.effectProps_, this);
            if (map_ != null) {
                map_.addObj(this.effect_, x_, y_);
            }
        }
    }

    public function setTex1(_arg1:int):void {
        if (_arg1 == this.tex1Id_) {
            return;
        }
        this.tex1Id_ = _arg1;
        this.clearCache();
    }

    public function setTex2(_arg1:int):void {
        if (_arg1 == this.tex2Id_) {
            return;
        }
        this.tex2Id_ = _arg1;
        this.clearCache();
    }

    public function setSize(size:int):void {
        this.size_ = size;
        if (this is Player)
            this.clearCache();
    }

    public function setGlow(glow:int):void {
        if (this.glowColor_ == glow) {
            return;
        }
        this.glowColor_ = glow;
        this.clearCache();
    }

    public function clearCache():void {
        this.texturingCache_ = new Dictionary();
        this.portrait_ = null;
    }

    public function playSound(_arg1:int):void {
        SoundEffectLibrary.play(this.props_.sounds_[_arg1]);
    }

    override public function dispose():void {
        var _local1:Object;
        var _local2:BitmapData;
        var _local3:Dictionary;
        var _local4:Object;
        var _local5:BitmapData;
        super.dispose();
        this.texture_ = null;
        if (this.portrait_ != null) {
            this.portrait_.dispose();
            this.portrait_ = null;
        }
        if (this.texturingCache_ != null) {
            for each (_local1 in this.texturingCache_) {
                _local2 = (_local1 as BitmapData);
                if (_local2 != null) {
                    _local2.dispose();
                }
                else {
                    _local3 = (_local1 as Dictionary);
                    for each (_local4 in _local3) {
                        _local5 = (_local4 as BitmapData);
                        if (_local5 != null) {
                            _local5.dispose();
                        }
                    }
                }
            }
            this.texturingCache_ = null;
        }
        if (this.obj3D_ != null) {
            this.obj3D_.dispose();
            this.obj3D_ = null;
        }
        if (this.object3d_ != null) {
            this.object3d_.dispose();
            this.object3d_ = null;
        }
        this.slotTypes_ = null;
        this.equipment_ = null;
        this.lockedSlot = null;
        if (this.nameBitmapData_ != null) {
            this.nameBitmapData_.dispose();
            this.nameBitmapData_ = null;
        }
        this.nameFill_ = null;
        this.namePath_ = null;
        this.bitmapFill_ = null;
        this.path_.commands = null;
        this.path_.data = null;
        this.vS_ = null;
        this.uvt_ = null;
        this.fillMatrix_ = null;
        this.icons_ = null;
        this.iconFills_ = null;
        this.iconPaths_ = null;
        this.shadowGradientFill_ = null;
        if (this.shadowPath_ != null) {
            this.shadowPath_.commands = null;
            this.shadowPath_.data = null;
            this.shadowPath_ = null;
        }
    }

    public function isStupefied():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.STUPEFIED_BIT) == 0)));
    }

    public function isWeak():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.WEAK_BIT) == 0)));
    }

    public function isSlow():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.SLOW_BIT) == 0)));
    }

    public function isSick():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.SICK_BIT) == 0)));
    }

    public function isCrippled():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.CRIPPLED_BIT) == 0)));
    }

    public function isStunned():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.STUNNED_BIT) == 0)));
    }

    public function isBlind():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.BLIND_BIT) == 0)));
    }

    public function isDrunk():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.DRUNK_BIT) == 0)));
    }

    public function isConfused():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.CONFUSED_BIT) == 0)));
    }

    public function isStunImmune():Boolean {
        return immunities_[1] > 0 || immunities_[1] < 0;
    }

    public function isInvisible():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.INVISIBLE_BIT) == 0)));
    }

    public function isParalyzed():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.PARALYZED_BIT) == 0)));
    }

    public function isSwift():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.SWIFT_BIT) == 0)));
    }

    public function isNinjaSpeedy():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.NINJA_SPEEDY_BIT) == 0)));
    }

    public function isHallucinating():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.HALLUCINATING_BIT) == 0)));
    }

    public function isRenewed():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.RENEWED_BIT) == 0)));
    }

    public function isBrave():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.BRAVE_BIT) == 0)));
    }

    public function isBerserk():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.BERSERK_BIT) == 0)));
    }

    public function isPaused():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.PAUSED_BIT) == 0)));
    }

    public function isStasis():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.STASIS_BIT) == 0)));
    }

    public function isInvincible():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.INVINCIBLE_BIT) == 0)));
    }

    public function isInvulnerable():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.INVULNERABLE_BIT) == 0)));
    }

    public function isArmored():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.ARMORED_BIT) == 0)));
    }

    public function isUnarmored():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.UNARMORED_BIT) == 0)));
    }

    public function isUnarmoredImmune():Boolean {
        return immunities_[2] > 0 || immunities_[2] < 0;
    }

    public function isSlowImmune():Boolean {
        return immunities_[0] > 0 || immunities_[0] < 0;
    }

    public function isUnsteady():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.UNSTEADY_BIT) == 0)));
    }

    public function isUnsighted():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.UNSIGHTED_BIT) == 0)));
    }

    public function isParalyzeImmune():Boolean {
        return immunities_[4] > 0 || immunities_[4] < 0;
    }

    public function isCrippledImmune():Boolean {
        return immunities_[7] > 0 || immunities_[7] < 0;
    }

    public function isPetrified():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.PETRIFIED_BIT) == 0)));
    }

    public function isPetrifyImmune():Boolean {
        return immunities_[6] > 0 || immunities_[6] < 0;
    }

    public function isCursed():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.CURSE_BIT) == 0)));
    }

    public function isCurseImmune():Boolean {
        return immunities_[5] > 0 || immunities_[5] < 0;
    }

    public function isHidden() : Boolean {
        return (this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.HIDDEN_BIT) != 0;
    }

    public function isSuppressed():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.SUPPRESSED_BIT) == 0)));
    }

    public function isStaggered():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.STAGGERED_BIT) == 0)));
    }

    public function isUnstoppable():Boolean {
        return (!(((this.condition_[ConditionEffect.CE_SECOND_BATCH] & ConditionEffect.UNSTOPPABLE_BIT) == 0)));
    }

    public function isSafe(_arg1:int = 20):Boolean {
        var _local2:GameObject;
        var _local3:int;
        var _local4:int;
        for each (_local2 in map_.goDict_) {
            if ((((_local2 is Character)) && (_local2.props_.isEnemy_))) {
                _local3 = (((x_ > _local2.x_)) ? (x_ - _local2.x_) : (_local2.x_ - x_));
                _local4 = (((y_ > _local2.y_)) ? (y_ - _local2.y_) : (_local2.y_ - y_));
                if ((((_local3 < _arg1)) && ((_local4 < _arg1)))) {
                    return (false);
                }
            }
        }
        return (true);
    }

    public function getName():String {
        return ((((((this.name_ == null)) || ((this.name_ == "")))) ? ObjectLibrary.typeToDisplayId_[this.objectType_] : this.name_));
    }

    public function getColor():uint {
        return (BitmapUtil.mostCommonColor(this.texture_));
    }

    public function getBulletId():uint {
        var _local1:uint = this.nextBulletId_;
        this.nextBulletId_ = ((this.nextBulletId_ + 1) % 128);
        return (_local1);
    }

    public function distTo(_arg1:WorldPosData):Number {
        var _local2:Number = (_arg1.x_ - x_);
        var _local3:Number = (_arg1.y_ - y_);
        return (Math.sqrt(((_local2 * _local2) + (_local3 * _local3))));
    }

    public function toggleShockEffect(_arg1:Boolean):void {
        if (_arg1) {
            this.isShocked = true;
        }
        else {
            this.isShocked = false;
            this.isShockedTransformSet = false;
        }
    }

    public function toggleChargingEffect(_arg1:Boolean):void {
        if (_arg1) {
            this.isCharging = true;
        }
        else {
            this.isCharging = false;
            this.isChargingTransformSet = false;
        }
    }

    override public function addTo(_arg1:Map, _arg2:Number, _arg3:Number):Boolean {
        map_ = _arg1;
        this.posAtTick_.x = (this.tickPosition_.x = _arg2);
        this.posAtTick_.y = (this.tickPosition_.y = _arg3);
        if (!this.moveTo(_arg2, _arg3)) {
            map_ = null;
            return (false);
        }
        if (this.effect_ != null) {
            map_.addObj(this.effect_, _arg2, _arg3);
        }
        return (true);
    }

    override public function removeFromMap():void {
        if (((this.props_.static_) && (!((square_ == null))))) {
            if (square_.obj_ == this) {
                square_.obj_ = null;
            }
            square_ = null;
        }
        if (this.effect_ != null) {
            map_.removeObj(this.effect_.objectId_);
        }
        if (((this.map_.gs_.damageCounter_) && (this.map_.gs_.damageCounter_.enemy == this)))
        {
            this.map_.gs_.removeDamageCounter();
        }
        super.removeFromMap();
        this.dispose();
    }

    public function moveTo(_arg1:Number, _arg2:Number):Boolean {
        var _local3:Square = map_.getSquare(_arg1, _arg2);
        if (_local3 == null) {
            return (false);
        }
        x_ = _arg1;
        y_ = _arg2;
        if (this.props_.static_) {
            if (square_ != null) {
                square_.obj_ = null;
            }
            _local3.obj_ = this;
        }
        square_ = _local3;
        if (this.obj3D_ != null) {
            this.obj3D_.setPosition(x_, y_, 0, this.props_.rotation_);
        }
        if (this.object3d_ != null) {
            this.object3d_.setPosition(x_, y_, 0, this.props_.rotation_);
        }
        return (true);
    }

    public function distToEnd():Number {
        var dx:Number = this.tickPosition_.x - x_;
        var dy:Number = this.tickPosition_.y - y_;
        return Math.sqrt((dx * dx) + (dy * dy));
    }

    //https://stackoverflow.com/questions/9567112/interpolate-as3
    public static function interpolate(destination:Number, current:Number, delta:Number):Number {
        return delta * destination + (1 - delta) * current;
    }

    override public function update(time:int, dt:int):Boolean
    {
        var tickDT:Number;
        var x:Number;
        var y:Number;
        var moving:Boolean;
        if (distToEnd() > 0.01)
        {
            tickDT = dt * 0.006;
            x = interpolate(this.tickPosition_.x, this.x_, tickDT);
            y = interpolate(this.tickPosition_.y, this.y_, tickDT);
            this.moveTo(x, y);
            moving = true;
        }
        else
        {
            moveVec_.x = 0;
            moveVec_.y = 0;
        }
        if (this.props_.whileMoving_ != null)
        {
            if (!moving)
            {
                z_ = this.props_.z_;
                this.flying_ = this.props_.flying_;
            }
            else
            {
                z_ = this.props_.whileMoving_.z_;
                this.flying_ = this.props_.whileMoving_.flying_;
            }
        }
        return true;
    }

    public function onGoto(_arg1:Number, _arg2:Number, _arg3:int):void {
        this.moveTo(_arg1, _arg2);
        this.lastTickUpdateTime_ = _arg3;
        this.tickPosition_.x = _arg1;
        this.tickPosition_.y = _arg2;
        this.posAtTick_.x = _arg1;
        this.posAtTick_.y = _arg2;
        this.moveVec_.x = 0;
        this.moveVec_.y = 0;
    }

    public function onTickPos(_arg1:Number, _arg2:Number, _arg3:int, _arg4:int):void {
        if (this.myLastTickId_ < map_.gs_.gsc_.lastTickId_) {
            this.moveTo(this.tickPosition_.x, this.tickPosition_.y);
        }
        this.lastTickUpdateTime_ = map_.gs_.lastUpdate_;
        this.tickPosition_.x = _arg1;
        this.tickPosition_.y = _arg2;
        this.posAtTick_.x = x_;
        this.posAtTick_.y = y_;
        this.moveVec_.x = ((this.tickPosition_.x - this.posAtTick_.x) / _arg3);
        this.moveVec_.y = ((this.tickPosition_.y - this.posAtTick_.y) / _arg3);
        this.myLastTickId_ = _arg4;
    }

    private function calcMoveVec(cameraAngle:Number, playerSpeed:Number):void {
        if (this.movDir.x != 0 || this.movDir.y != 0) {
            var dirMag:Number = Math.atan2(this.movDir.y, this.movDir.x);
            if (square_.props_.slideAmount_ > 0) {
                slideVec_.x = playerSpeed * Math.cos(cameraAngle + dirMag);
                slideVec_.y = playerSpeed * Math.sin(cameraAngle + dirMag);
                slideVec_.z = 0;
                moveVec_.scaleBy(square_.props_.slideAmount_);
                if (moveVec_.length < slideVec_.length) {
                    slideVec_.scaleBy(1 - square_.props_.slideAmount_);
                    moveVec_ = moveVec_.add(slideVec_);
                }
            }
            else {
                moveVec_.x = playerSpeed * Math.cos(cameraAngle + dirMag);
                moveVec_.y = playerSpeed * Math.sin(cameraAngle + dirMag);
            }
        }
        else if (moveVec_.length > 0.00012 && square_.props_.slideAmount_ > 0) {
            moveVec_.scaleBy(square_.props_.slideAmount_);
        }
        else {
            moveVec_.x = 0;
            moveVec_.y = 0;
        }
        if (square_ != null && square_.props_.push_) {
            moveVec_.x = moveVec_.x - square_.props_.animate_.dx_ / 1000;
            moveVec_.y = moveVec_.y - square_.props_.animate_.dy_ / 1000;
        }
    }

    public function collisionBlockMove(msDelta:int, playerSpeed:Number):Boolean {
        calcMoveVec(Parameters.data_.cameraAngle, playerSpeed);
        var x:Number = x_ + msDelta * moveVec_.x;
        var y:Number = y_ + msDelta * moveVec_.y;

        this.modifyMove(x, y, newP);
        return this.moveTo(newP.x, newP.y);
    }

    public function modifyMove(x:Number, y:Number, dest:Point):void {
        if (isPetrified() || isParalyzed()) {
            dest.x = x_;
            dest.y = y_;
            return;
        }
        var dx:Number = (x - x_);
        var dy:Number = (y - y_);
        if (dx < MOVE_THRESHOLD && dx > -MOVE_THRESHOLD && dy < MOVE_THRESHOLD && dy > -MOVE_THRESHOLD) {
            this.modifyStep(x, y, dest);
            return;
        }
        var ds:Number = (MOVE_THRESHOLD / Math.max(Math.abs(dx), Math.abs(dy)));
        var tds:Number = 0;
        dest.x = x_;
        dest.y = y_;
        var pointFound:Boolean;
        while (!pointFound) {
            if (tds + ds >= 1) {
                ds = (1 - tds);
                pointFound = true;
            }
            this.modifyStep((dest.x + (dx * ds)), (dest.y + (dy * ds)), dest);
            tds = (tds + ds);
        }
    }

    public function modifyStep(x:Number, y:Number, dest:Point):void {
        var fx:Number;
        var fy:Number;
        var isFarX:Boolean = (x_ % 0.5 == 0 && x != x_) || int(x_ / 0.5) != int(x / 0.5);
        var isFarY:Boolean = (y_ % 0.5 == 0 && y != y_) || int(y_ / 0.5) != int(y / 0.5);
        if ((!isFarX && !isFarY) || this.isValidPosition(x, y)) {
            dest.x = x;
            dest.y = y;
            return;
        }
        if (isFarX) {
            fx = (x > x_) ? int(x * 2) / 2 : int(x_ * 2) / 2;
            if (int(fx) > int(x_))
                fx = (fx - 0.01);
        }
        if (isFarY) {
            fy = (y > y_) ? int(y * 2) / 2 : int(y_ * 2) / 2;
            if (int(fy) > int(y_))
                fy = (fy - 0.01);
        }
        if (!isFarX) {
            dest.x = x;
            dest.y = fy;
            if (!(square_ == null) && !(square_.props_.slideAmount_ == 0)) {
                this.resetMoveVector(false);
            }
            return;
        }
        if (!isFarY) {
            dest.x = fx;
            dest.y = y;
            if (!(square_ == null) && !(square_.props_.slideAmount_ == 0)) {
                this.resetMoveVector(true);
            }
            return;
        }
        var ax:Number = (x > x_) ? x - fx : fx - x;
        var ay:Number = (y > y_) ? y - fy : fy - y;
        if (ax > ay) {
            if (this.isValidPosition(x, fy)) {
                dest.x = x;
                dest.y = fy;
                return;
            }
            if (this.isValidPosition(fx, y)) {
                dest.x = fx;
                dest.y = y;
                return;
            }
        }
        else {
            if (this.isValidPosition(fx, y)) {
                dest.x = fx;
                dest.y = y;
                return;
            }
            if (this.isValidPosition(x, fy)) {
                dest.x = x;
                dest.y = fy;
                return;
            }
        }
        dest.x = fx;
        dest.y = fy;
    }

    private function resetMoveVector(isFarY:Boolean):void {
        moveVec_.scaleBy(-0.5);
        if (isFarY) {
            moveVec_.y = (moveVec_.y * -1);
        }
        else {
            moveVec_.x = (moveVec_.x * -1);
        }
    }

    public function isValidPosition(x:Number, y:Number):Boolean {
        var square:Square = map_.getSquare(x, y);
        if (square_ != square && (square == null || !square.isWalkable()))
            return false;

        var xFrac:Number = x - int(x);
        var yFrac:Number = y - int(y);
        if (xFrac < 0.5) {
            if (this.isFullOccupy((x - 1), y))
                return false;

            if (yFrac < 0.5) {
                if (this.isFullOccupy(x, y - 1) || this.isFullOccupy(x - 1, y - 1))
                    return false;
            }
            else {
                if (yFrac > 0.5)
                    if (this.isFullOccupy(x, y + 1) || this.isFullOccupy(x - 1, y + 1))
                        return false;
            }
        }
        else {
            if (xFrac > 0.5) {
                if (this.isFullOccupy((x + 1), y))
                    return false;
                if (yFrac < 0.5) {
                    if (this.isFullOccupy(x, y - 1) || this.isFullOccupy(x + 1, y - 1))
                        return false;
                }
                else {
                    if (yFrac > 0.5)
                        if (this.isFullOccupy(x, y + 1) || this.isFullOccupy(x + 1, y + 1))
                            return false;
                }
            }
            else {
                if (yFrac < 0.5) {
                    if (this.isFullOccupy(x, (y - 1)))
                        return false;
                }
                else {
                    if (yFrac > 0.5) {
                        if (this.isFullOccupy(x, (y + 1)))
                            return false;
                    }
                }
            }
        }
        return true;
    }

    public function isFullOccupy(x:Number, y:Number):Boolean {
        var square:Square = map_.lookupSquare(x, y);
        return square == null || square.tileType_ == 0xFF || (square.obj_ != null && square.obj_.props_.fullOccupy_);
    }

    public function damage(damage:int, _arg3:Vector.<uint>, _arg4:Boolean, proj:Projectile,
                           isCrit:Boolean = false, delayedDamageType:Boolean = false):void {
        var _local7:int;
        var _local8:uint;
        var _local9:ConditionEffect;
        var _local10:CharacterStatusText;
        var _local13:String;
        var _local14:Vector.<uint>;
        var pierces:Boolean;
        if (_arg4) {
            this.dead_ = true;
        } else {
            if (_arg3 != null) {
                _local7 = 0;
                for each (_local8 in _arg3) {
                    _local9 = null;
                    switch (_local8) {
                        case ConditionEffect.NOTHING:
                            break;
                        case ConditionEffect.STUPEFIED:
                        case ConditionEffect.WEAK:
                        case ConditionEffect.SICK:
                        case ConditionEffect.BLIND:
                        case ConditionEffect.HALLUCINATING:
                        case ConditionEffect.DRUNK:
                        case ConditionEffect.CONFUSED:
                        case ConditionEffect.BLEEDING:
                        case ConditionEffect.STASIS:
                        case ConditionEffect.UNSTEADY:
                        case ConditionEffect.UNSIGHTED:
                        case ConditionEffect.HEXED:
                        case ConditionEffect.SUPPRESSED:
                        case ConditionEffect.EXPOSED:
                        case ConditionEffect.STAGGERED: // ironic, isn't it?
                            if (!this.isUnstoppable())
                                _local9 = ConditionEffect.effects_[_local8];
                            break;
                        case ConditionEffect.SWIFT:
                        case ConditionEffect.NINJA_SPEEDY:
                        case ConditionEffect.INVISIBLE:
                        case ConditionEffect.RENEWED:
                        case ConditionEffect.BRAVE:
                        case ConditionEffect.BERSERK:
                        case ConditionEffect.INVINCIBLE:
                        case ConditionEffect.INVULNERABLE:
                        case ConditionEffect.ARMORED:
                        case ConditionEffect.SHIELDED:
                        case ConditionEffect.ENLIGHTENED:
                        case ConditionEffect.UNSTOPPABLE: // ironic, isn't it?
                            if (!this.isStaggered())
                                _local9 = ConditionEffect.effects_[_local8];
                            break;
                        case ConditionEffect.SLOW:
                            if (this.isSlowImmune()) {
                                _local10 = new CharacterStatusText(this, 0xFF0000, 3000);
                                _local10.setStringBuilder(new LineBuilder().setParams("Immune"));
                                map_.mapOverlay_.addStatusText(_local10);
                            }
                            else {
                                if (!this.isUnstoppable())
                                    _local9 = ConditionEffect.effects_[_local8];
                            }
                            break;
                        case ConditionEffect.UNARMORED:
                            if (this.isUnarmoredImmune()) {
                                _local10 = new CharacterStatusText(this, 0xFF0000, 3000);
                                _local10.setStringBuilder(new LineBuilder().setParams("Immune"));
                                map_.mapOverlay_.addStatusText(_local10);
                            }
                            else {
                                if (!this.isUnstoppable())
                                    _local9 = ConditionEffect.effects_[_local8];
                            }
                            break;
                        case ConditionEffect.STUNNED:
                            if (this.isStunImmune()) {
                                _local10 = new CharacterStatusText(this, 0xFF0000, 3000);
                                _local10.setStringBuilder(new LineBuilder().setParams("Immune"));
                                map_.mapOverlay_.addStatusText(_local10);
                            }
                            else {
                                if (!this.isUnstoppable())
                                    _local9 = ConditionEffect.effects_[_local8];
                            }
                            break;
                        case ConditionEffect.CRIPPLED:
                            if (this.isCrippledImmune()) {
                                _local10 = new CharacterStatusText(this, 0xFF0000, 3000);
                                _local10.setStringBuilder(new LineBuilder().setParams("Immune"));
                                map_.mapOverlay_.addStatusText(_local10);
                            }
                            else {
                                if (!this.isUnstoppable())
                                    _local9 = ConditionEffect.effects_[_local8];
                            }
                            break;
                        case ConditionEffect.PARALYZED:
                            if (this.isParalyzeImmune()) {
                                _local10 = new CharacterStatusText(this, 0xFF0000, 3000);
                                _local10.setStringBuilder(new LineBuilder().setParams("Immune"));
                                map_.mapOverlay_.addStatusText(_local10);
                            }
                            else {
                                if (!this.isUnstoppable())
                                    _local9 = ConditionEffect.effects_[_local8];
                            }
                            break;
                        case ConditionEffect.PETRIFIED:
                            if (this.isPetrifyImmune()) {
                                _local10 = new CharacterStatusText(this, 0xFF0000, 3000);
                                _local10.setStringBuilder(new LineBuilder().setParams("Immune"));
                                map_.mapOverlay_.addStatusText(_local10);
                            }
                            else {
                                if (!this.isUnstoppable())
                                    _local9 = ConditionEffect.effects_[_local8];
                            }
                            break;
                        case ConditionEffect.CURSE:
                            if (this.isCurseImmune()) {
                                _local10 = new CharacterStatusText(this, 0xFF0000, 3000);
                                _local10.setStringBuilder(new LineBuilder().setParams("Immune"));
                                map_.mapOverlay_.addStatusText(_local10);
                            }
                            else {
                                if (!this.isUnstoppable())
                                    _local9 = ConditionEffect.effects_[_local8];
                            }
                            break;
                    }
                    if (_local9 != null) {
                        _local13 = _local9.localizationKey_;
                        this.showConditionEffect(_local7, _local13);
                        _local7 = (_local7 + 500);
                    }
                }
            }
        }
        _local14 = BloodComposition.getBloodComposition(this.objectType_, this.texture_, this.props_.bloodProb_, this.props_.bloodColor_);
        if (this.dead_) {
            map_.addObj(new ExplosionEffect(_local14, this.size_, 30), x_, y_);
        } else {
            if (proj != null) {
                map_.addObj(new HitEffect(_local14, this.size_, 10, proj.angle_, proj.projProps_.speed_), x_, y_);
            } else {
                map_.addObj(new ExplosionEffect(_local14, this.size_, 10), x_, y_);
            }
        }

        if (damage > 0) {
            pierces = this.isUnarmored() || (proj != null && proj.projProps_.damageType_ == DamageTypes.True);
            if (this is Player && (this as Player).shieldPoints_ > 0)
                this.showDamageText2(damage, (this as Player).shieldPoints_);
            else if (isCrit)
                this.showDamageText3(damage, pierces, delayedDamageType);
            else
                this.showDamageText(damage, pierces, delayedDamageType);
        }
    }

    public function showConditionEffect(_arg1:int, _arg2:String):void {
        var _local3:CharacterStatusText = new CharacterStatusText(this, 0xFF0000, 3000, _arg1);
        _local3.setStringBuilder(new LineBuilder().setParams(_arg2));
        map_.mapOverlay_.addStatusText(_local3);
    }

    public function showConditionEffectPet(_arg1:int, _arg2:String):void {
        var _local3:CharacterStatusText = new CharacterStatusText(this, 0xFF0000, 3000, _arg1);
        _local3.setStringBuilder(new StaticStringBuilder(("Pet " + _arg2)));
        map_.mapOverlay_.addStatusText(_local3);
    }

    public function showDamageText(dmg:int, pierces:Boolean, DTp:Boolean):void
    {
        var color:uint = ((Parameters.data_.dynamicColor) ? uint(int(Character.transitionGreenToRed(((this.hp_ / this.maxHP_) * 100)))) : 0xFF0000);
        var extraDmg:String = Parameters.data_.hpInfo ? " [" + Math.max(0, (DTp ? this.hp_ : this.hp_ - dmg)) + "]" : "";
        var dmgString:String = ("-" + dmg) + extraDmg;
        var charStatusText:CharacterStatusText = new CharacterStatusText(this, ((pierces) ? 0x9000FF : color), 1000);
        charStatusText.setStringBuilder(new StaticStringBuilder(dmgString));
        map_.mapOverlay_.addStatusText(charStatusText);
    }

    public function showDamageText2(dmg:int, sd:int):void
    {
        var extraDmg:String = Parameters.data_.hpInfo ? " [" + (sd - dmg) + "]" : "";
        var dmgString:String = ("-" + dmg) + extraDmg;
        var charStatusText:CharacterStatusText = new CharacterStatusText(this, 0xC9E9F6, 1000);
        charStatusText.setStringBuilder(new StaticStringBuilder(dmgString));
        map_.mapOverlay_.addStatusText(charStatusText);
    }

    public function showDamageText3(dmg:int, pierces:Boolean, DTp:Boolean):void {
        var finalDmg:int = dmg;
        var extraDmg:String = Parameters.data_.hpInfo ? " [" + (DTp ? this.hp_ : this.hp_ - finalDmg) + "]" : "";
        var dmgString:String = ("-" + finalDmg + "!") + extraDmg;
        var charStatusText:CharacterStatusText = new CharacterStatusText(this, pierces ? 0x9000FF : 0xFF4500, 1000);
        charStatusText.setStringBuilder(new StaticStringBuilder(dmgString));
        map_.mapOverlay_.addStatusText(charStatusText);
    }

    protected function makeNameBitmapData():BitmapData {
        var _local1:StringBuilder = new StaticStringBuilder(this.name_);
        var _local2:BitmapTextFactory = Global.bitmapTextFactory;
        return (_local2.make(_local1, 16, 0xFFFFFF, true, IDENTITY_MATRIX, true));
    }

    public function drawName(_arg1:Vector.<IGraphicsData>, _arg2:Camera):void {
        if (this.nameBitmapData_ == null) {
            this.nameBitmapData_ = this.makeNameBitmapData();
            this.nameFill_ = new GraphicsBitmapFill(null, new Matrix(), false, false);
            this.namePath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        }
        var _local3:int = ((this.nameBitmapData_.width / 2) + 1);
        var _local4:int = 30;
        var _local5:Vector.<Number> = this.namePath_.data;
        _local5.length = 0;
        _local5.push((posS_[0] - _local3), posS_[1], (posS_[0] + _local3), posS_[1], (posS_[0] + _local3), (posS_[1] + _local4), (posS_[0] - _local3), (posS_[1] + _local4));
        this.nameFill_.bitmapData = this.nameBitmapData_;
        var _local6:Matrix = this.nameFill_.matrix;
        _local6.identity();
        _local6.translate(_local5[0], _local5[1]);
        _arg1.push(this.nameFill_);
        _arg1.push(this.namePath_);
        _arg1.push(GraphicsUtil.END_FILL);
    }

    protected function getHallucinatingTexture():BitmapData {
        if (this.hallucinatingTexture_ == null) {
            this.hallucinatingTexture_ = AssetLibrary.getImageFromSet("realmEnvironment", int((Math.random() * 239)));
        }
        return (this.hallucinatingTexture_);
    }

    protected function getTexture(_arg1:Camera, _arg2:int):BitmapData
    {
        var _local3:Number = NaN;
        var _local4:int;
        var _local5:MaskedImage;
        var _local6:int;
        var _local7:BitmapData;
        var _local8:int;
        var _local9:BitmapData;
        var _local10:BitmapData = this.texture_;
        var _local11:int = this.size_;
        var _local12:BitmapData;
        if (this.animatedChar_ != null)
        {
            _local3 = 0;
            _local4 = AnimatedChar.STAND;
            if (_arg2 < (this.attackStart_ + ATTACK_PERIOD))
            {
                if (!this.props_.dontFaceAttacks_)
                {
                    this.facing_ = this.attackAngle_;
                }
                _local3 = (((_arg2 - this.attackStart_) % ATTACK_PERIOD) / ATTACK_PERIOD);
                _local4 = AnimatedChar.ATTACK;
            }
            else
            {
                if (((!(this.moveVec_.x == 0)) || (!(this.moveVec_.y == 0))))
                {
                    _local6 = int((0.5 / this.moveVec_.length));
                    _local6 = (_local6 + (400 - (_local6 % 400)));
                    if (((((this.moveVec_.x > ZERO_LIMIT) || (this.moveVec_.x < NEGATIVE_ZERO_LIMIT)) || (this.moveVec_.y > ZERO_LIMIT)) || (this.moveVec_.y < NEGATIVE_ZERO_LIMIT)))
                    {
                        this.facing_ = Math.atan2(this.moveVec_.y, this.moveVec_.x);
                        _local4 = AnimatedChar.WALK;
                    }
                    else
                    {
                        _local4 = AnimatedChar.STAND;
                    }
                    _local3 = ((_arg2 % _local6) / _local6);
                }
            }
            _local5 = this.animatedChar_.imageFromFacing(this.facing_, _arg1, _local4, _local3);
            _local10 = _local5.image_;
            _local12 = _local5.mask_;
        }
        else
        {
            if (this.animations_ != null)
            {
                _local7 = this.animations_.getTexture(_arg2);
                if (_local7 != null)
                {
                    _local10 = _local7;
                }
            }
        }
        if (this.props_.drawOnGround_)
        {
            return (_local10);
        }
        if (this.obj3D_ != null)
        {
            if (Parameters.isGpuRender())
            {
                return (TextureRedrawer.redraw(_local10, _local11, true, 0));
            }
            return (_local10);
        }
        if (_arg1.isHallucinating_)
        {
            _local8 = ((_local10 == null) ? int(8) : int(_local10.width));
            _local10 = this.getHallucinatingTexture();
            _local12 = null;
            _local11 = int((this.size_ * Math.min(1.5, (_local8 / _local10.width))));
        }
        if (this.isCursed())
        {
            _local10 = CachingColorTransformer.filterBitmapData(_local10, CURSED_FILTER);
        }
        if (this.isStasis())
        {
            _local10 = CachingColorTransformer.filterBitmapData(_local10, PAUSED_FILTER);
        }
        var _local13:int = ((this.map_.quest_.getObject(_arg2) == this) ? 0xFF0000 : (((this is Container) && (!((this as Container).isInteractive_))) ? 0xFF0000 : 0));
        if (((this.tex1Id_ == 0) && (this.tex2Id_ == 0)))
        {
            _local10 = TextureRedrawer.redraw(_local10, _local11, false, _local13);
        }
        else
        {
            _local9 = null;
            if (this.texturingCache_ == null)
            {
                this.texturingCache_ = new Dictionary();
            }
            else
            {
                _local9 = this.texturingCache_[_local10];
            }
            if (_local9 == null)
            {
                _local9 = TextureRedrawer.resize(_local10, _local12, _local11, false, this.tex1Id_, this.tex2Id_);
                _local9 = GlowRedrawer.outline(_local9, 0);
                this.texturingCache_[_local10] = _local9;
            }
            _local10 = _local9;
        }
        if (isInvisible()) {
            _local10 = CachingColorTransformer.alphaBitmapData(_local10, 40);
        }
        return (_local10);
    }

    public function useAltTexture(_arg1:String, _arg2:int):void {
        this.texture_ = AssetLibrary.getImageFromSet(_arg1, _arg2);
        this.sizeMult_ = (this.texture_.height / 8);
    }

    public function getPortrait(mult:int = 100, flip:Boolean = false):BitmapData {
        var bitmapData:BitmapData;
        var size:int;
        if (this.portrait_ == null) {
            bitmapData = (((this.props_.portrait_) != null) ? this.props_.portrait_.getTexture() : this.texture_);
            if (flip)
                bitmapData = BitmapUtil.flipBitmapData(bitmapData);
            size = ((4 / bitmapData.width) * mult);
            this.portrait_ = TextureRedrawer.resize(bitmapData, this.mask_, size, true, this.tex1Id_, this.tex2Id_);
            this.portrait_ = GlowRedrawer.outline(this.portrait_, 0);
        }
        return (this.portrait_);
    }

    public function setAttack(_arg1:int, _arg2:Number):void {
        this.attackAngle_ = _arg2;
        this.attackStart_ = getTimer();
    }

    override public function draw3d(_arg1:Vector.<Object3DStage3D>):void {
        if (this.object3d_ != null) {
            _arg1.push(this.object3d_);
        }
    }

    protected function drawHpBar(_arg1:Vector.<IGraphicsData>, _arg2:int=6):void{
        var _local6:Number;
        var _local7:Number;
        if (this.hpbarPath_ == null)
        {
            this.hpbarBackFill_ = new GraphicsSolidFill();
            this.hpbarBackPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
            this.hpbarFill_ = new GraphicsSolidFill();
            this.hpbarPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
            this.shieldBarFill_ = new GraphicsSolidFill(0xC9E9F6);
            this.shieldBarFillPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        }
        var maxHp:int = this.maxHP_;
        if (this.hp_ > maxHp)
        {
            maxHp = this.hp_;
        }
        this.hpbarBackFill_.color = 0x111111;
        var _local3:int = 20;
        var _local4:int = 4;
        this.hpbarBackPath_.data.length = 0;
        var _local5:Number = 1.2;
        (this.hpbarBackPath_.data as Vector.<Number>).push(((posS_[0] - _local3) - _local5), ((posS_[1] + _arg2) - _local5), ((posS_[0] + _local3) + _local5), ((posS_[1] + _arg2) - _local5), ((posS_[0] + _local3) + _local5), (((posS_[1] + _arg2) + _local4) + _local5), ((posS_[0] - _local3) - _local5), (((posS_[1] + _arg2) + _local4) + _local5));
        _arg1.push(this.hpbarBackFill_);
        _arg1.push(this.hpbarBackPath_);
        _arg1.push(GraphicsUtil.END_FILL);
        if (this.hp_ > 0)
        {
            _local6 = (this.hp_ / maxHp);
            _local7 = ((_local6 * 2) * _local3);
            this.hpbarPath_.data.length = 0;
            (this.hpbarPath_.data as Vector.<Number>).push((posS_[0] - _local3), (posS_[1] + _arg2), ((posS_[0] - _local3) + _local7), (posS_[1] + _arg2), ((posS_[0] - _local3) + _local7), ((posS_[1] + _arg2) + _local4), (posS_[0] - _local3), ((posS_[1] + _arg2) + _local4));
            this.hpbarFill_.color = 0xe03434;
            _arg1.push(this.hpbarFill_);
            _arg1.push(this.hpbarPath_);
            _arg1.push(GraphicsUtil.END_FILL);
        }

        if (this.props_.isPlayer_) {
            var player:Player = this as Player;
            if (player && player.shieldPoints_ > 0)
            {
                _local6 = player.shieldPoints_ / player.shieldPointsMax_ * 40;
                this.shieldBarFillPath_.data.length = 0;
                (this.shieldBarFillPath_.data as Vector.<Number>).push(posS_[0] - _local3,
                        posS_[1] + _arg2,
                        posS_[0] - _local3 + _local6,
                        posS_[1] + _arg2,
                        posS_[0] - _local3 + _local6,
                        posS_[1] + _arg2 + 4,
                        posS_[0] - _local3,
                        posS_[1] + _arg2 + 4);
                _arg1.push(this.shieldBarFill_);
                _arg1.push(this.shieldBarFillPath_);
                _arg1.push(GraphicsUtil.END_FILL);
            }
        }
        GraphicsFillExtra.setSoftwareDrawSolid(this.shieldBarFill_, true);
        GraphicsFillExtra.setSoftwareDrawSolid(this.hpbarFill_, true);
        GraphicsFillExtra.setSoftwareDrawSolid(this.hpbarBackFill_, true);
    }

    override public function draw(_arg1:Vector.<IGraphicsData>, _arg2:Camera, _arg3:int):void
    {
        var _local4:BitmapData = this.getTexture(_arg2, _arg3);
        if (this.props_.drawOnGround_)
        {
            if (square_.faces_.length == 0)
            {
                return;
            }
            this.path_.data = square_.faces_[0].face_.vout_;
            this.bitmapFill_.bitmapData = _local4;
            square_.baseTexMatrix_.calculateTextureMatrix(this.path_.data);
            this.bitmapFill_.matrix = square_.baseTexMatrix_.tToS_;
            _arg1.push(this.bitmapFill_);
            _arg1.push(this.path_);
            _arg1.push(GraphicsUtil.END_FILL);
            return;
        }
        var _local5:Boolean = (((((this.props_) && ((this.props_.isEnemy_) || (this.props_.isPlayer_))) && (!(this.isInvincible()))) && ((this.props_.isPlayer_) || (!(this.isInvulnerable())))) && (!(this.props_.noMiniMap_)));
        if (this.obj3D_ != null)
        {
            if (((_local5) && (this.bHPBarParamCheck())))
            {
                this.drawHpBar(_arg1, (0 + DEFAULT_HP_BAR_Y_OFFSET));
            }
            if (!Parameters.isGpuRender())
            {
                this.obj3D_.draw(_arg1, _arg2, this.props_.color_, _local4);
                return;
            }
        }
        var _local6:int = _local4.width;
        var _local7:int = _local4.height;
        var _local8:int = (square_.sink_ + this.sinkLevel_);
        if (((_local8 > 0) && ((this.flying_) || ((!(square_.obj_ == null)) && (square_.obj_.props_.protectFromSink_)))))
        {
            _local8 = 0;
        }
        if (Parameters.isGpuRender())
        {
            if (_local8 != 0)
            {
                GraphicsFillExtra.setSinkLevel(this.bitmapFill_, Math.max((((_local8 / _local7) * 1.65) - 0.02), 0));
                _local8 = (-(_local8) + 0.02);
            }
            else
            {
                if (((_local8 == 0) && (!(GraphicsFillExtra.getSinkLevel(this.bitmapFill_) == 0))))
                {
                    GraphicsFillExtra.clearSink(this.bitmapFill_);
                }
            }
        }
        this.vS_.length = 0;
        this.vS_.push((posS_[3] - (_local6 / 2)), ((posS_[4] - _local7) + _local8), (posS_[3] + (_local6 / 2)), ((posS_[4] - _local7) + _local8), (posS_[3] + (_local6 / 2)), posS_[4], (posS_[3] - (_local6 / 2)), posS_[4]);
        this.path_.data = this.vS_;
        if (this.flash_ != null)
        {
            if (!this.flash_.doneAt(_arg3))
            {
                if (Parameters.isGpuRender())
                {
                    this.flash_.applyGPUTextureColorTransform(_local4, _arg3);
                }
                else
                {
                    _local4 = this.flash_.apply(_local4, _arg3);
                }
            }
            else
            {
                this.flash_ = null;
            }
        }
        this.bitmapFill_.bitmapData = _local4;
        this.fillMatrix_.identity();
        this.fillMatrix_.translate(this.vS_[0], this.vS_[1]);
        this.bitmapFill_.matrix = this.fillMatrix_;
        _arg1.push(this.bitmapFill_);
        _arg1.push(this.path_);
        _arg1.push(GraphicsUtil.END_FILL);
        if (((!(this.isPaused())) && ((this.condition_[ConditionEffect.CE_FIRST_BATCH]) || (this.condition_[ConditionEffect.CE_SECOND_BATCH]))))
        {
            this.drawConditionIcons(_arg1, _arg2, _arg3);
        }
        if ((((this.props_.showName_) && (!(this.name_ == null))) && (!(this.name_.length == 0))))
        {
            this.drawName(_arg1, _arg2);
        }
        if (((Parameters.data_.HPBar) && (_local5)))
        {
            this.drawHpBar(_arg1, ((((this.props_.isPlayer_) && (!(this == map_.player_))) ? 16 : 0) + DEFAULT_HP_BAR_Y_OFFSET));
        }
        if (Parameters.data_.showDamageCounter && this.isQuest_ && this.damageDealt > 0 && this.map_.player_._lastHitQuest == this.objectId_)
        {
            this.map_.gs_.drawDamageCounter(this);
        }
    }

    private function bHPBarParamCheck():Boolean{
        return ((Parameters.data_.HPBar) && (((((Parameters.data_.HPBar == 1) || ((Parameters.data_.HPBar == 2) && (this.props_.isEnemy_))) || ((Parameters.data_.HPBar == 3) && ((this == map_.player_) || (this.props_.isEnemy_)))) || ((Parameters.data_.HPBar == 4) && (this == map_.player_))) || ((Parameters.data_.HPBar == 5) && (this.props_.isPlayer_))));
    }

    public function drawConditionIcons(_arg1:Vector.<IGraphicsData>, _arg2:Camera, _arg3:int):void {
        var _local9:BitmapData;
        var _local10:GraphicsBitmapFill;
        var _local11:GraphicsPath;
        var _local12:Number;
        var _local13:Number;
        var _local14:Matrix;
        if (this.icons_ == null) {
            this.icons_ = new Vector.<BitmapData>();
            this.iconFills_ = new Vector.<GraphicsBitmapFill>();
            this.iconPaths_ = new Vector.<GraphicsPath>();
        }
        this.icons_.length = 0;
        var _local4:int = (_arg3 / 500);
        ConditionEffect.getConditionEffectIcons(this.condition_[ConditionEffect.CE_FIRST_BATCH], this.icons_, _local4);
        ConditionEffect.getConditionEffectIcons2(this.condition_[ConditionEffect.CE_SECOND_BATCH], this.icons_, _local4);
        var _local5:Number = posS_[3];
        var _local6:Number = this.vS_[1];
        var _local7:int = this.icons_.length;
        var _local8:int;
        while (_local8 < _local7) {
            _local9 = this.icons_[_local8];
            if (_local8 >= this.iconFills_.length) {
                this.iconFills_.push(new GraphicsBitmapFill(null, new Matrix(), false, false));
                this.iconPaths_.push(new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>()));
            }
            _local10 = this.iconFills_[_local8];
            _local11 = this.iconPaths_[_local8];
            _local10.bitmapData = _local9;
            _local12 = ((_local5 - ((_local9.width * _local7) / 2)) + (_local8 * _local9.width));
            _local13 = (_local6 - (_local9.height / 2));
            _local11.data.length = 0;
            _local11.data.push(_local12, _local13, (_local12 + _local9.width), _local13, (_local12 + _local9.width), (_local13 + _local9.height), _local12, (_local13 + _local9.height));
            _local14 = _local10.matrix;
            _local14.identity();
            _local14.translate(_local12, _local13);
            _arg1.push(_local10);
            _arg1.push(_local11);
            _arg1.push(GraphicsUtil.END_FILL);
            _local8++;
        }
    }

    override public function drawShadow(_arg1:Vector.<IGraphicsData>, _arg2:Camera, _arg3:int):void {
        if (this.shadowGradientFill_ == null) {
            this.shadowGradientFill_ = new GraphicsGradientFill(GradientType.RADIAL, [this.props_.shadowColor_, this.props_.shadowColor_], [0.5, 0], null, new Matrix());
            this.shadowPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        }
        var _local4:Number = (((this.size_ / 100) * (this.props_.shadowSize_ / 100)) * this.sizeMult_);
        var _local5:Number = (30 * _local4);
        var _local6:Number = (15 * _local4);
        this.shadowGradientFill_.matrix.createGradientBox((_local5 * 2), (_local6 * 2), 0, (posS_[0] - _local5), (posS_[1] - _local6));
        _arg1.push(this.shadowGradientFill_);
        this.shadowPath_.data.length = 0;
        this.shadowPath_.data.push((posS_[0] - _local5), (posS_[1] - _local6), (posS_[0] + _local5), (posS_[1] - _local6), (posS_[0] + _local5), (posS_[1] + _local6), (posS_[0] - _local5), (posS_[1] + _local6));
        _arg1.push(this.shadowPath_);
        _arg1.push(GraphicsUtil.END_FILL);
    }

    public function clearTextureCache():void {
        this.texturingCache_ = new Dictionary();
    }

    public function toString():String {
        return ((((((((((("[" + getQualifiedClassName(this)) + " id: ") + objectId_) + " type: ") + ObjectLibrary.typeToDisplayId_[this.objectType_]) + " pos: ") + x_) + ", ") + y_) + "]"));
    }


}
}