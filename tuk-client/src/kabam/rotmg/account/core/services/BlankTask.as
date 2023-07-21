package kabam.rotmg.account.core.services {
import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.dialogs.control.OpenDialogSignal;

public class BlankTask extends BaseTask {

    [Inject]
    public var client:AppEngineClient;

    override protected function startTask():void {
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/blank", {});
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        completeTask(_arg1, _arg2);
    }


}
}
