﻿package kabam.rotmg.account.core.services {
import flash.net.URLLoaderDataFormat;

import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.appengine.api.AppEngineClient;

public class LoginTask extends BaseTask {

    public var account:Account = Global.account;
    public var data:AccountData = Global.accountData;
    public var client:AppEngineClient = Global.appEngine;


    override protected function startTask():void {
        this.client.complete.addOnce(this.onComplete);
        this.client.setDataFormat(URLLoaderDataFormat.TEXT);
        this.client.setMaxRetries(0);
        this.client.sendRequest("/account/verify", {
            "guid": this.data.username,
            "password": this.data.password
        });
    }

    private function onComplete(isOk:Boolean, data:*):void {
        if (isOk) {
            this.account.updateUser(this.data.username, this.data.password, "");
        }
        completeTask(isOk, data);
    }

}
}
