package kabam.rotmg.ui.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.events.Event;

import kabam.rotmg.account.core.services.GetOffersTask;

import org.osflash.signals.Signal;

public class NotEnoughGoldDialog extends Dialog {

    private static const TRACKING_TAG:String = "/notEnoughGold";

    public function NotEnoughGoldDialog() {
        super("Not Enough Gold", "You do not have enough Gold for this item. Would you like to buy Gold?", "Cancel", "Buy Gold", TRACKING_TAG);
        addEventListener(LEFT_BUTTON, onCancel);
        addEventListener(RIGHT_BUTTON, onBuy);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    public function initialize(e:Event):void {
        new GetOffersTask().start();
    }

    public function cancel():void {
        Global.closeDialogs();
    }

    public function onBuyGold():void {
        Global.openMoneyWindow();
    }

    private function onCancel(e:Event):void
    {
        cancel();
    }

    private function onBuy(e:Event):void
    {
        onBuyGold();
    }

}
}
