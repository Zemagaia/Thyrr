package kabam.rotmg.death.control {
import com.company.assembleegameclient.parameters.Parameters;

import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.TaskMonitor;
import kabam.lib.tasks.TaskSequence;
import kabam.rotmg.account.core.services.GetCharListTask;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.fame.model.FameVO;
import kabam.rotmg.fame.model.SimpleFameVO;
import kabam.rotmg.messaging.impl.incoming.Death;

public class HandleNormalDeath
{

    public var player:PlayerModel = Global.playerModel;
    public var monitor:TaskMonitor = Global.taskMonitor;
    private var fameVO:FameVO;


    public function HandleNormalDeath(death:Death) {
        this.fameVO = new SimpleFameVO(death.accountId_, death.charId_);
        this.updateParameters();
        this.gotoFameView();
    }

    private function updateParameters():void {
        Parameters.save();
    }

    private function gotoFameView():void {
        if (this.player.getAccountId() == "") {
            this.gotoFameViewOnceDataIsLoaded();
        }
        else {
            Global.showFameView(this.fameVO);
        }
    }

    private function gotoFameViewOnceDataIsLoaded():void {
        var _local1:TaskSequence = new TaskSequence();
        _local1.add(new GetCharListTask());
        _local1.add(new DispatchFunctionTask(Global.showFameView, this.fameVO));
        this.monitor.add(_local1);
        _local1.start();
    }


}
}
