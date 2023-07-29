package kabam.rotmg.characters.reskin.view {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.ui.panels.Panel;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;


import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

import org.osflash.signals.Signal;

public class ReskinPanel extends Panel {

    private var title:TextFieldDisplayConcrete;
    private var button:DeprecatedTextButton;

    public function ReskinPanel(_arg1:GameSprite = null) {
        super(_arg1);
        this.title = new TextFieldDisplayConcrete().setSize(18).setColor(0xFFFFFF).setAutoSize(TextFieldAutoSize.CENTER);
        this.title.x = int((WIDTH / 2));
        this.title.y = 6;
        this.title.setBold(true);
        this.title.filters = [new DropShadowFilter(0, 0, 0)];
        this.title.setStringBuilder(new LineBuilder().setParams("Change Skin"));
        addChild(this.title);
        this.button = new DeprecatedTextButton(16, "Choose");
        this.button.textChanged.addOnce(this.onTextSet);
        addChild(this.button);
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        button.addEventListener(MouseEvent.CLICK, onButton);
    }

    private function onButton(e:MouseEvent):void
    {
        Global.openReskinDialog();
    }

    private function onTextSet():void {
        this.button.x = int(((WIDTH / 2) - (this.button.width / 2)));
        this.button.y = ((HEIGHT - this.button.height) - 4);
    }

    private function onAddedToStage(_arg1:Event):void {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    private function onKeyDown(_arg1:KeyboardEvent):void {
        if ((((_arg1.keyCode == Parameters.data_.interact)) && ((stage.focus == null)))) {
            Global.openReskinDialog();
        }
    }


}
}
