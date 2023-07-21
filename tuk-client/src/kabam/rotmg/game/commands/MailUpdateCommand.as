package kabam.rotmg.game.commands {
import com.company.assembleegameclient.game.MailModel;

import robotlegs.bender.bundles.mvcs.Command;

public class MailUpdateCommand extends Command {

    [Inject]
    public var model:MailModel;
    [Inject]
    public var mailText_:String;


    override public function execute():void {
        this.model.setMailText(this.mailText_);
    }


}
}
