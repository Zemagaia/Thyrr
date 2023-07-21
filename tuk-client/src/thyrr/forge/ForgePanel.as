package thyrr.forge {

import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.panels.ButtonPanel;
import com.company.assembleegameclient.game.GameSprite;

import flash.events.Event;

import flash.events.KeyboardEvent;

import flash.events.MouseEvent;

public class ForgePanel extends ButtonPanel {

    public function ForgePanel(gameSprite:GameSprite) {
        super(gameSprite, "Forge", "Open");
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    override protected function onButtonClick(event:MouseEvent):void {
        this.open();
    }

    private function open():void {
        this.gs_.mui_.setEnablePlayerInput(false);
        this.gs_.addChild(new Forge(this.gs_.mui_.gs_));
    }

    private function onAddedToStage(_arg1:Event):void {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    private function onKeyDown(event:KeyboardEvent):void {
        if (event.keyCode == Parameters.data_.interact && stage.focus == null && this.gs_.mui_.enablePlayerInput_) {
            this.open();
        }
    }

}
}