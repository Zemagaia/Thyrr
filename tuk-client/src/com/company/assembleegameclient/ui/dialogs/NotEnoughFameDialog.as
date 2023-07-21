package com.company.assembleegameclient.ui.dialogs {
import flash.events.Event;



public class NotEnoughFameDialog extends Dialog {

    public function NotEnoughFameDialog() {
        super("Not Enough Fame", "You do not have enough Fame for this item. You gain Fame when your character dies after having accomplished great things.", "Ok", null, "/notEnoughFame");
        addEventListener(LEFT_BUTTON, this.onOk);
    }

    public function onOk(_arg1:Event):void {
        parent.removeChild(this);
    }


}
}
