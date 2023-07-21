package com.company.assembleegameclient.ui.tooltip.slotcomparisons {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;

import flash.utils.Dictionary;

import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;

public class SlotComparison {

    public var processedTags:Dictionary;
    public var processedActivateOnEquipTags:AppendingLineBuilder;
    public var comparisonStringBuilder:AppendingLineBuilder;

    public function compare(item:XML, curItem:XML, player:Player):void {
        this.resetFields();
        this.compareSlots(item, curItem, player);
    }

    protected function compareSlots(item:XML, curItem:XML, player:Player):void {
    }

    private function resetFields():void {
        this.processedTags = new Dictionary();
        this.processedActivateOnEquipTags = new AppendingLineBuilder();
    }

    protected function getTextColor(value:Number):uint {
        if (value < 0) {
            return TooltipHelper.WORSE_COLOR;
        }
        if (value > 0) {
            return TooltipHelper.BETTER_COLOR;
        }
        return TooltipHelper.NO_DIFF_COLOR;
    }

    protected function wrapInColoredFont(text:String, color:uint = 16777103):String {
        return ((((('<font color="#' + color.toString(16)) + '">') + text) + "</font>"));
    }

    protected static function getActivateTagByType(xml:XML, activate:String):XMLList {
        var matches:XMLList = xml.Activate;
        var matchList:XMLList = new XMLList();
        var n:int = 0;
        var i:int = 0;
        while (i < matches.length()) {
            if (matches[i] == activate) {
                matchList[n] = matches[i];
                n++;
            }
            i++;
        }
        return matchList;
    }
}
}
