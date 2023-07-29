package kabam.rotmg.core.commands {
import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.commands.ExternalOpenMoneyWindow;
import kabam.rotmg.account.core.view.MoneyFrame;
import kabam.rotmg.account.web.WebAccount;
import kabam.rotmg.chat.control.SpamFilter;
import kabam.rotmg.game.model.PotionInventoryModel;

public class AppInitDataReceived
{

    public var account:Account = Global.account;
    public var potionInventoryModel:PotionInventoryModel = Global.potionInventoryModel;
    public var spamFilter:SpamFilter = Global.spamFilter;
    private var data:XML;


    public function AppInitDataReceived(data:XML) {
        this.data = data;
        this.potionInventoryModel.initializePotionModels(data);
        this.spamFilter.setPatterns(data.FilterList.split(/\n/g));
    }

    public function openMoneyWindow():void {
        if (useExternalPaymentsWindow())
        {
            new ExternalOpenMoneyWindow();
            return;
        }
        Global.openDialog(new MoneyFrame());
    }

    private function useExternalPaymentsWindow():Boolean {
        return (this.account is WebAccount && data["UseExternalPayments"] == null) || Boolean(int(data["UseExternalPayments"]));
    }


}
}
