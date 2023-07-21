package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.EquippedGrid;
import com.company.assembleegameclient.ui.panels.itemgrids.InventoryGrid;
import com.company.assembleegameclient.ui.panels.itemgrids.ItemGrid;
import com.company.util.GraphicsUtil;

import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;

import thyrr.ui.items.InventorySlot;

import thyrr.utils.ItemData;

public class ItemTile extends Sprite {

    // public static const TILE_DOUBLE_CLICK:String = "TILE_DOUBLE_CLICK";
    // public static const TILE_SINGLE_CLICK:String = "TILE_SINGLE_CLICK";
    public static const WIDTH:int = 40;
    public static const HEIGHT:int = 40;
    public static const BORDER:int = 4;

    private var background:InventorySlot;
    public var itemSprite:ItemTileSprite;
    public var tileId:int;
    public var ownerGrid:ItemGrid;
    public var blockingItemUpdates:Boolean;

    private var itemContainer:Sprite;

    private var itemTileSprite_:ItemTileSprite;

    public function ItemTile(id:int, ownerGrid:ItemGrid)
    {
        super();
        this.tileId = id;
        this.ownerGrid = ownerGrid;
        this.init();
    }

    private function init() : void
    {
        this.itemTileSprite_ = new ItemTileSprite(this.ownerGrid.curPlayer);
        this.setItemSprite(itemTileSprite_);
    }

    public function updateLevelReqIconVisibility(player:Player):void {
        this.itemTileSprite_.updateLevelReqIconVisibility(player);
    }

    public function tickSprite():void {
        this.itemTileSprite_.tickSprite();
    }

    public function initBackground(rows:int, index:int, slots:int):void {
        this.background = new InventorySlot(index, slots, rows);
        this.background.x = this.background.y = - 2;
        addChild(this.background);
        removeChild(this.itemContainer);
        this.setItemSprite(itemTileSprite_);
    }

    public function setItem(itemData:ItemData):Boolean {
        if (this.itemSprite.item && itemData && itemData.ObjectType == this.itemSprite.item.ObjectType && itemData == this.itemSprite.item) {
            return (false);
        }
        if (this.blockingItemUpdates) {
            return (true);
        }
        this.itemSprite.setType(itemData);
        return (true);
    }

    public function setItemSprite(_arg_1:ItemTileSprite) : void
    {
        this.itemContainer = new Sprite();
        addChild(this.itemContainer);
        this.itemSprite = _arg_1;
        this.itemSprite.x = WIDTH / 2;
        this.itemSprite.y = HEIGHT / 2;
        this.itemContainer.addChild(this.itemSprite);
    }

    public function canHoldItem(_arg1:int):Boolean {
        return (true);
    }

    public function resetItemPosition():void {
        this.setItemSprite(this.itemSprite);
    }

    public function getItemId():int {
        if ((((this.itemSprite.item.ObjectType >= 0x9000)) && ((this.itemSprite.item.ObjectType < 0xF000)))) {
            return (36863);
        }
        return (this.itemSprite.item.ObjectType);
    }

    public function getItemData():ItemData {
        return (this.itemSprite.item);
    }

    protected function getBackgroundColor() : int
    {
        return 5526612;
    }

}
}
