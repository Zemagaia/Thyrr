package kabam.rotmg.ui.commands {
import com.company.assembleegameclient.account.ui.NewChooseNameFrame;

import flash.display.Sprite;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.ui.view.ChooseNameRegisterDialog;

public class ChooseName {

    public var account:Account = Global.account;

    public function ChooseName() {
        var sprite:Sprite;
        if (this.account.isRegistered())
            sprite = new NewChooseNameFrame();
        else
            sprite = new ChooseNameRegisterDialog();
        Global.openDialog(sprite);
    }


}
}
