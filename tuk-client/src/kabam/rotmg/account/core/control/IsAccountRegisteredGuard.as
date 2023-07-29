package kabam.rotmg.account.core.control {
import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.view.RegisterPromptDialog;

public class IsAccountRegisteredGuard {

    public var account:Account = Global.account;

    public function approve():Boolean {
        var _local1:Boolean = this.account.isRegistered();
        ((_local1) || (this.enterRegisterFlow()));
        return (_local1);
    }

    protected function getString():String {
        return ("");
    }

    private function enterRegisterFlow():void {
        Global.openDialog(new RegisterPromptDialog(this.getString()));
    }


}
}
