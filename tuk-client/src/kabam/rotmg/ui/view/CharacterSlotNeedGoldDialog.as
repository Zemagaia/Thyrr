package kabam.rotmg.ui.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.display.Sprite;
import flash.events.Event;

import kabam.rotmg.core.model.PlayerModel;


import org.osflash.signals.Signal;

public class CharacterSlotNeedGoldDialog extends Sprite {

    private static const ANALYTICS_PAGE:String = "/charSlotNeedGold";

    public var model:PlayerModel = Global.playerModel;

    private var dialog:Dialog;
    private var price:int;

    public function CharacterSlotNeedGoldDialog()
    {
        addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    private function initialize(e:Event):void
    {
        setPrice(this.model.getCharSlotPrice());
    }

    public function setPrice(_arg1:int):void {
        this.price = _arg1;
        ((((this.dialog) && (contains(this.dialog)))) && (removeChild(this.dialog)));
        this.makeDialog();
        this.dialog.addEventListener(Dialog.LEFT_BUTTON, this.onCancel);
        this.dialog.addEventListener(Dialog.RIGHT_BUTTON, this.onBuyGold);
    }

    private function makeDialog():void {
        this.dialog = new Dialog("Not Enough Gold", "", "Cancel", "Buy Gold", ANALYTICS_PAGE);
        this.dialog.setTextParams("Another character slot costs {price} Gold.  Would you like to buy Gold?", {"price": this.price});
        addChild(this.dialog);
    }

    public function onCancel(_arg1:Event):void {
        Global.closeDialogs();
    }

    public function onBuyGold(_arg1:Event):void {
        Global.openMoneyWindow();
    }


}
}
