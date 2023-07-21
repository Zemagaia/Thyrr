package com.company.assembleegameclient.ui.tooltip.slotcomparisons {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;

import kabam.rotmg.constants.*;
import kabam.rotmg.messaging.impl.data.StatData;

import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;

public class SealComparison extends SlotComparison {

    private var hpBoost:XML;
    private var curHpBoost:XML;
    private var brave:XML;
    private var curBrave:XML;
    private var renewed:XML;
    private var curRenewed:XML;

    override protected function compareSlots(itemXML:XML, curItemXML:XML, player:Player):void {
        this.extractDataFromXML(itemXML, curItemXML);
        comparisonStringBuilder = new AppendingLineBuilder();
        this.handleHpBoost(itemXML);
        this.handleBrave(itemXML);
        this.handleRenewed(itemXML);
        var tag:XML;
        if (itemXML.@id == "Seal of Blasphemous Prayer") {
            tag = itemXML.Activate.(text() == ActivationType.COND_EFFECT_SELF)[0];
            comparisonStringBuilder.pushParams(EquipmentToolTip.wrapColor("-On Self: ", TooltipHelper.UNTIERED_COLOR)
                    + "{effect} for {duration}", {
                "effect": EquipmentToolTip.wrapColor("Invulnerable", TooltipHelper.NO_DIFF_COLOR),
                "duration": EquipmentToolTip.wrapColor(tag.@duration + " secs", TooltipHelper.NO_DIFF_COLOR)
            }, TooltipHelper.UNTIERED_COLOR);
            processedTags[tag.toXMLString()] = true;
        }
    }

    private function extractDataFromXML(itemXML:XML, curItemXML:XML):void {
        this.hpBoost = this.getBoostAuraTagByType(itemXML, "Maximum HP");
        this.brave = this.getGATagByType(itemXML, "Brave");
        this.renewed = this.getGATagByType(itemXML, "Renewed");
        if (curItemXML != null) {
            this.curHpBoost = this.getBoostAuraTagByType(curItemXML, "Maximum HP");
            this.curBrave = this.getGATagByType(curItemXML, "Brave");
            this.curRenewed = this.getGATagByType(curItemXML, "Renewed");
        }
    }

    private function getGATagByType(xml:XML, typeName:String):XML {
        var matches:XMLList;
        var tag:XML;
        matches = xml.Activate.(text() == ActivationType.GENERIC_ACTIVATE);
        for each (tag in matches) {
            if (tag.@effect == typeName) {
                return (tag);
            }
        }
        return null;
    }

    private function getBoostAuraTagByType(xml:XML, typeName:String):XML {
        var matches:XMLList;
        var tag:XML;
        matches = xml.Activate.(text() == ActivationType.STAT_BOOST_AURA);
        for each (tag in matches) {
            var s:String = String(tag.@stat);
            switch (s){
                case "MaximumHP": s = "Maximum HP"; break;
                case "MaximumMP": s = "Maximum MP"; break;
                case "ShieldPoints": s = "Shield Points"; break;
                case "CriticalStrike": s = "Critical Strike"; break;
            }
            if (s == "") {
                s = StatData.statToName(int(tag.@statId));
            }
            if (s == typeName) {
                return (tag);
            }
        }
        return null;
    }

    private function handleHpBoost(item:XML):void {
        if (this.hpBoost == null) return;

        var amount:Number = this.hpBoost.@amount;
        var range:Number = this.hpBoost.@range;
        var duration:Number = this.hpBoost.@duration;
        var curAmount:Number;
        var curRange:Number;
        var curDuration:Number

        var color:uint = TooltipHelper.NO_DIFF_COLOR;
        if (this.hpBoost != null && this.curHpBoost != null) {
            curAmount = Number(this.curHpBoost.@amount);
            curRange = Number(this.curHpBoost.@range);
            curDuration = Number(this.curHpBoost.@duration);
            color = getTextColor(amount - curAmount);
        }

        comparisonStringBuilder.pushParams(EquipmentToolTip.colorByTier("-On Party: ", item)
                + "{amount} for {duration} within {range}", {
            "amount": EquipmentToolTip.prefix(amount) + " Maximum HP",
            "duration": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(duration, "sec"),
                    getTextColor(duration - curDuration)),
            "range": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(range, "sqr"),
                    getTextColor(range - curRange))
        }, TooltipHelper.LABEL_COLOR, false, color);
        processedTags[this.hpBoost.toXMLString()] = true;
    }

    private function handleBrave(item:XML):void {
        if (this.brave == null) return;

        var duration:Number = this.brave.@duration;
        var range:Number = this.brave.@range;
        var otherDuration:Number;
        var otherRange:Number;

        var color:int = TooltipHelper.NO_DIFF_COLOR;
        if (this.brave != null && this.curBrave != null) {
            otherDuration = Number(this.curBrave.@duration);
            otherRange = Number(this.curBrave.@range);
            color = getTextColor(duration - otherDuration);
        }

        comparisonStringBuilder.pushParams(EquipmentToolTip.colorByTier("-On Party: ", item)
                + "{effect} for {duration} within {range}", {
            "effect": "Brave",
            "duration": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(duration, "sec"),
                    getTextColor(duration - otherDuration)),
            "range": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(range, "sqr"),
                    getTextColor(range - otherRange))
        }, TooltipHelper.LABEL_COLOR, false, color);
        processedTags[this.brave.toXMLString()] = true;
    }

    private function handleRenewed(item:XML):void {
        if (this.renewed == null) return;

        var duration:Number = this.renewed.@duration;
        var range:Number = this.renewed.@range;
        var otherDuration:Number;
        var otherRange:Number;

        var color:int = TooltipHelper.NO_DIFF_COLOR;
        if (this.renewed != null && this.curRenewed != null) {
            otherDuration = Number(this.curRenewed.@duration);
            otherRange = Number(this.curRenewed.@range);
            color = getTextColor(duration - otherDuration);
        }

        comparisonStringBuilder.pushParams(EquipmentToolTip.colorByTier("-On Party: ", item)
                + "{effect} for {duration} within {range}", {
            "effect": "Renewed",
            "duration": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(duration, "sec"),
                    getTextColor(duration - otherDuration)),
            "range": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(range, "sqr"),
                    getTextColor(range - otherRange))
        }, TooltipHelper.LABEL_COLOR, false, color);
        processedTags[this.renewed.toXMLString()] = true;
    }
}
}
