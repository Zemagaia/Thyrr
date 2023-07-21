package kabam.rotmg.ui.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.events.Event;

import org.osflash.signals.Signal;

public class NotEnoughGoldDialog extends Dialog {

    private static const TRACKING_TAG:String = "/notEnoughGold";

    public var cancel:Signal;
    public var buyGold:Signal;

    public function NotEnoughGoldDialog() {
        super("Not Enough Gold", "You do not have enough Gold for this item. Would you like to buy Gold?", "Cancel", "Buy Gold", TRACKING_TAG);
        this.cancel = new Signal();
        this.buyGold = new Signal();
        addEventListener(LEFT_BUTTON, onCancel);
        addEventListener(RIGHT_BUTTON, onBuy);
    }

    private function onCancel(e:Event):void
    {
        cancel.dispatch();
    }

    private function onBuy(e:Event):void
    {
        buyGold.dispatch();
    }

}
}
