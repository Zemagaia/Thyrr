package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles
{
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.ItemGrid;
import com.company.assembleegameclient.util.EquipmentUtil;
import com.company.assembleegameclient.util.FilterUtil;

import flash.display.Bitmap;

import thyrr.utils.ItemData;

public class EquipmentTile extends InteractiveItemTile
{

    public var backgroundDetail:Bitmap;
    public var itemType:int;
    private var minManaUsage:int;

    public function EquipmentTile(id:int, itemGrid:ItemGrid, interactive:Boolean)
    {
        super(id, itemGrid, interactive);
    }

    override public function canHoldItem(_arg_1:int):Boolean
    {
        return ((_arg_1 <= 0) || (this.itemType == ObjectLibrary.getSlotTypeFromType(_arg_1)));
    }

    public function setType(_arg_1:int):void
    {
        this.backgroundDetail = EquipmentUtil.getEquipmentBackground(_arg_1, 4);
        if (this.backgroundDetail)
        {
            this.backgroundDetail.x = BORDER;
            this.backgroundDetail.y = BORDER;
            this.backgroundDetail.filters = FilterUtil.getNewGrayColorFilter();
            addChildAt(this.backgroundDetail, 1);
        }
        this.itemType = _arg_1;
    }

    override public function setItem(itemData:ItemData):Boolean
    {
        var _local_2:Boolean = super.setItem(itemData);
        if (_local_2)
        {
            this.backgroundDetail.visible = (itemSprite.item.ObjectType <= 0);
            this.updateMinMana();
        }
        return (_local_2);
    }

    private function updateMinMana():void
    {
        var item:XML;
        this.minManaUsage = 0;
        if (itemSprite.item.ObjectType <= 0)
        {
            return;
        }
        item = ObjectLibrary.xmlLibrary_[itemSprite.item.ObjectType];
        if (((item) && (item.hasOwnProperty("Usable"))))
        {
            if (item.hasOwnProperty("MultiPhase"))
            {
                this.minManaUsage = item.MpEndCost;
            }
            else
            {
                this.minManaUsage = item.MpCost;
            }
        }
    }

    public function updateDim(player:Player):void
    {
        itemSprite.setDim(player && (player.mp_ < this.minManaUsage || (player.isSuppressed() && this.minManaUsage > 0)));
    }

    override protected function beginDragCallback():void
    {
        this.backgroundDetail.visible = true;
    }

    override protected function endDragCallback():void
    {
        this.backgroundDetail.visible = (itemSprite.item.ObjectType <= 0);
    }


}
}//package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles

