package kabam.rotmg.account.core.services {
import kabam.lib.tasks.BaseTask;
import kabam.rotmg.appengine.api.AppEngineClient;

public class SendPasswordReminderTask extends BaseTask {

    public var email:String;
    public var client:AppEngineClient = Global.appEngine;

    public function SendPasswordReminderTask(email:String):void
    {
        this.email = email;
    }

    override protected function startTask():void {
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/account/fp", {"guid": this.email});
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        if (_arg1) {
            this.onForgotDone();
        }
        else {
            this.onForgotError(_arg2);
        }
    }

    private function onForgotDone():void {
        completeTask(true);
    }

    private function onForgotError(_arg1:String):void {
        completeTask(false, _arg1);
    }

}
}
