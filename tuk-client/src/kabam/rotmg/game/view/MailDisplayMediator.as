package kabam.rotmg.game.view {
import com.company.assembleegameclient.game.MailModel;

import kabam.rotmg.game.signals.UpdateMailStatusDisplaySignal;

public class MailDisplayMediator {

    [Inject]
    public var updateMailStatusDisplay_:UpdateMailStatusDisplaySignal;
    [Inject]
    public var view:MailDisplay;
    [Inject]
    public var mailModel_:MailModel;


    public function initialize():void {
        this.updateMailStatusDisplay_.add(this.onGiftChestUpdate);
        if (this.mailModel_.text_) {
            this.view.draw(this.mailModel_.text_);
        }
    }

    private function onGiftChestUpdate():void {
        if (this.mailModel_.text_) {
            this.view.draw(this.mailModel_.text_);
        }
    }


}
}
