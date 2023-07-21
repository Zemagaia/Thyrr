package com.company.assembleegameclient.ui.tooltip
{
public class TooltipHelper
{

    public static const BETTER_COLOR:uint = 0xFF00;
    public static const WORSE_COLOR:uint = 0xFF0000;
    public static const NO_DIFF_COLOR:uint = 16777103;
    public static const WIS_BONUS_COLOR:uint = 4219875;

    public static const LABEL_COLOR:uint = 0xB3B3B3; // default gray color
    public static const UNTIERED_COLOR:uint = 9055202;
    public static const LEGENDARY_COLOR:uint = 0xE29E5F;
    public static const MYTHIC_COLOR:uint = 0xC14543;
    public static const UNHOLY_COLOR:uint = 0xD34EA9;
    public static const DIVINE_COLOR:uint = 0x5A9985;

    public static const LUCK_STAT_COLOR:uint = 0x238c23;
    public static const HASTE_STAT_COLOR:uint = 0xadd8e6;
    public static const TENACITY_STAT_COLOR:uint = 0x996335;
    public static const CRITICAL_STRIKE_STAT_COLOR:uint = 16750848;

    public static const MP_COST_COLOR:uint = 0xB368FF;
    public static const HP_COST_COLOR:uint = 0xDD9090;

    public static function wrapInFontTag(text:String, colorStr:String):String
    {
        return '<font color="' + colorStr + '">' + text + "</font>";
    }

    public static function getTextColor(value:Number):uint
    {
        if (value < 0)
        {
            return (WORSE_COLOR);
        }
        if (value > 0)
        {
            return (BETTER_COLOR);
        }
        return (NO_DIFF_COLOR);
    }

    public static function getTextColor2(value:Number):uint
    {
        if (value < 0)
        {
            return (WORSE_COLOR);
        }
        return (NO_DIFF_COLOR);
    }

    public static function getRuneColor(value:Number):uint
    {
        if (value < 0)
        {
            return (WORSE_COLOR);
        }
        if (value > 0)
        {
            return (WIS_BONUS_COLOR);
        }
        return (NO_DIFF_COLOR);
    }

    public static function getPlural(value:Number, text:String):String
    {
        var fText:String = value + " " + text;
        if (value != 1)
        {
            return fText + "s";
        }
        return fText;
    }

    public static function getSpecialityColor(item:XML):uint
    {
        var color:uint = 16777215;
        var slotType:int = item.SlotType;
        if (!item.hasOwnProperty("Tier") && slotType != 0 && slotType != 10 && slotType != 26)
            color = UNTIERED_COLOR;
        if (item.hasOwnProperty("Tier") && slotType != 0 && slotType != 10 && slotType != 26)
            color = 0xB3B3B3;
        if (item.hasOwnProperty("Legendary"))
            color = LEGENDARY_COLOR;
        if (item.hasOwnProperty("Mythic"))
            color = MYTHIC_COLOR;
        if (item.hasOwnProperty("Unholy"))
            color = UNHOLY_COLOR;
        if (item.hasOwnProperty("Divine"))
            color = DIVINE_COLOR;
        return color;
    }

    public static function getSpecialityText(item:XML):String
    {
        var text:String = "Miscellaneous";
        var slotType:int = item.SlotType;
        var tier:int = item.Tier;
        if (item.hasOwnProperty("Tier"))
        {
            switch (tier)
            {
                case 0:
                    text = "Starter";
                    break;
                case 1:
                case 2:
                    text = "Common";
                    break;
                case 3:
                case 4:
                    text = "Uncommon";
                    break;
                case 5:
                case 6:
                    text = "Rare";
                    break;
                case 7:
                case 8:
                    text = "Epic";
                    break;
            }
        }
        if (!item.hasOwnProperty("Tier") && slotType != 0 && slotType != 10 && slotType != 26)
            text = "Untiered";
        if (item.hasOwnProperty("Consumable"))
            text = "Consumable";
        if (item.hasOwnProperty("@setName"))
            text = item.@setName;
        if (item.hasOwnProperty("Legendary"))
            text = "Legendary";
        if (item.hasOwnProperty("Mythic"))
            text = "Mythic";
        if (item.hasOwnProperty("Unholy"))
            text = "Unholy";
        if (item.hasOwnProperty("Divine"))
            text = "Divine";
        return text;
    }

    public static function compare(text:*, value:Number = 0):String
    {
        return wrapInFontTag(String(text), "#" + getTextColor(value).toString(16));
    }

}
}