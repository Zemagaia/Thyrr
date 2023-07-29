package kabam.rotmg.game.view {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.Panel;

import flash.events.Event;

import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.game.model.TextPanelData;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class TextPanel extends Panel {

    public var data:TextPanelData = Global.textPanelData;
    private var textField:TextFieldDisplayConcrete;

    public function TextPanel(_arg1:GameSprite) {
        super(_arg1);
        this.initTextfield();
        addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    private function initialize(e:Event):void
    {
        this.init(this.data.message);
    }

    public function init(_arg1:String):void {
        this.textField.setStringBuilder(new LineBuilder().setParams(_arg1));
        this.textField.setAutoSize(TextFieldAutoSize.CENTER).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        this.textField.x = (WIDTH / 2);
        this.textField.y = (HEIGHT / 2);
    }

    private function initTextfield():void {
        this.textField = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF);
        this.textField.setBold(true);
        this.textField.setStringBuilder(new LineBuilder().setParams("Gift Chest Is Empty"));
        this.textField.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.textField);
    }


}
}
