package com.company.ui {

import flash.events.Event;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextLineMetrics;

import kabam.rotmg.text.model.FontModel_VeniceClassic;
import kabam.rotmg.text.model.FontModel_VeniceClassic_Bold;

public class BaseSimpleText extends TextField {

    private static const GUTTER:int = 16;

    public static const VeniceClassic:Class = FontModel_VeniceClassic;
    public static const VeniceClassicBold:Class = FontModel_VeniceClassic_Bold;
    public static const VeniceClassicCFF:Class = FontModel_VeniceClassic;
    public static const VeniceClassicBoldCFF:Class = FontModel_VeniceClassic_Bold;
    public static var Font_:Font;
    public static var FontRegistered_:Boolean = false;

    public var inputWidth_:int;
    public var inputHeight_:int;
    public var actualWidth_:int;
    public var actualHeight_:int;
    public var autoResize:Boolean;

    public function BaseSimpleText(textSize:int, color:uint, makeSelectable:Boolean = false, widthParam:int = 0, heightParam:int = 0, isLink:Boolean = false) {
        if (!FontRegistered_) {
            Font.registerFont(VeniceClassic);
            Font.registerFont(VeniceClassicBold);
            Font.registerFont(VeniceClassicCFF);
            Font.registerFont(VeniceClassicBoldCFF);
            Font_ = new VeniceClassic();
            FontRegistered_ = true;
        }

        super();
        this.inputWidth_ = widthParam;
        if (this.inputWidth_ != 0) {
            width = widthParam;
        }
        this.inputHeight_ = heightParam;
        if (this.inputHeight_ != 0) {
            height = heightParam;
        }
        var format:TextFormat = defaultTextFormat;
        format.font = Font_.fontName;
        format.bold = false;
        format.size = textSize;
        format.color = color;
        embedFonts = true;
        defaultTextFormat = format;
        if (makeSelectable) {
            selectable = true;
            mouseEnabled = true;
            type = TextFieldType.INPUT;
            border = true;
            borderColor = color;
            addEventListener(Event.CHANGE, this.onChange);
        }
        else {
            selectable = false;
            mouseEnabled = false;
        }

        if (isLink) {
            mouseEnabled = true;
        }
    }

    public function setSize(size:int):BaseSimpleText {
        var format:TextFormat = defaultTextFormat;
        format.size = size;
        this.applyFormat(format);
        return this;
    }

    public function setColor(color:uint):BaseSimpleText {
        var format:TextFormat = defaultTextFormat;
        format.color = color;
        this.applyFormat(format);
        return this;
    }

    public function setBold(bold:Boolean):BaseSimpleText {
        var format:TextFormat = defaultTextFormat;
        format.bold = bold;
        this.applyFormat(format);
        return this;
    }

    public function setAlignment(alignment:String):BaseSimpleText {
        var format:TextFormat = defaultTextFormat;
        format.align = alignment;
        this.applyFormat(format);
        return this;
    }

    public function setText(text:String):BaseSimpleText {
        this.text = text;
        return this;
    }

    public function setIndent(indent:int):BaseSimpleText {
        var format:TextFormat = defaultTextFormat;
        format.indent = indent;
        this.applyFormat(format);
        return this;
    }

    private function applyFormat(format:TextFormat):void {
        setTextFormat(format);
        defaultTextFormat = format;
    }

    private function onChange(event:Event):void {
        this.updateMetrics();
    }

    public function updateMetrics():BaseSimpleText {
        var textMetrics:TextLineMetrics = null;
        var textWidth:int = 0;
        var textHeight:int = 0;
        this.actualWidth_ = 0;
        this.actualHeight_ = 0;
        var i:int = 0;
        while (i < numLines) {
            textMetrics = getLineMetrics(i);
            textWidth = textMetrics.width + 4;
            textHeight = textMetrics.height + 4;
            if (textWidth > this.actualWidth_) {
                this.actualWidth_ = textWidth;
            }
            this.actualHeight_ = this.actualHeight_ + textHeight;
            i++;
        }
        width = this.inputWidth_ == 0 ? this.actualWidth_ : this.inputWidth_;
        height = this.inputHeight_ == 0 ? this.actualHeight_ : this.inputHeight_;
        if (this.autoResize)
            this.resize();
        return this;
    }

    public function useTextDimensions():void {
        width = this.inputWidth_ == 0 ? (textWidth + 4) : (this.inputWidth_);
        height = this.inputHeight_ == 0 ? (textHeight + 4) : (this.inputHeight_);
        if (this.autoResize)
            this.resize();
    }

    public function setAutoSize(aSize:String):void {
        autoSize = aSize;
        if (this.inputWidth_ != 0 || this.inputHeight_ != 0)
            this.autoResize = true;
    }

    private function resize():void {
        while ((this.inputWidth_ > 0 && width > this.inputWidth_) || (this.inputHeight_ > 0 && height > this.inputHeight_)) {
            scaleX -= 0.05;
            scaleY -= 0.05;
        }
    }

    public function getSize():int {
        return int(defaultTextFormat.size);
    }
}
}
