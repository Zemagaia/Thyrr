package thyrr.assets {
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.map.GroundLibrary;

import flash.net.URLLoaderDataFormat;
import flash.utils.ByteArray;

import kabam.lib.tasks.BaseTask;
import kabam.rotmg.appengine.api.AppEngineClient;

public class RequestEmbeddedDataTask extends BaseTask {
    
    public var client:AppEngineClient = Global.appEngine;
    
    
    override protected function startTask():void {
        this.client.complete.addOnce(this.onComplete);
        this.client.setDataFormat(URLLoaderDataFormat.BINARY);
        this.client.sendRequest("/app/gSXmls", null);
    }

    private function onComplete(success:Boolean, data:*):void {
        if (success) {
            onDataComplete(data);
        }
        else {
            onTextError(data);
        }
        completeTask(success, data);
    }

    private function onDataComplete(data:ByteArray):void {
        data.endian = "littleEndian";
        var count:int = data.readInt();
        var i:int = 0;
        while (i < count) {
            this.insertXml(data.readUTFBytes(data.readInt()));
            i++;
        }
    }
    
    private function insertXml(rawXml:String):void {
        var xml:XML = XML(rawXml);
        GroundLibrary.parseFromXML(xml);
        ObjectLibrary.parseFromXML(xml, false);
    }
    
    private function onTextError(data:String):void {
        Global.loadingScreen.setTextKey("Load error, retrying");
    }
    
    
}
}