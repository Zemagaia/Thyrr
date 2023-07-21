package com.company.assembleegameclient.appengine {
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;

import flash.display.BitmapData;

public class SavedNewsItem {

    private static const FAME:String = "fame";

    private var iconName:String;
    public var title_:String;
    public var tagline_:String;
    public var link_:String;
    public var date_:int;

    public function SavedNewsItem(_arg1:String, _arg2:String, _arg3:String, _arg4:String, _arg5:int) {
        this.iconName = _arg1;
        this.title_ = _arg2;
        this.tagline_ = _arg3;
        this.link_ = _arg4;
        this.date_ = _arg5;
    }

    public static function fameIcon():BitmapData {
        var _local1:BitmapData = AssetLibrary.getImageFromSet("interfaceSmall", 80);
        return (TextureRedrawer.redraw(_local1, 80, true, 0));
    }

    public function isCharDeath():Boolean {
        return ((this.iconName == FAME));
    }


}
}
