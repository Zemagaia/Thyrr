package com.company.assembleegameclient.ui.panels.itemgrids {
import com.company.assembleegameclient.constants.InventoryOwnerTypes;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.objects.Container;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.OneWayContainer;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.panels.Panel;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.EquipmentTile;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InteractiveItemTile;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTile;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileEvent;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.ui.tooltip.TextToolTip;
import com.company.assembleegameclient.ui.tooltip.ToolTip;
import com.company.assembleegameclient.util.DisplayHierarchy;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.core.model.MapModel;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.game.model.PotionInventoryModel;
import kabam.rotmg.game.view.CooldownTimer;
import kabam.rotmg.game.view.components.TabStrip;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.model.TabStripModel;

import thyrr.ui.items.Scrollbar;
import thyrr.utils.ItemData;

public class ItemGrid extends Panel {

    private static const NO_CUT:Array = [0, 0, 0, 0];

    private const padding:uint = 4;
    private const rowLength:uint = 6;

    public var mapModel:MapModel = Global.mapModel;
    public var playerModel:PlayerModel = Global.playerModel;
    public var potionInventoryModel:PotionInventoryModel = Global.potionInventoryModel;
    public var hudModel:HUDModel = Global.hudModel;
    public var tabStripModel:TabStripModel = Global.tabStripModel;
    public var owner:GameObject;
    private var tooltip:ToolTip;
    private var tooltipFocusTile:ItemTile;
    public var curPlayer:Player;
    protected var indexOffset:int;
    public var interactive:Boolean;
    private var inventory:Sprite;
    private var scrollbar:Scrollbar;
    private var initialized:Boolean;
    private var trueHeight:int;

    public function ItemGrid(owner:GameObject, curPlayer:Player, indexOffset:int)
    {
        super(null);
        this.owner = owner;
        this.curPlayer = curPlayer;
        this.indexOffset = indexOffset;
        inventory = new Sprite();
        var container:Container = (owner as Container);
        if (owner == curPlayer || container != null) {
            this.interactive = true;
        }
        addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    public function initialize(e:Event):void {
        this.addEventListener(ItemTileEvent.ITEM_MOVE, this.onTileMove);
        this.addEventListener(ItemTileEvent.ITEM_SHIFT_CLICK, this.onShiftClick);
        this.addEventListener(ItemTileEvent.ITEM_DOUBLE_CLICK, this.onDoubleClick);
        this.addEventListener(ItemTileEvent.ITEM_CTRL_CLICK, this.onCtrlClick);
    }

    private function onAddToolTip(_arg1:ToolTip):void {
        Global.showTooltip(_arg1);
    }

    private function onTileMove(_arg1:ItemTileEvent):void {
        var _local4:InteractiveItemTile;
        var _local5:TabStrip;
        var _local6:int;
        var _local8:int;
        var _local2:InteractiveItemTile = _arg1.tile;
        var _local3:* = DisplayHierarchy.getParentWithTypeArray(_local2.getDropTarget(), TabStrip, InteractiveItemTile, Map);
        if (_local2.getItemId() == PotionInventoryModel.HEALTH_POTION_ID ||
                _local2.getItemId() == PotionInventoryModel.MAGIC_POTION_ID) {
            this.onPotionMove(_arg1);
            return;
        }
        if ((_local3 is InteractiveItemTile)) {
            _local4 = (_local3 as InteractiveItemTile);
            if (this.curPlayer.lockedSlot[_local4.tileId] == 0) {
                if (this.canSwapItems(_local2, _local4)) {
                    this.swapItemTiles(_local2, _local4);
                }
            } else {
                Global.addTextLine(ChatMessage.make(Parameters.ERROR_CHAT_NAME, "You cannot put items into this slot right now."));
            }
        } else {
            if ((_local3 is TabStrip)) {
                _local6 = _local2.ownerGrid.curPlayer.nextAvailableInventorySlot();
                if (_local6 != -1) {
                    GameServerConnection.instance.invSwap(this.curPlayer, _local2.ownerGrid.owner, _local2.tileId, _local2.itemSprite.item, this.curPlayer, _local6, new ItemData(null));
                    _local2.setItem(new ItemData(null));
                }
            }
            else {
                if ((_local3 is Map || this.hudModel.gameSprite.map.mouseX < 560)) {
                    this.dropItem(_local2);
                }
                else if (_local3 is CooldownTimer && curPlayer != null) {
                    var draggedXML:XML = ObjectLibrary.xmlLibrary_[_local2.itemSprite.item.ObjectType];
                    var abilXML:XML = ObjectLibrary.xmlLibrary_[curPlayer.equipment_[2].ObjectType];
                    if (draggedXML.SlotType == abilXML.SlotType) {
                        GameServerConnection.instance.invSwap(this.curPlayer, _local2.ownerGrid.owner, _local2.tileId, _local2.itemSprite.item, this.curPlayer, 2, this.curPlayer.equipment_[2]);
                    }
                }
            }
        }
        _local2.resetItemPosition();
    }

    private function petFoodCancel(itemSlot:InteractiveItemTile):Function {
        return (function ():void {
            itemSlot.blockingItemUpdates = false;
        });
    }

    private function onPotionMove(_arg1:ItemTileEvent):void {
        var _local2:InteractiveItemTile = _arg1.tile;
        var _local3:* = DisplayHierarchy.getParentWithTypeArray(_local2.getDropTarget(), TabStrip, Map);
        if (_local3 is TabStrip) {
            this.addToPotionStack(_local2);
        }
        else {
            if ((((_local3 is Map)) || ((this.hudModel.gameSprite.map.mouseX < 300)))) {
                this.dropItem(_local2);
            }
        }
        _local2.resetItemPosition();
    }

    private function addToPotionStack(_arg1:InteractiveItemTile):void {
        if (((((((!(GameServerConnection.instance != null)) || (!(this.interactive)))) || (!(_arg1 != null)))) || ((this.potionInventoryModel.getPotionModel(_arg1.getItemId()).maxPotionCount <= this.hudModel.gameSprite.map.player_.getPotionCount(_arg1.getItemId()))))) {
            return;
        }
        GameServerConnection.instance.invSwapPotion(this.curPlayer, this.owner, _arg1.tileId, _arg1.itemSprite.item, this.curPlayer, PotionInventoryModel.getPotionSlot(_arg1.getItemId()), new ItemData(null));
        _arg1.setItem(new ItemData(null));
    }

    private function canSwapItems(_arg1:InteractiveItemTile, _arg2:InteractiveItemTile):Boolean {
        if (!_arg1.canHoldItem(_arg2.getItemId())) {
            return (false);
        }
        if (!_arg2.canHoldItem(_arg1.getItemId())) {
            return (false);
        }
        if (((_arg2.parent.parent.parent as ItemGrid).owner is OneWayContainer)) {
            return (false);
        }
        if (((_arg1.blockingItemUpdates) || (_arg2.blockingItemUpdates))) {
            return (false);
        }
        return (true);
    }

    private function dropItem(_arg1:InteractiveItemTile):void {
        var _local4:Container;
        var _local5:Vector.<ItemData>;
        var _local6:int;
        var _local7:int;
        var _local2:Boolean = ObjectLibrary.isSoulbound(_arg1.itemSprite.item);
        var _local3:Container = (this.owner as Container);
        if ((((this.owner == this.curPlayer)) || (((((_local3) && ((_local3.ownerId_ == this.curPlayer.accountId_)))) && (!(_local2)))))) {
            _local4 = (this.mapModel.currentInteractiveTarget as Container);
            if (_local4) {
                _local5 = _local4.equipment_;
                _local6 = _local5.length;
                _local7 = 0;
                while (_local7 < _local6) {
                    if (_local5[_local7].ObjectType < 0) break;
                    _local7++;
                }
                if (_local7 < _local6) {
                    this.dropWithoutDestTile(_arg1, _local4, _local7);
                }
                else {
                    GameServerConnection.instance.invDrop(this.owner, _arg1.tileId, _arg1.getItemId());
                }
            }
            else {
                GameServerConnection.instance.invDrop(this.owner, _arg1.tileId, _arg1.getItemId());
            }
        }
        _arg1.setItem(new ItemData(null));
    }

    private function swapItemTiles(_arg1:ItemTile, _arg2:ItemTile):Boolean {
        if (((((((!(GameServerConnection.instance != null)) || (!(this.interactive)))) || (!(_arg1 != null)))) || (!(_arg2 != null)))) {
            return (false);
        }
        GameServerConnection.instance.invSwap(this.curPlayer, this.owner, _arg1.tileId, _arg1.itemSprite.item, _arg2.ownerGrid.owner, _arg2.tileId, _arg2.itemSprite.item);
        var _local4:ItemData = _arg1.getItemData();
        _arg1.setItem(_arg2.getItemData());
        _arg2.setItem(_local4);
        return (true);
    }

    private function dropWithoutDestTile(_arg1:ItemTile, _arg2:Container, _arg3:int):void {
        if (((((((!(GameServerConnection.instance != null)) || (!(this.interactive)))) || (!(_arg1 != null)))) || (!(_arg2 != null)))) {
            return;
        }
        GameServerConnection.instance.invSwap(this.curPlayer, this.owner, _arg1.tileId, _arg1.itemSprite.item, _arg2, _arg3, new ItemData(null));
        _arg1.setItem(new ItemData(null));
    }

    private function onShiftClick(_arg1:ItemTileEvent):void {
        var _local2:InteractiveItemTile = _arg1.tile;
        if ((((_local2.ownerGrid is InventoryGrid)) || ((_local2.ownerGrid is ContainerGrid)))) {
            GameServerConnection.instance.useItem_new(_local2.ownerGrid.owner, _local2.tileId);
        }
    }

    private function onCtrlClick(_arg1:ItemTileEvent):void {
        var _local2:InteractiveItemTile;
        var _local3:int;
        if (Parameters.data_.inventorySwap) {
            _local2 = _arg1.tile;
            if ((_local2.ownerGrid is InventoryGrid)) {
                _local3 = _local2.ownerGrid.curPlayer.swapInventoryIndex(this.tabStripModel.currentSelection);
                if (_local3 != -1) {
                    GameServerConnection.instance.invSwap(this.curPlayer, _local2.ownerGrid.owner, _local2.tileId, _local2.itemSprite.item, this.curPlayer, _local3, new ItemData(null));
                    _local2.setItem(new ItemData(null));
                }
            }
        }
    }

    private function onDoubleClick(_arg1:ItemTileEvent):void {
        var _local2:InteractiveItemTile = _arg1.tile;
        if (this.isStackablePotion(_local2)) {
            this.addToPotionStack(_local2);
        }
        else {
            if ((_local2.ownerGrid is ContainerGrid)) {
                this.equipOrUseContainer(_local2);
            }
            else {
                this.equipOrUseInventory(_local2);
            }
        }
        this.refreshTooltip();
    }

    private function isStackablePotion(_arg1:InteractiveItemTile):Boolean {
        return ((((_arg1.getItemId() == PotionInventoryModel.HEALTH_POTION_ID)) || ((_arg1.getItemId() == PotionInventoryModel.MAGIC_POTION_ID))));
    }

    private function pickUpItem(_arg1:InteractiveItemTile):void {
        var _local2:int = this.curPlayer.nextAvailableInventorySlot();
        if (_local2 != -1) {
            GameServerConnection.instance.invSwap(this.curPlayer, this.owner, _arg1.tileId, _arg1.itemSprite.item, this.curPlayer, _local2, new ItemData(null));
        }
    }

    private function equipOrUseContainer(_arg1:InteractiveItemTile):void {
        var _local2:GameObject = _arg1.ownerGrid.owner;
        var _local3:Player = this.curPlayer;
        var _local4:int = this.curPlayer.nextAvailableInventorySlot();
        if (_local4 != -1) {
            GameServerConnection.instance.invSwap(_local3, this.owner, _arg1.tileId, _arg1.itemSprite.item, this.curPlayer, _local4, new ItemData(null));
        }
        else {
            GameServerConnection.instance.useItem_new(_local2, _arg1.tileId);
        }
    }

    private function equipOrUseInventory(_arg1:InteractiveItemTile):void {
        var _local2:GameObject = _arg1.ownerGrid.owner;
        var _local3:Player = this.curPlayer;
        var _local4:int = ObjectLibrary.getMatchingSlotIndex(_arg1.getItemId(), _local3);
        if (_local4 != -1) {
            GameServerConnection.instance.invSwap(_local3, _local2, _arg1.tileId, _arg1.getItemData(), _local3, _local4, _local3.equipment_[_local4]);
        }
        else {
            GameServerConnection.instance.useItem_new(_local2, _arg1.tileId);
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
        onAddToolTip(this.tooltip);
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

    private function initContainer(rows:uint, slots:uint):void
    {
        if (initialized) return;
        initialized = true;
        trueHeight = 44 * rows;
        var container:Sprite = new Sprite();
        var shape:Shape = new Shape();
        shape.graphics.beginFill(0, 1);
        shape.graphics.drawRect(0, 0, 44 * Math.min(6, slots), Math.min(88, trueHeight));
        container.addChild(shape);
        container.addChild(inventory);
        container.mask = shape;
        addChild(container);
        if (slots <= 12) return;
        this.scrollbar = new Scrollbar(14, 88, 1.5, inventory);
        this.scrollbar.x = 44 * 6;
        this.scrollbar.setIndicatorSize(88, trueHeight);
        this.scrollbar.addEventListener(Event.CHANGE, this.onScrollBarChange);
        addChild(this.scrollbar);
        x -= 7;
    }

    private function onScrollBarChange(e:Event):void {
        if (this.inventory != null) {
            this.inventory.y = -this.scrollbar.pos() * (trueHeight - 88);
        }
    }

    protected function addToGrid(tile:ItemTile, rows:uint, index:uint, slots:int):void {
        initContainer(rows, slots);
        tile.initBackground(rows, index, slots);
        tile.addEventListener(MouseEvent.ROLL_OVER, this.onTileHover);
        var tick:Function = function (event:Event):void {
            tile.tickSprite();
        };
        tile.addEventListener(Event.ENTER_FRAME, tick);
        tile.x = 2 + (int((index % this.rowLength)) * (ItemTile.WIDTH + this.padding));
        tile.y = 2 + (int((index / this.rowLength)) * (ItemTile.HEIGHT + this.padding));
        inventory.addChild(tile);
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
