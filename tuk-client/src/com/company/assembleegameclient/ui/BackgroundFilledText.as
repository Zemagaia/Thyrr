﻿package com.company.assembleegameclient.ui {
import com.company.util.GraphicsUtil;

import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;

public class BackgroundFilledText extends Sprite {

    protected static const MARGIN:int = 4;

    public var bWidth:int = 0;
    public var text_:TextFieldDisplayConcrete;
    protected var w_:int;
    protected var enabledFill_:GraphicsSolidFill = new GraphicsSolidFill(0xFFFFFF, 1);
    protected var disabledFill_:GraphicsSolidFill = new GraphicsSolidFill(0x7F7F7F, 1);
    protected var path_:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());

    protected const graphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[enabledFill_, path_, GraphicsUtil.END_FILL];

    public function BackgroundFilledText(_arg1:int):void {
        super();
        this.bWidth = _arg1;
    }

    protected function centerTextAndDrawButton():void {
        this.w_ = (((this.bWidth) != 0) ? this.bWidth : (this.text_.width + 12));
        this.text_.x = (this.w_ / 2);
        GraphicsUtil.clearPath(this.path_);
        GraphicsUtil.drawCutEdgeRect(0, 0, this.w_, (this.text_.height + (MARGIN * 2)), 0, [0, 0, 0, 0], this.path_);
    }

    public function addText(_arg1:int):void {
        this.text_ = this.makeText().setSize(_arg1).setColor(0x363636);
        this.text_.setBold(true);
        this.text_.setAutoSize(TextFieldAutoSize.CENTER);
        this.text_.y = MARGIN;
        addChild(this.text_);
    }

    protected function makeText():TextFieldDisplayConcrete {
        return (new TextFieldDisplayConcrete());
    }


}
}
