package kabam.rotmg.startup.model.impl {
import kabam.lib.tasks.Task;
import kabam.rotmg.startup.model.api.StartupDelegate;

public class TaskDelegate implements StartupDelegate {

    public var task:Task;

    public var priority:int;

    public function TaskDelegate() {
        super();
    }

    public function getPriority():int {
        return this.priority;
    }

    public function make():Task {
        return this.task;
    }
}
}