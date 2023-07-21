package kabam.rotmg.game.view {
import com.company.assembleegameclient.objects.SellableObject;
import com.company.assembleegameclient.util.Currency;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.view.RegisterPromptDialog;
import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.game.model.GameModel;
import kabam.rotmg.ui.view.NotEnoughGoldDialog;

import robotlegs.bender.bundles.mvcs.Mediator;

public class SellableObjectPanelMediator extends Mediator {

    public static const TEXT:String = "In order to use {type} you must be a registered user.";

    [Inject]
    public var account:Account;
    [Inject]
    public var gameModel:GameModel;
    [Inject]
    public var view:SellableObjectPanel;
    [Inject]
    public var openDialog:OpenDialogSignal;


    override public function initialize():void {
        this.view.buyItem.add(this.onBuyItem);
    }

    override public function destroy():void {
        this.view.buyItem.remove(this.onBuyItem);
    }

    private function onBuyItem(_arg1:SellableObject):void {
        if (this.account.isRegistered()) {
            if ((((_arg1.currency_ == Currency.GOLD)) && (_arg1.price_ > this.gameModel.player.credits_))) {
                this.openDialog.dispatch(new NotEnoughGoldDialog());
            }
            else {
                this.view.gs_.gsc_.buy(_arg1.objectId_);
            }
        }
        else {
            this.openDialog.dispatch(this.makeRegisterDialog(_arg1));
        }
    }

    private function makeRegisterDialog(_arg1:SellableObject):RegisterPromptDialog {
        return (new RegisterPromptDialog(TEXT, {"type": Currency.typeToName(_arg1.currency_)}));
    }


}
}
