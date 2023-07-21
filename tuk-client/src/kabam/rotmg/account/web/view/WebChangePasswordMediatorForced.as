package kabam.rotmg.account.web.view {
import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.web.signals.WebChangePasswordSignal;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.core.signals.TaskErrorSignal;
import kabam.rotmg.dialogs.control.CloseDialogsSignal;
import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.messaging.impl.GameServerConnection;


import robotlegs.bender.bundles.mvcs.Mediator;

public class WebChangePasswordMediatorForced extends Mediator {

    [Inject]
    public var view:WebChangePasswordDialogForced;
    [Inject]
    public var change:WebChangePasswordSignal;
    [Inject]
    public var openDialog:OpenDialogSignal;
    [Inject]
    public var closeDialogs:CloseDialogsSignal;
    [Inject]
    public var loginError:TaskErrorSignal;
    [Inject]
    public var account:Account;
    private var newPassword:String;


    override public function initialize():void {
        this.view.change.add(this.onChange);
        this.loginError.add(this.onError);
    }

    override public function destroy():void {
        this.view.change.remove(this.onChange);
        this.loginError.remove(this.onError);
    }

    private function onChange():void {
        var _local1:AppEngineClient;
        var _local2:Object;
        if (((((this.isCurrentPasswordValid()) && (this.isNewPasswordValid()))) && (this.isNewPasswordVerified()))) {
            this.view.clearError();
            this.view.disable();
            _local1 = StaticInjectorContext.getInjector().getInstance(AppEngineClient);
            _local2 = {};
            _local2.password = GameServerConnection.rsaEncrypt(this.view.password_.text());
            this.newPassword = GameServerConnection.rsaEncrypt(this.view.newPassword_.text());
            _local2.newPassword = this.newPassword;
            _local2.guid = this.account.getUserId();
            _local1.sendRequest("/account/cpass", _local2);
            _local1.complete.addOnce(this.onComplete);
        }
    }

    private function isCurrentPasswordValid():Boolean {
        var _local1:Boolean = (this.view.password_.text().length >= 10);
        if (!_local1) {
            this.view.password_.setError("Incorrect Password");
        }
        return (_local1);
    }

    private function isNewPasswordValid():Boolean {
        var _local1:Boolean = (this.view.newPassword_.text().length >= 10);
        if (!_local1) {
            this.view.newPassword_.setError("Password must be at least 10 characters");
        }
        return (_local1);
    }

    private function isNewPasswordVerified():Boolean {
        var _local1:Boolean = (this.view.newPassword_.text() == this.view.retypeNewPassword_.text());
        if (!_local1) {
            this.view.retypeNewPassword_.setError("Password does not match");
        }
        return (_local1);
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        if (!_arg1) {
            this.onError(_arg2);
        }
        else {
            this.account.updateUser(this.account.getUserId(), this.newPassword, this.account.getToken());
            this.closeDialogs.dispatch();
        }
    }

    private function onError(_arg1:String):void {
        this.view.newPassword_.setError(_arg1);
        this.view.enable();
    }


}
}
