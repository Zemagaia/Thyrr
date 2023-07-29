package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;

import flash.events.Event;

import flash.events.MouseEvent;

import kabam.rotmg.account.core.Account;

import kabam.rotmg.appengine.api.AppEngineClient;

import kabam.rotmg.messaging.impl.GameServerConnection;

import org.osflash.signals.Signal;

public class WebChangePasswordDialogForced extends Frame {

    public var account:Account = Global.account;
    private var newPassword:String;
    public var password_:TextInputField;
    public var newPassword_:TextInputField;
    public var retypeNewPassword_:TextInputField;

    public function WebChangePasswordDialogForced() {
        super("Change your password", "", "Submit");
        this.password_ = new TextInputField("Password", true);
        addTextInputField(this.password_);
        this.newPassword_ = new TextInputField("New Password", true);
        addTextInputField(this.newPassword_);
        this.retypeNewPassword_ = new TextInputField("Retype New Password", true);
        addTextInputField(this.retypeNewPassword_);
        rightButton_.addEventListener(MouseEvent.CLICK, onChange);
    }

    public function initialize(e:Event):void {
        Global.taskErrorSignal.add(this.onError);
    }

    public function destroy(e:Event):void {
        Global.taskErrorSignal.remove(this.onError);
    }

    private function change():void {
        var _local1:AppEngineClient;
        var _local2:Object;
        if (((((this.isCurrentPasswordValid()) && (this.isNewPasswordValid()))) && (this.isNewPasswordVerified()))) {
            this.clearError();
            this.disable();
            _local1 = Global.appEngine;
            _local2 = {};
            _local2.password = GameServerConnection.rsaEncrypt(this.password_.text());
            this.newPassword = GameServerConnection.rsaEncrypt(this.newPassword_.text());
            _local2.newPassword = this.newPassword;
            _local2.guid = this.account.getUserId();
            _local1.sendRequest("/account/cpass", _local2);
            _local1.complete.addOnce(this.onComplete);
        }
    }

    private function isCurrentPasswordValid():Boolean {
        var _local1:Boolean = (this.password_.text().length >= 10);
        if (!_local1) {
            this.password_.setError("Incorrect Password");
        }
        return (_local1);
    }

    private function isNewPasswordValid():Boolean {
        var _local1:Boolean = (this.newPassword_.text().length >= 10);
        if (!_local1) {
            this.newPassword_.setError("Password must be at least 10 characters");
        }
        return (_local1);
    }

    private function isNewPasswordVerified():Boolean {
        var _local1:Boolean = (this.newPassword_.text() == this.retypeNewPassword_.text());
        if (!_local1) {
            this.retypeNewPassword_.setError("Password does not match");
        }
        return (_local1);
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        if (!_arg1) {
            this.onError(_arg2);
        }
        else {
            this.account.updateUser(this.account.getUserId(), this.newPassword, this.account.getToken());
            Global.closeDialogs();
        }
    }

    private function onError(_arg1:String):void {
        this.newPassword_.setError(_arg1);
        this.enable();
    }

    private function onChange(e:MouseEvent):void {
        change();
    }

    public function clearError():void {
        this.password_.clearError();
        this.retypeNewPassword_.clearError();
        this.newPassword_.clearError();
    }


}
}
