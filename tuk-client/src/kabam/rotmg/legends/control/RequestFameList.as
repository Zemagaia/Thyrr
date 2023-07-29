package kabam.rotmg.legends.control {
import kabam.lib.tasks.BranchingTask;
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.DispatchSignalTask;
import kabam.lib.tasks.Task;
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.death.model.DeathModel;
import kabam.rotmg.fame.model.FameModel;
import kabam.rotmg.legends.model.Timespan;
import kabam.rotmg.legends.service.GetLegendsListTask;

public class RequestFameList
{
    public var task:GetLegendsListTask;
    public var monitor:TaskMonitor = Global.taskMonitor;
    public var player:PlayerModel = Global.playerModel;
    public var death:DeathModel = Global.deathModel;
    public var model:FameModel = Global.fameModel;

    public function RequestFameList(span:Timespan) {
        this.task = new GetLegendsListTask(span);
        this.task.charId = this.getCharId();
        var task:BranchingTask = new BranchingTask(this.task, this.makeSuccess(), this.makeFailure());
        this.monitor.add(task);
        task.start();
    }

    private function getCharId():int {
        if (((this.player.hasAccount()) && (this.death.getIsDeathViewPending()))) {
            return (this.death.getLastDeath().charId_);
        }
        return (-1);
    }

    private function makeSuccess():Task {
        return (new DispatchFunctionTask(Global.fameListUpdate));
    }

    private function makeFailure():Task {
        return (new DispatchSignalTask(Global.taskErrorSignal, this.task));
    }


}
}
