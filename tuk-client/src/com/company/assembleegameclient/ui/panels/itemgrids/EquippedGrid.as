package com.company.assembleegameclient.ui.panels.itemgrids {
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.EquipmentTile;
import com.company.util.ArrayIterator;
import com.company.util.IIterator;

import kabam.lib.util.VectorAS3Util;
import kabam.rotmg.constants.ItemConstants;

import thyrr.utils.ItemData;

public class EquippedGrid extends ItemGrid {

    public static const NUM_SLOTS:uint = 6;

    private var tiles:Vector.<EquipmentTile>;

    public function EquippedGrid(owner:GameObject, slotTypes:Vector.<int>, player:Player, indexOffset:int = 0) {
        var tile:EquipmentTile;
        super(owner, player, indexOffset);
        this.tiles = new Vector.<EquipmentTile>(NUM_SLOTS);
        var i:int = 0;
        while (i < NUM_SLOTS) {
            tile = new EquipmentTile(i, this, interactive);
            addToGrid(tile, 1, i, tiles.length);
            tile.setType(slotTypes[i]);
            this.tiles[i] = tile;
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

    public function createInteractiveItemTileIterator():IIterator {
        return (new ArrayIterator(VectorAS3Util.toArray(this.tiles)));
    }

    override public function setItems(items:Vector.<ItemData>, _arg2:int = 0):void {
        var _local3:int;
        var _local4:int;
        if (items) {
            _local3 = items.length;
            _local4 = 0;
            while (_local4 < this.tiles.length) {
                if ((_local4 + _arg2) < _local3) {
                    this.tiles[_local4].setItem(items[(_local4 + _arg2)]);
                }
                else {
                    this.tiles[_local4].setItem(new ItemData(null));
                }
                this.tiles[_local4].updateDim(curPlayer);
                _local4++;
            }
        }
    }
}
}
