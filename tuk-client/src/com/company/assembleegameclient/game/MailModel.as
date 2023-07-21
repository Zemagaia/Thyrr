package com.company.assembleegameclient.game {
import kabam.rotmg.game.signals.UpdateMailStatusDisplaySignal;

public class MailModel {

    [Inject]
    public var updateMailStatusSignal_:UpdateMailStatusDisplaySignal;
    public var text_:String;


    public function setMailText(text:String):void {
        this.text_ = text;
        this.updateMailStatusSignal_.dispatch();
    }


}
}
