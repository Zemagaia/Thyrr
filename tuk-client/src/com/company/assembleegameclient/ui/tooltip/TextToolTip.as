package com.company.assembleegameclient.ui.tooltip {
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;

public class TextToolTip extends ToolTip {

    public var titleText_:TextFieldDisplayConcrete;
    public var tipText_:TextFieldDisplayConcrete;

    public function TextToolTip(color:uint, outlineColor:uint, titleText:String, tipText:String, width:int, tokens:Object = null) {
        super(color, 1, outlineColor, 1);
        setExtraWidth(8);
        if (titleText != null) {
            this.titleText_ = new TextFieldDisplayConcrete().setSize(20).setColor(0xFFFFFF);
            this.configureTextFieldDisplayAndAddChild(this.titleText_, width, titleText);
        }
        if (tipText != null) {
            this.tipText_ = new TextFieldDisplayConcrete().setSize(14).setColor(0xB3B3B3).setHTML(true);
            this.configureTextFieldDisplayAndAddChild(this.tipText_, width, tipText, tokens);
        }
    }

    override protected function alignUI():void {
        this.tipText_.y = ((this.titleText_) ? (this.titleText_.height + 8) : 0);
    }

    public function configureTextFieldDisplayAndAddChild(textField:TextFieldDisplayConcrete, width:int, key:String, tokens:Object = null):void {
        textField.setAutoSize(TextFieldAutoSize.LEFT);
        textField.setWordWrap(true).setTextWidth(width);
        textField.setStringBuilder(new LineBuilder().setParams(key, tokens));
        textField.filters = [new DropShadowFilter(0, 0, 0)];
        waiter.push(textField.textChanged);
        addChild(textField);
    }

    public function setTitle(builder:StringBuilder):void {
        this.titleText_.setStringBuilder(builder);
        draw();
    }

    public function setText(builder:StringBuilder):void {
        this.tipText_.setStringBuilder(builder);
        draw();
    }


}
}
