package com.company.assembleegameclient.util {
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.PointUtil;

import flash.display.BitmapData;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.geom.Matrix;



public class ConditionEffect {

    public static const NOTHING:uint = 0;
    public static const DEAD:uint = 1;
    public static const STUPEFIED:uint = 2;
    public static const WEAK:uint = 3;
    public static const SLOW:uint = 4;
    public static const SICK:uint = 5;
    public static const CRIPPLED:uint = 6;
    public static const STUNNED:uint = 7;
    public static const BLIND:uint = 8;
    public static const HALLUCINATING:uint = 9;
    public static const DRUNK:uint = 10;
    public static const CONFUSED:uint = 11;
    public static const INVISIBLE:uint = 12;
    public static const PARALYZED:uint = 13;
    public static const SWIFT:uint = 14;
    public static const BLEEDING:uint = 15;
    public static const RENEWED:uint = 16;
    public static const BRAVE:uint = 17;
    public static const BERSERK:uint = 18;
    public static const PAUSED:uint = 19;
    public static const STASIS:uint = 20;
    public static const INVINCIBLE:uint = 21;
    public static const INVULNERABLE:uint = 22;
    public static const ARMORED:uint = 23;
    public static const UNARMORED:uint = 24;
    public static const HEXED:uint = 25;
    public static const NINJA_SPEEDY:uint = 26;
    public static const UNSTEADY:uint = 27;
    public static const UNSIGHTED:uint = 28;
    public static const PETRIFIED:uint = 29;
    public static const PET_EFFECT_ICON:uint = 30;
    public static const CURSE:uint = 31;
    public static const HP_BOOST:uint = 32;
    public static const MP_BOOST:uint = 34;
    public static const STR_BOOST:uint = 34;
    public static const ARM_BOOST:uint = 35;
    public static const AGL_BOOST:uint = 36;
    public static const DEX_BOOST:uint = 37;
    public static const STA_BOOST:uint = 38;
    public static const INT_BOOST:uint = 39;
    public static const HIDDEN:uint = 40;
    public static const MUTED:int = 41;
    public static const SHIELDED:int = 42;
    public static const SHIELD_BOOST:uint = 43;
    public static const ENLIGHTENED:int = 44;
    public static const SUPPRESSED:int = 45;
    public static const EXPOSED:int = 46;
    public static const STAGGERED:int = 47;
    public static const UNSTOPPABLE:int = 48;
    public static const TAUNTED:int = 49;
    public static const RESISTANCE_BOOST:uint = 50;
    public static const WIT_BOOST:uint = 51;
    public static const DEAD_BIT:uint = (1 << (DEAD - 1));
    public static const STUPEFIED_BIT:uint = (1 << (STUPEFIED - 1));
    public static const WEAK_BIT:uint = (1 << (WEAK - 1));
    public static const SLOW_BIT:uint = (1 << (SLOW - 1));
    public static const SICK_BIT:uint = (1 << (SICK - 1));
    public static const CRIPPLED_BIT:uint = (1 << (CRIPPLED - 1));
    public static const STUNNED_BIT:uint = (1 << (STUNNED - 1));
    public static const BLIND_BIT:uint = (1 << (BLIND - 1));
    public static const HALLUCINATING_BIT:uint = (1 << (HALLUCINATING - 1));
    public static const DRUNK_BIT:uint = (1 << (DRUNK - 1));
    public static const CONFUSED_BIT:uint = (1 << (CONFUSED - 1));
    public static const INVISIBLE_BIT:uint = (1 << (INVISIBLE - 1));
    public static const PARALYZED_BIT:uint = (1 << (PARALYZED - 1));
    public static const SWIFT_BIT:uint = (1 << (SWIFT - 1));
    public static const BLEEDING_BIT:uint = (1 << (BLEEDING - 1));
    public static const RENEWED_BIT:uint = (1 << (RENEWED - 1));
    public static const BRAVE_BIT:uint = (1 << (BRAVE - 1));
    public static const BERSERK_BIT:uint = (1 << (BERSERK - 1));
    public static const PAUSED_BIT:uint = (1 << (PAUSED - 1));
    public static const STASIS_BIT:uint = (1 << (STASIS - 1));
    public static const INVINCIBLE_BIT:uint = (1 << (INVINCIBLE - 1));
    public static const INVULNERABLE_BIT:uint = (1 << (INVULNERABLE - 1));
    public static const ARMORED_BIT:uint = (1 << (ARMORED - 1));
    public static const UNARMORED_BIT:uint = (1 << (UNARMORED - 1));
    public static const HEXED_BIT:uint = (1 << (HEXED - 1));
    public static const NINJA_SPEEDY_BIT:uint = (1 << (NINJA_SPEEDY - 1));
    public static const UNSTEADY_BIT:uint = (1 << (UNSTEADY - 1));
    public static const UNSIGHTED_BIT:uint = (1 << (UNSIGHTED - 1));
    public static const PETRIFIED_BIT:uint = (1 << (PETRIFIED - 1));
    public static const PET_EFFECT_ICON_BIT:uint = (1 << (PET_EFFECT_ICON - 1));
    public static const CURSE_BIT:uint = (1 << (CURSE - 1));
    public static const HP_BOOST_BIT:uint = (1 << (HP_BOOST - NEW_CON_THRESHOLD));
    public static const MP_BOOST_BIT:uint = (1 << (MP_BOOST - NEW_CON_THRESHOLD));
    public static const STR_BOOST_BIT:uint = (1 << (STR_BOOST - NEW_CON_THRESHOLD));
    public static const ARM_BOOST_BIT:uint = (1 << (ARM_BOOST - NEW_CON_THRESHOLD));
    public static const AGL_BOOST_BIT:uint = (1 << (AGL_BOOST - NEW_CON_THRESHOLD));
    public static const STA_BOOST_BIT:uint = (1 << (STA_BOOST - NEW_CON_THRESHOLD));
    public static const INT_BOOST_BIT:uint = (1 << (INT_BOOST - NEW_CON_THRESHOLD));
    public static const DEX_BOOST_BIT:uint = (1 << (DEX_BOOST - NEW_CON_THRESHOLD));
    public static const HIDDEN_BIT:uint = (1 << (HIDDEN - NEW_CON_THRESHOLD));
    public static const MUTED_BIT:uint = (1 << (MUTED - NEW_CON_THRESHOLD));
    public static const SHIELDED_BIT:uint = (1 << (SHIELDED - NEW_CON_THRESHOLD));
    public static const SHIELD_BOOST_BIT:uint = (1 << (SHIELD_BOOST - NEW_CON_THRESHOLD));
    public static const ENLIGHTENED_BIT:uint = (1 << (ENLIGHTENED - NEW_CON_THRESHOLD));
    public static const SUPPRESSED_BIT:uint = (1 << (SUPPRESSED - NEW_CON_THRESHOLD));
    public static const EXPOSED_BIT:uint = (1 << (EXPOSED - NEW_CON_THRESHOLD));
    public static const STAGGERED_BIT:uint = (1 << (STAGGERED - NEW_CON_THRESHOLD));
    public static const UNSTOPPABLE_BIT:uint = (1 << (UNSTOPPABLE - NEW_CON_THRESHOLD));
    public static const TAUNTED_BIT:uint = (1 << (TAUNTED - NEW_CON_THRESHOLD));
    public static const RESISTANCE_BOOST_BIT:uint = (1 << (RESISTANCE_BOOST - NEW_CON_THRESHOLD));
    public static const WIT_BOOST_BIT:uint = (1 << (WIT_BOOST - NEW_CON_THRESHOLD));
    public static const MAP_FILTER_BITMASK:uint = DRUNK_BIT | UNSIGHTED_BIT | PAUSED_BIT;
    public static const PROJ_NOHIT_BITMASK:uint = INVINCIBLE_BIT | STASIS_BIT | PAUSED_BIT;
    public static const CE_FIRST_BATCH:uint = 0;
    public static const CE_SECOND_BATCH:uint = 1;
    public static const NUMBER_CE_BATCHES:uint = 2;
    public static const NEW_CON_THRESHOLD:uint = 32;
    private static const GLOW_FILTER:GlowFilter = new GlowFilter(0, 0.3, 6, 6, 2, BitmapFilterQuality.LOW, false, false);

    public static var effects_:Vector.<ConditionEffect> =
            new <ConditionEffect>[
                new ConditionEffect("Nothing", 0, null, "Nothing"),
                new ConditionEffect("Dead", DEAD_BIT, null, "Dead"),
                new ConditionEffect("Stupefied", STUPEFIED_BIT, [32], "Stupefied"),
                new ConditionEffect("Weak", WEAK_BIT, [34], "Weak"),
                new ConditionEffect("Slow", SLOW_BIT, [1], "Slow"),
                new ConditionEffect("Sick", SICK_BIT, [39], "Sick"),
                new ConditionEffect("Crippled", CRIPPLED_BIT, [44], "Crippled"),
                new ConditionEffect("Stunned", STUNNED_BIT, [45], "Stunned"),
                new ConditionEffect("Blind", BLIND_BIT, [41], "Blind"),
                new ConditionEffect("Hallucinating", HALLUCINATING_BIT, [42], "Hallucinating"),
                new ConditionEffect("Drunk", DRUNK_BIT, [43], "Drunk"),
                new ConditionEffect("Confused", CONFUSED_BIT, [2], "Confused"),
                new ConditionEffect("Invisible", INVISIBLE_BIT, null, "Invisible"),
                new ConditionEffect("Paralyzed", PARALYZED_BIT, [53], "Paralyzed"),
                new ConditionEffect("Swift", SWIFT_BIT, [0], "Swift"),
                new ConditionEffect("Bleeding", BLEEDING_BIT, [46], "Bleeding"),
                new ConditionEffect("Renewed", RENEWED_BIT, [47], "Renewed"),
                new ConditionEffect("Brave", BRAVE_BIT, [49], "Brave"),
                new ConditionEffect("Berserk", BERSERK_BIT, [50], "Berserk"),
                new ConditionEffect("Paused", PAUSED_BIT, null, "Paused"),
                new ConditionEffect("Stasis", STASIS_BIT, null, "Stasis"),
                new ConditionEffect("Invincible", INVINCIBLE_BIT, null, "Invincible"),
                new ConditionEffect("Invulnerable", INVULNERABLE_BIT, [17], "Invulnerable"),
                new ConditionEffect("Armored", ARMORED_BIT, [16], "Armored"),
                new ConditionEffect("Unarmored", UNARMORED_BIT, [55], "Unarmored"),
                new ConditionEffect("Hexed", HEXED_BIT, [42], "Hexed"),
                new ConditionEffect("Ninja Speedy", NINJA_SPEEDY_BIT, [0], "Ninja Speedy"),
                new ConditionEffect("Unsteady", UNSTEADY_BIT, [56], "Unsteady"),
                new ConditionEffect("Unsighted", UNSIGHTED_BIT, [57], "Unsighted"),
                new ConditionEffect("Petrify", PETRIFIED_BIT, null, "Petrify"),
                new ConditionEffect("Pet Disable", PET_EFFECT_ICON_BIT, [27], "Stasis", true),
                new ConditionEffect("Curse", CURSE_BIT, [58], "Curse"),
                new ConditionEffect("HP Boost", HP_BOOST_BIT, [32], "HP Boost", true),
                new ConditionEffect("MP Boost", MP_BOOST_BIT, [33], "MP Boost", true),
                new ConditionEffect("Str Boost", STR_BOOST_BIT, [34], "Str Boost", true),
                new ConditionEffect("Arm Boost", ARM_BOOST_BIT, [35], "Arm Boost", true),
                new ConditionEffect("Agl Boost", AGL_BOOST_BIT, [36], "Agl Boost", true),
                new ConditionEffect("Dex Boost", DEX_BOOST_BIT, [37], "Dex Boost", true),
                new ConditionEffect("Sta Boost", STA_BOOST_BIT, [38], "Sta Boost", true),
                new ConditionEffect("Int Boost", INT_BOOST_BIT, [39], "Int Boost", true),
                new ConditionEffect("Hidden", HIDDEN_BIT, [27], "Hidden", true),
                new ConditionEffect("Muted", MUTED_BIT, [21], "Muted", true),
                new ConditionEffect("Shielded", SHIELDED_BIT, [0x12], "Shielded"),
                new ConditionEffect("Shield Boost", SHIELD_BOOST_BIT, [40], "Shield Boost", true),
                new ConditionEffect("Enlightened", ENLIGHTENED_BIT, [0x17], "Enlightened"),
                new ConditionEffect("Suppressed", SUPPRESSED_BIT, [0x3c], "Suppressed"),
                new ConditionEffect("Exposed", EXPOSED_BIT, [0x15], "Exposed"),
                new ConditionEffect("Staggered", STAGGERED_BIT, [0x3d], "Staggered"),
                new ConditionEffect("Unstoppable", UNSTOPPABLE_BIT, [0x13], "Unstoppable"),
                new ConditionEffect("Taunted", TAUNTED_BIT, [59], "Taunted"),
                new ConditionEffect("Shield Boost", RESISTANCE_BOOST_BIT, [42], "Resistance Boost", true),
                new ConditionEffect("Wit Boost", WIT_BOOST_BIT, [43], "Wit Boost", true)
            ];
    
    private static var conditionEffectFromName_:Object = null;
    private static var effectIconCache:Object = null;
    private static var bitToIcon_:Object = null;
    private static var bitToIcon2_:Object = null;

    public var name_:String;
    public var bit_:uint;
    public var iconOffsets_:Array;
    public var localizationKey_:String;
    public var icon16Bit_:Boolean;

    public function ConditionEffect(_arg1:String, _arg2:uint, _arg3:Array, _arg4:String = "", _arg5:Boolean = false) {
        this.name_ = _arg1;
        this.bit_ = _arg2;
        this.iconOffsets_ = _arg3;
        this.localizationKey_ = _arg4;
        this.icon16Bit_ = _arg5;
    }

    public static function getConditionEffectFromName(_arg1:String):uint {
        var _local2:uint;
        if (conditionEffectFromName_ == null) {
            conditionEffectFromName_ = new Object();
            _local2 = 0;
            while (_local2 < effects_.length) {
                conditionEffectFromName_[effects_[_local2].name_] = _local2;
                _local2++;
            }
        }
        return (conditionEffectFromName_[_arg1]);
    }

    public static function getConditionEffectIcons(_arg1:uint, _arg2:Vector.<BitmapData>, _arg3:int):void {
        var _local4:uint;
        var _local5:uint;
        var _local6:Vector.<BitmapData>;
        while (_arg1 != 0) {
            _local4 = (_arg1 & (_arg1 - 1));
            _local5 = (_arg1 ^ _local4);
            _local6 = getIconsFromBit(_local5);
            if (_local6 != null) {
                _arg2.push(_local6[(_arg3 % _local6.length)]);
            }
            _arg1 = _local4;
        }
    }

    public static function getConditionEffectIcons2(_arg1:uint, _arg2:Vector.<BitmapData>, _arg3:int):void {
        var _local4:uint;
        var _local5:uint;
        var _local6:Vector.<BitmapData>;
        while (_arg1 != 0) {
            _local4 = (_arg1 & (_arg1 - 1));
            _local5 = (_arg1 ^ _local4);
            _local6 = getIconsFromBit2(_local5);
            if (_local6 != null) {
                _arg2.push(_local6[(_arg3 % _local6.length)]);
            }
            _arg1 = _local4;
        }
    }

    private static function getIconsFromBit(_arg1:uint):Vector.<BitmapData> {
        var _local2:Matrix;
        var _local3:uint;
        var _local4:Vector.<BitmapData>;
        var _local5:int;
        var _local6:BitmapData;
        if (bitToIcon_ == null) {
            bitToIcon_ = new Object();
            _local2 = new Matrix();
            _local2.translate(4, 4);
            _local3 = 0;
            while (_local3 < 32) {
                _local4 = null;
                if (effects_[_local3].iconOffsets_ != null) {
                    _local4 = new Vector.<BitmapData>();
                    _local5 = 0;
                    while (_local5 < effects_[_local3].iconOffsets_.length) {
                        _local6 = new BitmapDataSpy(16, 16, true, 0);
                        _local6.draw(AssetLibrary.getImageFromSet("interfaceSmall", effects_[_local3].iconOffsets_[_local5]), _local2);
                        _local6 = GlowRedrawer.outline(_local6, 0xFFFFFFFF);
                        _local6.applyFilter(_local6, _local6.rect, PointUtil.ORIGIN, GLOW_FILTER);
                        _local4.push(_local6);
                        _local5++;
                    }
                }
                bitToIcon_[effects_[_local3].bit_] = _local4;
                _local3++;
            }
        }
        return (bitToIcon_[_arg1]);
    }

    private static function getIconsFromBit2(_arg1:uint):Vector.<BitmapData> {
        var _local2:Vector.<BitmapData>;
        var _local3:BitmapData;
        var _local4:Matrix;
        var _local5:Matrix;
        var _local6:uint;
        var _local7:int;
        if (bitToIcon2_ == null) {
            bitToIcon2_ = [];
            _local2 = new Vector.<BitmapData>();
            _local4 = new Matrix();
            _local4.translate(4, 4);
            _local5 = new Matrix();
            _local5.translate(1.5, 1.5);
            _local6 = 32;
            while (_local6 < effects_.length) {
                _local2 = null;
                if (effects_[_local6].iconOffsets_ != null) {
                    _local2 = new Vector.<BitmapData>();
                    _local7 = 0;
                    while (_local7 < effects_[_local6].iconOffsets_.length) {
                        if (effects_[_local6].icon16Bit_) {
                            _local3 = new BitmapDataSpy(18, 18, true, 0);
                            _local3.draw(AssetLibrary.getImageFromSet("interfaceBig", effects_[_local6].iconOffsets_[_local7]), _local5);
                        }
                        else {
                            _local3 = new BitmapDataSpy(16, 16, true, 0);
                            _local3.draw(AssetLibrary.getImageFromSet("interfaceSmall", effects_[_local6].iconOffsets_[_local7]), _local4);
                        }
                        _local3 = GlowRedrawer.outline(_local3, 0xFFFFFFFF);
                        _local3.applyFilter(_local3, _local3.rect, PointUtil.ORIGIN, GLOW_FILTER);
                        _local2.push(_local3);
                        _local7++;
                    }
                }
                bitToIcon2_[effects_[_local6].bit_] = _local2;
                _local6++;
            }
        }
        if (((!((bitToIcon2_ == null))) && (!((bitToIcon2_[_arg1] == null))))) {
            return (bitToIcon2_[_arg1]);
        }
        return (null);
    }


}
}
