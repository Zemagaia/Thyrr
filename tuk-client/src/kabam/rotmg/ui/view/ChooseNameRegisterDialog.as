package kabam.rotmg.ui.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.events.Event;

import org.osflash.signals.Signal;

public class ChooseNameRegisterDialog extends Dialog {

    private static const TRACKING_TAG:String = "/chooseNameNeedRegister";

    public var cancel:Signal;
    public var register:Signal;

    public function ChooseNameRegisterDialog() {
        super("Not Registered", "In order to select a unique name you must be a registered user.", "Cancel", "Register", TRACKING_TAG);
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
