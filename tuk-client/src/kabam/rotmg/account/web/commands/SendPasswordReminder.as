package kabam.rotmg.account.web.commands {
import kabam.lib.tasks.BranchingTask;
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.DispatchSignalTask;
import kabam.lib.tasks.Task;
import kabam.lib.tasks.TaskGroup;
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.core.services.SendPasswordReminderTask;
import kabam.rotmg.account.web.view.WebLoginDialog;

public class SendPasswordReminder
{

    public var monitor:TaskMonitor = Global.taskMonitor;

    public function SendPasswordReminder(email:String) {
        var passwordReminderTask:Task = new SendPasswordReminderTask(email);
        var success:TaskGroup = new TaskGroup();
        success.add(new DispatchFunctionTask(Global.openDialog, new WebLoginDialog()));
        var failure:TaskGroup = new TaskGroup();
        failure.add(new DispatchSignalTask(Global.taskErrorSignal, passwordReminderTask));
        var task:BranchingTask = new BranchingTask(passwordReminderTask, success, failure);
        this.monitor.add(task);
        task.start();
    }


}
}
