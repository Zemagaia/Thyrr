package com.company.assembleegameclient.ui.tooltip.slotcomparisons
{
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;

import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;

public class TomeComparison extends SlotComparison
{


    override protected function compareSlots(item:XML, curItem:XML, player:Player):void // not rly
    {
        var tag:XML;
        comparisonStringBuilder = new AppendingLineBuilder();
        switch (item["@id"])
        {
            case "Tome of Purification":
                var range:Number = item.Activate.(text() == "RemoveNegativeConditions").@range;
                tag = item.Activate.(text() == "RemoveNegativeConditions")[0];
                comparisonStringBuilder.pushParams("-Removes negative conditions within {range}", {
                    "range": range + " sqrs"
                }, TooltipHelper.NO_DIFF_COLOR);
                processedTags[tag.toXMLString()] = true;
                break;
            case "Tome of Holy Protection":
            case "Tome of Frigid Protection":
                tag = item.Activate.(text() == "ConditionEffectSelf")[0];
                var duration:Number = tag.@duration;
                comparisonStringBuilder.pushParams(EquipmentToolTip.wrapColor("-On Self: ", TooltipHelper.UNTIERED_COLOR)
                        + "{effect} for {duration}", {
                    "effect": EquipmentToolTip.wrapColor("Armored", TooltipHelper.NO_DIFF_COLOR),
                    "duration": EquipmentToolTip.wrapColor(duration + " secs", TooltipHelper.NO_DIFF_COLOR)
                }, TooltipHelper.UNTIERED_COLOR, false, TooltipHelper.NO_DIFF_COLOR);
                processedTags[tag.toXMLString()] = true;
                break;
        }
    }

}
}