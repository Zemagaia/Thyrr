package kabam.rotmg.game.view.components {

import thyrr.ui.buttons.ToggleableButton;
import thyrr.utils.Utils;

public class TabIconView extends TabView {

    public var button:ToggleableButton;

    public function TabIconView(index:int, background:ToggleableButton) {
        super(index);
        this.init(background);
    }

    private function init(button:ToggleableButton):void {
        this.button = button;
        this.button.removeListeners();
        this.button.filters = [Utils.OutlineFilter];
        addChild(button);
    }

    override public function setSelected(_arg1:Boolean):void {
        super.setSelected(_arg1);
        button.setSelected(_arg1, true);
    }

}
}
