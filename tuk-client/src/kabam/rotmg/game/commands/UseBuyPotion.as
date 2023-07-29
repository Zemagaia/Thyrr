package kabam.rotmg.game.commands {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.sound.SoundEffectLibrary;

import flash.utils.getTimer;

import kabam.rotmg.game.model.PotionInventoryModel;
import kabam.rotmg.game.model.UseBuyPotionVO;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.model.PotionModel;

public class UseBuyPotion
{
    public var vo:UseBuyPotionVO;
    public var potInventoryModel:PotionInventoryModel = Global.potionInventoryModel;
    public var hudModel:HUDModel = Global.hudModel;
    private var player:Player;
    private var potionId:int;
    private var count:int;
    private var potion:PotionModel;

    public function execute(potionVO:UseBuyPotionVO):void {
        vo = potionVO;
        this.player = this.hudModel.gameSprite.map.player_;
        if (this.player == null) {
            return;
        }
        this.potionId = this.vo.objectId;
        this.count = this.player.getPotionCount(this.potionId);
        this.potion = this.potInventoryModel.getPotionModel(this.potionId);
        if (this.count > 0) {
            this.usePotionIfEffective();
        }
        else {
            trace("Not safe to purchase potion");
        }
    }

    private function usePotionIfEffective():void {
        if (this.isPlayerStatMaxed()) {
            trace("UseBuyPotionCommand.execute: User has MAX of that attribute, not requesting a use/buy from server.");
        }
        else {
            this.sendServerRequest();
            SoundEffectLibrary.play("use_potion");
        }
    }

    private function isPlayerStatMaxed():Boolean {
        if (this.potionId == PotionInventoryModel.HEALTH_POTION_ID) {
            return ((this.player.hp_ >= this.player.maxHP_));
        }
        if (this.potionId == PotionInventoryModel.MAGIC_POTION_ID) {
            return ((this.player.mp_ >= this.player.maxMP_));
        }
        return (false);
    }

    private function sendServerRequest():void {
        var _local1:int = PotionInventoryModel.getPotionSlot(this.vo.objectId);
        GameServerConnection.instance.useItem(getTimer(), this.player.objectId_, _local1, this.potionId, this.player.x_, this.player.y_, 1);
        if (this.player.getPotionCount(this.vo.objectId) == 0) {
            this.potInventoryModel.getPotionModel(this.vo.objectId).purchasedPot();
        }
    }


}
}
