package kabam.rotmg.characters.deletion.view {
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.display.Sprite;
import flash.events.Event;



import org.osflash.signals.Signal;

public class ConfirmDeleteCharacterDialog extends Sprite {

    private const CANCEL_EVENT:String = Dialog.LEFT_BUTTON;
    private const DELETE_EVENT:String = Dialog.RIGHT_BUTTON;

    public var deleteCharacter:Signal;
    public var cancel:Signal;

    public function ConfirmDeleteCharacterDialog() {
        this.deleteCharacter = new Signal();
        this.cancel = new Signal();
    }

    public function setText(_arg1:String, _arg2:String):void {
        var _local3:Dialog = new Dialog("Verify Deletion", "", "Cancel", "Delete", "/deleteDialog");
        _local3.setTextParams("Are you really sure you want to delete {name} the {displayID}?", {
            "name": _arg1,
            "displayID": _arg2
        });
        _local3.addEventListener(this.CANCEL_EVENT, this.onCancel);
        _local3.addEventListener(this.DELETE_EVENT, this.onDelete);
        addChild(_local3);
    }

    private function onCancel(_arg1:Event):void {
        this.cancel.dispatch();
    }

    private function onDelete(_arg1:Event):void {
        this.deleteCharacter.dispatch();
    }


}
}
