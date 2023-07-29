package com.company.assembleegameclient.account.ui {
import com.company.util.MoreObjectUtil;

import flash.events.MouseEvent;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.core.model.PlayerModel;

public class NewChooseNameFrame extends Frame {

    public var account:Account = Global.account;
    public var client:AppEngineClient = Global.appEngine;
    public var playerModel:PlayerModel = Global.playerModel;
    private var input:TextInputField;
    private var name_:String

    public function NewChooseNameFrame() {
        super("Choose a unique account name", "Cancel", "Choose");
        this.input = new TextInputField("Name", false);
        this.input.inputText_.restrict = "A-Za-z";
        var _local1:int = 10;
        this.input.inputText_.maxChars = _local1;
        addTextInputField(this.input);
        addPlainText("Maximum {maxChars} characters", {"maxChars": _local1});
        addPlainText("No numbers, spaces or punctuation");
        addPlainText("Racism or profanity gets you banned");
        leftButton_.addEventListener(MouseEvent.CLICK, this.onCancel);
        rightButton_.addEventListener(MouseEvent.CLICK, this.onChoose);
    }

    private function onChoose(_arg1:MouseEvent):void {
        this.name_ = this.input.text();
        if (this.name_.length < 1) {
            this.setError("Name too short");
        }
        else {
            this.sendNameToServer();
        }
    }

    private function sendNameToServer():void {
        var _local1:Object = {"name": this.name_};
        MoreObjectUtil.addToObject(_local1, this.account.getCredentials());
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/account/setName", _local1);
        this.disable();
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        if (_arg1) {
            this.onNameChoseDone();
        }
        else {
            this.onNameChoseError(_arg2);
        }
    }

    private function onNameChoseDone():void {
        if (this.playerModel != null) {
            this.playerModel.setName(this.name_);
        }
        Global.changeName(this.name_);
        Global.closeDialogs();
    }

    private function onNameChoseError(_arg1:String):void {
        this.setError(_arg1);
        this.enable();
    }

    private function onCancel(_arg1:MouseEvent):void {
        Global.closeDialogs();
    }

    public function setError(_arg1:String):void {
        this.input.setError(_arg1);
    }


}
}
