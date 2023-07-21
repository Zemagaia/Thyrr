package kabam.rotmg.game.view.components {

import thyrr.ui.buttons.ToggleableButton;

public class TabIconView extends TabView {

    public var button:ToggleableButton;

    public function TabIconView(index:int, background:ToggleableButton) {
        super(index);
        this.init(background);
    }

    private function init(button:ToggleableButton):void {
        this.button = button;
        this.button.removeListeners();
        addChild(button);
    }

    override public function setSelected(_arg1:Boolean):void {
        button.setSelected(_arg1, true);
    }

}
}
