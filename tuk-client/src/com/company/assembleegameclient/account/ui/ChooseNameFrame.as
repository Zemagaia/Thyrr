package com.company.assembleegameclient.account.ui {
import com.company.assembleegameclient.game.GameSprite;

import flash.events.MouseEvent;



import org.osflash.signals.Signal;

public class ChooseNameFrame extends Frame {

    public const cancel:Signal = new Signal();
    public const choose:Signal = new Signal(String);

    public var gameSprite:GameSprite;
    public var isPurchase:Boolean;
    private var nameInput:TextInputField;

    public function ChooseNameFrame(_arg1:GameSprite, _arg2:Boolean) {
        super("Choose a unique account name", "Cancel", "Choose");
        this.gameSprite = _arg1;
        this.isPurchase = _arg2;
        this.nameInput = new TextInputField("Name", false);
        this.nameInput.inputText_.restrict = "A-Za-z";
        var _local3:int = 10;
        this.nameInput.inputText_.maxChars = _local3;
        addTextInputField(this.nameInput);
        addPlainText("Maximum {maxChars} characters", {"maxChars": _local3});
        addPlainText("No numbers, spaces or punctuation");
        addPlainText("Racism or profanity gets you banned");
        leftButton_.addEventListener(MouseEvent.CLICK, this.onCancel);
        rightButton_.addEventListener(MouseEvent.CLICK, this.onChoose);
    }

    private function onCancel(_arg1:MouseEvent):void {
        this.cancel.dispatch();
    }

    private function onChoose(_arg1:MouseEvent):void {
        this.choose.dispatch(this.nameInput.text());
        disable();
    }

    public function setError(_arg1:String):void {
        this.nameInput.setError(_arg1);
    }


}
}
