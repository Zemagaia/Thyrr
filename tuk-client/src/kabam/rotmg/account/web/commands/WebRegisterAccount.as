package kabam.rotmg.account.web.commands {
import kabam.lib.tasks.BranchingTask;
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.DispatchSignalTask;
import kabam.lib.tasks.Task;
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.web.services.WebRegisterAccountTask;
import kabam.rotmg.account.web.view.WebAccountDetailDialog;

public class WebRegisterAccount {

    public var monitor:TaskMonitor = Global.taskMonitor;

    public function WebRegisterAccount() {
        var task:Task = new BranchingTask(new WebRegisterAccountTask(), this.makeSuccess(), this.makeFailure());
        this.monitor.add(task);
        task.start();
    }

    private function makeSuccess():Task {
        return new DispatchFunctionTask(Global.openDialog, new WebAccountDetailDialog());
    }

    private function makeFailure():Task {
        return new DispatchSignalTask(Global.taskErrorSignal, new WebRegisterAccountTask());
    }


}
}
