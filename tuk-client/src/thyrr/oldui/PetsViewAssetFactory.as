package thyrr.oldui {
import com.company.assembleegameclient.objects.ObjectLibrary;

import flash.display.Bitmap;
import flash.filters.DropShadowFilter;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;

import thyrr.oldui.closeButton.DialogCloseButton;

public class PetsViewAssetFactory {

    public static function returnCloseButton(_arg1:int):DialogCloseButton {
        var _local2:DialogCloseButton;
        _local2 = new DialogCloseButton();
        _local2.y = 4;
        _local2.x = ((_arg1 - _local2.width) - 5);
        return (_local2);
    }

    public static function returnBitmap(_arg1:uint, _arg2:uint = 80):Bitmap {
        return (new Bitmap(ObjectLibrary.getRedrawnTextureFromType(_arg1, _arg2, true)));
    }

    public static function returnTextfield(_arg1:int, _arg2:int, _arg3:Boolean, _arg4:Boolean = false):TextFieldDisplayConcrete {
        var _local5:TextFieldDisplayConcrete = new TextFieldDisplayConcrete();
        _local5.setSize(_arg2).setColor(_arg1).setBold(_arg3);
        _local5.setVerticalAlign(TextFieldDisplayConcrete.BOTTOM);
        _local5.filters = ((_arg4) ? [new DropShadowFilter(0, 0, 0)] : []);
        return (_local5);
    }

}
}
