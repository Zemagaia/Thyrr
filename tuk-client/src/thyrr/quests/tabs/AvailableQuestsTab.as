package thyrr.quests.tabs {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;
import com.company.assembleegameclient.ui.LegacyScrollbar;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.memMarket.utils.DialogUtils;
import kabam.rotmg.messaging.impl.incoming.quests.FetchAvailableQuestsResult;
import kabam.rotmg.messaging.impl.outgoing.quests.AcceptQuest;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import thyrr.quests.data.QuestData;
import thyrr.quests.model.QuestContent;
import thyrr.quests.model.QuestIconBuilder;
import thyrr.quests.signals.FetchAvailableQuestsSignal;
import thyrr.oldui.DefaultTab;

public class AvailableQuestsTab extends DefaultTab {

    private static const X_OFFSET:int = AcceptedQuestsTab.X_OFFSET;
    private static const Y_OFFSET:int = AcceptedQuestsTab.Y_OFFSET;

    public const fetchSignal_:FetchAvailableQuestsSignal = new FetchAvailableQuestsSignal();

    private var shape_:Shape;
    private var resultMask_:Sprite;
    private var resultBackground_:Sprite;
    private var resultItems_:Vector.<QuestIconBuilder>;
    private var resultScroll_:LegacyScrollbar;
    private var isOneSelected_:Boolean;
    private var noQuestsText_:TextFieldDisplayConcrete;

    private var content_:QuestContent;

    public function AvailableQuestsTab(gameSprite:GameSprite) {
        super(gameSprite);
        this.fetchSignal_.add(this.onFetch);
        this.shape_ = new Shape();
        this.shape_.graphics.beginFill(0);
        this.shape_.graphics.drawRect(X_OFFSET + 14, Y_OFFSET, 54, 534);
        this.shape_.graphics.endFill();
        this.resultMask_ = new Sprite();
        this.resultMask_.addChild(this.shape_);
        this.resultMask_.mask = this.shape_;
        addChild(this.resultMask_);
        this.resultBackground_ = new Sprite();
        this.resultMask_.addChild(this.resultBackground_);
        this.resultItems_ = new Vector.<QuestIconBuilder>();
        this.fetchQuests();
        addEventListener(MouseEvent.CLICK, this.onUpdate);
    }

    private function fetchQuests():void {
        this.gameSprite_.gsc_.fetchAvailableQuests();
    }

    private function onFetch(result:FetchAvailableQuestsResult):void {
        if (result.description_ == "You do not have any available quests, Quest Added" || result.description_ == "You do not have any available quests") {
            this.clearPreviousResults();
            this.noQuestsText_ = new TextFieldDisplayConcrete().setColor(0xB3B3B3).setSize(14);
            this.noQuestsText_.setAutoSize(TextFieldAutoSize.CENTER);
            this.noQuestsText_.setStringBuilder(new StaticStringBuilder("You do not have any available quests"));
            this.noQuestsText_.x = Main.DefaultWidth / 2;
            this.noQuestsText_.y = (Main.DefaultWidth / 2 - Main.DefaultWidth / 5) - 10;
            this.noQuestsText_.filters = [new DropShadowFilter(0, 0, 0)];
            if (!contains(this.noQuestsText_))
                addChild(this.noQuestsText_);
            return;
        }

        if (result.description_ != "" && result.description_ != "Quest added") {
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", result.description_);
        }

        var i:int = 0;
        var questDatas:Vector.<QuestData> = new Vector.<QuestData>(result.results_.length);
        while (i < result.results_.length) {
            questDatas[i] = result.results_[i];
            i++;
        }

        if (this.resultScroll_ != null) {
            this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            removeChild(this.resultScroll_);
            this.resultScroll_ = null;
        }

        var item:QuestIconBuilder;
        this.clearPreviousResults();
        i = 0;
        while (i < questDatas.length) {
            item = new QuestIconBuilder(questDatas[i], null, 52, 52);
            this.resultItems_.push(item);
            i++;
        }

        this.positionIcons();
        var o:QuestIconBuilder;
        for each (o in this.resultItems_) {
            this.resultBackground_.addChild(o);
        }
        this.resultBackground_.x = X_OFFSET - 319;
        if (this.resultBackground_.numChildren > 9) {
            this.resultScroll_ = new LegacyScrollbar(16, 534, 0.3);
            this.resultScroll_.x = X_OFFSET + 81;
            this.resultScroll_.y = Y_OFFSET;
            this.resultScroll_.setIndicatorSize(534, this.resultBackground_.height);
            this.resultScroll_.addEventListener(Event.CHANGE, this.onResultScrollChanged);
            addChild(this.resultScroll_);
        }
    }

    private function clearPreviousResults():void {
        var i:QuestIconBuilder;
        for each (i in this.resultItems_) {
            i.dispose();
            this.resultBackground_.removeChild(i);
            i = null;
        }
        this.resultItems_.length = 0;
    }

    private function positionIcons():void {
        var index:int;
        var i:QuestIconBuilder;
        index = 0;
        for each (i in this.resultItems_) {
            i.x = X_OFFSET + 14;
            i.y = (60 * index) + Y_OFFSET + 1;
            index++;
        }
    }

    private function onResultScrollChanged(event:Event):void {
        this.resultBackground_.y = -this.resultScroll_.pos() * (this.resultBackground_.height - 534);
    }

    private function onUpdate(event:MouseEvent):void {
        var x:int = -1;
        var i:int;
        if (this.resultItems_ != null) {
            this.isOneSelected_ = false;
            var resultItem:QuestIconBuilder;
            i = 0;
            while (i < this.resultItems_.length) {
                if (this.resultItems_[i].selected_) {
                    this.isOneSelected_ = true;
                    x = i;
                    break;
                }
                i++;
            }
            if (this.isOneSelected_) {
                i = 0;
                while (i < this.resultItems_.length) {
                    resultItem = this.resultItems_[i];
                    if (i != x) {
                        resultItem.removeListeners();
                        resultItem.filters = ItemTileSprite.DIM_FILTER;
                        i++;
                        continue;
                    }
                    if (this.content_ != null && !contains(this.content_)) {
                        this.content_.dispose();
                        this.content_ = null;
                        break;
                    }
                    if (this.content_ == null) {
                        this.content_ = new QuestContent(resultItem.availableQuestData_, null);
                        this.content_.acceptButton_.addEventListener(MouseEvent.CLICK, this.onAccept);
                        this.content_.dismissButton_.addEventListener(MouseEvent.CLICK, this.onDismiss);
                        this.content_.x = 430;
                        if (this.resultScroll_ == null) {
                            this.content_.x -= 20;
                        }
                        this.content_.y = Y_OFFSET;
                        addChild(this.content_);
                    }
                    i++;
                }
                return;
            }
            i = 0;
            while (i < this.resultItems_.length) {
                if (i == x)
                {
                    i++;
                    continue;
                }
                resultItem = this.resultItems_[i];
                if (this.content_ != null) {
                    this.content_.acceptButton_.removeEventListener(MouseEvent.CLICK, this.onAccept);
                    this.content_.dismissButton_.removeEventListener(MouseEvent.CLICK, this.onDismiss);
                    this.content_.dispose();
                    if (contains(this.content_))
                        this.removeChild(this.content_);
                    this.content_ = null;
                }
                resultItem.addListeners();
                resultItem.filters = [];
                i++;
            }
        }
    }

    private function onAccept(event:MouseEvent):void {
        removeChild(this.content_);
        this.gameSprite_.gsc_.acceptQuest(this.content_.questId_, AcceptQuest.Accept);
    }

    private function onDismiss(event:MouseEvent):void {
        if (this.content_.dismissButton_.text_.getText() == "Confirm") {
            removeChild(this.content_);
            this.gameSprite_.gsc_.acceptQuest(this.content_.questId_, AcceptQuest.Dismiss);
        }
        this.content_.dismissButton_.removeEventListener(MouseEvent.CLICK, this.onDismiss);
        this.content_.background_.removeChild(this.content_.dismissButton_);
        this.content_.dismissButton_ = new DeprecatedTextButton(18, "Confirm");
        this.content_.dismissButton_.x = 80;
        this.content_.dismissButton_.y = this.content_.background_.height - 38;
        this.content_.background_.addChild(this.content_.dismissButton_);
        this.content_.dismissButton_.addEventListener(MouseEvent.CLICK, this.onDismiss);
    }

    override public function dispose():void {
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
        this.noQuestsText_ = null;
        if (this.content_ != null)
            this.content_.dispose();
        this.content_ = null;
        super.dispose();
    }

}
}