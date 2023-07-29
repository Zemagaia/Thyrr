package kabam.rotmg.stage3D {

import com.company.assembleegameclient.util.StageProxy;

import com.company.assembleegameclient.util.Stage3DProxy;
import com.company.assembleegameclient.parameters.Parameters;

import flash.events.ErrorEvent;
import flash.events.Event;

import kabam.rotmg.stage3D.proxies.Context3DProxy;

import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;

import com.company.assembleegameclient.engine3d.Model3D;

public class Stage3DConfig {

    public static var WIDTH:int = Main.DefaultWidth;
    public static var HALF_WIDTH:int = (WIDTH / 2);
    public static var HEIGHT:int = Main.DefaultHeight;
    public static var HALF_HEIGHT:int = (HEIGHT / 2);

    private var stageProxy:StageProxy = Global.stageProxy;
    private var renderer:Renderer;
    private var stage3D:Stage3DProxy;

    public function Stage3DConfig() {
        this.stage3D = this.stageProxy.getStage3Ds(0);
        this.stage3D.addEventListener(ErrorEvent.ERROR, Parameters.clearGpuRenderEvent);
        this.stage3D.addEventListener(Event.CONTEXT3D_CREATE, this.onContextCreate);
        this.stage3D.requestContext3D();
    }

    public static function resetDimensions():void {
        var mscale:Number = Parameters.data_.mscale;
        var fWidth:Number = (Main.sWidth / mscale);
        var fHeight:Number = (Main.sHeight / mscale);
        WIDTH = fWidth;
        HALF_WIDTH = (fWidth / 2);
        HEIGHT = fHeight;
        HALF_HEIGHT = (fHeight / 2);
    }

    private function onContextCreate(_arg1:Event):void {
        this.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, this.onContextCreate);
        var _local2:Context3DProxy = this.stage3D.getContext3D();
        if (_local2.GetContext3D().driverInfo.toLowerCase().indexOf("software") != -1) {
            Parameters.clearGpuRender();
        }
        _local2.configureBackBuffer(WIDTH, HEIGHT, 2, true);
        _local2.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        _local2.setDepthTest(false, Context3DCompareMode.LESS_EQUAL);
        Global.setContext3DProxy(_local2);
        this.renderer = Global.renderer;
        this.renderer.init(_local2.GetContext3D());
        Model3D.Create3dBuffer(_local2.GetContext3D());
    }


}
}