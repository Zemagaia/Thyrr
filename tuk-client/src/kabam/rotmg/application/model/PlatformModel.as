﻿package kabam.rotmg.application.model {
import flash.system.Capabilities;

public class PlatformModel {

    private static var platform:PlatformType;

    private const DESKTOP:String = "Desktop";


    public function isWeb():Boolean {
        return (!((Capabilities.playerType == this.DESKTOP)));
    }

    public function isDesktop():Boolean {
        return ((Capabilities.playerType == this.DESKTOP));
    }

    public function getPlatform():PlatformType {
        return ((platform = ((platform) || (this.determinePlatform()))));
    }

    private function determinePlatform():PlatformType {
        var _local1:Object = Global.loaderInfo.parameters;
        if (this.isKongregate(_local1)) {
            return (PlatformType.KONGREGATE);
        }
        if (this.isSteam(_local1)) {
            return (PlatformType.STEAM);
        }
        if (this.isKabam(_local1)) {
            return (PlatformType.KABAM);
        }
        return (PlatformType.WEB);
    }

    private function isKongregate(_arg1:Object):Boolean {
        return (!((_arg1.kongregate_api_path == null)));
    }

    private function isSteam(_arg1:Object):Boolean {
        return (!((_arg1.steam_api_path == null)));
    }

    private function isKabam(_arg1:Object):Boolean {
        return (!((_arg1.kabam_signed_request == null)));
    }


}
}
