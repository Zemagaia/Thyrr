package thyrr.mail.model {
import com.company.assembleegameclient.ui.LegacyScrollbar;
import com.company.ui.BaseSimpleText;

import flash.display.Shape;

import flash.display.Sprite;

import com.company.assembleegameclient.game.GameSprite;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import thyrr.mail.data.AccountMailsData;

public class FullMailItem extends MailItem {

    private var shape_:Shape;
    private var mask_:Sprite;
    public var background_:Sprite;
    private var scrollbar_:LegacyScrollbar;

    private var timeText_:BaseSimpleText;

    protected static var INNER_WIDTH:int = WebMain.DefaultWidth / 2 - 10;
    protected static var INNER_HEIGHT:int = 564;

    public function FullMailItem(mailData:AccountMailsData, gameSprite:GameSprite, width:int, height:int = 0) {
        super(mailData, gameSprite, width, height);
        this.shape_ = new Shape();
        this.shape_.graphics.beginFill(0);
        this.shape_.graphics.drawRect(0, 0, INNER_WIDTH, INNER_HEIGHT);
        this.shape_.graphics.endFill();
        this.mask_ = new Sprite();
        this.mask_.addChild(this.shape_);
        this.mask_.mask = this.shape_;
        addChild(this.mask_);
        this.background_ = new Sprite();
        this.mask_.addChild(this.background_);
        this.mask_.y += 2;
    }

    public override function draw():void {
        if (this.scrollbar_ != null) {
            this.scrollbar_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            removeChild(this.scrollbar_);
            this.scrollbar_ = null;
        }

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
        this.timeText_.x = INNER_WIDTH - 60 - this.timeText_.width;
        this.timeText_.y = 6;
        this.timeText_.setAutoSize(TextFieldAutoSize.RIGHT);
        this.timeText_.updateMetrics();
        this.background_.addChild(this.timeText_);
        this.text_.setIndent(16);
        var text:String = this.mailData_.content_;
        this.text_.text = text;
        this.text_.htmlText = this.text_.text;
        this.text_.updateMetrics();
        this.text_.filters = this.timeText_.filters = [new DropShadowFilter(0, 0, 0)];

        this.h_ = Math.min(568, 16 + 16 * this.text_.numLines);
        this.drawDialogRect(this.w_, this.h_);
        this.text_.x = 50;
        this.text_.y = 4;
        this.background_.addChild(this.text_);

        if (22 + 16 * this.text_.numLines > 568) {
            this.scrollbar_ = new LegacyScrollbar(16, 530, 0.3);
            this.scrollbar_.x = INNER_WIDTH - 52;
            this.scrollbar_.y = 32;
            this.scrollbar_.setIndicatorSize(568, 22 + 16 * this.text_.numLines);
            this.scrollbar_.addEventListener(Event.CHANGE, this.onResultScrollChanged);
            addChild(this.scrollbar_);
        }
    }

    private function onResultScrollChanged(event:Event):void {
        this.background_.y = -this.scrollbar_.pos() * ((22 + 16 * this.text_.numLines) - 568);
    }

    private function drawDialogRect(w:int, h:int, lineColor:uint = 0x676767, fillColor:uint = 0x454545, alpha:Number = 0.5):void {
        this.bgRect_.graphics.clear();
        this.bgRect_.draw(w, h, 4, lineColor, fillColor);
        this.alpha = alpha;
    }

    public override function dispose():void {
        this.shape_.parent.removeChild(this.shape_);
        this.shape_ = null;
        this.mask_.removeChild(this.background_);
        this.mask_ = null;
        this.background_.graphics.clear();
        this.background_ = null;
        this.gameSprite_ = null;
        this.bgRect_ = null;
        var i:int = (numChildren - 1);
        while (i >= 0) {
            removeChildAt(i);
            i--;
        }
        if (this.scrollbar_ != null) {
            this.scrollbar_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            this.scrollbar_ = null;
        }
        removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        removeEventListener(MouseEvent.CLICK, this.onClick);
    }

}
}