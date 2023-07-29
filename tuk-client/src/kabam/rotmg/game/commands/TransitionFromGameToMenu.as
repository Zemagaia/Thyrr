package kabam.rotmg.game.commands {
import com.company.assembleegameclient.screens.CharacterSelectionScreen;

import kabam.rotmg.chat.model.TellModel;

import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.death.model.DeathModel;
import kabam.rotmg.fame.model.FameVO;
import kabam.rotmg.fame.model.SimpleFameVO;
import kabam.rotmg.messaging.impl.incoming.Death;

public class TransitionFromGameToMenu
{
    public var player:PlayerModel = Global.playerModel;
    public var model:DeathModel = Global.deathModel;
    public var tellModel:TellModel = Global.tellModel;

    public function execute():void {
        tellModel.clearRecipients();
        Global.invalidateData();
        if (this.model.getIsDeathViewPending())
            this.showDeathView();
        else
            this.showCurrentCharacterScreen();
    }

    private function showDeathView():void {
        var death:Death = this.model.getLastDeath();
        var vo:FameVO = new SimpleFameVO(this.player.getAccountId(), death.charId_);
        Global.showFameView(vo);
    }

    private function showCurrentCharacterScreen():void {
        Global.setCharacterSelectionScreen(new CharacterSelectionScreen());
        Global.setScreenWithValidData(Global.characterSelectionScreen);
    }


}
}
