package kabam.rotmg.account.core.services {
import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.core.model.PlayerModel;

public class BuyCharacterSlotTask extends BaseTask {

    public var account:Account = Global.account;
    public var price:int;
    public var client:AppEngineClient = Global.appEngine;

    public var model:PlayerModel = Global.playerModel;

    public function BuyCharacterSlotTask(price:int):void
    {
        this.price = price;
    }

    override protected function startTask():void {
        this.client.setMaxRetries(2);
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/account/pcharS", this.account.getCredentials());
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        ((_arg1) && (this.updatePlayerData()));
        completeTask(_arg1, _arg2);
    }

    private function updatePlayerData():void {
        this.model.setMaxCharacters((this.model.getMaxCharacters() + 1));
        if (this.model.getCharSlotCurrency() == 0) {
            this.model.changeCredits(-this.price);
        }
        else {
            this.model.changeFame(-this.price);
        }
    }


}
}
