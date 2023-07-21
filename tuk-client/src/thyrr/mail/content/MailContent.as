package thyrr.mail.content {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.LegacyScrollbar;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.memMarket.utils.DialogUtils;
import kabam.rotmg.messaging.impl.incoming.mail.FetchMailResult;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import thyrr.mail.data.AccountMailsData;
import thyrr.mail.model.FullMailItem;
import thyrr.mail.model.MailItem;

import thyrr.mail.signals.FetchMailSignal;

public class MailContent extends Sprite {

    private static const X_OFFSET:int = WebMain.DefaultWidth / 2 - WebMain.DefaultWidth / 4 - 5;
    private static const Y_OFFSET:int = 94;

    public const fetchSignal_:FetchMailSignal = new FetchMailSignal();

    private var shape_:Shape;
    private var resultMask_:Sprite;
    private var resultBackground_:Sprite;
    private var resultItems_:Vector.<MailItem>;
    private var resultScroll_:LegacyScrollbar;
    private var noMailText_:TextFieldDisplayConcrete;

    private var content_:FullMailItem;
    private var gameSprite_:GameSprite;

    public function MailContent(gameSprite:GameSprite) {
        super();
        this.gameSprite_ = gameSprite;
        this.fetchSignal_.add(this.onFetch);
        this.shape_ = new Shape();
        this.shape_.graphics.beginFill(0);
        this.shape_.graphics.drawRect(X_OFFSET, Y_OFFSET, WebMain.DefaultWidth / 2 - 8, 570);
        this.shape_.graphics.endFill();
        this.resultMask_ = new Sprite();
        this.resultMask_.addChild(this.shape_);
        this.resultMask_.mask = this.shape_;
        addChild(this.resultMask_);
        this.resultBackground_ = new Sprite();
        this.resultMask_.addChild(this.resultBackground_);
        this.resultItems_ = new Vector.<MailItem>();
        this.fetchMail();
        addEventListener(MouseEvent.CLICK, this.onUpdate);
        addEventListener(Event.REMOVED_FROM_STAGE, this.dispose);
    }

    private function fetchMail():void {
        this.gameSprite_.gsc_.fetchMail();
    }

    private function onFetch(result:FetchMailResult):void {
        if (result.description_ == "No Mail") {
            this.clearPreviousResults();
            this.noMailText_ = new TextFieldDisplayConcrete().setColor(0xB3B3B3).setSize(14)
                    .setAutoSize(TextFieldAutoSize.CENTER).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
            this.noMailText_.setStringBuilder(new StaticStringBuilder("You do not have any unread mails"));
            this.noMailText_.x = WebMain.DefaultWidth / 2;
            this.noMailText_.y = (WebMain.DefaultWidth / 2 - WebMain.DefaultWidth / 5) - 10;
            this.noMailText_.filters = [new DropShadowFilter(0, 0, 0)];
            if (!contains(this.noMailText_))
                addChild(this.noMailText_);
            return;
        }

        if (result.description_ != "") {
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", result.description_);
        }

        var i:int;
        var mailsData:Vector.<AccountMailsData> = new Vector.<AccountMailsData>(result.results_.length);
        i = 0;
        while (i < result.results_.length) {
            mailsData[i] = result.results_[i];
            i++;
        }

        if (this.resultScroll_ != null) {
            this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            removeChild(this.resultScroll_);
            this.resultScroll_ = null;
        }

        var item:MailItem;
        this.clearPreviousResults();
        i = 0;
        while (i < mailsData.length) {
            if (mailsData[i].addTime_ != 0) {
                item = new MailItem(mailsData[i], this.gameSprite_, 600, 57);
                item.draw();
                this.resultItems_.push(item);
            }
            i++;
        }

        this.positionIcons();
        var o:MailItem;
        for each (o in this.resultItems_) {
            this.resultBackground_.addChild(o);
        }
        this.resultBackground_.x = X_OFFSET - 319;
        if (this.resultBackground_.numChildren > 8) {
            this.resultScroll_ = new LegacyScrollbar(16, 540, 0.3);
            this.resultScroll_.x = WebMain.DefaultWidth / 2 + this.shape_.width / 2 - 18;
            this.resultScroll_.y = Y_OFFSET + 30;
            this.resultScroll_.setIndicatorSize(570, this.resultBackground_.height);
            this.resultScroll_.addEventListener(Event.CHANGE, this.onResultScrollChanged);
            addChild(this.resultScroll_);
        }
    }

    private function clearPreviousResults():void {
        var i:MailItem;
        for each (i in this.resultItems_) {
            i.dispose();
            this.resultBackground_.removeChild(i);
            i = null;
        }
        this.resultItems_.length = 0;
    }

    private function positionIcons():void {
        var index:int;
        var i:MailItem;
        index = 0;
        for each (i in this.resultItems_) {
            i.x = X_OFFSET + 14;
            i.y = (65 * index) + Y_OFFSET + 1;
            index++;
        }
    }

    private function onResultScrollChanged(event:Event):void {
        this.resultBackground_.y = -this.resultScroll_.pos() * (this.resultBackground_.height - 570);
    }

    private function onUpdate(event:MouseEvent):void {
        var x:int = -1;
        var i:int = 0;
        var resultItem:MailItem;
        var isOneSelected:Boolean = false;
        while (i < this.resultItems_.length) {
            resultItem = this.resultItems_[i];
            if (resultItem.selected_)
                isOneSelected = true;
            i++;
        }
        if (this.resultItems_ != null && this.content_ == null) {
            i = 0;
            while (i < this.resultItems_.length) {
                resultItem = this.resultItems_[i];
                if (resultItem.selected_)
                    x = i;
                else {
                    if (isOneSelected) {
                        resultItem.removeListeners();
                        resultItem.drawBgOut();
                        resultItem.filters = ItemTileSprite.DIM_FILTER;
                    }
                    i++;
                    continue;
                }
                if (this.content_ == null && x == i) {
                    resultItem.removeListeners();
                    resultItem.drawBgOut();
                    resultItem.filters = [];
                    resultItem.selected_ = true;
                    this.content_ = new FullMailItem(resultItem.mailData_, resultItem.gameSprite_, resultItem.w_, 57);
                    this.content_.draw();
                    this.content_.x = resultItem.x - 4;
                    this.content_.y = Y_OFFSET + 1;
                    this.content_.modify();
                    addChild(this.content_);
                }
                i++;
            }
        }
        else if (this.content_ != null && !contains(this.content_) && this.resultItems_ != null) {
            this.content_.dispose();
            this.content_ = null;
            i = 0;
            while (i < this.resultItems_.length) {
                resultItem = this.resultItems_[i];
                resultItem.selected_ = false;
                resultItem.addListeners();
                resultItem.drawBgOut();
                resultItem.filters = [];
                i++;
            }
        }
    }

    public function dispose(event:Event):void {
        this.fetchSignal_.remove(this.onFetch);
        this.shape_.parent.removeChild(this.shape_);
        this.shape_ = null;
        this.resultItems_ = null;
        this.resultMask_.removeChild(this.resultBackground_);
        this.resultMask_ = null;
        this.resultBackground_ = null;
        if (this.resultScroll_ != null) {
            this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            this.resultScroll_ = null;
        }
        this.noMailText_ = null;
        if (this.content_ != null)
            this.content_.dispose();
        this.content_ = null;
    }

}
}