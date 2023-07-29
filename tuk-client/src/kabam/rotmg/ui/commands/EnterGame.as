package kabam.rotmg.ui.commands {
import com.company.assembleegameclient.screens.CharacterSelectionScreen;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.game.model.GameInitData;
import kabam.rotmg.servers.api.ServerModel;
import kabam.rotmg.ui.noservers.NoServersDialogFactory;
import kabam.rotmg.ui.view.AgeVerificationDialog;

public class EnterGame
{
    private const DEFAULT_CHARACTER:int = 782;

    public var account:Account = Global.account;
    public var model:PlayerModel = Global.playerModel;
    public var servers:ServerModel = Global.serverModel;
    public var noServersDialogFactory:NoServersDialogFactory = Global.noServersDialogFactory;

    public function EnterGame()
    {
        if (!this.servers.isServerAvailable())
        {
            this.showNoServersDialog();
            return;
        }
        if (!this.model.getIsAgeVerified())
        {
            this.showAgeVerificationDialog();
            return;
        }
        this.showCurrentCharacterScreen();
    }

    private function showCurrentCharacterScreen():void {
        Global.setCharacterSelectionScreen(new CharacterSelectionScreen());
        Global.setScreenWithValidData(Global.characterSelectionScreen);
    }

    private function showAgeVerificationDialog():void {
        Global.openDialog(new AgeVerificationDialog());
    }

    private function showNoServersDialog():void {
        Global.openDialog(this.noServersDialogFactory.makeDialog());
    }
}
}
