package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.MathUtil;
import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import org.osflash.signals.Signal;

import thyrr.utils.Utils;

public class StatusBar extends Sprite {

    public static var barTextSignal:Signal = new Signal(Boolean);

    public var w_:int;
    public var h_:int;
    public var color_:uint;
    public var backColor_:uint;
    public var pulseBackColor:uint;
    public var textColor_:uint;
    public var val_:Number = -1;
    public var max_:Number = -1;
    public var boost_:Number = -1;
    public var maxMax_:Number = -1;
    private var labelText_:TextFieldDisplayConcrete;
    private var labelTextStringBuilder_:LineBuilder;
    private var valueText_:TextFieldDisplayConcrete;
    private var valueTextStringBuilder_:StaticStringBuilder;
    private var boostText_:TextFieldDisplayConcrete;
    private var multiplierText:TextFieldDisplayConcrete;
    public var multiplierIcon:Sprite;
    private var colorSprite:Sprite;
    private var defaultForegroundColor:Number;
    private var defaultBackgroundColor:Number;
    public var mouseOver_:Boolean = false;
    private var isPulsing:Boolean = false;
    private var repetitions:int;
    private var direction:int = -1;
    private var speed:Number = 0.1;
    private var smallSize:Boolean;
    public var alpha_:Number = 1;
    private var texIndex:int;

    // true width = width + 32
    // true height = height + 8

    public function StatusBar(w:int, h:int, color:uint, backColor:uint, key:String = null, texIndex:int = -1, smallSizes:Boolean = false) {
        this.colorSprite = new Sprite();
        super();
        addChild(this.colorSprite);
        this.w_ = w;
        this.h_ = h;
        this.defaultForegroundColor = (this.color_ = color);
        this.defaultBackgroundColor = (this.backColor_ = backColor);
        this.texIndex = texIndex;
        if (texIndex > -1)
            drawBackground();
        this.textColor_ = 0xFFFFFF;
        this.smallSize = smallSizes;
        if (((!((key == null))) && (!((key.length == 0))))) {
            this.labelText_ = new TextFieldDisplayConcrete().setSize(11).setColor(this.textColor_);
            this.labelText_.setBold(true);
            this.labelTextStringBuilder_ = new LineBuilder().setParams(key);
            this.labelText_.setStringBuilder(this.labelTextStringBuilder_);
            this.centerVertically(this.labelText_);
            this.labelText_.filters = [new DropShadowFilter(0,0,0,0.6,3,3,3)];
            addChild(this.labelText_);
        }
        this.valueText_ = new TextFieldDisplayConcrete().setSize(smallSizes ? 11 : 13).setColor(0xFFFFFF);
        this.valueText_.setBold(true);
        this.valueText_.filters = [new DropShadowFilter(0,0,0,0.6,3,3,3)];
        this.centerVertically(this.valueText_);
        this.valueTextStringBuilder_ = new StaticStringBuilder();

        this.boostText_ = new TextFieldDisplayConcrete().setSize(smallSizes ? 11 : 13).setColor(this.textColor_);
        this.boostText_.setBold(true);
        this.boostText_.alpha = 0.6;
        this.centerVertically(this.boostText_);
        this.boostText_.filters = [new DropShadowFilter(0,0,0,0.6,3,3,3)];

        this.multiplierIcon = new Sprite();
        this.multiplierIcon.x = (this.w_ - 28);
        this.multiplierIcon.graphics.beginFill(0xFF00FF, 0);
        this.multiplierIcon.graphics.drawRect(0, 0, 20, 20);
        this.multiplierIcon.addEventListener(MouseEvent.MOUSE_OVER, this.onMultiplierOver);
        this.multiplierIcon.addEventListener(MouseEvent.MOUSE_OUT, this.onMultiplierOut);
        this.multiplierText = new TextFieldDisplayConcrete().setSize(12).setColor(0x309C63);
        this.multiplierText.setBold(true);
        this.multiplierText.setStringBuilder(new StaticStringBuilder("x1.3"));
        this.multiplierText.filters = [new DropShadowFilter(0, 0, 0)];
        this.multiplierIcon.addChild(this.multiplierText);

        if (!Parameters.data_.toggleBarText) {
            addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
            addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
        }
        barTextSignal.add(this.setBarText);
    }

    private var icon:Bitmap;
    private function drawBackground():void
    {
        graphics.clear();
        graphics.beginFill(Utils.color(backColor_, 1/(1.35*1.35)));
        graphics.drawRect(-28, -4, w_ + 32, h_ + 8);
        graphics.beginFill(backColor_);
        graphics.drawRect(-26, -2, w_ + 28, h_ + 4);
        if (backColor_ == 0xAEA9A9)
        {
            graphics.beginFill(backColor_ == 0xAEA9A9 ? Utils.color(0xAEA9A9, 1/1.35) : backColor_);
            graphics.drawRect(0, 0, w_, h_);
        }
        var color:int = 0;
        switch (texIndex)
        {
            // XP
            case 0x50: color = 0x236D7A; break;
            // HP
            case 0x51: color = 0x631525; break;
            // MP
            case 0x52: color = 0x46275C; break;
        }
        graphics.beginFill(color);
        graphics.drawRect(-24, 0, 22, h_);
        graphics.endFill();
        if (icon == null)
        {
            var data:BitmapData = AssetLibrary.getImageFromSet("interfaceBig", texIndex);
            icon = new Bitmap(data);
            icon.x = -21;
            icon.y = 1;
            addChild(icon);
        }
    }

    public function centerVertically(_arg1:TextFieldDisplayConcrete):void {
        _arg1.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        _arg1.y = ((this.h_ / 2) + 1);
    }

    private function onMultiplierOver(_arg1:MouseEvent):void {
        dispatchEvent(new Event("MULTIPLIER_OVER"));
    }

    private function onMultiplierOut(_arg1:MouseEvent):void {
        dispatchEvent(new Event("MULTIPLIER_OUT"));
    }

    public function draw(value:Number, max:Number, boost:Number, maxMax:Number = -1):void {
        if (max > 0) {
            value = Math.min(max, Math.max(0, value));
        }
        if ((((((((value == this.val_)) && ((max == this.max_)))) && ((boost == this.boost_)))) && ((maxMax == this.maxMax_)))) {
            return;
        }
        this.val_ = value;
        this.max_ = max;
        this.boost_ = boost;
        this.maxMax_ = maxMax;
        this.internalDraw();
    }

    public function setLabelText(key:String, tokens:Object = null):void {
        this.labelTextStringBuilder_.setParams(key, tokens);
        this.labelText_.setStringBuilder(this.labelTextStringBuilder_);
    }

    public function setValueText(string:String, align:Boolean = true):void {
        this.valueText_.setStringBuilder(this.valueTextStringBuilder_.setString(string));
        if (align)
            this.valueText_.x = ((this.w_ / 2) - ((this.valueText_.width) / 2));
    }

    private function setTextColor(_arg1:uint):void {
        this.textColor_ = _arg1;
        if (this.boostText_ != null) {
            this.boostText_.setColor(this.textColor_);
        }
        this.valueText_.setColor(this.textColor_);
    }

    public function setBarText(_arg1:Boolean):void {
        this.mouseOver_ = false;
        if (_arg1) {
            removeEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
            removeEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
        }
        else {
            addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
            addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
        }
        this.internalDraw();
    }

    private function internalDraw():void {
        this.colorSprite.graphics.clear();
        var _local1:uint = 0xFFFFFF;
        if ((((this.maxMax_ > 0)) && (((this.max_ - this.boost_) == this.maxMax_)))) {
            _local1 = 0xFCDF00;
        }
        if (this.textColor_ != _local1) {
            this.setTextColor(_local1);
        }
        if (this.texIndex > -1)
            drawBackground();
        if (this.isPulsing) {
            this.colorSprite.graphics.beginFill(this.pulseBackColor);
            this.colorSprite.graphics.drawRect(0, 0, this.w_, this.h_);
        }
        this.colorSprite.graphics.beginFill(this.color_);
        if (this.max_ > 0) {
            this.colorSprite.graphics.drawRect(0, 0, (this.w_ * (this.val_ / this.max_)), this.h_);
        }
        else {
            this.colorSprite.graphics.drawRect(0, 0, this.w_, this.h_);
        }
        this.colorSprite.graphics.endFill();
        if (contains(this.valueText_)) {
            removeChild(this.valueText_);
        }
        if (contains(this.boostText_)) {
            removeChild(this.boostText_);
        }
        this.drawWithMouseOver();
    }

    public function drawWithMouseOver():void {
        if (this.max_ > 0) {
            this.valueText_.setStringBuilder(this.valueTextStringBuilder_.setString(
                    (this.val_ > 1000000 ? MathUtil.round(this.val_ / 1000000, 3) + "M"
                            : this.val_ > 1000 ? MathUtil.round(this.val_ / 1000, 1) + "K" : this.val_.toString()) + "/" +
                    (this.max_ > 1000000 ? MathUtil.round(this.max_ / 1000000, 2) + "M" :
                            this.max_ > 1000 ? MathUtil.round(this.max_ / 1000, 1) + "K" : this.max_.toString())
            ));
        }
        else {
            this.valueText_.setStringBuilder(this.valueTextStringBuilder_.setString(
                    (this.val_ > 1000000 ? MathUtil.round(this.val_ / 1000000, 3) + "M"
                            : this.val_ > 1000 ? MathUtil.round(this.val_ / 1000, 2) + "K" : this.val_.toString())
                    ));
        }
        if (!contains(this.valueText_)) {
            this.valueText_.mouseEnabled = false;
            this.valueText_.mouseChildren = false;
            addChild(this.valueText_);
        }
        if (this.boost_ != 0) {
            this.boostText_.setStringBuilder(this.valueTextStringBuilder_.setString((((" (" + (((this.boost_ > 0)) ? "+" : "")) + this.boost_.toString()) + ")")));
            if (!contains(this.boostText_)) {
                this.boostText_.mouseEnabled = false;
                this.boostText_.mouseChildren = false;
                if (!this.smallSize)
                    addChild(this.boostText_);
            }
            this.valueText_.x = ((this.w_ / 2) - ((this.valueText_.width + this.boostText_.width) / 2));
            this.boostText_.x = (this.valueText_.x + this.valueText_.width);
        }
        else {
            if (!_showPerc)
            {
                this.valueText_.x = ((this.w_ / 2) - (this.valueText_.width / 2));
                if (contains(this.boostText_)) {
                    removeChild(this.boostText_);
                }
            }
            else
            {
                var perc:Number = Number((this.val_ / this.max_) * 100);
                this.boostText_.setStringBuilder(this.valueTextStringBuilder_.setString("(" + perc.toFixed(1) + "%)"));
                this.boostText_.mouseEnabled = false;
                this.boostText_.mouseChildren = false;
                if (!contains(this.boostText_))
                    addChild(this.boostText_);
                this.valueText_.x = ((this.w_ / 2) - ((this.valueText_.width + this.boostText_.width) / 2));
                this.boostText_.x = (this.valueText_.x + this.valueText_.width);
            }
        }
    }

    private var _showPerc:Boolean = false;
    public function showPercentages(showPerc:Boolean):void {
        _showPerc = showPerc;
        if (showPerc)
            drawWithMouseOver();
    }

    public function showMultiplierText():void {
        this.multiplierIcon.mouseEnabled = false;
        this.multiplierIcon.mouseChildren = false;
        addChild(this.multiplierIcon);
        this.startPulse(3, 0x309C63, 0xFFFFFF);
    }

    public function hideMultiplierText():void {
        if (this.multiplierIcon.parent) {
            removeChild(this.multiplierIcon);
        }
    }

    public function startPulse(repetitions:Number, color:Number, pulseBgColor:Number):void {
        this.isPulsing = true;
        this.color_ = color;
        this.pulseBackColor = pulseBgColor;
        this.repetitions = repetitions;
        this.internalDraw();
        addEventListener(Event.ENTER_FRAME, this.onPulse);
    }

    private function onPulse(_arg1:Event):void {
        if ((((this.colorSprite.alpha > 1)) || ((this.colorSprite.alpha < 0)))) {
            this.direction = (this.direction * -1);
            if (this.colorSprite.alpha > 1) {
                this.repetitions--;
                if (!this.repetitions) {
                    this.isPulsing = false;
                    this.color_ = this.defaultForegroundColor;
                    this.backColor_ = this.defaultBackgroundColor;
                    this.colorSprite.alpha = 1;
                    this.internalDraw();
                    removeEventListener(Event.ENTER_FRAME, this.onPulse);
                }
            }
        }
        this.colorSprite.alpha = (this.colorSprite.alpha + (this.speed * this.direction));
    }

    private function onMouseOver(_arg1:MouseEvent):void {
        this.mouseOver_ = true;
        this.internalDraw();
    }

    private function onMouseOut(_arg1:MouseEvent):void {
        this.mouseOver_ = false;
        this.internalDraw();
    }


}
}
