package kabam.rotmg.account.web.services {
import flash.net.URLLoaderDataFormat;

import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.services.RegisterAccountTask;
import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.core.model.PlayerModel;

public class WebRegisterAccountTask extends BaseTask implements RegisterAccountTask {

    public var data:AccountData = Global.accountData;
    public var account:Account = Global.account;
    public var model:PlayerModel = Global.playerModel;
    public var client:AppEngineClient = Global.appEngine;


    override protected function startTask():void {
        this.client.complete.addOnce(this.onComplete);
        this.client.setDataFormat(URLLoaderDataFormat.TEXT);
        this.client.setMaxRetries(0);
        this.client.sendRequest("/account/register", this.makeDataPacket());
    }

    private function makeDataPacket():Object {
        var _local1:Object = {};
        _local1.guid = this.account.getUserId();
        _local1.newGUID = this.data.username;
        _local1.newPassword = this.data.password;
        _local1.entrytag = this.account.getEntryTag();
        _local1.isAgeVerified = 1;
        return (_local1);
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        ((_arg1) && (this.onRegisterDone(_arg2)));
        completeTask(_arg1, _arg2);
    }

    private function onRegisterDone(_arg1:String):void {
        this.model.setIsAgeVerified(true);
        var _local2:XML = new XML(_arg1);
        if (_local2.hasOwnProperty("token")) {
            this.data.token = _local2.token;
            this.account.updateUser(this.data.username, this.data.password, _local2.token);
        }
        else {
            this.account.updateUser(this.data.username, this.data.password, "");
        }
    }


}
}
