package kabam.rotmg.language.service {
import com.company.assembleegameclient.ui.dialogs.ErrorDialog;

import kabam.lib.json.JsonParser;

import kabam.lib.tasks.BaseTask;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.language.model.LanguageModel;
import kabam.rotmg.language.model.StringMap;

public class GetLanguageService extends BaseTask {

    public var model:LanguageModel = Global.languageModel;
    public var strings:StringMap = Global.stringMap;

    public var client:AppEngineClient = Global.appEngine;
    private var language:String;

    private static function get json_():JsonParser {
        return (Global.jsonParser);
    }

    override protected function startTask():void {
        this.language = this.model.getLanguageFamily();
        this.client.complete.addOnce(this.onComplete);
        this.client.setMaxRetries(3);
        this.client.sendRequest("/app/glangs", {"languageType": this.language});
    }

    private function onComplete(isOk:Boolean, data:*):void {
        if (isOk) {
            this.onLanguageResponse(data);
        }
        else {
            this.onLanguageError();
        }
        completeTask(isOk, data);
    }

    private function onLanguageResponse(data:String):void {
        var language:String = this.language;
        this.strings.clear();
        var keys:Object = json_.parse(data);
        for (var key:String in keys) {
            this.strings.setValue(key, keys[key], language);
        }
    }

    private function onLanguageError():void {
        this.strings.setValue("ok", "ok", this.model.getLanguageFamily());
        var dialog:ErrorDialog = new ErrorDialog((("Unable to load language [" + this.language) + "]"));
        Global.openDialog(dialog);
        completeTask(false);
    }


}
}
