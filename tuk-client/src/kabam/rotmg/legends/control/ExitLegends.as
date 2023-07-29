package kabam.rotmg.legends.control {
import com.company.assembleegameclient.screens.CharacterSelectionScreen;

import kabam.rotmg.death.model.DeathModel;
import kabam.rotmg.ui.view.TitleView;

public class ExitLegends
{

    public var model:DeathModel = Global.deathModel;

    public function ExitLegends() {
        if (this.model.getIsDeathViewPending()) {
            this.clearRecentlyDeceasedAndGotoCharacterView();
        }
        else {
            this.gotoTitleView();
        }
    }

    private function clearRecentlyDeceasedAndGotoCharacterView():void {
        this.model.clearPendingDeathView();
        Global.invalidateData();
        Global.setCharacterSelectionScreen(new CharacterSelectionScreen());
        Global.setScreen(Global.characterSelectionScreen);
    }

    private function gotoTitleView():void {
        Global.setScreen(new TitleView());
    }


}
}
