package kabam.rotmg.death.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.display.Sprite;
import flash.events.Event;

import org.osflash.signals.Signal;

public class ZombifyDialog extends Sprite {

    public static const TITLE:String = "You have died.";
    public static const BODY:String = "Your cursed amulet has reanimated you into a zombie that will wander the realm attacking other adventurers.";
    public static const BUTTON:String = "Accept Death";

    public const closed:Signal = new Signal();

    private var dialog:Dialog;

    public function ZombifyDialog() {
        this.dialog = new Dialog(TITLE, BODY, BUTTON, null, null);
        this.dialog.offsetX = -100;
        this.dialog.offsetY = 200;
        this.dialog.addEventListener(Dialog.LEFT_BUTTON, this.onButtonClick);
        addChild(this.dialog);
    }

    private function onButtonClick(_arg1:Event):void {
        this.closed.dispatch();
    }


}
}
