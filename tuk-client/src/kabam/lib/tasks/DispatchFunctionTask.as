package kabam.lib.tasks {

public class DispatchFunctionTask extends BaseTask {

    private var func:Function;
    private var params:Array;

    public function DispatchFunctionTask(func:Function, ...params) {
        this.func = func;
        this.params = params;
    }

    override protected function startTask():void {
        func.apply(null, this.params);
        completeTask(true);
    }


}
}
