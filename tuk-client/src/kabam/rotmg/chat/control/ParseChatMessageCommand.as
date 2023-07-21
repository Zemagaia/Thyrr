package kabam.rotmg.chat.control {

import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;

import kabam.rotmg.build.api.BuildData;

import kabam.rotmg.chat.model.ChatMessage;

import kabam.rotmg.game.signals.AddTextLineSignal;


import flash.events.Event;

import kabam.rotmg.ui.model.HUDModel;

public class ParseChatMessageCommand {

    [Inject]
    public var data:String;
    [Inject]
    public var hudModel:HUDModel;
    [Inject]
    public var addTextLine:AddTextLineSignal;
    [Inject]
    public var client:AppEngineClient;
    [Inject]
    public var account:Account;
    [Inject]
    public var buildData:BuildData;

    public function execute():void {
        var data:Array;
        if (this.data.charAt(0) == "/") {
            data = this.data.substr(1, this.data.length).split(" ");
            switch (data[0]) {
                case "mscale":
                    if (data.length == 2 && data[1] >= 0.5 && data[1] <= 5) {
                        Parameters.data_["mscale"] = data[1];
                        Parameters.save();
                        Parameters.root.dispatchEvent(new Event(Event.RESIZE));
                        this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME, "Map Scale: " + data[1]));
                    }
                    else {
                        this.addTextLine.dispatch(ChatMessage.make(Parameters.HELP_CHAT_NAME, "Map Scale: " + Parameters.data_.mscale + " - Usage: /mscale <any number between 0.5 and 5>"));
                    }
                    return;
            }
        }
        this.hudModel.gameSprite.gsc_.playerText(this.data);
    }

}
}