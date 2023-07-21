package thyrr.mail.model {
import com.company.ui.BaseSimpleText;

import flash.display.Sprite;

import com.company.assembleegameclient.game.GameSprite;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.util.components.DialogBackground;

import thyrr.mail.data.AccountMailsData;
import thyrr.oldui.closeButton.DialogCloseButton;

public class MailItem extends Sprite {

    public var gameSprite_:GameSprite;
    public var bgRect_:DialogBackground;
    public var selected_:Boolean = false;
    public var mailData_:AccountMailsData;

    public var text_:BaseSimpleText;
    private var closeButton_:DialogCloseButton;
    private var timeText_:BaseSimpleText;

    public var w_:int;
    public var h_:int;

    private static var INNER_WIDTH:int = WebMain.DefaultWidth / 2 - 12;

    public function MailItem(mailData:AccountMailsData, gameSprite:GameSprite, width:int, height:int = 0) {
        this.mailData_ = mailData;
        this.gameSprite_ = gameSprite;
        this.bgRect_ = new DialogBackground();
        addChild(this.bgRect_);
        this.w_ = width;
        this.h_ = height;
        this.text_ = new BaseSimpleText(16, 0xB3B3B3, false, 500);
        this.text_.multiline = true;
        this.text_.wordWrap = true;
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        addEventListener(MouseEvent.CLICK, this.onClick);
    }

    public function draw():void {
        var unix:Number = (this.mailData_.endTime_ * 1000);
        var later:Date = new Date(unix);
        var now:Date = new Date();
        var ms:Number = Math.floor((later.time - now.time));
        var minutes:Number = (ms / (3600000 / 60));
        var hours:Number = (ms / 3600000);
        var days:Number = (ms / (3600000 * 24));
        var value:Number;
        var abbrev:String;
        var color:uint;
        value = days > 1.0 ? days : hours > 1.0 ? hours : minutes;
        abbrev = days > 1.0 ? "d" : hours > 1.0 ? "h" : "m";
        color = hours > 12.0 ? 0xFFFFFF : hours > 2.0 ? 0xFF9900 : 0xFF0000;
        this.timeText_ = new BaseSimpleText(13, color);
        this.timeText_.setBold(true);
        this.timeText_.text = value.toFixed(1) + abbrev;
        this.timeText_.x = INNER_WIDTH - 30 - this.timeText_.width;
        this.timeText_.y = 6;
        this.timeText_.setAutoSize(TextFieldAutoSize.RIGHT);
        this.timeText_.updateMetrics();
        addChild(this.timeText_);
        this.text_.setIndent(16);
        var text:String = this.mailData_.content_;
        this.text_.text = text;
        if (this.text_.numLines > 1) {
            text = this.text_.getLineText(0);
            this.text_.text = "<p align='center'>" + text.slice(0, text.length - 4) + "..." + "</p>" + "<p align='center'><font size='14'><b>(Click to expand)</b></font></p>";
            this.text_.htmlText = this.text_.text;
            this.text_.updateMetrics();
        }
        else {
            this.text_.htmlText = "<p align='center'>" + this.text_.text + "</p>";
            this.text_.updateMetrics();
        }
        this.text_.filters = this.timeText_.filters = [new DropShadowFilter(0, 0, 0)];

        this.drawDialogRect(this.w_, this.h_ > 568 ? 568 : this.h_);
        this.text_.x = 50;
        this.text_.y = 12;
        addChild(this.text_);
    }

    private function drawDialogRect(w:int, h:int, lineColor:uint = 0x676767, fillColor:uint = 0x454545, alpha:Number = 0.5):void {
        this.bgRect_.graphics.clear();
        this.bgRect_.draw(w, h, 4, lineColor, fillColor);
        this.alpha = alpha;
    }

    public function onMouseOver(me:MouseEvent):void {
        this.drawBgOver();
    }

    public function onMouseOut(me:MouseEvent):void {
        this.drawBgOut();
    }

    public function onClick(me:MouseEvent):void {
        this.selected_ = !this.selected_;
        if (this.selected_) {
            this.drawBgOver();
            removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        }
        else {
            this.drawBgOut();
            addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        }
    }

    public function drawBgOver():void {
        this.drawDialogRect(this.w_, this.h_, 0x676767, 0x454545, 1);
    }

    public function drawBgOut():void {
        this.drawDialogRect(this.w_, this.h_, 0x676767, 0x454545, 0.5);
    }

    public function addListeners():void {
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        addEventListener(MouseEvent.CLICK, this.onClick);
    }

    public function removeListeners():void {
        removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        removeEventListener(MouseEvent.CLICK, this.onClick);
        this.bgRect_.graphics.clear();
        this.bgRect_.draw(this.w_, this.h_, 4, 0x676767, 0x454545);
        alpha = 0.5;
    }

    public function modify():void {
        removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        removeEventListener(MouseEvent.CLICK, this.onClick);
        this.bgRect_.graphics.clear();
        this.bgRect_.draw(this.w_, this.h_, 4, 0x676767, 0x454545);
        this.closeButton_ = new DialogCloseButton();
        this.closeButton_.x = this.bgRect_.x + this.bgRect_.width - this.closeButton_.width - 6;
        this.closeButton_.y = this.bgRect_.y + 4;
        this.closeButton_.addEventListener(MouseEvent.CLICK, this.onClose);
        addChild(this.closeButton_);
        alpha = 1;
    }

    public function dispose():void {
        this.gameSprite_ = null;
        this.bgRect_ = null;
        var i:int = (numChildren - 1);
        while (i >= 0) {
            removeChildAt(i);
            i--;
        }
        removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        removeEventListener(MouseEvent.CLICK, this.onClick);
    }

    public function onClose(event:MouseEvent):void {
        this.parent.removeChild(this);
    }

}
}