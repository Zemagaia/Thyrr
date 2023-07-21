package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.sound.Music;
import com.company.assembleegameclient.sound.SFX;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

import thyrr.ui.buttons.ToggleableButton;
import thyrr.utils.Utils;

public class SoundIcon extends ToggleableButton {

    public function SoundIcon() {
        super(24, 24, 0xAEA9A9, 6);
        // to avoid jumpy movement
        removeListeners();
        this.setSelected(!(Parameters.data_.playMusic || Parameters.data_.playSFX));
        addEventListener(MouseEvent.CLICK, this.onIconClick);
        filters = [new GlowFilter(0, 1, 4, 4, 2, 1)];
        x = 2;
        y = 2 + ((Parameters.data_.playMusic || Parameters.data_.playSFX) ? 4 : 0);
    }

    public override function setSelected(selected:Boolean, drawBottomLine:Boolean = false):void {
        var color:uint = Parameters.data_.playMusic || Parameters.data_.playSFX && origColor_ == 0xAEA9A9 ? Utils.color(origColor_, 1.3) : origColor_;
        toggle(color, !(Parameters.data_.playMusic || Parameters.data_.playSFX));
    }

    private function onIconClick(_arg1:MouseEvent):void {
        var muted:Boolean = !(Parameters.data_.playMusic || Parameters.data_.playSFX);
        Music.setPlayMusic(muted);
        SFX.setPlaySFX(muted);
        Parameters.data_.playPewPew = muted;
        Parameters.save();
        this.setSelected(muted);
    }


}
}
