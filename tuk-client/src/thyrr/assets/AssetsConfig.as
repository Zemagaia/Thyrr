package thyrr.assets {
import thyrr.assets.CharacterFactory;
import thyrr.assets.IconFactory;
import thyrr.assets.RequestEmbeddedAssetsTask;
import thyrr.assets.RequestEmbeddedDataTask;
import kabam.rotmg.startup.control.StartupSequence;

import org.swiftsuspenders.Injector;

import robotlegs.bender.framework.api.IConfig;

public class AssetsConfig implements IConfig {

    [Inject]
    public var injector:Injector;
    [Inject]
    public var startup:StartupSequence;


    public function configure():void {
        this.injector.map(CharacterFactory).asSingleton();
        this.injector.map(IconFactory).asSingleton();
        this.startup.addTask(RequestEmbeddedDataTask);
        this.startup.addTask(RequestEmbeddedAssetsTask);
    }


}
}
