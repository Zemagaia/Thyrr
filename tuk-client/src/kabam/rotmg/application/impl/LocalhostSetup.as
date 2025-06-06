﻿package kabam.rotmg.application.impl {
import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.application.api.ApplicationSetup;

public class LocalhostSetup implements ApplicationSetup {

    private const SERVER:String = "http://localhost:8080";
    private const BUILD_LABEL:String = "<font color='#FFEE00'>LOCALHOST</font> #{VERSION}";


    public function getAppEngineUrl(_arg1:Boolean = false):String {
        return (this.SERVER);
    }

    public function getBuildLabel():String {
        return this.BUILD_LABEL.replace("{VERSION}", Parameters.FULL_BUILD);
    }

    public function useLocalTextures():Boolean {
        return (true);
    }

    public function useProductionDialogs():Boolean {
        return (false);
    }

    public function areErrorsReported():Boolean {
        return (false);
    }

    public function areDeveloperHotkeysEnabled():Boolean {
        return (true);
    }

    public function isDebug():Boolean {
        return (true);
    }


}
}
