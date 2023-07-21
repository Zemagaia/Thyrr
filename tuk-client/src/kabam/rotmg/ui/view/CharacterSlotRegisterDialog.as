package kabam.rotmg.ui.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.display.Sprite;
import flash.events.Event;

import org.osflash.signals.Signal;

public class CharacterSlotRegisterDialog extends Sprite {

    private static const TEXT:String = "In order to have more than one character slot, you must be a registered user.";
    private static const TITLE:String = "Not Registered";
    private static const CANCEL:String = "Cancel";
    private static const REGISTER:String = "Register";
    private static const ANALYTICS_PAGE:String = "/charSlotNeedRegister";

    public var cancel:Signal;
    public var register:Signal;
    private var dialog:Dialog;

    public function CharacterSlotRegisterDialog() {
        this.makeDialog();
        this.makeSignals();
    }

    private function makeDialog():void {
        this.dialog = new Dialog(TITLE, TEXT, CANCEL, REGISTER, ANALYTICS_PAGE);
        addChild(this.dialog);
    }

    private function makeSignals():void {
        this.cancel = new Signal();
        this.register = new Signal();
        dialog.addEventListener(Dialog.LEFT_BUTTON, onCancel);
        dialog.addEventListener(Dialog.RIGHT_BUTTON, onRegister);
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
