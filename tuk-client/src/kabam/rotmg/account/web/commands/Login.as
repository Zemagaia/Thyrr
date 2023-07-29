package kabam.rotmg.account.web.commands {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.screens.CharacterSelectionScreen;

import flash.display.Sprite;

import kabam.lib.tasks.BranchingTask;
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.DispatchSignalTask;
import kabam.lib.tasks.TaskMonitor;
import kabam.lib.tasks.TaskSequence;
import kabam.rotmg.account.core.services.LoginTask;
import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.core.model.ScreenModel;

public class Login
{

    public var data:AccountData;
    public var monitor:TaskMonitor = Global.taskMonitor;
    public var screenModel:ScreenModel = Global.screenModel;
    private var setScreenTask:DispatchFunctionTask;

    public function Login(accountData:AccountData) {
        data = accountData;
        this.setScreenTask = new DispatchFunctionTask(Global.setScreenWithValidData, this.getTargetScreen());
        var task:BranchingTask = new BranchingTask(new LoginTask(), this.makeSuccessTask(), this.makeFailureTask());
        this.monitor.add(task);
        task.start();
    }

    private function makeSuccessTask():TaskSequence {
        var task:TaskSequence;
        task = new TaskSequence();
        task.add(new DispatchFunctionTask(Global.closeDialogs));
        task.add(new DispatchFunctionTask(Global.invalidateData));
        task.add(this.setScreenTask);
        return (task);
    }

    private function makeFailureTask():TaskSequence {
        var task:TaskSequence = new TaskSequence();
        task.add(new DispatchSignalTask(Global.taskErrorSignal, new LoginTask()));
        task.add(this.setScreenTask);
        return (task);
    }

    private function getTargetScreen():Sprite {
        var screenClass:Class = this.screenModel.getCurrentScreenType();
        if ((((screenClass == null)) || ((screenClass == GameSprite)))) {
            screenClass = CharacterSelectionScreen;
        }
        return (new (screenClass)());
    }


}
}
