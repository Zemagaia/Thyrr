package kabam.rotmg.account.web.commands {
import kabam.lib.tasks.BranchingTask;
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.DispatchSignalTask;
import kabam.lib.tasks.Task;
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.core.services.ChangePasswordTask;
import kabam.rotmg.account.web.view.WebAccountDetailDialog;

public class WebChangePassword {

    public var monitor:TaskMonitor = Global.taskMonitor;
    private var changePassword:ChangePasswordTask;

    public function WebChangePassword()
    {
        this.changePassword = new ChangePasswordTask();
        var task:BranchingTask = new BranchingTask(this.changePassword, this.makeSuccess(), this.makeFailure());
        this.monitor.add(task);
        task.start();
    }

    private function makeSuccess():Task {
        return new DispatchFunctionTask(Global.openDialog, new WebAccountDetailDialog());
    }

    private function makeFailure():Task {
        return (new DispatchSignalTask(Global.taskErrorSignal, this.changePassword));
    }


}
}
