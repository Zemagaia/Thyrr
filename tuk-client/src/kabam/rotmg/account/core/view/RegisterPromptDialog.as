package kabam.rotmg.account.core.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.events.Event;


import org.osflash.signals.Signal;

public class RegisterPromptDialog extends Dialog {


    public function RegisterPromptDialog(_arg1:String, _arg2:Object = null) {
        super("Not Registered", _arg1, "Cancel", "Register", _arg2);
        addEventListener(LEFT_BUTTON, onCancel);
        addEventListener(RIGHT_BUTTON, onRegister);
    }

    private function onCancel(e:Event):void
    {
        Global.closeDialogs();
    }

    private function onRegister(e:Event):void
    {
        Global.closeDialogs();
        Global.openAccountInfo();
    }

}
}
