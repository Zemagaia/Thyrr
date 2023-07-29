package kabam.rotmg.startup.control
{
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.core.services.GetCharListTask;
import kabam.rotmg.account.web.services.LoadAccountTask;
import kabam.rotmg.core.service.RequestAppInitTask;
import kabam.rotmg.language.service.GetLanguageService;

import thyrr.assets.RequestEmbeddedAssetsTask;
import thyrr.assets.RequestEmbeddedDataTask;

public class StartupTasksHandler
{
    public var startup:StartupSequence = Global.startupSequence;
    public var monitor:TaskMonitor = Global.taskMonitor;

    public function StartupTasksHandler()
    {
        // add tasks
        this.startup.addTask(new GetLanguageService(), -999);
        this.startup.addFunction(Global.setupDomainSecurity, -1000);
        this.startup.addTask(new RequestAppInitTask());
        this.startup.addTask(new RequestEmbeddedDataTask());
        this.startup.addTask(new RequestEmbeddedAssetsTask());
        this.startup.addFunction(Global.setupDomainSecurity);
        this.startup.addFunction(Global.showLoadingUI, -1);
        this.startup.addTask(new LoadAccountTask());
        this.startup.addTask(new GetCharListTask());
        this.startup.addFunction(Global.showTitleUI, StartupSequence.LAST);
        this.startup.addFunction(Global.mapExternalCallbacks);
        // start
        this.monitor.add(this.startup);
        this.startup.start();
    }
}
}
