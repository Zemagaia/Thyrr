﻿package kabam.rotmg.application.impl {
import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.application.api.ApplicationSetup;

public class FixedIPSetup implements ApplicationSetup {

    private const SERVER:String = "rotmgtesting.appspot.com";
    private const UNENCRYPTED:String = ("http://" + SERVER);
    private const ENCRYPTED:String = ("https://" + SERVER);
    private const BUILD_LABEL:String = "<font color='#9900FF'>{IP}</font> #{VERSION}";

    private var ipAddress:String;


    public function setAddress(_arg1:String):FixedIPSetup {
        this.ipAddress = _arg1;
        return (this);
    }

    public function getAppEngineUrl(_arg1:Boolean = false):String {
        return (((_arg1) ? this.UNENCRYPTED : this.ENCRYPTED));
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
        return (false);
    }


}
}
