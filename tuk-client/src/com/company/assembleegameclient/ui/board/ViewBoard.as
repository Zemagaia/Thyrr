﻿package com.company.assembleegameclient.ui.board {
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.ui.LegacyScrollbar;
import com.company.ui.BaseSimpleText;
import com.company.util.GraphicsUtil;
import com.company.util.HTMLUtil;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

internal class ViewBoard extends Sprite {

    public static const TEXT_WIDTH:int = 400;
    public static const TEXT_HEIGHT:int = 400;
    private static const URL_REGEX:RegExp = /((https?|ftp):((\/\/)|(\\\\))+[\w\d:#@%\/;$()~_?+-=\\.&]*)/g;

    private var text_:String;
    public var w_:int;
    public var h_:int;
    private var boardText_:BaseSimpleText;
    private var mainSprite_:Sprite;
    private var scrollBar_:LegacyScrollbar;
    private var editButton_:DeprecatedTextButton;
    private var closeButton_:DeprecatedTextButton;
    private var backgroundFill_:GraphicsSolidFill = new GraphicsSolidFill(0x333333, 1);
    private var outlineFill_:GraphicsSolidFill = new GraphicsSolidFill(0xFFFFFF, 1);
    private var lineStyle_:GraphicsStroke = new GraphicsStroke(2, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3, outlineFill_);
    private var path_:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());

    private const graphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[lineStyle_, backgroundFill_, path_, GraphicsUtil.END_FILL, GraphicsUtil.END_STROKE];

    public function ViewBoard(_arg1:String, _arg2:Boolean) {
        super();
        this.text_ = _arg1;
        this.mainSprite_ = new Sprite();
        var _local3:Shape = new Shape();
        var _local4:Graphics = _local3.graphics;
        _local4.beginFill(0);
        _local4.drawRect(0, 0, TEXT_WIDTH, TEXT_HEIGHT);
        _local4.endFill();
        this.mainSprite_.addChild(_local3);
        this.mainSprite_.mask = _local3;
        addChild(this.mainSprite_);
        var _local5:String = HTMLUtil.escape(_arg1);
        _local5 = _local5.replace(URL_REGEX, ('<font color="#7777EE"><a href="$1" target="_blank">' + "$1</a></font>"));
        this.boardText_ = new BaseSimpleText(16, 0xB3B3B3, false, TEXT_WIDTH, 0);
        this.boardText_.border = false;
        this.boardText_.mouseEnabled = true;
        this.boardText_.multiline = true;
        this.boardText_.wordWrap = true;
        this.boardText_.htmlText = _local5;
        this.boardText_.useTextDimensions();
        this.mainSprite_.addChild(this.boardText_);
        var _local6:Boolean = (this.boardText_.height > 400);
        if (_local6) {
            this.scrollBar_ = new LegacyScrollbar(16, (TEXT_HEIGHT - 4));
            this.scrollBar_.x = (TEXT_WIDTH + 6);
            this.scrollBar_.y = 0;
            this.scrollBar_.setIndicatorSize(400, this.boardText_.height);
            this.scrollBar_.addEventListener(Event.CHANGE, this.onScrollBarChange);
            addChild(this.scrollBar_);
        }
        this.w_ = (TEXT_WIDTH + ((_local6) ? 26 : 0));
        this.editButton_ = new DeprecatedTextButton(14, "Edit", 120);
        this.editButton_.x = 4;
        this.editButton_.y = (TEXT_HEIGHT + 4);
        this.editButton_.addEventListener(MouseEvent.CLICK, this.onEdit);
        addChild(this.editButton_);
        this.editButton_.visible = _arg2;
        this.closeButton_ = new DeprecatedTextButton(14, "Close", 120);
        this.closeButton_.x = (this.w_ - 124);
        this.closeButton_.y = (TEXT_HEIGHT + 4);
        this.closeButton_.addEventListener(MouseEvent.CLICK, this.onClose);
        this.closeButton_.textChanged.addOnce(this.layoutBackground);
        addChild(this.closeButton_);
    }

    private function layoutBackground():void {
        this.h_ = ((TEXT_HEIGHT + this.closeButton_.height) + 8);
        x = ((Main.DefaultWidth / 2) - (this.w_ / 2));
        y = ((Main.DefaultHeight / 2) - (this.h_ / 2));
        graphics.clear();
        GraphicsUtil.clearPath(this.path_);
        GraphicsUtil.drawCutEdgeRect(-6, -6, (this.w_ + 12), (this.h_ + 12), 4, [1, 1, 1, 1], this.path_);
        graphics.drawGraphicsData(this.graphicsData_);
    }

    private function onScrollBarChange(_arg1:Event):void {
        this.boardText_.y = (-(this.scrollBar_.pos()) * (this.boardText_.height - 400));
    }

    private function onEdit(_arg1:Event):void {
        dispatchEvent(new Event(Event.CHANGE));
    }

    private function onClose(_arg1:Event):void {
        dispatchEvent(new Event(Event.COMPLETE));
    }


}
}
