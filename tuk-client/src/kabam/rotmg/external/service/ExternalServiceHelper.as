package kabam.rotmg.external.service {
import flash.external.ExternalInterface;

public class ExternalServiceHelper {

    public function mapExternalCallbacks():void {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("updatePlayerCredits", Global.requestPlayerCredits);
        }
    }


}
}
