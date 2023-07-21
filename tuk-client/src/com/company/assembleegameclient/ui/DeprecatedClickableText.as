package com.company.assembleegameclient.ui {
import kabam.rotmg.text.view.TextFieldDisplayConcrete;

public class DeprecatedClickableText extends ClickableTextBase {

    public function DeprecatedClickableText(size:int, bold:Boolean, text:String, color:uint = 0xFFFFFF) {
        super(size, bold, text, color);
    }

    override protected function makeText():TextFieldDisplayConcrete {
        return (new TextFieldDisplayConcrete());
    }


}
}
