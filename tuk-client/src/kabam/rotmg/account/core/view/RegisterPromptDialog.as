package kabam.rotmg.account.core.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.events.Event;


import org.osflash.signals.Signal;

public class RegisterPromptDialog extends Dialog {

    public var cancel:Signal;
    public var register:Signal;

    public function RegisterPromptDialog(_arg1:String, _arg2:Object = null) {
        super("Not Registered", _arg1, "Cancel", "Register", _arg2);
        this.cancel = new Signal();
        this.register = new Signal();
        addEventListener(LEFT_BUTTON, onCancel);
        addEventListener(RIGHT_BUTTON, onRegister);
    }

    private function onCancel(e:Event):void
    {
        cancel.dispatch();
    }

    private function onRegister(e:Event):void
    {
        register.dispatch();
    }

}
}
