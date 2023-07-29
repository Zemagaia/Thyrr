package kabam.rotmg.application.api {
public interface ApplicationSetup {

    function getBuildLabel():String;

    function getAppEngineUrl(_arg1:Boolean = false):String;

    function useLocalTextures():Boolean;

    function areDeveloperHotkeysEnabled():Boolean;

    function useProductionDialogs():Boolean;

    function areErrorsReported():Boolean;

}
}
