package com.company.assembleegameclient.ui {
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import org.osflash.signals.Signal;

public class DeprecatedTextButton extends TextButtonBase {

    public const textChanged:Signal = new Signal();

    public function DeprecatedTextButton(size:int, text:String, buttonWidth:int = 0, staticStringBuilder:Boolean = false) {
        super(buttonWidth);
        addText(size);
        if (staticStringBuilder) {
            text_.setStringBuilder(new StaticStringBuilder(text));
        }
        else {
            text_.setStringBuilder(new LineBuilder().setParams(text));
        }
        text_.textChanged.add(this.onTextChanged);
    }

    protected function onTextChanged():void {
        initText();
        this.textChanged.dispatch();
    }


}
}
