//kabam.rotmg.memMarket.utils.ItemUtils

package kabam.rotmg.memMarket.utils
{
import com.company.assembleegameclient.objects.ObjectLibrary;

import thyrr.utils.ItemData;

public class ItemUtils
    {

        public static function isBanned(itemData:ItemData):Boolean
        {
            return (ObjectLibrary.isSoulbound(itemData));
        }

    }
}//package kabam.rotmg.memMarket.utils

