package thyrr.ui.utils {

import flash.display.Sprite;

import thyrr.utils.Utils;

public class HUDViewBackground extends Sprite {

    public function HUDViewBackground() {
        super();
        var background:Sprite = new Sprite();
        background.graphics.beginFill(0x544945);
        background.graphics.drawRect(0, 0, 288, 792);
        this.filters = [Utils.OutlineFilter];
        addChild(background);
    }
}
}
