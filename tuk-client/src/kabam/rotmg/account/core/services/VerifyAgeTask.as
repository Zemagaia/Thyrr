package kabam.rotmg.account.core.services {
import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.core.model.PlayerModel;

public class VerifyAgeTask extends BaseTask {

    public var account:Account = Global.account;
    public var playerModel:PlayerModel = Global.playerModel;
    public var client:AppEngineClient = Global.appEngine;


    override protected function startTask():void {
        if (this.account.isRegistered()) {
            this.sendVerifyToServer();
        }
        else {
            this.verifyUserAge();
        }
    }

    private function sendVerifyToServer():void {
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/account/verAge", this.makeDataPacket());
    }

    private function makeDataPacket():Object {
        var _local1:Object = this.account.getCredentials();
        _local1.isAgeVerified = 1;
        return (_local1);
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        ((_arg1) && (this.verifyUserAge()));
        completeTask(_arg1, _arg2);
    }

    private function verifyUserAge():void {
        this.playerModel.setIsAgeVerified(true);
        completeTask(true);
    }


}
}
