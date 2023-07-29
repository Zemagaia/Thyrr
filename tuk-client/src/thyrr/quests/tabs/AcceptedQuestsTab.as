package thyrr.quests.tabs {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;
import com.company.assembleegameclient.ui.LegacyScrollbar;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.memMarket.utils.DialogUtils;
import kabam.rotmg.messaging.impl.incoming.quests.DeliverItemsResult;
import kabam.rotmg.messaging.impl.incoming.quests.FetchAccountQuestsResult;
import kabam.rotmg.messaging.impl.incoming.quests.FetchCharacterQuestsResult;
import kabam.rotmg.messaging.impl.outgoing.quests.AcceptQuest;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import thyrr.quests.data.AcceptedQuestData;

import thyrr.quests.model.QuestContent;
import thyrr.quests.model.QuestIconBuilder;
import thyrr.quests.signals.DeliverItemsSignal;
import thyrr.quests.signals.FetchAccountQuestsSignal;
import thyrr.quests.signals.FetchCharacterQuestsSignal;
import thyrr.oldui.DefaultTab;

public class AcceptedQuestsTab extends DefaultTab {

    public static const X_OFFSET:int = Main.DefaultWidth / 2 - Main.DefaultWidth / 4;
    public static const Y_OFFSET:int = 114;

    public const fetchSignal_:FetchCharacterQuestsSignal = new FetchCharacterQuestsSignal();
    public const fetchAccSignal_:FetchAccountQuestsSignal = new FetchAccountQuestsSignal();
    public const deliverSignal_:DeliverItemsSignal = new DeliverItemsSignal();

    private var shape_:Shape;
    private var resultMask_:Sprite;
    private var resultBackground_:Sprite;
    private var resultItems_:Vector.<QuestIconBuilder>;
    private var resultScroll_:LegacyScrollbar;
    private var isOneSelected_:Boolean;
    private var noQuestsText_:TextFieldDisplayConcrete;

    private var content_:QuestContent;

    public function AcceptedQuestsTab(gameSprite:GameSprite, fetchChar:Boolean = true) {
        super(gameSprite);
        this.deliverSignal_.add(this.onDeliverItems);
        this.fetchSignal_.add(this.onFetch);
        this.fetchAccSignal_.add(this.onFetchAcc);
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
        if (fetchChar)
            this.fetchQuests();
        else
            this.fetchAccQuests();
        addEventListener(MouseEvent.CLICK, this.onUpdate);
    }

    private function fetchQuests():void {
        this.gameSprite_.gsc_.fetchCharacterQuests();
    }

    private function fetchAccQuests():void {
        this.gameSprite_.gsc_.fetchAccountQuests();
    }

    private function onFetch(result:FetchCharacterQuestsResult):void {
        if (result.description_ == "You do not have any character quests") {
            this.clearPreviousResults();
            this.noQuestsText_ = new TextFieldDisplayConcrete().setColor(0xB3B3B3).setSize(14);
            this.noQuestsText_.setAutoSize(TextFieldAutoSize.CENTER);
            this.noQuestsText_.setStringBuilder(new StaticStringBuilder(result.description_));
            this.noQuestsText_.x = Main.DefaultWidth / 2;
            this.noQuestsText_.y = (Main.DefaultWidth / 2 - Main.DefaultWidth / 5) - 10;
            this.noQuestsText_.filters = [new DropShadowFilter(0, 0, 0)];
            if (!contains(this.noQuestsText_))
                addChild(this.noQuestsText_);
            return;
        }

        if (result.description_ != "") {
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", result.description_);
        }

        var i:int = 0;
        var questDatas:Vector.<AcceptedQuestData> = new Vector.<AcceptedQuestData>(result.results_.length);
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
            item = new QuestIconBuilder(null, questDatas[i], 52, 52);
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

    private var isAcc_:Boolean = false;
    private function onFetchAcc(result:FetchAccountQuestsResult):void {
        if (result.description_ == "You do not have any account quests") {
            this.clearPreviousResults();
            this.noQuestsText_ = new TextFieldDisplayConcrete().setColor(0xB3B3B3).setSize(14);
            this.noQuestsText_.setAutoSize(TextFieldAutoSize.CENTER);
            this.noQuestsText_.setStringBuilder(new StaticStringBuilder("You do not have any account quests"));
            this.noQuestsText_.x = Main.DefaultWidth / 2;
            this.noQuestsText_.y = (Main.DefaultWidth / 2 - Main.DefaultWidth / 5) - 10;
            this.noQuestsText_.filters = [new DropShadowFilter(0, 0, 0)];
            if (!contains(this.noQuestsText_))
                addChild(this.noQuestsText_);
            return;
        }

        this.isAcc_ = true;

        if (result.description_ != "") {
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", result.description_);
        }

        var i:int = 0;
        var questDatas:Vector.<AcceptedQuestData> = new Vector.<AcceptedQuestData>(result.results_.length);
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
            item = new QuestIconBuilder(null, questDatas[i], 52, 52);
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
            if (this.isOneSelected_)
            {
                i = 0;
                while (i < this.resultItems_.length)
                {
                    resultItem = this.resultItems_[i];
                    if (i == x)
                    {
                        if (this.content_ != null && !contains(this.content_))
                        {
                            this.content_.dispose();
                            this.content_ = null;
                            break;
                        }
                        if (this.content_ == null)
                        {
                            this.content_ = new QuestContent(null, resultItem.questData_);
                            if (!this.isAcc_)
                            {
                                this.content_.acceptButton_.addEventListener(MouseEvent.CLICK, this.onDeliver);
                                this.content_.dismissButton_.addEventListener(MouseEvent.CLICK, this.onDelete);
                                this.content_.warpButton_.addEventListener(MouseEvent.CLICK, this.onScout);
                            }
                            else
                            {
                                this.content_.acceptButton_.addEventListener(MouseEvent.CLICK, this.onDeliverAcc);
                                this.content_.dismissButton_.addEventListener(MouseEvent.CLICK, this.onDeleteAcc);
                                this.content_.warpButton_.addEventListener(MouseEvent.CLICK, this.onScoutAcc);
                            }
                            this.content_.x = 410;
                            this.content_.y = Y_OFFSET;
                            addChild(this.content_);
                        }
                        i++;
                        continue;
                    }
                    resultItem.removeListeners();
                    resultItem.filters = ItemTileSprite.DIM_FILTER;
                    i++;
                }
            }
            else
            {
                i = 0;
                while (i < this.resultItems_.length)
                {
                    if (i == x)
                    {
                        i++;
                        continue;
                    }
                    resultItem = this.resultItems_[i];
                    if (this.content_ != null)
                    {
                        if (!this.isAcc_)
                        {
                            this.content_.acceptButton_.removeEventListener(MouseEvent.CLICK, this.onDeliver);
                            this.content_.dismissButton_.removeEventListener(MouseEvent.CLICK, this.onDelete);
                            this.content_.warpButton_.removeEventListener(MouseEvent.CLICK, this.onScout);
                        }
                        else
                        {
                            this.content_.acceptButton_.addEventListener(MouseEvent.CLICK, this.onDeliverAcc);
                            this.content_.dismissButton_.addEventListener(MouseEvent.CLICK, this.onDeleteAcc);
                            this.content_.warpButton_.addEventListener(MouseEvent.CLICK, this.onScoutAcc);
                        }
                        this.content_.dispose();
                        if (contains(this.content_))
                        {
                            this.removeChild(this.content_);
                        }
                        this.content_ = null;
                    }
                    resultItem.addListeners();
                    resultItem.filters = [];
                    i++;
                }
            }
        }
    }

    private function onDeliver(event:MouseEvent):void {
        this.gameSprite_.gsc_.acceptQuest(this.content_.questId_, AcceptQuest.Deliver);
    }

    private function onDeliverAcc(event:MouseEvent):void {
        this.gameSprite_.gsc_.acceptQuest(this.content_.questId_, AcceptQuest.Deliver_Account);
    }

    public function onDeliverItems(result:DeliverItemsResult):void {
        var i:int = 0;
        while (i < this.content_.deliver_.length) {
            if (result.delivered_[i]) {
                this.content_.deliver_[i].setColor(0x00CC00);
            }
            i++;
        }
        this.updateButtonsPosition(result.delivered_);
    }

    private function onScout(event:MouseEvent):void {
        this.gameSprite_.gsc_.acceptQuest(this.content_.questId_, AcceptQuest.Scout);
    }

    private function onScoutAcc(event:MouseEvent):void {
        this.gameSprite_.gsc_.acceptQuest(this.content_.questId_, AcceptQuest.Scout_Account);
    }

    private function updateButtonsPosition(Is:Vector.<Boolean>):void {
        var complete:Boolean = false;
        var i:int = 0;
        while (i < Is.length)
        {
            if (i == 0)
            {
                complete = false;
                break;
            }
            i++;
        }

        if (this.content_.background_.contains(this.content_.acceptButton_) && complete)
            this.content_.background_.removeChild(this.content_.acceptButton_);

        this.content_.dismissButton_.textChanged.addOnce(this.positionDismissButton);
    }

    private function positionDismissButton():void {
        if (this.content_.background_.contains(this.content_.acceptButton_)) {
            this.content_.dismissButton_.x = 80;
        }
        else {
            this.content_.dismissButton_.x = QuestContent.INNER_WIDTH / 2 - this.content_.dismissButton_.width;
        }
        this.content_.dismissButton_.y = this.content_.background_.height - this.content_.dismissButton_.height - 16;
    }

    private function onDelete(event:MouseEvent):void {
        if (this.content_.dismissButton_.text_.getText() == "Confirm") {
            removeChild(this.content_);
            this.gameSprite_.gsc_.acceptQuest(this.content_.questId_, AcceptQuest.Delete);
        }
        this.content_.dismissButton_.removeEventListener(MouseEvent.CLICK, this.onDelete);
        this.content_.background_.removeChild(this.content_.dismissButton_);
        this.content_.dismissButton_.setText("Confirm");
        this.content_.background_.addChild(this.content_.dismissButton_);
        this.content_.dismissButton_.addEventListener(MouseEvent.CLICK, this.onDelete);
        this.content_.dismissButton_.textChanged.addOnce(this.positionDismissButton);
    }

    private function onDeleteAcc(event:MouseEvent):void {
        if (this.content_.dismissButton_.text_.getText() == "Confirm") {
            removeChild(this.content_);
            this.gameSprite_.gsc_.acceptQuest(this.content_.questId_, AcceptQuest.Delete_Account);
        }
        this.content_.dismissButton_.removeEventListener(MouseEvent.CLICK, this.onDeleteAcc);
        this.content_.background_.removeChild(this.content_.dismissButton_);
        this.content_.dismissButton_.setText("Confirm");
        this.content_.background_.addChild(this.content_.dismissButton_);
        this.content_.dismissButton_.addEventListener(MouseEvent.CLICK, this.onDeleteAcc);
        this.content_.dismissButton_.textChanged.addOnce(this.positionDismissButton);
    }

    override public function dispose():void {
        this.fetchSignal_.remove(this.onFetch);
        this.fetchAccSignal_.remove(this.onFetchAcc);
        this.deliverSignal_.remove(this.onDeliverItems);
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