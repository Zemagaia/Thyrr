
//kabam.rotmg.memMarket.utils.IconUtils

package kabam.rotmg.memMarket.utils
{
    import com.company.util.AssetLibrary;
    import flash.display.BitmapData;
    import com.company.assembleegameclient.util.TextureRedrawer;

    public class IconUtils 
    {

        /* Draw the fame icon */
        public static function getFameIcon(size:int = 40) : BitmapData
        {
            var fameBD:BitmapData = AssetLibrary.getImageFromSet("interfaceSmall",80);
            return TextureRedrawer.redraw(fameBD,size,true,0);
        }

        /* Draw the gold icon */
        public static function getCoinIcon(size:int = 40) : BitmapData
        {
            var fameBD:BitmapData = AssetLibrary.getImageFromSet("interfaceSmall",81);
            return TextureRedrawer.redraw(fameBD,size,true,0);
        }

    }
}//package kabam.rotmg.memMarket.utils

