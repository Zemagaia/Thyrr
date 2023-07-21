package com.company.assembleegameclient.ui {
import flash.events.MouseEvent;

import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class TextButtonBase extends BackgroundFilledText {

    public function TextButtonBase(buttonWidth:int) {
        super(buttonWidth);
    }

    protected function initText():void {
        centerTextAndDrawButton();
        this.draw();
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
    }

    public function setText(text:String):void {
        text_.setStringBuilder(new LineBuilder().setParams(text));
    }

    public function setEnabled(enabled:Boolean):void {
        if (enabled == mouseEnabled) {
            return;
        }
        mouseEnabled = enabled;
        graphicsData_[0] = enabled ? enabledFill_ : disabledFill_;
        this.draw();
    }

    private function onMouseOver(event:MouseEvent):void {
        enabledFill_.color = 16768133;
        this.draw();
    }

    private function onRollOut(event:MouseEvent):void {
        enabledFill_.color = 0xFFFFFF;
        this.draw();
    }

    private function draw():void {
        graphics.clear();
        graphics.drawGraphicsData(graphicsData_);
    }


}
}
