package thyrr.assets {
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;

public class IconFactory {


    public static function makeCoin(_arg1:int = 40):BitmapData {
        var _local2:BitmapData = TextureRedrawer.resize(AssetLibrary.getImageFromSet("interfaceSmall", 81), null, _arg1, true, 0, 0);
        return (cropAndGlowIcon(_local2));
    }

    public static function makeUnholyEssence(_arg1:int = 40):BitmapData {
        var _local2:BitmapData = TextureRedrawer.resize(AssetLibrary.getImageFromSet("interfaceSmall", 65), null, _arg1, true, 0, 0);
        return (cropAndGlowIcon(_local2));
    }

    public static function makeDivineEssence(_arg1:int = 40):BitmapData {
        var _local2:BitmapData = TextureRedrawer.resize(AssetLibrary.getImageFromSet("interfaceSmall", 64), null, _arg1, true, 0, 0);
        return (cropAndGlowIcon(_local2));
    }

    public static function makeFortune():BitmapData {
        var _local1:BitmapData = TextureRedrawer.resize(AssetLibrary.getImageFromSet("interfaceSmall", 32), null, 20, true, 0, 0);
        return (cropAndGlowIcon(_local1));
    }

    public static function makeFame():BitmapData {
        var _local1:BitmapData = TextureRedrawer.resize(AssetLibrary.getImageFromSet("interfaceSmall", 80), null, 40, true, 0, 0);
        return (cropAndGlowIcon(_local1));
    }

    public static function makeGuildFame():BitmapData {
        var _local1:BitmapData = TextureRedrawer.resize(AssetLibrary.getImageFromSet("interfaceSmall", 82), null, 40, true, 0, 0);
        return (cropAndGlowIcon(_local1));
    }

    private static function cropAndGlowIcon(_arg1:BitmapData):BitmapData {
        _arg1 = GlowRedrawer.outline(_arg1, 0xFFFFFFFF);
        return (BitmapUtil.cropToBitmapData(_arg1, 10, 10, (_arg1.width - 20), (_arg1.height - 20)));
    }


    public function makeIconBitmap(_arg1:int):Bitmap {
        var _local2:BitmapData = AssetLibrary.getImageFromSet("interfaceBig", _arg1);
        _local2 = TextureRedrawer.redraw(_local2, (320 / _local2.width), true, 0);
        return (new Bitmap(_local2));
    }



}
}
