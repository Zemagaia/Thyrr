﻿package com.company.assembleegameclient.ui.icons {
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.tooltip.TextToolTip;
import com.company.util.KeyCodes;
import com.company.util.MoreColorUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.tooltips.HoverTooltipDelegate;

public class IconButton extends Sprite {

    protected static const mouseOverCT:ColorTransform = new ColorTransform(1, (220 / 0xFF), (133 / 0xFF));
    protected static const disableCT:ColorTransform = new ColorTransform(0.6, 0.6, 0.6, 1);

    public var hoverTooltipDelegate:HoverTooltipDelegate;
    protected var origIconBitmapData_:BitmapData;
    protected var iconBitmapData_:BitmapData;
    protected var icon_:Bitmap;
    protected var label_:TextFieldDisplayConcrete;
    protected var hotkeyName_:String;
    protected var ct_:ColorTransform = null;
    private var toolTip_:TextToolTip = null;

    public function IconButton(_arg1:BitmapData, _arg2:String, _arg3:String, _arg4:String = "") {
        this.hoverTooltipDelegate = new HoverTooltipDelegate();
        super();
        this.origIconBitmapData_ = _arg1;
        this.icon_ = new Bitmap(this.origIconBitmapData_);
        this.icon_.x = -12;
        this.icon_.y = -12;
        this.icon_.scaleY = this.icon_.scaleX = 2;
        addChild(this.icon_);
        if (_arg2 != "") {
            this.label_ = new TextFieldDisplayConcrete().setColor(0xFFFFFF).setSize(14);
            this.label_.setStringBuilder(new LineBuilder().setParams(_arg2));
            this.label_.x = ((this.icon_.x + this.icon_.width) - 8);
            this.label_.y = 0;
            addChild(this.label_);
        }
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        this.setToolTipTitle(_arg3);
        this.hotkeyName_ = _arg4;
        if (this.hotkeyName_ != "") {
            this.setToolTipText("Hotkey: {hotkey}", {"hotkey": KeyCodes.CharCodeStrings[Parameters.data_[this.hotkeyName_]]});
        }
    }

    public function destroy():void {
        removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        this.hoverTooltipDelegate.removeDisplayObject();
        this.hoverTooltipDelegate.tooltip = null;
        this.hoverTooltipDelegate = null;
        this.origIconBitmapData_ = null;
        this.iconBitmapData_ = null;
        this.icon_ = null;
        this.label_ = null;
        this.toolTip_ = null;
    }

    public function setToolTipTitle(_arg1:String, _arg2:Object = null):void {
        if (_arg1 != "") {
            if (this.toolTip_ == null) {
                this.toolTip_ = new TextToolTip(0x2B2B2B, 0x7B7B7B, "", "", 200);
                this.hoverTooltipDelegate.setDisplayObject(this);
                this.hoverTooltipDelegate.tooltip = this.toolTip_;
            }
            this.toolTip_.setTitle(new LineBuilder().setParams(_arg1, _arg2));
        }
    }

    public function setToolTipText(_arg1:String, _arg2:Object = null):void {
        if (_arg1 != "") {
            if (this.toolTip_ == null) {
                this.toolTip_ = new TextToolTip(0x2B2B2B, 0x7B7B7B, "", "", 200);
                this.hoverTooltipDelegate.setDisplayObject(this);
                this.hoverTooltipDelegate.tooltip = this.toolTip_;
            }
            this.toolTip_.setText(new LineBuilder().setParams(_arg1, _arg2));
        }
    }

    public function setColorTransform(_arg1:ColorTransform):void {
        if (_arg1 == this.ct_) {
            return;
        }
        this.ct_ = _arg1;
        if (this.ct_ == null) {
            transform.colorTransform = MoreColorUtil.identity;
        }
        else {
            transform.colorTransform = this.ct_;
        }
    }

    public function set enabled(_arg1:Boolean):void {
        if (_arg1) {
            addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
            this.setColorTransform(null);
            mouseEnabled = (mouseChildren = true);
        }
        else {
            removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
            this.setColorTransform(disableCT);
            mouseEnabled = (mouseChildren = false);
        }
    }

    protected function onMouseOver(_arg1:MouseEvent):void {
        this.setColorTransform(mouseOverCT);
    }

    protected function onMouseOut(_arg1:MouseEvent):void {
        this.setColorTransform(null);
    }

}
}
