package com.company.assembleegameclient.ui.panels {
import com.company.assembleegameclient.game.GameSprite;

import flash.display.DisplayObject;

import flash.display.Sprite;

public class Panel extends Sprite {

    public static const WIDTH:int = 190;
    public static const HEIGHT:int = 88;

    public var gs_:GameSprite;
    protected var panelBg_:DisplayObject = new PanelBG();

    public function Panel(gs:GameSprite) {
        this.gs_ = gs;
    }

    public function draw():void {
    }

    protected function DrawPanelBg():void {
        this.panelBg_.x = -6;
        this.panelBg_.y = -8;
        addChild(this.panelBg_);
    }

}
}
