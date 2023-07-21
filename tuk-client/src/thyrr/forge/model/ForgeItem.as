package thyrr.forge.model {

import com.company.assembleegameclient.objects.Player;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.util.ItemWithTooltip;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.util.components.DialogBackground;

import thyrr.forge.tabs.ForgeTab;
import thyrr.forge.tabs.RuneTab;
import thyrr.utils.ItemData;

public class ForgeItem extends Sprite {

    private var background_:DialogBackground;

    public var itemWithTooltip_:ItemWithTooltip;
    public var selected_:Boolean;
    public var slot_:int; // default to -1 from constructor
    public var assignedSlot_:int = -1;
    public var objType_:int;
    public var player_:Player;
    public var itemData_:ItemData;

    public function ForgeItem(item:ItemData, player:Player = null, slot:int = -1, addListeners:Boolean = true) {
        this.objType_ = item.ObjectType;
        this.player_ = player;
        this.itemData_ = item;
        this.slot_ = slot;
        this.background_ = new DialogBackground();
        addChild(this.background_);
        if (this.objType_ > 0) {
            this.itemWithTooltip_ = new ItemWithTooltip(this.objType_, 80, true, this.player_, this.itemData_);
            this.itemWithTooltip_.x = -8;
            this.itemWithTooltip_.y = -8;
            addChild(this.itemWithTooltip_);
        }
        if (item.ObjectType > 0 && !addListeners)
            drawBackground(0xD37337, 0x2B2B2B);
        else
            drawBackground(0x7B7B7B, 0x2B2B2B);
        if (addListeners) {
            addEventListener(MouseEvent.CLICK, this.onSelected);
            addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        }
    }

    private function drawBackground(lineColor:uint, backColor:uint):void {
        this.background_.graphics.clear();
        this.background_.draw(40, 40, 0, lineColor, backColor);
    }

    private function onSelected(event:MouseEvent):void {
        this.selected_ = !this.selected_;
        if (parent is ForgeTab)
            (parent as ForgeTab).updateSelected(this.slot_);
        else if (parent is RuneTab)
            (parent as RuneTab).updateSelected(this.slot_);
    }

    /// Update background color;
    /// <p>Set selected to false if <b>lineColor</b> is 0x7B7B7B and <b>backColor</b> is 0x2B2B2B</p>
    public function setBackground(lineColor:uint, backColor:uint):void {
        this.drawBackground(lineColor, backColor);
        if (lineColor == 0x7B7B7B && backColor == 0x2B2B2B) {
            this.selected_ = false;
        }
    }

    /// Update item with tooltip
    public function setItem(itemType:int, player:Player = null, itemData:ItemData = null):void {
        this.objType_ = itemType;
        this.player_ = player;
        this.itemData_ = itemData;
        if (itemType != -1) {
            this.itemWithTooltip_ = new ItemWithTooltip(itemType, 80, true, player, itemData);
            this.itemWithTooltip_.x = -8;
            this.itemWithTooltip_.y = -8;
            addChild(this.itemWithTooltip_);
        }
        else
            if (contains(this.itemWithTooltip_))
                removeChild(this.itemWithTooltip_);
    }

    /// Add some text (used for result on forge, so that's why it's named like that)
    public function setResult():void {
        var text:TextFieldDisplayConcrete = new TextFieldDisplayConcrete();
        text.setStringBuilder(new StaticStringBuilder("?")).setSize(24).setColor(0xFFFFFF).setBold(true);
        text.x = 13;
        text.y = 8;
        text.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(text);
        removeEventListener(MouseEvent.CLICK, this.onSelected);
    }

    private function onRemovedFromStage(e:Event):void {
        this.itemWithTooltip_ = null;
    }

}
}