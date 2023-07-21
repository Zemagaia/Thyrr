package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.ItemGrid;

import thyrr.utils.ItemData;

public class InventoryTile extends InteractiveItemTile {

    public function InventoryTile(id:int, itemGrid:ItemGrid, interactive:Boolean) {
        super(id, itemGrid, interactive);
    }

    override public function setItemSprite(_arg1:ItemTileSprite):void {
        super.setItemSprite(_arg1);
        _arg1.setDim(false);
    }

    override public function setItem(itemData:ItemData):Boolean {
        var _local2:Boolean = super.setItem(itemData);
        return (_local2);
    }

    override public function updateLevelReqIconVisibility(player:Player):void {
        super.updateLevelReqIconVisibility(player);
    }

}
}
