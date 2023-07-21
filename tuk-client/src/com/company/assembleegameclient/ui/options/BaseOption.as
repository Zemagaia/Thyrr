package com.company.assembleegameclient.ui.options {
import com.company.assembleegameclient.ui.tooltip.TextToolTip;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;

public class BaseOption extends Option {

    public var paramName_:String;
    private var tooltipText_:String;
    protected var tooltip_:TextToolTip;
    protected var desc_:TextFieldDisplayConcrete;

    public function BaseOption(param:String, descParam:String, tooltipText:String) {
        this.paramName_ = param;
        this.tooltipText_ = tooltipText;
        this.desc_ = new TextFieldDisplayConcrete().setSize(18).setColor(0xB3B3B3);
        this.desc_.setStringBuilder(new LineBuilder().setParams(descParam));
        this.desc_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 2)];
        this.desc_.x = (KeyCodeBox.WIDTH + 24);
        this.desc_.mouseEnabled = true;
        this.desc_.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        this.desc_.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        addChild(this.desc_);
        this.tooltip_ = new TextToolTip(0x2B2B2B, 0x7B7B7B, null, this.tooltipText_, 160);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        textChanged = this.desc_.textChanged;
    }

    public function setDescription(_arg1:StringBuilder):void {
        this.desc_.setStringBuilder(_arg1);
    }

    public function setTooltipText(_arg1:StringBuilder):void {
        this.tooltip_.setText(_arg1);
    }

    public function refresh():void {
    }

    private function onMouseOver(_arg1:MouseEvent):void {
        parent.addChild(this.tooltip_);
    }

    private function onRollOut(_arg1:MouseEvent):void {
        this.removeToolTip();
    }

    private function onRemovedFromStage(_arg1:Event):void {
        this.removeToolTip();
    }

    private function removeToolTip():void {
        if (((!((this.tooltip_ == null))) && (parent.contains(this.tooltip_)))) {
            parent.removeChild(this.tooltip_);
        }
    }


}
}
