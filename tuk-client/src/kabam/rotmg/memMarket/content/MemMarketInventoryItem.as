﻿
//kabam.rotmg.memMarket.content.MemMarketInventoryItem

package kabam.rotmg.memMarket.content
{
    import kabam.rotmg.memMarket.utils.ItemUtils;
    import kabam.rotmg.memMarket.utils.TintUtils;
    import flash.events.MouseEvent;
    import com.company.assembleegameclient.game.GameSprite;

import thyrr.utils.ItemData;

public class MemMarketInventoryItem extends MemMarketItem
    {

        public var slot_:int;
        public var selected_:Boolean;

        public function MemMarketInventoryItem(gameSprite:GameSprite, itemData:ItemData, slot:int)
        {
            super(gameSprite, SLOT_WIDTH, SLOT_HEIGHT, 80, itemData, null);
            this.slot_ = slot;
            if (this.itemType_ != -1)
            {
                if (ItemUtils.isBanned(this.itemData_))
                {
                    TintUtils.addTint(this.shape_, 6036765, 0.4);
                }
                else
                {
                    addEventListener(MouseEvent.CLICK, this.onClick);
                }
            }
        }

        private function onClick(event:MouseEvent):void
        {
            this.selected_ = (!(this.selected_));
            if (this.selected_)
            {
                TintUtils.addTint(this.shape_, 16758335, 0.4);
            }
            else
            {
                TintUtils.removeTint(this.shape_);
            }
        }

        public function reset():void
        {
            this.itemType_ = -1;
            this.selected_ = false;
            TintUtils.removeTint(this.shape_);
            removeEventListener(MouseEvent.CLICK, this.onClick);
            removeChild(this.icon_);
            if (this.quality_) {
                removeChild(this.quality_);
                this.quality_ = null;
            }
            this.icon_ = null;
            if (this.toolTip_ != null)
            {
                this.toolTip_.parent.removeChild(this.toolTip_);
                this.toolTip_ = null;
            }
            this.removeListeners();
        }

        override public function dispose():void
        {
            removeEventListener(MouseEvent.CLICK, this.onClick);
            super.dispose();
        }


    }
}//package kabam.rotmg.memMarket.content

