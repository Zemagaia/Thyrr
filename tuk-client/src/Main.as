package {
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.AssetLoader;
import com.company.assembleegameclient.util.StageProxy;

import flash.display.LoaderInfo;

import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageScaleMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.system.Capabilities;

import kabam.rotmg.classes.control.ParseClassesAndSkinsXml;

import kabam.rotmg.startup.control.StartupTasksHandler;

import kabam.rotmg.stage3D.Stage3DConfig;
import kabam.rotmg.startup.control.StartupPacketHandler;
import kabam.rotmg.ui.UIUtils;

import thyrr.assets.EmbeddedData;

[SWF(frameRate="60", backgroundColor="#000000", width="1408", height="792")]
public class Main extends Sprite {

    private const UNCAUGHT_ERROR_EVENTS:String = "uncaughtErrorEvents";
    private const UNCAUGHT_ERROR:String = "uncaughtError";

    public static var ENV:String;
    public static var STAGE:Stage;
    public static var sWidth:Number = DefaultWidth;
    public static var sHeight:Number = DefaultHeight;
    public static var DefaultWidth:Number = 1408;
    public static var DefaultHeight:Number = 792;

    private var loaderInfo_:LoaderInfo;

    public function Main() {
        if (stage) {
            stage.addEventListener(Event.RESIZE, this.onStageResize);
            initialize();
            addEventListener(Event.REMOVED_FROM_STAGE, destroy);
            this.setup();
        }
        else {
            addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, destroy);
        }
    }

    public function initialize():void {
        this.loaderInfo_ = root.stage.root.loaderInfo;
        if (this.canCatchGlobalErrors()) {
            this.addGlobalErrorListener();
        }
    }

    public function destroy(e:Event):void {
        if (this.canCatchGlobalErrors()) {
            this.removeGlobalErrorListener();
        }
    }

    private function canCatchGlobalErrors():Boolean {
        return (this.loaderInfo_.hasOwnProperty(this.UNCAUGHT_ERROR_EVENTS));
    }

    private function addGlobalErrorListener():void {
        var eventDispatcher:IEventDispatcher = IEventDispatcher(this.loaderInfo_[this.UNCAUGHT_ERROR_EVENTS]);
        eventDispatcher.addEventListener(this.UNCAUGHT_ERROR, this.handleUncaughtError);
    }

    private function removeGlobalErrorListener():void {
        var eventDispatcher:IEventDispatcher = IEventDispatcher(this.loaderInfo_[this.UNCAUGHT_ERROR_EVENTS]);
        eventDispatcher.removeEventListener(this.UNCAUGHT_ERROR, this.handleUncaughtError);
    }

    private function handleUncaughtError(error:ErrorEvent):void {
        Global.logError(error);
    }

    private function onAddedToStage(_arg1:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        initialize()
        this.setup();
    }

    private function setup():void {
        this.setEnvironment();
        this.hackParameters();
        Global.init(this.loaderInfo_, new StageProxy(this));
        new Stage3DConfig();
        new ParseClassesAndSkinsXml(XML(new EmbeddedData.playersCXML()));
        new AssetLoader();
        Global.setupLayers();
        addChild(Global.layers);
        stage.scaleMode = StageScaleMode.EXACT_FIT;
        new StartupTasksHandler();
        new StartupPacketHandler();
        this.configureForAirIfDesktopPlayer();
        STAGE = stage;
        UIUtils.toggleQuality(Parameters.data_.uiQuality);
    }

    private function setEnvironment():void {
        ENV = stage.loaderInfo.parameters["env"];

        ENV = "production";

        if (ENV == null) ENV = "localhost";
    }

    private function hackParameters():void {
        Parameters.root = stage.root;
    }

    private function configureForAirIfDesktopPlayer():void {
        if (Capabilities.playerType == "Desktop") {
            Parameters.data_.fullscreenMode = false;
            Parameters.save();
        }
    }

    public function onStageResize(_arg_1:Event):void {
        if (stage.scaleMode == StageScaleMode.NO_SCALE) {
            this.scaleX = (stage.stageWidth / DefaultWidth);
            this.scaleY = (stage.stageHeight / DefaultHeight);
            this.x = ((DefaultWidth - stage.stageWidth) >> 1);
            this.y = ((DefaultHeight - stage.stageHeight) >> 1);
        } else {
            this.scaleX = 1;
            this.scaleY = 1;
            this.x = 0;
            this.y = 0;
        }
        sWidth = stage.stageWidth;
        sHeight = stage.stageHeight;
        Camera.resetDimensions();
        Stage3DConfig.resetDimensions();
    }
}
}
