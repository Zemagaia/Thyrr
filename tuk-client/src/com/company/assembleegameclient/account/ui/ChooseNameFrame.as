package com.company.assembleegameclient.account.ui {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.game.events.NameResultEvent;

import flash.events.MouseEvent;



import org.osflash.signals.Signal;

public class ChooseNameFrame extends Frame {

    private var name_:String;
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
        Global.closeDialogs();
    }

    private function onChoose(_arg1:MouseEvent):void {
        this.name_ = this.nameInput.text();
        this.gameSprite.addEventListener(NameResultEvent.NAMERESULTEVENT, this.onNameResult);
        this.gameSprite.gsc_.chooseName(this.name_);
        this.disable();
        disable();
    }

    public function onNameResult(_arg1:NameResultEvent):void {
        this.gameSprite.removeEventListener(NameResultEvent.NAMERESULTEVENT, this.onNameResult);
        var _local2:Boolean = _arg1.m_.success_;
        if (_local2) {
            this.handleSuccessfulNameChange();
        }
        else {
            this.handleFailedNameChange(_arg1.m_.errorText_);
        }
    }

    private function handleSuccessfulNameChange():void {
        this.gameSprite.model.setName(this.name_);
        this.gameSprite.map.player_.name_ = this.name_;
        Global.closeDialogs();
        Global.changeName(this.name_);
    }

    private function handleFailedNameChange(_arg1:String):void {
        this.setError(_arg1);
        this.enable();
    }

    public function setError(_arg1:String):void {
        this.nameInput.setError(_arg1);
    }


}
}
