package kabam.rotmg.errors {
import com.company.util.CapabilitiesUtil;

import flash.events.ErrorEvent;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.application.api.ApplicationSetup;

public class ReportErrorToAppEngine
{
    public var account:Account = Global.account;
    public var client:AppEngineClient = Global.appEngine;
    public var setup:ApplicationSetup = Global.applicationSetup;
    private var error:*;

    public function execute(event:ErrorEvent):void
    {
        event.preventDefault();
        this.error = event["error"];
        this.getMessage(event);
        var _local1:Array = [];
        _local1.push(("Build: " + this.setup.getBuildLabel()));
        _local1.push(("message: " + this.getMessage(event)));
        _local1.push(("stackTrace: " + this.getStackTrace()));
        _local1.push(CapabilitiesUtil.getHumanReadable());
        this.client.setSendEncrypted(false);
        this.client.sendRequest("/clientError/add", {
            "text": _local1.join("\n"),
            "guid": this.account.getUserId()
        });
    }

    private function getMessage(event:ErrorEvent):String {
        if ((this.error is Error)) {
            return (this.error.message);
        }
        if (event != null) {
            return (event.text);
        }
        if (this.error != null) {
            return (this.error.toString());
        }
        return ("(empty)");
    }

    private function getStackTrace():String {
        return ((((this.error is Error)) ? Error(this.error).getStackTrace() : "(empty)"));
    }
}
}
