package kabam.rotmg.account.core.commands {
import com.company.assembleegameclient.screens.CharacterSelectionScreen;
import com.company.assembleegameclient.ui.dialogs.ErrorDialog;

import kabam.lib.tasks.BranchingTask;
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.Task;
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.core.services.VerifyAgeTask;

public class VerifyAge
{

    private const UNABLE_TO_VERIFY:String = "Unable to verify age";
    public var monitor:TaskMonitor = Global.taskMonitor;

    public function VerifyAge() {
        var task:BranchingTask = new BranchingTask(new VerifyAgeTask(), makeSuccessTask(), makeFailureTask());
        this.monitor.add(task);
        task.start();
    }

    private function makeSuccessTask():Task {
        Global.setCharacterSelectionScreen(new CharacterSelectionScreen());
        return (new DispatchFunctionTask(Global.setScreenWithValidData, Global.characterSelectionScreen));
    }

    private function makeFailureTask():Task {
        return (new DispatchFunctionTask(Global.openDialog, new ErrorDialog(this.UNABLE_TO_VERIFY)));
    }


}
}
