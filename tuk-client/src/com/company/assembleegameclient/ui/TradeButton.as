﻿package com.company.assembleegameclient.ui {
import com.company.util.GraphicsUtil;

import flash.display.CapsStyle;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;
import flash.utils.getTimer;


import kabam.rotmg.text.view.StaticTextDisplay;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class TradeButton extends BackgroundFilledText {

    private static const WAIT_TIME:int = 2999;
    private static const COUNTDOWN_STATE:int = 0;
    private static const NORMAL_STATE:int = 1;
    private static const WAITING_STATE:int = 2;
    private static const DISABLED_STATE:int = 3;

    public var statusBar_:Sprite;
    public var barMask_:Shape;
    public var myText:StaticTextDisplay;
    public var h_:int;
    private var state_:int;
    private var lastResetTime_:int;
    private var barGraphicsData_:Vector.<IGraphicsData>;
    private var outlineGraphicsData_:Vector.<IGraphicsData>;

    public function TradeButton(_arg1:int, _arg2:int = 0) {
        super(_arg2);
        this.makeGraphics();
        this.lastResetTime_ = getTimer();
        this.myText = new StaticTextDisplay();
        this.myText.setAutoSize(TextFieldAutoSize.CENTER).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        this.myText.setSize(_arg1).setColor(0x363636).setBold(true);
        this.myText.setStringBuilder(new LineBuilder().setParams("Trade"));
        w_ = (((_arg2) != 0) ? _arg2 : (this.myText.width + 12));
        this.h_ = (this.myText.height + 8);
        this.myText.x = (w_ / 2);
        this.myText.y = (this.h_ / 2);
        GraphicsUtil.clearPath(path_);
        GraphicsUtil.drawCutEdgeRect(0, 0, w_, (this.myText.height + 8), 4, [1, 1, 1, 1], path_);
        this.statusBar_ = this.newStatusBar();
        addChild(this.statusBar_);
        addChild(this.myText);
        this.draw();
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        addEventListener(MouseEvent.CLICK, this.onClick);
    }

    private function makeGraphics():void {
        var _local1:GraphicsSolidFill = new GraphicsSolidFill(0xBFBFBF, 1);
        this.barGraphicsData_ = new <IGraphicsData>[_local1, path_, GraphicsUtil.END_FILL];
        var _local2:GraphicsSolidFill = new GraphicsSolidFill(0xFFFFFF, 1);
        var _local3:GraphicsStroke = new GraphicsStroke(2, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3, _local2);
        this.outlineGraphicsData_ = new <IGraphicsData>[_local3, path_, GraphicsUtil.END_STROKE];
    }

    public function reset():void {
        this.lastResetTime_ = getTimer();
        this.state_ = COUNTDOWN_STATE;
        this.setEnabled(false);
        this.setText("Trade");
    }

    public function disable():void {
        this.state_ = DISABLED_STATE;
        this.setEnabled(false);
        this.setText("Trade");
    }

    private function setText(_arg1:String):void {
        this.myText.setStringBuilder(new LineBuilder().setParams(_arg1));
    }

    private function setEnabled(_arg1:Boolean):void {
        if (_arg1 == mouseEnabled) {
            return;
        }
        mouseEnabled = _arg1;
        mouseChildren = _arg1;
        graphicsData_[0] = ((_arg1) ? enabledFill_ : disabledFill_);
        this.draw();
    }

    private function onAddedToStage(_arg1:Event):void {
        addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
        this.reset();
        this.draw();
    }

    private function onRemovedFromStage(_arg1:Event):void {
        removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
    }

    private function onEnterFrame(_arg1:Event):void {
        this.draw();
    }

    private function onMouseOver(_arg1:MouseEvent):void {
        enabledFill_.color = 16768133;
        this.draw();
    }

    private function onRollOut(_arg1:MouseEvent):void {
        enabledFill_.color = 0xFFFFFF;
        this.draw();
    }

    private function onClick(_arg1:MouseEvent):void {
        this.state_ = WAITING_STATE;
        this.setEnabled(false);
        this.setText("Waiting");
    }

    private function newStatusBar():Sprite {
        var _local1:Sprite = new Sprite();
        var _local2:Sprite = new Sprite();
        var _local3:Shape = new Shape();
        _local3.graphics.clear();
        _local3.graphics.drawGraphicsData(this.barGraphicsData_);
        _local2.addChild(_local3);
        this.barMask_ = new Shape();
        _local2.addChild(this.barMask_);
        _local2.mask = this.barMask_;
        _local1.addChild(_local2);
        var _local4:Shape = new Shape();
        _local4.graphics.clear();
        _local4.graphics.drawGraphicsData(this.outlineGraphicsData_);
        _local1.addChild(_local4);
        return (_local1);
    }

    private function drawCountDown(_arg1:Number):void {
        this.barMask_.graphics.clear();
        this.barMask_.graphics.beginFill(0xBFBFBF);
        this.barMask_.graphics.drawRect(0, 0, (w_ * _arg1), this.h_);
        this.barMask_.graphics.endFill();
    }

    private function draw():void {
        var _local1:int;
        var _local2:Number;
        _local1 = getTimer();
        if (this.state_ == COUNTDOWN_STATE) {
            if ((_local1 - this.lastResetTime_) >= WAIT_TIME) {
                this.state_ = NORMAL_STATE;
                this.setEnabled(true);
            }
        }
        switch (this.state_) {
            case COUNTDOWN_STATE:
                this.statusBar_.visible = true;
                _local2 = ((_local1 - this.lastResetTime_) / WAIT_TIME);
                this.drawCountDown(_local2);
                break;
            case DISABLED_STATE:
            case NORMAL_STATE:
            case WAITING_STATE:
                this.statusBar_.visible = false;
                break;
        }
        graphics.clear();
        graphics.drawGraphicsData(graphicsData_);
    }


}
}
