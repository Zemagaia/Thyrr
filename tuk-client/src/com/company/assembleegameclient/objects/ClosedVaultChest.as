package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.ui.tooltip.TextToolTip;
import com.company.assembleegameclient.ui.tooltip.ToolTip;

import flash.display.BitmapData;



public class ClosedVaultChest extends SellableObject {

    public function ClosedVaultChest(_arg1:XML) {
        super(_arg1);
    }

    override public function soldObjectName():String {
        return ("Vault Chest");
    }

    override public function soldObjectInternalName():String {
        return ("Vault Chest");
    }

    override public function getTooltip():ToolTip {
        return (new TextToolTip(0x2B2B2B, 0x7B7B7B, this.soldObjectName(), "A chest that will safely store 8 items and is accessible by all of your characters.", 200));
    }

    override public function getSellableType():int {
        return (ObjectLibrary.idToType_["Vault Chest"]);
    }

    override public function getIcon():BitmapData {
        return (ObjectLibrary.getRedrawnTextureFromType(ObjectLibrary.idToType_["Vault Chest"], 80, true));
    }


}
}
