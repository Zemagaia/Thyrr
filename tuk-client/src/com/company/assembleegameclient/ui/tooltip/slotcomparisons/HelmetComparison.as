package com.company.assembleegameclient.ui.tooltip.slotcomparisons {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;

import kabam.rotmg.constants.*;
import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;

public class HelmetComparison extends SlotComparison {

    private var berserk:XML;
    private var speedy:XML;
    private var curBerserk:XML;
    private var curSpeedy:XML;

    override protected function compareSlots(itemXML:XML, curItemXML:XML, player:Player):void {
        this.extractDataFromXML(itemXML, curItemXML);
        comparisonStringBuilder = new AppendingLineBuilder();
        this.handleBerserk(itemXML);
        this.handleSpeedy(itemXML);
        this.handleExceptions(itemXML);
    }

    private function extractDataFromXML(itemXML:XML, curItemXML:XML):void {
        this.berserk = this.getAuraTagByType(itemXML, "Berserk");
        this.speedy = this.getSelfTagByType(itemXML, "Swift");
        if (curItemXML != null) {
            this.curBerserk = this.getAuraTagByType(curItemXML, "Berserk");
            this.curSpeedy = this.getSelfTagByType(curItemXML, "Swift");
        }
    }

    private function getAuraTagByType(xml:XML, typeName:String):XML {
        var matches:XMLList;
        var tag:XML;
        matches = xml.Activate.(text() == ActivationType.COND_EFFECT_AURA);
        for each (tag in matches) {
            if (tag.@effect == typeName) {
                return (tag);
            }
        }
        return null;
    }

    private function getSelfTagByType(xml:XML, typeName:String):XML {
        var matches:XMLList;
        var tag:XML;
        matches = xml.Activate.(text() == ActivationType.COND_EFFECT_SELF);
        for each (tag in matches) {
            if (tag.@effect == typeName) {
                return (tag);
            }
        }
        return null;
    }

    private function handleBerserk(item:XML):void {
        if (this.berserk == null) {
            return;
        }
        var range:Number = Number(this.berserk.@range);
        var curRange:Number;
        var duration:Number = Number(this.berserk.@duration);
        var curDuration:Number;
        var color:int = TooltipHelper.NO_DIFF_COLOR;
        if (this.berserk != null && this.curBerserk != null) {
            curRange = Number(this.curBerserk.@range);
            curDuration = Number(this.curBerserk.@duration);
            color = getTextColor(duration - curDuration);
        }
        comparisonStringBuilder.pushParams(EquipmentToolTip.colorByTier("-On Party: ", item)
                + "{effect} for {duration} within {range} ", {
            "effect": "Berserk",
            "duration": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(duration, "sec"),
                    getTextColor(duration - curDuration)),
            "range": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(range, "sqr"),
                    getTextColor(range - curRange))
        }, TooltipHelper.LABEL_COLOR, false, color);
        processedTags[this.berserk.toXMLString()] = true;
    }

    private function handleSpeedy(item:XML):void {
        if (this.speedy == null) return;
        var duration:Number = this.speedy.@duration;
        var curDuration:Number;
        var color:int = TooltipHelper.NO_DIFF_COLOR;
        if (this.speedy != null && this.curSpeedy != null) {
            curDuration = Number(this.curSpeedy.@duration);
            color = getTextColor(duration - curDuration);
        }
        comparisonStringBuilder.pushParams(EquipmentToolTip.colorByTier("-On Self: ", item)
                + "{effect} for {duration}", {
            "effect": "Swift",
            "duration": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(duration, "sec"),
                    getTextColor(duration - curDuration))
        }, TooltipHelper.LABEL_COLOR, false, color);
        processedTags[this.speedy.toXMLString()] = true;
    }


    private function handleExceptions(item:XML):void {
        var tag:XML;
        if (item.@id == "Helm of the Juggernaut") {
            tag = item.Activate.(text() == ActivationType.COND_EFFECT_SELF)[0];
            comparisonStringBuilder.pushParams(EquipmentToolTip.colorByTier("-On Self: ", item)
                    + "{effect} for {duration}", {
                "effect": EquipmentToolTip.wrapColor("Armored", TooltipHelper.NO_DIFF_COLOR),
                "duration": EquipmentToolTip.wrapColor(tag.@duration + " secs", TooltipHelper.NO_DIFF_COLOR)
            }, TooltipHelper.UNTIERED_COLOR);
            processedTags[tag.toXMLString()] = true;
        }
    }
}
}
