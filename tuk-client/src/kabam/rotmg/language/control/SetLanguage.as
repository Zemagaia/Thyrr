package kabam.rotmg.language.control {
import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.TaskMonitor;
import kabam.lib.tasks.TaskSequence;
import kabam.rotmg.language.model.LanguageModel;
import kabam.rotmg.language.service.GetLanguageService;

public class SetLanguage
{

    public var model:LanguageModel = Global.languageModel;
    public var monitor:TaskMonitor = Global.taskMonitor;


    public function SetLanguage(language:String) {
        this.model.setLanguage(language);
        Global.showLoadingUI();
        var sequence:TaskSequence = new TaskSequence();
        sequence.add(new GetLanguageService());
        sequence.add(new DispatchFunctionTask(Global.reloadCurrentScreen));
        this.monitor.add(sequence);
        sequence.start();
    }


}
}
