package kabam.rotmg.death.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.ColorMatrixFilter;



import org.osflash.signals.Signal;

public class ResurrectionView extends Sprite {

    public const showDialog:Signal = new Signal(Sprite);
    public const closed:Signal = new Signal();
    private const POPUP_BACKGROUND_COLOR:Number = 0;
    private const POPUP_LINE_COLOR:Number = 0x3B3B3B;
    private const POPUP_WIDTH:Number = 300;
    private const POPUP_HEIGHT:Number = 400;

    private var popup:Dialog;


    public function init(_arg1:BitmapData):void {
        this.createBackground(_arg1);
        this.createPopup();
    }

    private function createBackground(_arg1:BitmapData):void {
        var _local4:Bitmap;
        var _local2:Array = [0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 1, 0];
        var _local3:ColorMatrixFilter = new ColorMatrixFilter(_local2);
        _local4 = new Bitmap(_arg1);
        _local4.filters = [_local3];
        addChild(_local4);
    }

    public function createPopup():void {
        this.popup = new Dialog("YOU HAVE DIED!",
                "Realm of the Mad God is a perma-death game. If you die, you'll lose your character and any items in your inventory, but you'll gain fame based on your deeds. You've just been saved from death. This won't happen again, so be careful adventurer!",
                "Save Me", null, null);
        this.popup.addEventListener(Dialog.LEFT_BUTTON, this.onButtonClick);
        this.showDialog.dispatch(this.popup);
    }

    private function onButtonClick(_arg1:Event):void {
        this.closed.dispatch();
    }


}
}
