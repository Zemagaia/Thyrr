package thyrr.utils
{

import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;

import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import flash.utils.Dictionary;

public class Utils
{

    public static const OutlineFilter:DropShadowFilter = new DropShadowFilter(0,0,0,0.8,1.5,1.5,5);

    public static function color(hex:uint, mult:Number = 1):uint
    {
        var r:uint = ((hex & 0xff0000) >> 16) * mult;
        var g:uint = ((hex & 0x00ff00) >> 8) * mult;
        var b:uint = ((hex & 0x0000ff) >> 0) * mult;
        return (r << 16) + (g << 8) + (b << 0);
    }

    public static function getClock(hour:int):BitmapData
    {
        var data:BitmapData = AssetLibrary.getImageFromSet("interfaceBig", 0x40 + int(hour / 3));
        data = TextureRedrawer.redraw(data, 100, true, 0, false);
        data = BitmapUtil.cropToBitmapData(data, 8, 8, data.width - 16, data.height - 16);
        return data;
    }

    public static function getBitmapDatas(length:int, bases:Vector.<BitmapData>, size:int = 40):Vector.<BitmapData>
    {
        var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(length);
        var i:int = 0;
        while (i < bitmaps.length)
        {
            bitmaps[i] = bases[i];
            bitmaps[i] = TextureRedrawer.redraw(bitmaps[i], size, true, 0, false);
            bitmaps[i] = BitmapUtil.cropToBitmapData(bitmaps[i], 8, 8, bitmaps[i].width - 16, bitmaps[i].height - 16);
            i++;
        }
        return bitmaps;
    }

    public static function sortStrings(a:String, b:String):Number
    {
        if (a < b)
            return -1;
        else if (a > b)
            return 1;
        return 0;
    }

    // from somewhere, I don't remember
    public static function sortDictionaryByValue(d:Dictionary):Array
    {
        var a:Array = [];
        for (var dictionaryKey:Object in d)
            a.push({key: dictionaryKey, value: d[dictionaryKey]});
        a.sortOn("value", [Array.CASEINSENSITIVE | Array.DESCENDING]);
        return a;
    }

}
}