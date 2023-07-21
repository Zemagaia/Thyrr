package com.company.assembleegameclient.ui.options {
import com.company.assembleegameclient.parameters.Parameters;

import flash.events.Event;

public class SliderOption extends BaseOption {

    private var sliderBar:VolumeSliderBar;
    private var disabled_:Boolean;
    private var callbackFunc:Function;

    public function SliderOption(param:String, callbackFunc:Function = null, disabled:Boolean = false) {
        super(param, "", "");
        this.sliderBar = new VolumeSliderBar(Parameters.data_[paramName_]);
        this.sliderBar.addEventListener(Event.CHANGE, this.onChange);
        this.callbackFunc = callbackFunc;
        addChild(this.sliderBar);
        this.setDisabled(disabled);
    }

    public function setDisabled(disabled:Boolean):void {
        this.disabled_ = disabled;
        mouseEnabled = !(this.disabled_);
        mouseChildren = !(this.disabled_);
    }

    override public function refresh():void {
        this.sliderBar.currentVolume = Parameters.data_[paramName_];
    }

    private function onChange(_arg1:Event):void {
        Parameters.data_[paramName_] = this.sliderBar.currentVolume;
        if (this.callbackFunc != null) {
            this.callbackFunc(this.sliderBar.currentVolume);
        }
        Parameters.save();
    }


}
}
