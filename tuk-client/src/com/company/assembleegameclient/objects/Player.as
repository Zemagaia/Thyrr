package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Square;
import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
import com.company.assembleegameclient.objects.ProjectileProperties;
import com.company.assembleegameclient.objects.particles.HealingEffect;
import com.company.assembleegameclient.objects.particles.LevelUpEffect;
import com.company.assembleegameclient.objects.particles.UnstoppableEffect;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.company.assembleegameclient.util.AnimatedChar;
import com.company.assembleegameclient.util.ConditionEffect;
import com.company.assembleegameclient.util.FameUtil;
import com.company.assembleegameclient.util.FreeList;
import com.company.assembleegameclient.util.MaskedImage;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.util.BitmapUtil;
import com.company.util.CachingColorTransformer;
import com.company.util.ConversionUtil;
import com.company.util.GraphicsUtil;
import com.company.util.IntPoint;
import com.company.util.MoreColorUtil;
import com.company.util.PointUtil;
import com.company.util.Trig;

import flash.display.BitmapData;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.constants.ActivationType;
import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.constants.UseType;
import kabam.rotmg.game.model.PotionInventoryModel;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.text.view.BitmapTextFactory;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;
import kabam.rotmg.ui.model.TabStripModel;

import thyrr.assets.CharacterFactory;
import thyrr.utils.DamageTypes;
import thyrr.utils.ItemData;

public class Player extends Character {

    public static const MS_BETWEEN_TELEPORT:int = 10000;
    private static const NEARBY:Vector.<Point> = new <Point>[new Point(0, 0), new Point(1, 0), new Point(0, 1), new Point(1, 1)];
    private static const RANK_OFFSET_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 2, 2);
    private static const NAME_OFFSET_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 20, 1);
    private static const MIN_MOVE_SPEED:Number = 0.004;
    private static const MAX_MOVE_SPEED:Number = 0.0096;
    private static const MIN_ATTACK_FREQ:Number = 0.0015;
    private static const MAX_ATTACK_FREQ:Number = 0.008;
    private static const MIN_ATTACK_MULT:Number = 0.5;
    private static const MAX_ATTACK_MULT:Number = 2;
    private static const LOW_HEALTH_CT_OFFSET:int = 128;

    private static var lowHealthCT:Dictionary = new Dictionary();
    public static var rank:int = 0;
    public static var isAdmin:Boolean = false;
    public static var isMod:Boolean = false;

    public var xpTimer:int;
    public var skinId:int;
    public var skin:AnimatedChar;
    public var isShooting:Boolean;
    public var accountId_:String = "";
    public var credits_:int = 0;
    public var tokens_:int = 0;
    public var unholyEssence_:int = 0;
    public var divineEssence_:int = 0;
    public var numStars_:int = 0;
    public var fame_:int = 0;
    public var nameChosen_:Boolean = false;
    public var currFame_:int = 0;
    public var nextClassQuestFame_:int = -1;
    public var guildName_:String = null;
    public var guildRank_:int = -1;
    public var isFellowGuild_:Boolean = false;
    public var breath_:int = -1;
    public var maxMP_:int = 200;
    public var mp_:Number = 0;
    public var nextLevelExp_:int = 1000;
    public var exp_:int = 0;
    public var strength_:int = 0;
    public var wit_:int = 0;
    public var agility_:int = 0;
    public var dexterity_:int = 0;
    public var stamina_:int = 0;
    public var intelligence_:int = 0;
    public var maxHPBoost_:int = 0;
    public var maxMPBoost_:int = 0;
    public var strengthBoost_:int = 0;
    public var witBoost_:int = 0;
    public var armorBoost_:int = 0;
    public var resistanceBoost_:int = 0;
    public var agilityBoost_:int = 0;
    public var staminaBoost_:int = 0;
    public var intelligenceBoost_:int = 0;
    public var dexterityBoost_:int = 0;
    public var xpBoost_:int = 0;
    public var healthStackCount_:int = 0;
    public var magicStackCount_:int = 0;
    public var strengthMax_:int = 0;
    public var witMax_:int = 0;
    public var armorMax_:int = 0;
    public var resistanceMax_:int = 0;
    public var agilityMax_:int = 0;
    public var dexterityMax_:int = 0;
    public var staminaMax_:int = 0;
    public var intelligenceMax_:int = 0;
    public var maxHPMax_:int = 0;
    public var maxMPMax_:int = 0;
    public var hasBackpack_:Boolean = false;
    public var rank_:int = 0;
    public var shield_:int = 0;
    public var shieldBoost_:int = 0;
    public var shieldPointsMax_:int = 0;
    public var shieldPoints_:int = 0;
    public var shieldMax_:int = 0;
    public var admin_:Boolean = false;
    public var starred_:Boolean = false;
    public var ignored_:Boolean = false;
    public var distSqFromThisPlayer_:Number = 0;
    protected var moveMultiplier_:Number = 1;
    public var attackPeriod_:int = 0;
    public var nextAltAttack_:int = 0;
    public var lastAltAttack_:int = 0;
    public var nextAltAttack2_:int = 0;
    public var lastAltAttack2_:int = 0;
    public var flamePillarReset_:int = 0;
    public var nextTeleportAt_:int = 0;
    public var dropBoost:int = 0;
    public var tierBoost:int = 0;
    public var commune:GameObject;
    protected var healingEffect_:HealingEffect = null;
    protected var unstoppableEffect_:UnstoppableEffect = null;
    protected var nearestMerchant_:Merchant = null;
    public var isDefaultAnimatedChar:Boolean = true;
    public var projectileIdSetOverrideNew:String = "";
    public var projectileIdSetOverrideOld:String = "";
    private var factory:CharacterFactory;
    private var ip_:IntPoint;
    private var breathBackFill_:GraphicsSolidFill = null;
    private var breathBackPath_:GraphicsPath = null;
    private var breathFill_:GraphicsSolidFill = null;
    private var breathPath_:GraphicsPath = null;
    private var hallucinatingMaskedImage_:MaskedImage = null;
    private var mpBarBackFill_:GraphicsSolidFill = null;
    private var mpBarBackPath_:GraphicsPath = null;
    private var mpBarFill_:GraphicsSolidFill = null;
    private var mpBarPath_:GraphicsPath = null;
    public var light_:int = -1;
    public var lightMax_:int = -1;
    private var lightBackFill_:GraphicsSolidFill = null;
    private var lightBackPath_:GraphicsPath = null;
    private var lightFill_:GraphicsSolidFill = null;
    private var lightPath_:GraphicsPath = null;
    public var _lastHitQuest:int = -1;
    public var haste_:int = -1;
    public var hasteBoost_:int = -1;
    public var tenacity_:int = -1;
    public var tenacityBoost_:int = -1;
    public var criticalStrike_:int = -1;
    public var criticalStrikeBoost_:int = -1;
    public var luck_:int = -1;
    public var luckBonus_:int = -1;
    public var lifeSteal_:int = -1;
    public var lifeStealBoost_:int = -1;
    public var manaLeech_:int = -1;
    public var manaLeechBoost_:int = -1;
    public var manaLeechKill_:int = -1;
    public var manaLeechKillBoost_:int = -1;
    public var lifeStealKill_:int = -1;
    public var lifeStealKillBoost_:int = -1;
    public var offensiveAbility_:int = 0;
    public var defensiveAbility_:int = 0;
    public var flamePillarState_:int = 0;
    public var overrideProjDescTemp:ProjectileProperties;
    public var overrideProjDesc:ProjectileProperties;

    public function Player(_arg1:XML) {
        this.ip_ = new IntPoint();
        this.factory = Global.characterFactory;
        super(_arg1);
        this.strengthMax_ = int(_arg1.Strength.@max);
        this.witMax_ = int(_arg1.Wit.@max);
        this.armorMax_ = int(_arg1.Armor.@max);
        this.resistanceMax_ = int(_arg1.Resistance.@max);
        this.agilityMax_ = int(_arg1.Agility.@max);
        this.dexterityMax_ = int(_arg1.Dexterity.@max);
        this.staminaMax_ = int(_arg1.Stamina.@max);
        this.intelligenceMax_ = int(_arg1.Intelligence.@max);
        this.maxHPMax_ = int(_arg1.MaxHitPoints.@max);
        this.maxMPMax_ = int(_arg1.MaxMagicPoints.@max);
        texturingCache_ = new Dictionary();
    }

    public static function fromPlayerXML(_arg1:String, xml:XML):Player {
        var _local3:int = int(xml.ObjectType);
        var _local4:XML = ObjectLibrary.xmlLibrary_[_local3];
        var player:Player = new Player(_local4);
        player.name_ = _arg1;
        player.level_ = int(xml.Level);
        player.exp_ = int(xml.Exp);
        player.equipment_ = ConversionUtil.itemDataFromBase64(xml.Equipment);
        player.lockedSlot = new Vector.<int>(player.equipment_.length);
        player.maxHP_ = int(xml.MaxHitPoints);
        player.hp_ = int(xml.HitPoints);
        player.maxMP_ = int(xml.MaxMagicPoints);
        player.mp_ = int(xml.MagicPoints);
        player.strength_ = int(xml.Strength);
        player.wit_ = int(xml.Wit);
        player.armor_ = int(xml.Armor);
        player.resistance_ = int(xml.Resistance);
        player.agility_ = int(xml.Agility);
        player.dexterity_ = int(xml.Dexterity);
        player.stamina_ = int(xml.Stamina);
        player.intelligence_ = int(xml.Intelligence);
        player.tex1Id_ = int(xml.Tex1);
        player.tex2Id_ = int(xml.Tex2);
        return (player);
    }

    public function setRelativeMovement(angle:Number, x:Number, y:Number):void {
        var controlled:GameObject = commune != null && !(commune is Player) ? commune : this;
        var _local4:Number;
        if (controlled.movDir == null)
            controlled.movDir = new Point();
        controlled.rotateDir = angle;
        controlled.movDir.x = x;
        controlled.movDir.y = y;
        if (isConfused()) {
            _local4 = controlled.movDir.x;
            controlled.rotateDir = -(controlled.rotateDir);
            controlled.movDir.x = -(controlled.movDir.y);
            controlled.movDir.y = -(_local4);
        }
    }

    public function setCredits(_arg1:int):void {
        this.credits_ = _arg1;
    }

    public function setTokens(_arg1:int):void {
        this.tokens_ = _arg1;
    }

    public function setUnholyEssence(_arg1:int):void {
        this.unholyEssence_ = _arg1;
    }

    public function setDivineEssence(_arg1:int):void {
        this.divineEssence_ = _arg1;
    }

    public function setGuildName(_arg1:String):void {
        var _local3:GameObject;
        var _local4:Player;
        var _local5:Boolean;
        this.guildName_ = _arg1;
        var _local2:Player = map_.player_;
        if (_local2 == this) {
            for each (_local3 in map_.goDict_) {
                _local4 = (_local3 as Player);
                if (((!((_local4 == null))) && (!((_local4 == this))))) {
                    _local4.setGuildName(_local4.guildName_);
                }
            }
        }
        else {
            _local5 = ((((((!((_local2 == null))) && (!((_local2.guildName_ == null))))) && (!((_local2.guildName_ == ""))))) && ((_local2.guildName_ == this.guildName_)));
            if (_local5 != this.isFellowGuild_) {
                this.isFellowGuild_ = _local5;
                nameBitmapData_ = null;
            }
        }
    }

    public function isTeleportEligible(_arg1:Player):Boolean {
        return (!(((_arg1.isPaused()) || (_arg1.isInvisible()))));
    }

    public function msUtilTeleport():int {
        var _local1:int = getTimer();
        return (Math.max(0, (this.nextTeleportAt_ - _local1)));
    }

    public function teleportTo(_arg1:Player):Boolean {
        if (isPaused()) {
            Global.addTextLine(this.makeErrorMessage("Can not teleport while paused"));
            return (false);
        }
        var _local2:int = this.msUtilTeleport();
        if (_local2 > 0) {
            Global.addTextLine(this.makeErrorMessage("You can not teleport for another {seconds} seconds.", {"seconds": int(((_local2 / 1000) + 1))}));
            return (false);
        }
        if (!this.isTeleportEligible(_arg1)) {
            if (_arg1.isInvisible()) {
                Global.addTextLine(this.makeErrorMessage("Can not teleport to {player} while they are invisible", {"player": _arg1.name_}));
            }
            else {
                Global.addTextLine(this.makeErrorMessage("Can not teleport to {player}", {"player": _arg1.name_}));
            }
            return (false);
        }
        map_.gs_.gsc_.teleport(_arg1.objectId_);
        this.nextTeleportAt_ = (getTimer() + MS_BETWEEN_TELEPORT);
        return (true);
    }

    private function makeErrorMessage(_arg1:String, _arg2:Object = null):ChatMessage {
        return (ChatMessage.make(Parameters.ERROR_CHAT_NAME, _arg1, -1, -1, "", false, _arg2));
    }


    public function levelUpEffect(text:String, showEff:Boolean = true):void {
        if (showEff && !Parameters.data_.noParticlesMaster) {
            this.levelUpParticleEffect();
        }
        var status:CharacterStatusText = new CharacterStatusText(this, 65280, 2000);
        status.setStringBuilder(new LineBuilder().setParams(text));
        map_.mapOverlay_.addStatusText(status);
    }

    public function handleLevelUp(_arg1:Boolean):void {
        SoundEffectLibrary.play("level_up");
        if (_arg1) {
            this.levelUpEffect("New Class Unlocked!", false);
            this.levelUpEffect("Level Up!");
        }
        else {
            this.levelUpEffect("Level Up!");
        }
        map_.gs_.hud._equippedGrid.updateLevelReqIconVisibility(this);
        map_.gs_.hud.tabStrip.InventoryTab.inv.updateLevelReqIconVisibility(this);
        if (map_.gs_.hud.tabStrip.BackpackTab != null)
            map_.gs_.hud.tabStrip.BackpackTab.inv.updateLevelReqIconVisibility(this);
    }

    public function levelUpParticleEffect(_arg1:uint = 0xFF00FF00):void {
        map_.addObj(new LevelUpEffect(this, _arg1, 20), x_, y_);
    }

    public function handleExpUp(_arg1:int):void {
        if (level_ == 300) {
            return;
        }
        var _local2:CharacterStatusText = new CharacterStatusText(this, 0xFF00, 1000);
        _local2.setStringBuilder(new LineBuilder().setParams("+{exp} EXP", {"exp": _arg1}));
        map_.mapOverlay_.addStatusText(_local2);
    }

    private function getNearbyMerchant():Merchant {
        var _local3:Point;
        var _local4:Merchant;
        var _local1:int = ((((x_ - int(x_))) > 0.5) ? 1 : -1);
        var _local2:int = ((((y_ - int(y_))) > 0.5) ? 1 : -1);
        for each (_local3 in NEARBY) {
            this.ip_.x_ = (x_ + (_local1 * _local3.x));
            this.ip_.y_ = (y_ + (_local2 * _local3.y));
            _local4 = map_.merchLookup_[this.ip_];
            if (_local4 != null) {
                return ((((PointUtil.distanceSquaredXY(_local4.x_, _local4.y_, x_, y_) < 1)) ? _local4 : null));
            }
        }
        return (null);
    }

    override public function moveTo(_arg1:Number, _arg2:Number):Boolean {
        var _local3:Boolean = super.moveTo(_arg1, _arg2);
        if (map_.gs_.evalIsNotInCombatMapArea()) {
            this.nearestMerchant_ = this.getNearbyMerchant();
        }
        return (_local3);
    }

    private function resetMoveVector(_arg1:Boolean):void {
        moveVec_.scaleBy(-0.5);
        if (_arg1) {
            moveVec_.y = (moveVec_.y * -1);
        }
        else {
            moveVec_.x = (moveVec_.x * -1);
        }
    }

    override public function update(currentTime:int, deltaMS:int):Boolean {
        if (this.tierBoost && !isPaused()) {
            this.tierBoost = this.tierBoost - deltaMS;
            if (this.tierBoost < 0) {
                this.tierBoost = 0;
            }
        }
        if (this.dropBoost && !isPaused()) {
            this.dropBoost = this.dropBoost - deltaMS;
            if (this.dropBoost < 0) {
                this.dropBoost = 0;
            }
        }
        if (this.xpTimer && !isPaused()) {
            this.xpTimer = this.xpTimer - deltaMS;
            if (this.xpTimer < 0) {
                this.xpTimer = 0;
            }
        }

        if (isRenewed() && !isPaused()
                && this.healingEffect_ == null
                && !Parameters.data_.noParticlesMaster) {
            this.healingEffect_ = new HealingEffect(this);
            map_.addObj(this.healingEffect_, x_, y_);
        }
        else {
            if (this.healingEffect_ != null) {
                map_.removeObj(this.healingEffect_.objectId_);
                this.healingEffect_ = null;
            }
        }

        if (isUnstoppable() && !isPaused()
                && this.unstoppableEffect_ == null
                && !Parameters.data_.noParticlesMaster) {
            this.unstoppableEffect_ = new UnstoppableEffect(this);
            map_.addObj(this.unstoppableEffect_, x_, y_);
        }
        else {
            if (this.unstoppableEffect_ != null) {
                map_.removeObj(this.unstoppableEffect_.objectId_);
                this.unstoppableEffect_ = null;
            }
        }

        var controlled:GameObject = commune != null && !(commune is Player) ? commune : this;
        var angle:Number = Parameters.data_.cameraAngle;
        if (controlled.rotateDir != 0) {
            angle = angle + deltaMS * Parameters.PLAYER_ROTATE_SPEED * controlled.rotateDir;
            Parameters.data_.cameraAngle = angle;
        }

        if (map_.player_ == this && isPaused() && (this.commune == null || this.commune is Player))
            return true;

        if (controlled.movDir != null) {
            controlled.collisionBlockMove(deltaMS, getMoveSpeed());
        }

        else if (!super.update(currentTime, deltaMS))
            return false;

        if (map_.player_ == this && isPaused())
            return true;

        return true;
    }

    public function onMove():void {
        if (map_ == null) {
            return;
        }
        var _local1:Square = map_.getSquare(x_, y_);
        if (_local1.props_.sinking_) {
            sinkLevel_ = Math.min((sinkLevel_ + 1), Parameters.MAX_SINK_LEVEL);
            this.moveMultiplier_ = (0.1 + ((1 - (sinkLevel_ / Parameters.MAX_SINK_LEVEL)) * (_local1.props_.speed_ - 0.1)));
        }
        else {
            sinkLevel_ = 0;
            this.moveMultiplier_ = _local1.props_.speed_;
        }
    }

    override protected function makeNameBitmapData():BitmapData {
        var _local1:StringBuilder = new StaticStringBuilder(name_);
        var _local2:BitmapTextFactory = Global.bitmapTextFactory;
        var _local3:BitmapData = _local2.make(_local1, 16, this.getNameColor(), true, NAME_OFFSET_MATRIX, true);
        _local3.draw(FameUtil.numStarsToIcon(this.numStars_, this.admin_), RANK_OFFSET_MATRIX);
        return (_local3);
    }

    private function getNameColor():uint {
        if (this.isFellowGuild_) {
            return (Parameters.FELLOW_GUILD_COLOR);
        }
        if (this.nameChosen_) {
            return (Parameters.NAME_CHOSEN_COLOR);
        }
        return (0xFFFFFF);
    }

    protected function drawBreathBar(_arg1:Vector.<IGraphicsData>, _arg2:int, split:Boolean):void {
        var _local8:Number;
        var _local9:Number;
        if (this.breathPath_ == null) {
            this.breathBackFill_ = new GraphicsSolidFill();
            this.breathBackPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
            this.breathFill_ = new GraphicsSolidFill(2542335);
            this.breathPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        }
        if (this.breath_ <= Parameters.BREATH_THRESH) {
            _local8 = ((Parameters.BREATH_THRESH - this.breath_) / Parameters.BREATH_THRESH);
            this.breathBackFill_.color = MoreColorUtil.lerpColor(0x111111, 0xFF0000, (Math.abs(Math.sin((_arg2 / 300))) * _local8));
        } else {
            this.breathBackFill_.color = 0x111111;
        }
        var w:int = split ? 10 : 20;
        var y:int = 6;
        if (Parameters.data_.HPBar)
            y = 18;
        var h:int = 4;
        var moveX:int = split ? 10 : 0;
        var _local6:Vector.<Number> = (this.breathBackPath_.data as Vector.<Number>);
        _local6.length = 0;
        var _local7:Number = 1.2;
        _local6.push(
                ((posS_[0] - w)) + moveX,
                ((posS_[1] + y) - _local7),
                ((posS_[0] + w) + _local7) + moveX,
                ((posS_[1] + y) - _local7),
                ((posS_[0] + w) + _local7) + moveX,
                (((posS_[1] + y) + h) + _local7),
                ((posS_[0] - w)) + moveX,
                (((posS_[1] + y) + h) + _local7));
        _arg1.push(this.breathBackFill_);
        _arg1.push(this.breathBackPath_);
        _arg1.push(GraphicsUtil.END_FILL);
        if (this.breath_ > 0) {
            _local9 = (((this.breath_ / 100) * 2) * w);
            this.breathPath_.data.length = 0;
            _local6 = (this.breathPath_.data as Vector.<Number>);
            _local6.length = 0;
            _local6.push(
                    (posS_[0] - w) + moveX,
                    (posS_[1] + y),
                    ((posS_[0] - w) + _local9) + moveX,
                    (posS_[1] + y),
                    ((posS_[0] - w) + _local9) + moveX,
                    ((posS_[1] + y) + h),
                    (posS_[0] - w) + moveX,
                    ((posS_[1] + y) + h));
            _arg1.push(this.breathFill_);
            _arg1.push(this.breathPath_);
            _arg1.push(GraphicsUtil.END_FILL);
        }
        GraphicsFillExtra.setSoftwareDrawSolid(this.breathFill_, true);
        GraphicsFillExtra.setSoftwareDrawSolid(this.breathBackFill_, true);
    }

    protected function drawMpBar(_arg1:Vector.<IGraphicsData>, _arg2:int):void {
        var _local9:Number;
        if (this.mpBarPath_ == null) {
            this.mpBarBackFill_ = new GraphicsSolidFill();
            this.mpBarBackPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
            this.mpBarFill_ = new GraphicsSolidFill(0x9000ff);
            this.mpBarPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        }
        var maxMp:int = this.maxMP_;
        if (this.mp_ > maxMp)
        {
            maxMp = this.mp_;
        }
        this.mpBarBackFill_.color = 0x111111;
        var w:int = 20;
        var y:int = 12;
        var h:int = 4;
        var _local6:Vector.<Number> = (this.mpBarBackPath_.data as Vector.<Number>);
        _local6.length = 0;
        var _local7:Number = 1.2;
        _local6.push(
                ((posS_[0] - w) - _local7),
                ((posS_[1] + y) - _local7),
                ((posS_[0] + w) + _local7),
                ((posS_[1] + y) - _local7),
                ((posS_[0] + w) + _local7),
                (((posS_[1] + y) + h) + _local7),
                ((posS_[0] - w) - _local7),
                (((posS_[1] + y) + h) + _local7));
        _arg1.push(this.mpBarBackFill_);
        _arg1.push(this.mpBarBackPath_);
        _arg1.push(GraphicsUtil.END_FILL);
        if (this.mp_ > 0) {
            _local9 = (((this.mp_ / maxMp) * 2) * w);
            this.mpBarPath_.data.length = 0;
            _local6 = (this.mpBarPath_.data as Vector.<Number>);
            _local6.length = 0;
            _local6.push(
                    (posS_[0] - w),
                    (posS_[1] + y),
                    ((posS_[0] - w) + _local9),
                    (posS_[1] + y),
                    ((posS_[0] - w) + _local9),
                    ((posS_[1] + y) + h),
                    (posS_[0] - w),
                    ((posS_[1] + y) + h));
            _arg1.push(this.mpBarFill_);
            _arg1.push(this.mpBarPath_);
            _arg1.push(GraphicsUtil.END_FILL);
        }
        GraphicsFillExtra.setSoftwareDrawSolid(this.mpBarFill_, true);
        GraphicsFillExtra.setSoftwareDrawSolid(this.mpBarBackFill_, true);
    }

    protected function drawLightBar(_arg1:Vector.<IGraphicsData>, _arg2:int, split:Boolean):void {
        var _local9:Number;
        if (this.lightPath_ == null) {
            this.lightBackFill_ = new GraphicsSolidFill();
            this.lightBackPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
            this.lightFill_ = new GraphicsSolidFill(0xFFFFD9);
            this.lightPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        }
        this.lightBackFill_.color = 0x111111;
        var w:int = split ? 10 : 20;
        var y:int = 18;
        var h:int = 4;
        var moveX:int = split ? 10 : 0;
        var _local6:Vector.<Number> = (this.lightBackPath_.data as Vector.<Number>);
        _local6.length = 0;
        var _local7:Number = 1.2;
        _local6.push(
                ((posS_[0] - w) - _local7) - moveX,
                ((posS_[1] + y) - _local7),
                ((posS_[0] + w) + _local7) - moveX,
                ((posS_[1] + y) - _local7),
                ((posS_[0] + w) + _local7) - moveX,
                (((posS_[1] + y) + h) + _local7),
                ((posS_[0] - w) - _local7) - moveX,
                (((posS_[1] + y) + h) + _local7));
        _arg1.push(this.lightBackFill_);
        _arg1.push(this.lightBackPath_);
        _arg1.push(GraphicsUtil.END_FILL);
        if (this.light_ > 0) {
            if (this.light_ > this.lightMax_)
                _local9 = ((1 * 2) * w);
            else
                _local9 = (((this.light_ / this.lightMax_) * 2) * w);
            this.lightPath_.data.length = 0;
            _local6 = (this.lightPath_.data as Vector.<Number>);
            _local6.length = 0;
            _local6.push(
                    (posS_[0] - w) - moveX,
                    (posS_[1] + y),
                    ((posS_[0] - w) + _local9) - moveX,
                    (posS_[1] + y),
                    ((posS_[0] - w) + _local9) - moveX,
                    ((posS_[1] + y) + h),
                    (posS_[0] - w) - moveX,
                    ((posS_[1] + y) + h));
            _arg1.push(this.lightFill_);
            _arg1.push(this.lightPath_);
            _arg1.push(GraphicsUtil.END_FILL);
        }
        GraphicsFillExtra.setSoftwareDrawSolid(this.lightFill_, true);
        GraphicsFillExtra.setSoftwareDrawSolid(this.lightBackFill_, true);
    }

    override public function draw(_arg1:Vector.<IGraphicsData>, _arg2:Camera, _arg3:int):void
    {
        super.draw(_arg1, _arg2, _arg3);
        if (this != map_.player_)
        {
            if (!Parameters.screenShotMode_)
            {
                drawName(_arg1, _arg2);
            }
        }
        else
        {
            if (this.breath_ >= 0 && this.lightMax_ <= 0)
            {
                this.drawBreathBar(_arg1, _arg3, false);
            }
            if (Parameters.data_.HPBar)
            {
                this.drawMpBar(_arg1, _arg3);
                if (this.lightMax_ > 0 && this.breath_ < 0)
                {
                    this.drawLightBar(_arg1, _arg3, false);
                }
                if (this.lightMax_ > 0 && this.breath_ >= 0)
                {
                    this.drawLightBar(_arg1, _arg3, true);
                    this.drawBreathBar(_arg1, _arg3, true);
                }
            }
        }
    }

    private function getMoveSpeed():Number {
        var controlled:GameObject = commune != null && !(commune is Player) ? commune : this;
        if (controlled.isSlow())
            return MIN_MOVE_SPEED * this.moveMultiplier_;

        var agility:int = this.agility_ <= 384 ? this.agility_ : 384;
        var moveSpeed:Number = MIN_MOVE_SPEED + agility / 75 * (MAX_MOVE_SPEED - MIN_MOVE_SPEED);
        if (controlled.isSwift() || controlled.isNinjaSpeedy())
            moveSpeed = (moveSpeed * 1.5);

        return moveSpeed * this.moveMultiplier_;
    }

    public function attackFrequency():Number {
        if (isCrippled()) {
            return (MIN_ATTACK_FREQ);
        }

        var dexterity:int = this.dexterity_ <= 384 ? this.dexterity_ : 384;
        var _local1:Number = (MIN_ATTACK_FREQ + ((dexterity / 75) * (MAX_ATTACK_FREQ - MIN_ATTACK_FREQ)));
        if (isBerserk()) {
            _local1 = (_local1 * 1.5);
        }
        return (_local1);
    }

    private function attackMultiplier(proj:Projectile):Number {
        if (isWeak()) {
            return (MIN_ATTACK_MULT);
        }

        var isMagic:Boolean;
        switch (proj.damageType_)
        {
            case DamageTypes.Magical:
            case DamageTypes.Water:
            case DamageTypes.Fire:
            case DamageTypes.Holy:
                isMagic = true;
                break;
        }
        var power:int = isMagic ? this.wit_ <= 384 ? this.wit_ : 384 : this.strength_ <= 384 ? this.strength_ : 384;
        var _local1:Number = (MIN_ATTACK_MULT + ((power / 75) * (MAX_ATTACK_MULT - MIN_ATTACK_MULT)));
        if (isBrave()) {
            _local1 = (_local1 * 1.5);
        }
        return (_local1);
    }

    private function makeSkinTexture():void {
        var _local1:MaskedImage = this.skin.imageFromAngle(0, AnimatedChar.STAND, 0);
        animatedChar_ = this.skin;
        texture_ = _local1.image_;
        mask_ = _local1.mask_;
        this.isDefaultAnimatedChar = true;
    }

    private function setToRandomAnimatedCharacter():void {
        var _local1:Vector.<XML> = ObjectLibrary.hexTransforms_;
        var _local2:uint = Math.floor((Math.random() * _local1.length));
        var _local3:int = _local1[_local2].@type;
        var _local4:TextureData = ObjectLibrary.typeToTextureData_[_local3];
        texture_ = _local4.texture_;
        mask_ = _local4.mask_;
        animatedChar_ = _local4.animatedChar_;
        this.isDefaultAnimatedChar = false;
    }

    override protected function getTexture(camera:Camera, currentTime:int):BitmapData {
        var pos:Number = 0;
        var action:int = AnimatedChar.STAND;

        if (this.flamePillarReset_ < currentTime)
        {
            this.flamePillarState_ = 0;
        }

        if ((this.isShooting || currentTime < (attackStart_ + this.attackPeriod_)) && !(isPaused())) {
            facing_ = attackAngle_;
            pos = ((currentTime - attackStart_) % this.attackPeriod_) / this.attackPeriod_;
            action = AnimatedChar.ATTACK;
        }
        else {
            if (moveVec_.x != 0 || moveVec_.y != 0) {
                var movPeriod:int = 3.5 / this.getMoveSpeed();
                if (moveVec_.y != 0 || moveVec_.x != 0) {
                    facing_ = Math.atan2(moveVec_.y, moveVec_.x);
                }
                pos = (currentTime % movPeriod) / movPeriod;
                action = AnimatedChar.WALK;
            }
        }

        if (this.isHexed()) {
            this.isDefaultAnimatedChar && this.setToRandomAnimatedCharacter();
        }
        else {
            if (!this.isDefaultAnimatedChar) {
                this.makeSkinTexture();
            }
        }

        var maskImg:MaskedImage;
        if (camera.isHallucinating_) {
            maskImg = getHallucinatingMaskedImage();
        }
        else {
            maskImg = animatedChar_.imageFromFacing(facing_, camera, action, pos);
        }

        var tex1Id:int = tex1Id_;
        var tex2Id:int = tex2Id_;
        var tex:BitmapData;
        if (this.nearestMerchant_) {
            var merchDict:Dictionary = texturingCache_[this.nearestMerchant_];
            if (merchDict == null) {
                texturingCache_[this.nearestMerchant_] = new Dictionary();
            }
            else {
                tex = merchDict[maskImg];
            }
            tex1Id = this.nearestMerchant_.getTex1Id(tex1Id_);
            tex2Id = this.nearestMerchant_.getTex2Id(tex2Id_);
        }
        else {
            tex = texturingCache_[maskImg];
        }
        if (tex == null) {
            tex = TextureRedrawer.resize(maskImg.image_, maskImg.mask_, size_, false, tex1Id, tex2Id);
            if (this.nearestMerchant_ != null) {
                texturingCache_[this.nearestMerchant_][maskImg] = tex;
            }
            else {
                texturingCache_[maskImg] = tex;
            }
        }

        if (hp_ < maxHP_ * 0.2) {
            var intensity:Number = int(Math.abs(Math.sin(currentTime / 200)) * 10) / 10;
            var ct:* = lowHealthCT[intensity];
            if (ct == null) {
                ct = new ColorTransform(1, 1, 1, 1,
                        intensity * LOW_HEALTH_CT_OFFSET,
                        -intensity * LOW_HEALTH_CT_OFFSET,
                        -intensity * LOW_HEALTH_CT_OFFSET);
                lowHealthCT[intensity] = ct;
            }
            tex = CachingColorTransformer.transformBitmapData(tex, ct);
        }

        var plrTex:BitmapData = texturingCache_[tex];
        if (plrTex == null) {
            plrTex = GlowRedrawer.outline(tex, this.glowColor_);
            texturingCache_[tex] = plrTex;
        }
        if (isPaused() || isStasis() || isPetrified()) {
            plrTex = CachingColorTransformer.filterBitmapData(plrTex, PAUSED_FILTER);
        }
        else {
            if (isInvisible()) {
                plrTex = CachingColorTransformer.alphaBitmapData(plrTex, 40);
            }
        }
        return plrTex;
    }

    private function getHallucinatingMaskedImage():MaskedImage {
        if (hallucinatingMaskedImage_ == null) {
            hallucinatingMaskedImage_ = new MaskedImage(getHallucinatingTexture(), null);
        }
        return hallucinatingMaskedImage_;
    }

    override public function getPortrait(mult:int = 100, flip:Boolean = false):BitmapData {
        var maskedImg:MaskedImage;
        var size:int;
        if (portrait_ == null) {
            maskedImg = animatedChar_.imageFromDir(AnimatedChar.RIGHT, AnimatedChar.STAND, 0);
            if (flip)
                maskedImg.image_ = BitmapUtil.flipBitmapData(maskedImg.image_);
            size = ((4 / maskedImg.image_.width) * mult);
            portrait_ = TextureRedrawer.resize(maskedImg.image_, maskedImg.mask_, size, true, tex1Id_, tex2Id_);
            portrait_ = GlowRedrawer.outline(portrait_, 0);
        }
        return (portrait_);
    }

    public function useAltWeapon(_arg1:Number, _arg2:Number, useType:int, activateId:int = 1):Boolean {
        var xml:XML;
        var time:int;
        var angle:Number;
        var cost:int;
        var cooldown:int;
        if ((((map_ == null)) || (isPaused()))) {
            return (false);
        }
        var _local4:int = equipment_[2].ObjectType;
        if (_local4 == -1) {
            return (false);
        }
        var item:XML = ObjectLibrary.xmlLibrary_[_local4];
        if ((((item == null)) || (!(item.hasOwnProperty("Usable"))))) {
            return (false);
        }
        var _local6:Point = map_.pSTopW(_arg1, _arg2);
        if (_local6 == null) {
            SoundEffectLibrary.play("error");
            return (false);
        }
        for each (xml in item.Activate) {
            if (xml.toString() == ActivationType.TELEPORT) {
                if (!this.isValidPosition(_local6.x, _local6.y)) {
                    SoundEffectLibrary.play("error");
                    return (false);
                }
            }
        }
        time = getTimer();
        if (useType == UseType.START_USE) {
            if ((time < this.nextAltAttack_ && activateId == 1) ||
                    (time < this.nextAltAttack2_ && activateId == 2) || this.isSuppressed()) {
                SoundEffectLibrary.play("error");
                return false;
            }
            cost = int(item.MpCost);
            if (cost + this.flamePillarState_ * 20 > this.mp_ && activateId == 1) {
                SoundEffectLibrary.play("no_mana");
                return false;
            }
            cost = int(item.MpCost2);
            if (cost > this.mp_ && activateId == 2) {
                SoundEffectLibrary.play("no_mana");
                return false;
            }
            cost = int(item.LightCost);
            if (cost > this.light_ && activateId == 1 && cost > 0) {
                SoundEffectLibrary.play("no_mana");
                return false;
            }
            cost = int(item.HpCost);
            if (cost > this.hp_ && activateId == 1 && cost > 0) {
                SoundEffectLibrary.play("no_mana"); // lol
                return false;
            }
            cooldown = 500;
            if (item.hasOwnProperty("Cooldown"))
            {
                var cd:Number = item.Cooldown != null ? Number(item.Cooldown) : 0.5;
                var haste:int = ((this != null) ? this.haste_ : 0);
                var hasteModCd:Number = cd * (100 / (100 + haste));
                cooldown = hasteModCd * 1000;
            }
            if (activateId == 1)
            {
                this.nextAltAttack_ = time + cooldown;
                this.lastAltAttack_ = time;
            }
            cooldown = 500;
            if (item.hasOwnProperty("Cooldown2"))
            {
                cd = item.Cooldown2 != null ? Number(item.Cooldown2) : 0.5;
                haste = ((this != null) ? this.haste_ : 0);
                hasteModCd = cd * (100 / (100 + haste));
                cooldown = hasteModCd * 1000;
            }
            if (activateId == 2)
            {
                this.nextAltAttack2_ = time + cooldown;
                this.lastAltAttack2_ = time;
            }

            var activateTags:XMLList = item.Activate2;
            if (activateId == 2 && activateTags.length() != 0 || activateId == 1) {
                if (item.Power == "Pillar of Flame")
                {
                    this.flamePillarReset_ = this.nextAltAttack_ + cd * 1000;
                    if (this.flamePillarState_ < 3)
                    {
                        this.flamePillarState_++;
                    }
                }
            }

            map_.gs_.gsc_.useItem(time, objectId_, 2, _local4, _local6.x, _local6.y, activateId);
            angle = Math.atan2(_arg2, _arg1);
            if (item.Activate == ActivationType.SHOOT && activateId == 1) {
                this.doShoot(time, _local4, item, (Parameters.data_.cameraAngle + angle), false);
            }
            if (item.Activate2 == ActivationType.SHOOT && activateId == 2) {
                this.doShoot(time, _local4, item, (Parameters.data_.cameraAngle + angle), false);
            }
        }
        else {
            if (item.hasOwnProperty("MultiPhase") && activateId == 1 ||
                item.hasOwnProperty("MultiPhase2") && activateId == 2) { // we'll see...
                map_.gs_.gsc_.useItem(time, objectId_, 2, _local4, _local6.x, _local6.y, activateId);
                angle = Math.atan2(_arg2, _arg1);
                if (int(item.MpEndCost) <= this.mp_ && activateId == 1 && int(item.LightEndCost) <= 0) {
                    this.doShoot(time, _local4, item, (Parameters.data_.cameraAngle + angle), false);
                }
                else if (int(item.MpEndCost2) <= this.mp_ && activateId == 2) {
                    this.doShoot(time, _local4, item, (Parameters.data_.cameraAngle + angle), false);
                }
                else if (int(item.LightEndCost) <= this.light_ && activateId == 1) {
                    this.doShoot(time, _local4, item, (Parameters.data_.cameraAngle + angle), false);
                }
            }
        }
        return true;
    }

    public function useOffensiveAbility(targetX:Number, targetY:Number):Boolean {
        if (map_ == null || isPaused()) {
            return false;
        }
        var target:Point = map_.pSTopW(targetX, targetY);
        if (target == null) {
            SoundEffectLibrary.play("error");
            return false;
        }
        var shootAngle:Number = Math.atan2(targetY, targetX);
        map_.gs_.gsc_.useOffensiveAbility(getTimer(), target.x, target.y, Parameters.data_.cameraAngle + shootAngle);
        return true;
    }

    public function useDefensiveAbility(targetX:Number, targetY:Number):Boolean {
        if (map_ == null || isPaused()) {
            return false;
        }
        var target:Point = map_.pSTopW(targetX, targetY);
        if (target == null) {
            SoundEffectLibrary.play("error");
            return false;
        }
        var shootAngle:Number = Math.atan2(targetY, targetX);
        map_.gs_.gsc_.useDefensiveAbility(getTimer(), target.x, target.y, Parameters.data_.cameraAngle + shootAngle);
        return true;
    }

    public function attemptAttackAngle(_arg1:Number):void {
        this.shoot((Parameters.data_.cameraAngle + _arg1));
    }

    override public function setAttack(_arg1:int, _arg2:Number):void {
        var _local3:XML = ObjectLibrary.xmlLibrary_[_arg1];
        if ((((_local3 == null)) || (!(_local3.hasOwnProperty("RateOfFire"))))) {
            return;
        }
        var _local4:Number = Number(_local3.RateOfFire);
        this.attackPeriod_ = ((1 / this.attackFrequency()) * (1 / _local4));
        super.setAttack(_arg1, _arg2);
    }

    private function shoot(angle:Number):void {
        if (map_ == null || isStunned() || isPaused() || isPetrified()) {
            return;
        }

        var weapType:int = equipment_[1].ObjectType;
        if (weapType == -1) {
            return;
        }

        var weapon:XML = ObjectLibrary.xmlLibrary_[weapType];
        var curTime:int = getTimer();
        var fireRate:Number = Number(weapon.RateOfFire);
        this.attackPeriod_ = (1 / this.attackFrequency()) * (1 / fireRate);
        if (curTime < attackStart_ + this.attackPeriod_) {
            return;
        }

        attackAngle_ = angle;
        attackStart_ = curTime;
        this.doShoot(attackStart_, weapType, weapon, attackAngle_, true);
    }

    private function doShoot(time:int, equipType:int, xml:XML, angle:Number, isWeapon:Boolean):void {
        var bulletId:uint;
        var proj:Projectile;
        var minDmg:int;
        var maxDmg:int;
        var attackMult:Number;
        var damage:int;
        this.isShooting = isWeapon;
        var i:int = 0;
        var objProps:ObjectProperties = ObjectLibrary.propsLibrary_[equipType];
        var tProj:ProjectileProperties = objProps.projectiles_[0];
        if (this.overrideProjDescTemp.key != 0) {
            overrideProjDesc = new ProjectileProperties(tProj.root).importFromProps(this.overrideProjDescTemp);
        }
        else {
            overrideProjDesc = null;
        }
        var numProjs:int = ((xml.hasOwnProperty("NumProjectiles")) ? int(xml.NumProjectiles) : 1);
        var arcGap:Number = xml.hasOwnProperty("ArcGap") ? Number(xml.ArcGap) : 11.25;
        tProj = this.overrideProjDesc;
        if (tProj != null) {
            numProjs = tProj.projCount_ > 0 ? tProj.projCount_ : numProjs + tProj.numProjectiles_;
            arcGap += tProj.arcGap_;
        }
        arcGap *= Trig.toRadians;
        var curGap:Number = (angle - ((arcGap * (numProjs - 1)) / 2));
        while (i < numProjs) {
            bulletId = getBulletId();
            proj = (FreeList.newObject(Projectile) as Projectile);
            if (((isWeapon) && (!((this.projectileIdSetOverrideNew == ""))))) {
                proj.reset(equipType, 0, objectId_, bulletId, i, curGap, time, this.projectileIdSetOverrideNew, this.projectileIdSetOverrideOld, overrideProjDesc, objProps);
            }
            else {
                proj.reset(equipType, 0, objectId_, bulletId, i, curGap, time, "", "", isWeapon ? overrideProjDesc : null, objProps);
            }
            minDmg = int(proj.projProps_.minDamage_);
            maxDmg = int(proj.projProps_.maxDamage_);
            var itemData:ItemData = this.equipment_[1];
            if (!isWeapon)
                itemData = this.equipment_[2];
            proj.damageType_ = proj.projProps_.damageType_;
            attackMult = isWeapon ? this.attackMultiplier(proj) : 1;
            damage = (minDmg == maxDmg ? minDmg : map_.gs_.gsc_.getNextInt(minDmg, maxDmg)) * attackMult;
            if (itemData && itemData.Quality > 0) {
                damage *= itemData.Quality;
            }
            if (time > (map_.gs_.moveRecords_.lastClearTime_ + 600) || isBlind()) {
                damage = 0;
            }
            if (map_.gs_.gsc_.getNextInt(0, 1000) < (1 + this.criticalStrike_) * 10)
            {
                var j:int = 0;
                while (j < 6)
                {
                    var item:XML = ObjectLibrary.xmlLibrary_[equipment_[i].ObjectType];
                    if (item && item.Power == "Rotting Touch")
                        damage += strength_ / 2;
                    j++;
                }

                damage += damage * 0.67;
                proj.isCrit_ = true;
            }
            proj.setDamage(damage);
            if ((((i == 0)) && (!((proj.sound_ == null))))) {
                SoundEffectLibrary.play(proj.sound_, 0.75, false);
            }
            map_.addObj(proj, (x_ + (Math.cos(angle) * 0.3)), (y_ + (Math.sin(angle) * 0.3)));
            map_.gs_.gsc_.playerShoot(time, proj, angle);
            curGap = (curGap + arcGap);
            i++;
        }
    }

    public function isHexed():Boolean {
        return (!(((condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.HEXED_BIT) == 0)));
    }

    public function isInventoryFull():Boolean {
        if (equipment_ == null) {
            return (false);
        }
        var _local1:int = equipment_.length;
        var _local2:uint = 4;
        while (_local2 < _local1) {
            if (equipment_[_local2].ObjectType <= 0) {
                return (false);
            }
            _local2++;
        }
        return (true);
    }

    public function nextAvailableInventorySlot():int {
        var _local1:int = ((this.hasBackpack_) ? equipment_.length : (equipment_.length - GeneralConstants.NUM_INVENTORY_SLOTS));
        var _local2:uint = 4;
        while (_local2 < _local1) {
            if (equipment_[_local2] && equipment_[_local2].ObjectType <= 0) {
                return (_local2);
            }
            _local2++;
        }
        return (-1);
    }
    public function swapInventoryIndex(_arg1:String):int {
        var _local2:int;
        var _local3:int;
        if (!this.hasBackpack_) {
            return (-1);
        }
        if (_arg1 == TabStripModel.BACKPACK) {
            _local2 = GeneralConstants.NUM_EQUIPMENT_SLOTS;
            _local3 = (GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS);
        }
        else {
            _local2 = (GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS);
            _local3 = equipment_.length;
        }
        var _local4:uint = _local2;
        while (_local4 < _local3) {
            if (equipment_[_local4] <= 0) {
                return (_local4);
            }
            _local4++;
        }
        return (-1);
    }

    public function getPotionCount(_arg1:int):int {
        switch (_arg1) {
            case PotionInventoryModel.HEALTH_POTION_ID:
                return (this.healthStackCount_);
            case PotionInventoryModel.MAGIC_POTION_ID:
                return (this.magicStackCount_);
        }
        return (0);
    }

    public function getTex1():int {
        return (tex1Id_);
    }

    public function getTex2():int {
        return (tex2Id_);
    }
}
}