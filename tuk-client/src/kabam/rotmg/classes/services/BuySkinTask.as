package kabam.rotmg.classes.services {
import com.company.assembleegameclient.ui.dialogs.ErrorDialog;

import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.CharacterSkinState;
import kabam.rotmg.core.model.PlayerModel;

public class BuySkinTask extends BaseTask {

    public var skin:CharacterSkin;
    public var client:AppEngineClient = Global.appEngine;
    public var account:Account = Global.account;
    public var player:PlayerModel = Global.playerModel;

    public function BuySkinTask(skin:CharacterSkin)
    {
        this.skin = skin;
    }

    override protected function startTask():void {
        this.skin.setState(CharacterSkinState.PURCHASING);
        this.player.changeCredits(-(this.skin.cost));
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("account/pskin", this.makeCredentials());
    }

    private function makeCredentials():Object {
        var _local1:Object = this.account.getCredentials();
        _local1.skinType = this.skin.id;
        return (_local1);
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        if (_arg1) {
            this.completePurchase();
        }
        else {
            this.abandonPurchase(_arg2);
        }
        completeTask(_arg1, _arg2);
    }

    private function completePurchase():void {
        this.skin.setState(CharacterSkinState.OWNED);
        this.skin.setIsSelected(true);
    }

    private function abandonPurchase(_arg1:String):void {
        var _local2:ErrorDialog = new ErrorDialog(_arg1);
        Global.openDialog(_local2);
        this.skin.setState(CharacterSkinState.PURCHASABLE);
        this.player.changeCredits(this.skin.cost);
    }


}
}
