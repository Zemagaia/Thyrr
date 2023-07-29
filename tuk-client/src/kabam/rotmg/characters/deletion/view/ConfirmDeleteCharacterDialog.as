package kabam.rotmg.characters.deletion.view {
import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.display.Sprite;
import flash.events.Event;

import kabam.rotmg.characters.model.CharacterModel;

public class ConfirmDeleteCharacterDialog extends Sprite {

    private const CANCEL_EVENT:String = Dialog.LEFT_BUTTON;
    private const DELETE_EVENT:String = Dialog.RIGHT_BUTTON;

    public var model:CharacterModel = Global.characterModel;

    private var character:SavedCharacter;

    public function ConfirmDeleteCharacterDialog() {
        addEventListener(Event.ADDED_TO_STAGE, initialize)
    }

    public function initialize(e:Event):void {
        this.character = this.model.getSelected();
        this.setText(this.character.name(), this.character.displayId());
    }

    private function onDeleteCharacter():void {
        Global.deleteCharacter(this.character);
    }

    private function closeDialog():void {
        Global.closeDialogs();
    }

    public function setText(name:String, displayID:String):void {
        var dialog:Dialog = new Dialog("Verify Deletion", "", "Cancel", "Delete", "/deleteDialog");
        dialog.setTextParams("Are you really sure you want to delete {name} the {displayID}?", {
            "name": name,
            "displayID": displayID
        });
        dialog.addEventListener(this.CANCEL_EVENT, this.onCancel);
        dialog.addEventListener(this.DELETE_EVENT, this.onDelete);
        addChild(dialog);
    }

    private function onCancel(e:Event):void {
        closeDialog();
    }

    private function onDelete(e:Event):void {
        onDeleteCharacter();
    }


}
}
