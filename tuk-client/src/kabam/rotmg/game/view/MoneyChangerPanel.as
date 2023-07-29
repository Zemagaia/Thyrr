package kabam.rotmg.game.view {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.panels.ButtonPanel;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import kabam.rotmg.account.core.Account;

import kabam.rotmg.account.core.view.RegisterPromptDialog;


import org.osflash.signals.Signal;

public class MoneyChangerPanel extends ButtonPanel {

    public var account:Account = Global.account;

    public function MoneyChangerPanel(_arg1:GameSprite) {
        super(_arg1, "Buy Realm Gold", "Buy");
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function onAddedToStage(_arg1:Event):void {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    override protected function onButtonClick(_arg1:MouseEvent):void {
        this.onTriggered();
    }

    private function onTriggered():void {
        if (this.account.isRegistered()) {
            Global.openMoneyWindow();
        }
        else {
            Global.openDialog(new RegisterPromptDialog("In order to buy Gold you must be a registered user."));
        }
    }

    private function onKeyDown(_arg1:KeyboardEvent):void {
        if ((((_arg1.keyCode == Parameters.data_.interact)) && ((stage.focus == null)))) {
            this.onTriggered();
        }
    }


}
}
