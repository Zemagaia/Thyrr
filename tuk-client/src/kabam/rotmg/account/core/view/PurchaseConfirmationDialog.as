package kabam.rotmg.account.core.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.events.Event;

public class PurchaseConfirmationDialog extends Dialog {

    public var confirmedHandler:Function;

    public function PurchaseConfirmationDialog(_arg1:*) {
        super("Purchase confirmation", "Continue with purchase?", "Yes", "No", null);
        this.confirmedHandler = _arg1;
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        this.addEventListener(Dialog.LEFT_BUTTON, this.onYesClickHandler);
        this.addEventListener(Dialog.RIGHT_BUTTON, this.onNoClickHandler);
    }

    private function onYesClickHandler(_arg1:Event):void {
        Global.closeDialogs();
        this.confirmedHandler();
    }

    private function onNoClickHandler(_arg1:Event):void {
        Global.closeDialogs();
    }

    public function destroy(e:Event):void {
        this.removeEventListener(Dialog.LEFT_BUTTON, this.onYesClickHandler);
        this.removeEventListener(Dialog.RIGHT_BUTTON, this.onNoClickHandler);
    }

}
}
