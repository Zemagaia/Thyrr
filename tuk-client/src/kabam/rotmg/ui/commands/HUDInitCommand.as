package kabam.rotmg.ui.commands {
import com.company.assembleegameclient.editor.Command;
import com.company.assembleegameclient.game.GameSprite;

import kabam.rotmg.ui.model.HUDModel;

public class HUDInitCommand extends Command {

    public var model:HUDModel = Global.hudModel;

    override public function HUDInitCommand(gs:GameSprite):void {
        this.model.gameSprite = gs;
        Global.hudModelInitialized();
    }


}
}
