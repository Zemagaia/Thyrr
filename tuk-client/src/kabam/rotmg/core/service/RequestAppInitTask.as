package kabam.rotmg.core.service {
import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.application.DynamicSettings;

public class RequestAppInitTask extends BaseTask {

    public var client:AppEngineClient = Global.appEngine;
    public var account:Account = Global.account;

    override protected function startTask():void {
        this.client.setMaxRetries(2);
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/app/init", {"game_net": this.account.gameNetwork()});
    }

    private function onComplete(isOk:Boolean, data:*):void {
        var xml:XML = XML(data);
        if (isOk)
            Global.onAppInitDataReceived(xml);
        this.initDynamicSettingsClass(xml);
        completeTask(isOk, data);
    }

    private function initDynamicSettingsClass(xml:XML):void {
        if (xml != null) {
            DynamicSettings.xml = xml;
        }
    }


}
}
