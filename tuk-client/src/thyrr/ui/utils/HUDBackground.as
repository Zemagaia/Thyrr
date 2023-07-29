package thyrr.ui.utils {

import flash.display.Sprite;

import thyrr.utils.Utils;

public class HUDBackground extends Sprite {

    public function HUDBackground() {
        super();
        var background:Sprite = new Sprite();
        background.graphics.beginFill(0x5F5C5C);
        background.graphics.drawRect(0, 0, 288, 792);
        this.filters = [Utils.OutlineFilter];
        addChild(background);
    }
}
}
