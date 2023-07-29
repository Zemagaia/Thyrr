package com.company.assembleegameclient.ui.tooltip {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.options.Options;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.tooltips.Tooltips;
import kabam.rotmg.ui.view.SignalWaiter;

import thyrr.ui.items.SimpleBox;
import thyrr.utils.Utils;

public class ToolTip extends Sprite {

    protected const waiter:SignalWaiter = new SignalWaiter();

    private var background_:uint;
    private var backgroundAlpha_:Number;
    private var outline_:uint;
    private var outlineAlpha_:Number;
    private var followMouse_:Boolean;
    private var forcePositionLeft_:Boolean = false;
    private var forcePositionRight_:Boolean = false;
    public var contentWidth_:int;
    public var contentHeight_:int;
    private var targetObj:DisplayObject;
    public var _addExtraWidth:Boolean;
    private var simpleBox:SimpleBox;

    public function ToolTip(bgColor:uint, bgAlpha:Number, outColor:uint, outAlpha:Number, followMouse:Boolean = true, extraWidth:Boolean = false) {
        simpleBox = new SimpleBox(24, 24, bgColor).setOutline(outColor);
        addChild(simpleBox);
        simpleBox.x = -6;
        simpleBox.y = -6;
        this.background_ = bgColor;
        this.backgroundAlpha_ = bgAlpha;
        this.outline_ = outColor;
        this.outlineAlpha_ = outAlpha;
        this.followMouse_ = followMouse;
        _addExtraWidth = extraWidth;
        mouseEnabled = false;
        mouseChildren = false;
        filters = [Utils.OutlineFilter];
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        this.waiter.complete.add(this.alignUIAndDraw);
    }

    private function alignUIAndDraw():void {
        this.alignUI();
        this.draw();
        this.position();
    }

    protected function alignUI():void {
    }

    public function attachToTarget(_arg1:DisplayObject):void {
        if (_arg1) {
            this.targetObj = _arg1;
            this.targetObj.addEventListener(MouseEvent.ROLL_OUT, this.onLeaveTarget);
        }
    }

    public function detachFromTarget():void {
        if (this.targetObj) {
            this.targetObj.removeEventListener(MouseEvent.ROLL_OUT, this.onLeaveTarget);
            if (parent) {
                parent.removeChild(this);
            }
            this.targetObj = null;
        }
    }

    public function forcePostionLeft():void {
        this.forcePositionLeft_ = true;
        this.forcePositionRight_ = false;
    }

    public function forcePostionRight():void {
        this.forcePositionRight_ = true;
        this.forcePositionLeft_ = false;
    }

    private function onLeaveTarget(_arg1:MouseEvent):void {
        this.detachFromTarget();
    }

    private function onAddedToStage(_arg1:Event):void {
        if (this.waiter.isEmpty()) {
            this.draw();
        }
        if (this.followMouse_) {
            this.position();
            addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        }
    }

    private function onRemovedFromStage(_arg1:Event):void {
        if (this.followMouse_) {
            removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        }
    }

    private function onEnterFrame(_arg1:Event):void {
        this.position();
    }

    protected function position() : void
    {
        var _local_1:Number = NaN;
        var _local_2:Number = NaN;
        var _local_3:Number = Main.DefaultWidth / stage.stageWidth;
        var _local_4:Number = Main.DefaultHeight / stage.stageHeight;
        if (this.parent is Options || this.parent is GameSprite)
        {
            _local_1 = (stage.mouseX + stage.stageWidth / 2 - (400 * Main.DefaultWidth / 800)) / stage.stageWidth * Main.DefaultWidth;
            _local_2 = (stage.mouseY + stage.stageHeight / 2 - (300 * Main.DefaultHeight / 600)) / stage.stageHeight * Main.DefaultHeight;
        }
        else
        {
            _local_1 = (stage.stageWidth - Main.DefaultWidth) / 2 + stage.mouseX;
            _local_2 = (stage.stageHeight - Main.DefaultHeight) / 2 + stage.mouseY;
            if(this.parent is Tooltips)
            {
                this.parent.scaleX = _local_3 / _local_4;
                this.parent.scaleY = 1;
                _local_1 = _local_1 * _local_4;
                _local_2 = _local_2 * _local_4;
            }
        }
        if(stage == null)
        {
            return;
        }
        if(stage.mouseX + 0.5 * stage.stageWidth - 400 < stage.stageWidth / 2)
        {
            x = _local_1 + 12;
        }
        else
        {
            x = _local_1 - width - 1;
        }
        if(x < 12)
        {
            x = 12;
        }
        if(stage.mouseY + 0.5 * stage.stageHeight - 300 < stage.stageHeight / 3)
        {
            y = _local_2 + 12;
        }
        else
        {
            y = _local_2 - height - 1;
        }
        if(y < 12)
        {
            y = 12;
        }
    }

    private var _extraWidth:int;
    private var _extraHeight:int;
    public function setExtraWidth(w:int):void {
        _extraWidth = w;
    }

    public function setExtraHeight(h:int):void {
        _extraHeight = h;
    }

    private var bw:int;
    private var bh:int;
    public function draw():void {
        this.contentWidth_ = width;
        this.contentHeight_ = height;
        if (bw == 0)
        {
            bw = this.contentWidth_ + (_addExtraWidth ? 12 : 0) + _extraWidth;
            bh = this.contentHeight_ + 12 + _extraHeight;
        }
        simpleBox.modify(bw, bh);
    }


}
}
