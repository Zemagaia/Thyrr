package kabam.rotmg.core.commands {
import flash.display.Sprite;

import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.TaskMonitor;
import kabam.lib.tasks.TaskSequence;
import kabam.rotmg.account.core.services.GetCharListTask;
import kabam.rotmg.core.model.PlayerModel;

public class SetScreenWithValidData
{
    public var model:PlayerModel = Global.playerModel;
    public var monitor:TaskMonitor = Global.taskMonitor;

    public function SetScreenWithValidData(view:Sprite) {
        if (this.model.isInvalidated) {
            this.reloadDataThenSetScreen(view);
        }
        else {
            Global.setScreen(view);
        }
    }

    private function reloadDataThenSetScreen(view:Sprite):void {
        Global.setScreen(Global.loadingScreen);
        var sequence:TaskSequence = new TaskSequence();
        sequence.add(new GetCharListTask());
        sequence.add(new DispatchFunctionTask(Global.setScreen, view));
        this.monitor.add(sequence);
        sequence.start();
    }


}
}
