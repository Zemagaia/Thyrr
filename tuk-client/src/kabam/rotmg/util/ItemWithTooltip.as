package kabam.rotmg.util {
import com.company.assembleegameclient.constants.InventoryOwnerTypes;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.ui.tooltip.ToolTip;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.tooltips.HoverTooltipDelegate;

import org.osflash.signals.Signal;

import thyrr.utils.ItemData;

public class ItemWithTooltip extends Sprite {

    public var hoverTooltipDelegate:HoverTooltipDelegate;
    private var tooltip:ToolTip;
    public var onMouseOver:Signal;
    public var onMouseOut:Signal;
    public var itemBitmap:Bitmap;

    public function ItemWithTooltip(itemType:int, size:int = 100, addListeners:Boolean = false, player:Player = null, itemData:ItemData = null) {
        itemData = itemData != null ? itemData : new ItemData(null);
        itemData.ObjectType = itemType;
        this.hoverTooltipDelegate = new HoverTooltipDelegate();
        this.onMouseOver = new Signal();
        this.onMouseOut = new Signal();
        super();
        var item:BitmapData = ObjectLibrary.getRedrawnTextureFromType(itemType, size, true, false);
        this.itemBitmap = new Bitmap(item);
        addChild(this.itemBitmap);
        this.hoverTooltipDelegate.setDisplayObject(this);
        this.tooltip = new EquipmentToolTip(itemData, player, -1, InventoryOwnerTypes.NPC);
        this.tooltip.forcePostionLeft();
        this.hoverTooltipDelegate.tooltip = this.tooltip;
        if (addListeners) {
            addEventListener(Event.REMOVED_FROM_STAGE, this.onDestruct);
            addEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
            addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        }
    }

    public function disableTooltip():void {
        this.hoverTooltipDelegate.removeDisplayObject();
    }

    public function enableTooltip():void {
        this.hoverTooltipDelegate.setDisplayObject(this);
    }

    private function onDestruct(_arg1:Event):void {
        removeEventListener(Event.REMOVED_FROM_STAGE, this.onDestruct);
        removeEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
        removeEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        dispose();
    }

    public function dispose():void {
        var i:int = 0;
        while (i < numChildren){
            removeChildAt(i);
            i++;
        }
        this.hoverTooltipDelegate = null;
        this.tooltip = null;
        this.onMouseOver = null;
        this.onMouseOut = null;
        this.itemBitmap.bitmapData = null;
    }

    private function onRollOver(event:MouseEvent):void {
        this.onMouseOver.dispatch();
    }

    private function onRollOut(event:MouseEvent):void {
        this.onMouseOut.dispatch();
    }

}
}
