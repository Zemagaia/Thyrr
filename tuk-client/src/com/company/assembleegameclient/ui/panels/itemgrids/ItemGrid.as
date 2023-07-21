package com.company.assembleegameclient.ui.panels.itemgrids {
import com.company.assembleegameclient.constants.InventoryOwnerTypes;
import com.company.assembleegameclient.objects.Container;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.Panel;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.EquipmentTile;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTile;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.ui.tooltip.TextToolTip;
import com.company.assembleegameclient.ui.tooltip.ToolTip;

import flash.events.Event;

import flash.events.MouseEvent;

import kabam.rotmg.constants.ItemConstants;


import org.osflash.signals.Signal;

import thyrr.utils.ItemData;

public class ItemGrid extends Panel {

    private static const NO_CUT:Array = [0, 0, 0, 0];

    private const padding:uint = 4;
    private const rowLength:uint = 6;
    public const addToolTip:Signal = new Signal(ToolTip);

    public var owner:GameObject;
    private var tooltip:ToolTip;
    private var tooltipFocusTile:ItemTile;
    public var curPlayer:Player;
    protected var indexOffset:int;
    public var interactive:Boolean;

    public function ItemGrid(owner:GameObject, curPlayer:Player, indexOffset:int) {
        super(null);
        this.owner = owner;
        this.curPlayer = curPlayer;
        this.indexOffset = indexOffset;
        var container:Container = (owner as Container);
        if (owner == curPlayer || container) {
            this.interactive = true;
        }
    }

    public function hideTooltip():void {
        if (this.tooltip) {
            this.tooltip.detachFromTarget();
            this.tooltip = null;
            this.tooltipFocusTile = null;
        }
    }

    public function refreshTooltip():void {
        if (((((!(stage != null)) || (!(this.tooltip != null)))) || (!(this.tooltip.stage != null)))) {
            return;
        }
        if (this.tooltipFocusTile) {
            this.tooltip.detachFromTarget();
            this.tooltip = null;
            this.addToolTipToTile(this.tooltipFocusTile);
        }
    }

    private function onTileHover(me:MouseEvent):void {
        if (stage == null) {
            return;
        }
        var tile:ItemTile = (me.currentTarget as ItemTile);
        this.addToolTipToTile(tile);
        this.tooltipFocusTile = tile;
    }

    private function addToolTipToTile(tile:ItemTile):void {
        var itemType:String;
        if (tile.itemSprite.item && tile.itemSprite.item.ObjectType > 0) {
            this.tooltip = new EquipmentToolTip(tile.itemSprite.item, this.curPlayer, ((this.owner) ? this.owner.objectType_ : -1), this.getCharacterType());
        }
        else {
            if ((tile is EquipmentTile)) {
                itemType = ItemConstants.itemTypeToName((tile as EquipmentTile).itemType);
            }
            else {
                itemType = "item";
            }
            this.tooltip = new TextToolTip(0x2B2B2B, 0x7B7B7B, null, "Empty {itemType} slot", 200, {"itemType": itemType});
        }
        this.tooltip.attachToTarget(tile);
        this.addToolTip.dispatch(this.tooltip);
    }

    private function getCharacterType():String {
        if (this.owner == this.curPlayer) {
            return (InventoryOwnerTypes.CURRENT_PLAYER);
        }
        if ((this.owner is Player)) {
            return (InventoryOwnerTypes.OTHER_PLAYER);
        }
        return (InventoryOwnerTypes.NPC);
    }

    protected function addToGrid(tile:ItemTile, rows:uint, index:uint, slots:int):void {
        tile.initBackground(rows, index, slots);
        tile.addEventListener(MouseEvent.ROLL_OVER, this.onTileHover);
        var tick:Function = function (event:Event):void {
            tile.tickSprite();
        };
        tile.addEventListener(Event.ENTER_FRAME, tick);
        tile.x = (int((index % this.rowLength)) * (ItemTile.WIDTH + this.padding));
        tile.y = (int((index / this.rowLength)) * (ItemTile.HEIGHT + this.padding));
        addChild(tile);
    }

    public function setItems(items:Vector.<ItemData>, indexOffset:int = 0):void {
    }

    public function enableInteraction(enabled:Boolean):void {
        mouseEnabled = enabled;
    }

    override public function draw():void {
        this.setItems(this.owner.equipment_, this.indexOffset);
    }


}
}
