package kabam.rotmg.account.core {
import com.company.assembleegameclient.screens.CharacterSelectionScreen;
import com.company.assembleegameclient.ui.dialogs.ErrorDialog;
import com.company.assembleegameclient.ui.dialogs.NotEnoughFameDialog;

import kabam.lib.tasks.BranchingTask;
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.Task;
import kabam.lib.tasks.TaskMonitor;
import kabam.lib.tasks.TaskSequence;
import kabam.rotmg.account.core.control.IsAccountRegisteredToBuyGoldGuard;
import kabam.rotmg.account.core.services.BuyCharacterSlotTask;
import kabam.rotmg.account.core.view.BuyingDialog;
import kabam.rotmg.account.core.view.PurchaseConfirmationDialog;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.ui.view.CharacterSlotNeedGoldDialog;

public class BuyCharacterSlot
{

    public var price:int;
    public var monitor:TaskMonitor = Global.taskMonitor;

    public var model:PlayerModel = Global.playerModel;
    public var account:Account = Global.account;


    public function BuyCharacterSlot(price:int) {
        if (!(new IsAccountRegisteredToBuyGoldGuard().approve())) return;
        this.price = price;
        if (this.isSlotUnaffordable()) {
            if (this.model.getCharSlotCurrency() == 0) {
                this.promptToGetMoreGold();
            }
            else {
                this.promptNotEnoughFame();
            }
        }
        else {
            this.purchaseSlot();
        }
    }

    private function isSlotUnaffordable():Boolean {
        var tooPoor:Boolean = this.model.getCharSlotCurrency() == 0 ?
                this.model.getCredits() < this.model.getCharSlotPrice() :
                this.model.getFame() < this.model.getCharSlotPrice();
        return tooPoor;
    }

    private function promptToGetMoreGold():void {
        Global.openDialog(new CharacterSlotNeedGoldDialog());
    }

    private function promptNotEnoughFame():void {
        Global.openDialog(new NotEnoughFameDialog());
    }

    private function purchaseSlot():void {
        Global.openDialog(new PurchaseConfirmationDialog(this.purchaseConfirmed));
    }

    private function purchaseConfirmed():void {
        Global.openDialog(new BuyingDialog());
        var sequence:TaskSequence = new TaskSequence();
        sequence.add(new BranchingTask(new BuyCharacterSlotTask(this.price), makeSuccessTask(), makeFailureTask()));
        sequence.add(new DispatchFunctionTask(Global.closeDialogs));
        this.monitor.add(sequence);
        sequence.start();
    }

    private static function makeSuccessTask():Task {
        Global.setCharacterSelectionScreen(new CharacterSelectionScreen());
        return new DispatchFunctionTask(Global.setScreen, Global.characterSelectionScreen);
    }

    private static function makeFailureTask():Task {
        return new DispatchFunctionTask(Global.openDialog, new ErrorDialog("Unable to complete character slot purchase"));
    }


}
}
