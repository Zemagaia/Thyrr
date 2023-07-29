package kabam.rotmg.characters.deletion.control {
import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.screens.CharacterSelectionScreen;

import kabam.lib.tasks.BranchingTask;
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.Task;
import kabam.lib.tasks.TaskMonitor;
import kabam.lib.tasks.TaskSequence;
import kabam.rotmg.characters.deletion.service.DeleteCharacterTask;
import kabam.rotmg.characters.deletion.view.DeletingCharacterView;

public class DeleteCharacter
{

    public var monitor:TaskMonitor = Global.taskMonitor;

    public function DeleteCharacter(savedCharacter:SavedCharacter) {
        var sequence:TaskSequence = new TaskSequence();
        sequence.add(new DispatchFunctionTask(Global.openDialog, new DeletingCharacterView()));
        sequence.add(new BranchingTask(new DeleteCharacterTask(savedCharacter), this.onSuccess(), this.onFailure()));
        this.monitor.add(sequence);
        sequence.start();
    }

    private function onSuccess():Task {
        var sequence:TaskSequence = new TaskSequence();
        Global.setCharacterSelectionScreen(new CharacterSelectionScreen());
        sequence.add(new DispatchFunctionTask(Global.setScreen, Global.characterSelectionScreen));
        sequence.add(new DispatchFunctionTask(Global.closeDialogs));
        return (sequence);
    }

    private function onFailure():Task {
        return (new DispatchFunctionTask(Global.openDialog, "Unable to delete character"));
    }


}
}
