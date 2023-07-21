package com.company.assembleegameclient.ui.panels.itemgrids {
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InventoryTile;

import kabam.rotmg.constants.ItemConstants;

import thyrr.utils.ItemData;

public class InventoryGrid extends ItemGrid {

    private const NUM_SLOTS:uint = 12;

    private var tiles:Vector.<InventoryTile>;
    private var isBackpack:Boolean;

    public function InventoryGrid(owner:GameObject, player:Player, indexOffset:int = 0, isBackpack:Boolean = false) {
        var inventoryTile:InventoryTile;
        super(owner, player, indexOffset);
        this.tiles = new Vector.<InventoryTile>(this.NUM_SLOTS);
        this.isBackpack = isBackpack;
        var i:int = 0;
        while (i < this.NUM_SLOTS) {
            inventoryTile = new InventoryTile((i + indexOffset), this, interactive);
            addToGrid(inventoryTile, 2, i, tiles.length);
            this.tiles[i] = inventoryTile;
            i++;
        }
    }

    public function updateLevelReqIconVisibility(player:Player):void {
        var i:int = 0;
        while (i < this.tiles.length) {
            this.tiles[i].updateLevelReqIconVisibility(player);
            i++;
        }
    }

    override public function setItems(items:Vector.<ItemData>, _arg2:int = 0):void {
        var _local3:Boolean;
        var _local4:int;
        var _local5:int;
        if (items) {
            _local3 = false;
            _local4 = items.length;
            _local5 = 0;
            while (_local5 < this.NUM_SLOTS) {
                if ((_local5 + indexOffset) < _local4) {
                    if (this.tiles[_local5].setItem(items[(_local5 + indexOffset)])) {
                        _local3 = true;
                    }
                }
                else {
                    if (this.tiles[_local5].setItem(ItemConstants.DEFAULT_ITEM)) {
                        _local3 = true;
                    }
                }
                _local5++;
            }
            if (_local3) {
                refreshTooltip();
            }
        }
    }
}
}
