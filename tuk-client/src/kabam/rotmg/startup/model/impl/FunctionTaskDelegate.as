package kabam.rotmg.startup.model.impl {

import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.Task;
import kabam.rotmg.startup.model.api.StartupDelegate;

public class FunctionTaskDelegate implements StartupDelegate {

    public var func:Function;

    public var priority:int;

    public function FunctionTaskDelegate() {
        super();
    }

    public function getPriority():int {
        return this.priority;
    }

    public function make():Task {
        return new DispatchFunctionTask(func);
    }
}
}