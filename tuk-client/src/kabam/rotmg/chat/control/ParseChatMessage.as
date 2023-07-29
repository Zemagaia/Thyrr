package kabam.rotmg.chat.control
{

import com.company.assembleegameclient.parameters.Parameters;

import flash.events.Event;

import kabam.lib.tasks.Task;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.language.service.GetLanguageService;
import kabam.rotmg.ui.model.HUDModel;

public class ParseChatMessage
{

    public var hudModel:HUDModel = Global.hudModel;
    public var client:AppEngineClient = Global.appEngine;
    public var account:Account = Global.account;

    public function execute(msg:String):void
    {
        var data:Array;
        if (msg.charAt(0) == "/")
        {
            data = msg.substr(1, msg.length).split(" ");
            switch (data[0])
            {
                case "mscale":
                    if (data.length == 2 && data[1] >= 0.5 && data[1] <= 5)
                    {
                        Parameters.data_["mscale"] = data[1];
                        Parameters.save();
                        Parameters.root.dispatchEvent(new Event(Event.RESIZE));
                        Global.addTextLine(ChatMessage.make(Parameters.HELP_CHAT_NAME, "Map Scale: " + data[1]));
                    }
                    else
                    {
                        Global.addTextLine(ChatMessage.make(Parameters.HELP_CHAT_NAME, "Map Scale: " + Parameters.data_.mscale + " - Usage: /mscale <any number between 0.5 and 5>"));
                    }
                    return;
                case "language":
                    Global.languageModel.setLanguage(data[1]);
                    var task:Task = new GetLanguageService();
                    Global.taskMonitor.add(task);
                    task.start();
                    task.finished.add(onLanguageChanged);
                    return;
            }
        }
        this.hudModel.gameSprite.gsc_.playerText(msg);
    }

    private function onLanguageChanged(task:Task, isOk:Boolean, data:String = ""):void
    {
        Global.addTextLine(ChatMessage.make(Parameters.HELP_CHAT_NAME, "game.languagechanged"));
    }

}
}