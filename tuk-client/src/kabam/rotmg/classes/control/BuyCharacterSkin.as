package kabam.rotmg.classes.control {
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.core.control.IsAccountRegisteredToBuyGoldGuard;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.CharacterSkinState;
import kabam.rotmg.classes.services.BuySkinTask;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.ui.view.NotEnoughGoldDialog;

public class BuyCharacterSkin
{

    public var skin:CharacterSkin;
    public var model:PlayerModel = Global.playerModel;
    public var monitor:TaskMonitor = Global.taskMonitor;

    public function BuyCharacterSkin(skin:CharacterSkin) {
        if (!(new IsAccountRegisteredToBuyGoldGuard().approve())) return;
        this.skin = skin;
        if (this.isSkinPurchasable()) {
            this.enterPurchaseFlow();
        }
    }

    private function enterPurchaseFlow():void {
        if (this.isSkinAffordable()) {
            this.purchaseSkin();
        }
        else {
            this.enterGetCreditsFlow();
        }
    }

    private function isSkinPurchasable():Boolean {
        return ((this.skin.getState() == CharacterSkinState.PURCHASABLE));
    }

    private function isSkinAffordable():Boolean {
        return ((this.model.getCredits() >= this.skin.cost));
    }

    private function purchaseSkin():void {
        var task:BuySkinTask = new BuySkinTask(skin);
        this.monitor.add(task);
        task.start();
    }

    private function enterGetCreditsFlow():void {
        Global.openDialog(new NotEnoughGoldDialog());
    }


}
}
