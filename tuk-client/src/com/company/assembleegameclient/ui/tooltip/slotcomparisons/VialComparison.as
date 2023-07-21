package com.company.assembleegameclient.ui.tooltip.slotcomparisons {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;
import com.company.assembleegameclient.util.MathUtil;

import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;

public class VialComparison extends SlotComparison {

    private var activates:XMLList;
    private var curActivates:XMLList;

    override protected function compareSlots(itemXML:XML, curItemXML:XML, player:Player):void {
        this.extractDataFromXML(itemXML, curItemXML);
        comparisonStringBuilder = new AppendingLineBuilder();
        this.handleVial(itemXML, curItemXML, player);
    }

    private function extractDataFromXML(itemXML:XML, curItemXML:XML):void {
        this.activates = getActivateTagByType(itemXML, "Vial");
        if (curItemXML != null)
            this.curActivates = getActivateTagByType(curItemXML, "Vial");
    }

    private function handleVial(itemXML:XML, curItemXML:XML, player:Player):void {
        if (this.activates == null) return;
        var activate:XML;
        var curActivate:XML;

        for each (curActivate in this.curActivates) {
            var curRadius:Number = Number(curActivate.@radius);
            var curThrowTime:Number = Number(curActivate.@throwTime);
            if (!curThrowTime) curThrowTime = 0.8;
            var curImpactDamage:Number = Number(curActivate.@impactDamage);
            var curTotalDamage:Number = Number(curActivate.@totalDamage);
            var curDuration:Number = Number(curActivate.@duration);
        }

        var wis:int = ((player != null) ? player.intelligence_ : 10);
        var wisRes:Number = Math.max(0, (wis - 50));

        for each (activate in this.activates) {
            var radius:Number = Number(activate.@radius);
            var throwTime:Number = Number(activate.@throwTime);
            if (!throwTime) throwTime = 0.8;
            var impactDamage:Number = Number(activate.@impactDamage);
            var totalDamage:Number = Number(activate.@totalDamage);
            var duration:Number = Number(activate.@duration);
            var wismodMult:Number = Number(activate.@wismodMult);
            if (!wismodMult) wismodMult = 1.0;

            var wismodTotalDmg:Number = MathUtil.round((totalDamage / 10 * (wisRes / 3)) * wismodMult, 0);
            var wismodImpDmg:Number = MathUtil.round((impactDamage / 10 * (wisRes / 3)) * wismodMult,0);
            totalDamage += wismodTotalDmg;
            impactDamage += wismodImpDmg;

            var keyReplacements:Object;
            if (itemXML == curItemXML){
                keyReplacements = {
                    "radius": TooltipHelper.getPlural(radius, "sqr"),
                    "throwTime": TooltipHelper.getPlural(throwTime, "sec"),
                    "totalDamage": totalDamage + EquipmentToolTip.colorWisBonus(wismodTotalDmg) + " damage",
                    "impactDamage": impactDamage + EquipmentToolTip.colorWisBonus(wismodImpDmg),
                    "duration": TooltipHelper.getPlural(duration, "sec")
                }
            }
            else {
                keyReplacements = {
                    "radius": TooltipHelper.compare(TooltipHelper.getPlural(radius, "sqr"), radius - curRadius),
                    "throwTime": TooltipHelper.compare(TooltipHelper.getPlural(throwTime, "sec"), curThrowTime - throwTime),
                    "totalDamage": TooltipHelper.compare(totalDamage + EquipmentToolTip.colorWisBonus(wismodTotalDmg) + " damage",
                            totalDamage - curTotalDamage),
                    "impactDamage": TooltipHelper.compare(impactDamage + EquipmentToolTip.colorWisBonus(wismodImpDmg),
                            impactDamage - curImpactDamage),
                    "duration": TooltipHelper.compare(TooltipHelper.getPlural(duration, "sec"), curDuration - duration)
                }
            }

            comparisonStringBuilder.pushParams(EquipmentToolTip.colorByTier("-Vial: ", itemXML)
                    + "{totalDamage}"
                    + (impactDamage ? " ({impactDamage} immediately)" : "")
                    + " within {radius}"
                    + " after {throwTime} over {duration}",
                    keyReplacements, TooltipHelper.LABEL_COLOR, false, TooltipHelper.NO_DIFF_COLOR);
            processedTags[activate.toXMLString()] = true;
        }
    }
}
}
