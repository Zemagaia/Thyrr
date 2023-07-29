package com.company.assembleegameclient.ui.panels.itemgrids {
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InteractiveItemTile;

import flash.display.DisplayObject;

import kabam.rotmg.constants.ItemConstants;

import thyrr.utils.ItemData;

public class ContainerGrid extends ItemGrid {

    private var tiles:Vector.<InteractiveItemTile>;
    private var slots:int;

    public function ContainerGrid(_arg1:GameObject, _arg2:Player) {
        super(_arg1, _arg2, 0);
    }

    override public function setItems(equipment:Vector.<ItemData>, indexOffset:int = 0):void {
        var tileSet:Boolean;
        var invLength:int;
        var i:int;
        if (equipment) {
            var initialized:Boolean = slots == equipment.length;
            slots = equipment.length;
            if (!initialized)
                this.tiles = new Vector.<InteractiveItemTile>(equipment.length);
            tileSet = false;
            invLength = equipment.length;
            i = 0;
            while (i < tiles.length) {
                if (!initialized)
                {
                    var tile:InteractiveItemTile = new InteractiveItemTile((i + indexOffset), this, interactive);
                    addToGrid(tile, uint(Math.ceil(tiles.length / 6)), i, tiles.length);
                    this.tiles[i] = tile;
                }
                if ((i + indexOffset) < invLength) {
                    if (this.tiles[i].setItem(equipment[(i + indexOffset)])) {
                        tileSet = true;
                    }
                }
                else {
                    if (this.tiles[i].setItem(new ItemData(null))) {
                        tileSet = true;
                    }
                }
                i++;
            }
            if (tileSet) {
                refreshTooltip();
            }
        }
    }


}
}
