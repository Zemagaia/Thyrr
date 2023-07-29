package kabam.rotmg.account.core.services {
import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;

public class ChangePasswordTask extends BaseTask {

    public var account:Account = Global.account;
    public var client:AppEngineClient = Global.appEngine;

    override protected function startTask():void {
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/account/cpass", this.makeDataPacket());
    }

    private function onComplete(isOk:Boolean, data:*):void {
        ((isOk) && (this.onChangeDone()));
        completeTask(isOk, data);
    }

    private function makeDataPacket():Object {
        var data:Object = {};
        data.guid = this.account.getUserId();
        data.password = Global.changePasswordData.currentPassword;
        data.newPassword = Global.changePasswordData.newPassword;
        return (data);
    }

    private function onChangeDone():void {
        this.account.updateUser(this.account.getUserId(), Global.changePasswordData.newPassword, this.account.getToken());
        completeTask(true);
    }


}
}
