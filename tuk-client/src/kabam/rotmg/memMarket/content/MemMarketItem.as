﻿
//kabam.rotmg.memMarket.content.MemMarketItem

package kabam.rotmg.memMarket.content
{
import com.company.assembleegameclient.ui.tooltip.TooltipHelper;
import com.company.assembleegameclient.util.FilterUtil;

import flash.display.Sprite;
    import com.company.assembleegameclient.game.GameSprite;

import flash.text.TextFieldAutoSize;

import kabam.rotmg.messaging.impl.data.MarketData;
    import flash.display.Shape;
    import flash.display.Bitmap;
    import com.company.assembleegameclient.ui.tooltip.ToolTip;
    import com.company.assembleegameclient.objects.ObjectLibrary;
    import flash.events.MouseEvent;
    import flash.display.Graphics;
    import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
    import com.company.assembleegameclient.constants.InventoryOwnerTypes;
    import kabam.rotmg.text.view.TextFieldDisplayConcrete;
    import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

    import thyrr.utils.ItemData;

    public class MemMarketItem extends Sprite 
    {

        public static const OFFER_WIDTH:int = 100;
        public static const OFFER_HEIGHT:int = 83;
        public static const SLOT_WIDTH:int = 50;
        public static const SLOT_HEIGHT:int = 50;

        public var gameSprite_:GameSprite;
        public var itemType_:int;
        public var itemData_:ItemData;
        public var id_:int;
        public var data_:MarketData;
        public var shape_:Shape;
        public var icon_:Bitmap;
        public var toolTip_:ToolTip;
        public var quality_:TextFieldDisplayConcrete;

        public function MemMarketItem(gameSprite:GameSprite, width:int, height:int, iconSize:int, itemData:ItemData, data:MarketData)
        {
            this.gameSprite_ = gameSprite;
            this.itemData_ = itemData;
            this.itemType_ = itemData.ObjectType;
            this.id_ = ((data == null) ? -1 : data.id_);
            this.data_ = data;
            this.shape_ = new Shape();
            drawRoundRectAsFill(this.shape_.graphics, 0, 0, width, height, 5);
            addChild(this.shape_);
            if (this.itemType_ != -1)
            {
                this.icon_ = new Bitmap(ObjectLibrary.getRedrawnTextureFromType(this.itemType_, iconSize, true));
                this.icon_.x = -3;
                this.icon_.y = -3;
                addChild(this.icon_);
                addEventListener(MouseEvent.MOUSE_OVER, this.onOver);
                addEventListener(MouseEvent.MOUSE_OUT, this.onOut);
                if (this.itemData_) {
                    var quality:Number = this.itemData_.Quality;
                    if (quality > 0.0) {
                        var color:uint = (quality >= 1.15 ? TooltipHelper.UNTIERED_COLOR : quality >= 1.05 ? 0x00FF00 :
                                quality >= 1.0 ? 16777103 : quality >= 0.95 ? 0xFF9900 : 0xFF0000);
                        this.quality_ = new TextFieldDisplayConcrete().setColor(color).setSize(10).setBold(true);
                        var text:String = (quality * 100).toFixed() + "%";
                        this.quality_.setStringBuilder(new StaticStringBuilder(text)).setAutoSize(TextFieldAutoSize.RIGHT);
                        this.quality_.x = 55 + this.icon_.x;
                        this.quality_.y = 2;
                        addChild(this.quality_);
                        this.quality_.filters = FilterUtil.getTextOutlineFilter();
                    }
                }
            }
        }

        public static function drawRoundRectAsFill(graphics:Graphics, x:Number, y:Number, w:Number, h:Number, radius:Number, lineColor:uint=0x676767, fillColor:uint=0x454545, lineThickness:Number=1, lineAlpha:Number=1, fillAlpha:Number=1):void
        {
            graphics.lineStyle(0, 0, 0);
            graphics.beginFill(lineColor, lineAlpha);
            graphics.drawRoundRect(x, y, w, h, (2 * radius), (2 * radius));
            graphics.drawRoundRect((x + lineThickness), (y + lineThickness), (w - (2 * lineThickness)), (h - (2 * lineThickness)), ((2 * radius) - (2 * lineThickness)), ((2 * radius) - (2 * lineThickness)));
            graphics.endFill();
            graphics.beginFill(fillColor, fillAlpha);
            graphics.drawRoundRect((x + lineThickness), (y + lineThickness), (w - (2 * lineThickness)), (h - (2 * lineThickness)), ((2 * radius) - (2 * lineThickness)), ((2 * radius) - (2 * lineThickness)));
            graphics.endFill();
        }


        protected function removeListeners():void
        {
            removeEventListener(MouseEvent.MOUSE_OVER, this.onOver);
            removeEventListener(MouseEvent.MOUSE_OUT, this.onOut);
        }

        private function onOver(event:MouseEvent):void
        {
            this.toolTip_ = new EquipmentToolTip(this.itemData_, this.gameSprite_.map.player_, this.gameSprite_.map.player_.objectType_, InventoryOwnerTypes.MARKET);
            this.gameSprite_.addChild(this.toolTip_);
            this.icon_.alpha = 0.7;
        }

        private function onOut(event:MouseEvent):void
        {
            this.toolTip_.parent.removeChild(this.toolTip_);
            this.toolTip_ = null;
            this.icon_.alpha = 1;
        }

        public function dispose():void
        {
            this.gameSprite_ = null;
            this.shape_ = null;
            this.icon_ = null;
            if (this.quality_)
                this.quality_ = null;
            if (this.toolTip_ != null)
            {
                this.toolTip_.parent.removeChild(this.toolTip_);
                this.toolTip_ = null;
            }
            this.removeListeners();
            var i:int = (numChildren - 1);
            while (i >= 0)
            {
                removeChildAt(i);
                i--;
            }
        }


    }
}//package kabam.rotmg.memMarket.content

