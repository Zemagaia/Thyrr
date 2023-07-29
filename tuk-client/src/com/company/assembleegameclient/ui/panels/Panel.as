package com.company.assembleegameclient.ui.panels {
import com.company.assembleegameclient.game.GameSprite;

import flash.display.DisplayObject;
import flash.display.Sprite;

public class Panel extends Sprite {

    public static const WIDTH:int = 266;
    public static const HEIGHT:int = 88;

    public var gs_:GameSprite;

    public function Panel(gs:GameSprite) {
        this.gs_ = gs;
    }

    public function draw():void {
    }

}
}
