package kabam.rotmg.messaging.impl.data {
import com.company.util.ConversionUtil;

import flash.utils.ByteArray;

import thyrr.utils.ItemData;

public class StatData {

    public static const MAX_HP_STAT:int = 0;
    public static const HP_STAT:int = 1;
    public static const SIZE_STAT:int = 2;
    public static const MAX_MP_STAT:int = 3;
    public static const MP_STAT:int = 4;
    public static const NEXT_LEVEL_EXP_STAT:int = 5;
    public static const EXP_STAT:int = 6;
    public static const LEVEL_STAT:int = 7;
    public static const INVENTORY_STAT:int = 8;
    // 10-19 unused
    public static const STRENGTH_STAT:int = 20;
    public static const ARMOR_STAT:int = 21;
    public static const AGILITY_STAT:int = 22;
    public static const STAMINA_STAT:int = 26;
    public static const INTELLIGENCE_STAT:int = 27;
    public static const DEXTERITY_STAT:int = 28;
    public static const CONDITION_STAT:int = 29;
    public static const NUM_STARS_STAT:int = 30;
    public static const NAME_STAT:int = 31;
    public static const TEX1_STAT:int = 32;
    public static const TEX2_STAT:int = 33;
    public static const MERCHANDISE_TYPE_STAT:int = 34;
    public static const CREDITS_STAT:int = 35;
    public static const MERCHANDISE_PRICE_STAT:int = 36;
    public static const ACTIVE_STAT:int = 37;
    public static const ACCOUNT_ID_STAT:int = 38;
    public static const FAME_STAT:int = 39;
    public static const MERCHANDISE_CURRENCY_STAT:int = 40;
    public static const CONNECT_STAT:int = 41;
    public static const MERCHANDISE_COUNT_STAT:int = 42;
    public static const MERCHANDISE_MINS_LEFT_STAT:int = 43;
    public static const MERCHANDISE_DISCOUNT_STAT:int = 44;
    public static const MERCHANDISE_RANK_REQ_STAT:int = 45;
    public static const MAX_HP_BOOST_STAT:int = 46;
    public static const MAX_MP_BOOST_STAT:int = 47;
    public static const STRENGTH_BOOST_STAT:int = 48;
    public static const ARMOR_BOOST_STAT:int = 49;
    public static const AGILITY_BOOST_STAT:int = 50;
    public static const STAMINA_BOOST_STAT:int = 51;
    public static const INTELLIGENCE_BOOST_STAT:int = 52;
    public static const DEXTERITY_BOOST_STAT:int = 53;
    public static const OWNER_ACCOUNT_ID_STAT:int = 54;
    public static const RANK_REQUIRED_STAT:int = 55;
    public static const NAME_CHOSEN_STAT:int = 56;
    public static const CURR_FAME_STAT:int = 57;
    public static const NEXT_CLASS_QUEST_FAME_STAT:int = 58;
    public static const GLOW_COLOR_STAT:int = 59;
    public static const SINK_LEVEL_STAT:int = 60;
    public static const ALT_TEXTURE_STAT:int = 61;
    public static const GUILD_NAME_STAT:int = 62;
    public static const GUILD_RANK_STAT:int = 63;
    public static const BREATH_STAT:int = 64;
    public static const XP_BOOSTED_STAT:int = 65;
    public static const XP_TIMER_STAT:int = 66;
    public static const LD_TIMER_STAT:int = 67;
    public static const LT_TIMER_STAT:int = 68;
    public static const HEALTH_STACK_COUNT:int = 69;
    public static const MAGIC_STACK_COUNT:int = 70;
    // 71-78 unused
    public static const HASBACKPACK_STAT:int = 79;
    public static const TEXTURE_STAT:int = 80;
    // 89-95 unused
    public static const NEW_CON_STAT:int = 96;
    public static const FORTUNE_TOKEN_STAT:int = 97;
    // 98-101 unused
    public static const LUCK:int = 102;
    public static const RANK:int = 103;
    public static const ADMIN:int = 104;
    public static const LUCK_BONUS:int = 105;
    public static const UNHOLY_ESSENCE_STAT:int = 106;
    public static const DIVINE_ESSENCE_STAT:int = 107;
    public static const HASTE:int = 108;
    public static const HASTE_BOOST:int = 109;
    public static const SHIELD_STAT:int = 110;
    public static const SHIELD_BOOST_STAT:int = 111;
    public static const SHIELDPOINTS:int = 112;
    public static const SHIELDMAX:int = 113;
    public static const LIGHTMAX:int = 114;
    public static const LIGHT:int = 115;
    // 116 unused
    public static const TENACITY:int = 117;
    public static const TENACITY_BOOST:int = 118;
    public static const CRITICAL_STRIKE:int = 119;
    public static const CRITICAL_STRIKE_BOOST:int = 120;
    public static const LIFE_STEAL:int = 121;
    public static const LIFE_STEAL_BOOST:int = 122;
    public static const MANA_LEECH:int = 123;
    public static const MANA_LEECH_BOOST:int = 124;
    public static const LIFE_STEAL_KILL:int = 125;
    public static const LIFE_STEAL_KILL_BOOST:int = 126;
    public static const MANA_LEECH_KILL:int = 127;
    public static const MANA_LEECH_KILL_BOOST:int = 128;
    // 129-155 unused
    public static const RESISTANCE_STAT:int = 156;
    public static const RESISTANCE_BOOST_STAT:int = 157;
    public static const OFFENSIVE_ABILITY_STAT:int = 158;
    public static const DEFENSIVE_ABILITY_STAT:int = 159;
    public static const PET_DATA_STAT:int = 81;
    public static const WIT_STAT:int = 82;
    public static const WIT_BOOST_STAT:int = 83;
    public static const LETHALITY:int = 84;
    public static const LETHALITY_BOOST:int = 85;
    public static const PIERCING:int = 86;
    public static const PIERCING_BOOST:int = 87;
    public static const IMMUNITIES:int = 88;
    public static const OVERRIDE_PROJ_DESC:int = 9;

    public var statType_:uint = 0;
    public var statValue_:int;
    public var strStatValue_:String;
    public var statValues_:Vector.<int>;
    public var byteArrayValue_:ByteArray;
    public var itemsValue_:Vector.<ItemData>;

    public static function statToName(stat:int):String {
        switch (stat) {
            case MAX_HP_STAT:
                return "Maximum HP";
            case HP_STAT:
                return "HP";
            case SIZE_STAT:
                return "Size";
            case MAX_MP_STAT:
                return "Maximum MP";
            case MP_STAT:
                return "MP";
            case EXP_STAT:
                return "XP";
            case LEVEL_STAT:
                return "Level";
            case STRENGTH_STAT:
                return "Strength";
            case ARMOR_STAT:
                return "Armor";
            case AGILITY_STAT:
                return "Agility";
            case STAMINA_STAT:
                return "Stamina";
            case INTELLIGENCE_STAT:
                return "Intelligence";
            case DEXTERITY_STAT:
                return "Dexterity";
            case LUCK:
                return "Luck";
            case HASTE:
                return "Haste";
            case SHIELD_STAT:
                return "Shield Points";
            case TENACITY:
                return "Tenacity";
            case CRITICAL_STRIKE:
                return "Critical Strike";
            case LIFE_STEAL:
                return "Health on Hit";
            case MANA_LEECH:
                return "Mana on Hit";
            case LIFE_STEAL_KILL:
                return "Health on Kill";
            case MANA_LEECH_KILL:
                return "Mana on Kill";
            case RESISTANCE_STAT:
                return "Resistance";
            case WIT_STAT:
                return "Wit";
            case LETHALITY:
                return "Lethality";
            case PIERCING:
                return "Piercing";
        }
        return "Unknown Stat";
    }

    public function isStringStat():Boolean {
        switch (this.statType_) {
            case NAME_STAT:
            case GUILD_NAME_STAT:
            case ACCOUNT_ID_STAT:
            case OWNER_ACCOUNT_ID_STAT:
                return (true);
        }
        return (false);
    }

    public function isByteArrayStat():Boolean {
        switch (this.statType_) {
            case PET_DATA_STAT:
            case OVERRIDE_PROJ_DESC:
                return (true);
        }
        return (false);
    }

    public function isArrayStat():Boolean {
        switch (this.statType_) {
            case IMMUNITIES:
                return (true);
        }
        return (false);
    }

    public function parseFromInput(data:ByteArray):void
    {
        var ba:ByteArray;
        this.statType_ = data.readUnsignedByte();
        var i:int = 0;
        if (isArrayStat())
        {
            var len:int = data.readShort();
            this.statValues_ = new Vector.<int>();
            i = 0;
            while (i < len)
            {
                this.statValues_.push(data.readInt());
                i++;
            }
            return;
        }

        if (isByteArrayStat())
        {
            ba = new ByteArray();
            ba.endian = "littleEndian";
            data.readBytes(ba, 0, data.readShort());
            this.byteArrayValue_ = ba;
            return;
        }

        if (this.statType_ == INVENTORY_STAT)
        {
            this.itemsValue_ = ConversionUtil.itemDataFromBytes(data);
            return;
        }

        if (!this.isStringStat())
        {
            this.statValue_ = data.readInt();
            return;
        }

        this.strStatValue_ = data.readUTF();
    }

    public function writeToOutput(_arg1:ByteArray):void {
        _arg1.writeByte(this.statType_);
        if (!this.isStringStat()) {
            _arg1.writeInt(this.statValue_);
        }
        else {
            _arg1.writeUTF(this.strStatValue_);
        }
    }

    public function toString():String {
        if (!this.isStringStat()) {
            return ((((("[" + this.statType_) + ": ") + this.statValue_) + "]"));
        }
        return ((((("[" + this.statType_) + ': "') + this.strStatValue_) + '"]'));
    }


}
}
