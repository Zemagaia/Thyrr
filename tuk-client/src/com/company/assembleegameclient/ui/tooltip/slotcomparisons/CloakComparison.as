package com.company.assembleegameclient.ui.tooltip.slotcomparisons {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;

import kabam.rotmg.constants.*;

import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;

public class CloakComparison extends SlotComparison {

    private var _invisible:XML;
    private var _curInvisible:XML;

    override protected function compareSlots(itemXML:XML, curItemXML:XML, player:Player):void {
        this.extractDataFromXML(itemXML, curItemXML);
        comparisonStringBuilder = new AppendingLineBuilder();
        this.handleInvisible(itemXML);
        this.handleExceptions(itemXML);
    }

    private function extractDataFromXML(itemXML:XML, curItemXML:XML):void {
        _invisible = this.getInvisibleTag(itemXML);
        if (curItemXML != null) {
            _curInvisible = this.getInvisibleTag(curItemXML);
        }
    }

    private function handleExceptions(item:XML):void {
        var tag:XML;
        if (item.@id == "Cloak of the Planewalker") {
            tag = item.Activate.(text() == ActivationType.TELEPORT)[0];
            comparisonStringBuilder.pushParams("-Teleport to Target", {}, TooltipHelper.NO_DIFF_COLOR);
            processedTags[tag.toXMLString()] = true;
        }
    }

    private function getInvisibleTag(xml:XML):XML {
        var matches:XMLList;
        var tag:XML;
        matches = xml.Activate.(text() == ActivationType.COND_EFFECT_SELF);
        for each (tag in matches) {
            if (tag.(@effect == "Invisible")) {
                return (tag);
            }
        }
        return null;
    }

    private function handleInvisible(item:XML):void {
        if (_invisible == null) return;
        var duration:Number = _invisible.@duration;
        var curDuration:Number;
        var color:int = TooltipHelper.NO_DIFF_COLOR;
        if (_invisible != null && _curInvisible != null) {
            curDuration = Number(_curInvisible.@duration);
            color = getTextColor(duration - curDuration);
        }
        comparisonStringBuilder.pushParams(EquipmentToolTip.colorByTier("-On Self: ", item)
                + "{effect} for {duration}", {
            "effect": "Invisible",
            "duration": EquipmentToolTip.wrapColor(
                    TooltipHelper.getPlural(duration, "sec"),
                    getTextColor(duration - curDuration))
        }, TooltipHelper.LABEL_COLOR, false, color);
        processedTags[_invisible.toXMLString()] = true;
    }
}
}
