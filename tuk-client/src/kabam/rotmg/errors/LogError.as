package kabam.rotmg.errors {
import flash.events.ErrorEvent;

public class LogError
{
    public function execute(event:ErrorEvent):void {
        trace(event.text);
        if (event["error"] != null && event["error"] is Error) {
            this.logErrorObject(event["error"]);
        }
    }

    private function logErrorObject(error:Error):void {
        trace(error.message);
        trace(error.getStackTrace());
    }
}
}
