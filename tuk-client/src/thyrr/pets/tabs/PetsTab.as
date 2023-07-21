package thyrr.pets.tabs {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.LegacyScrollbar;
import com.company.assembleegameclient.ui.dialogs.Dialog;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.messaging.impl.incoming.pets.FetchPetsResult;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import thyrr.pets.PetViewer;

import thyrr.pets.model.PetContent;

import thyrr.pets.model.PetIcon;
import thyrr.pets.signals.FetchPetsSignal;

import thyrr.quests.tabs.AcceptedQuestsTab;
import thyrr.oldui.DefaultTab;

public class PetsTab extends DefaultTab {

    private static const X_OFFSET:int = AcceptedQuestsTab.X_OFFSET;
    private static const Y_OFFSET:int = AcceptedQuestsTab.Y_OFFSET;

    public const fetchPetsSignal_:FetchPetsSignal = new FetchPetsSignal();

    private var shape_:Shape;
    private var resultMask_:Sprite;
    private var resultBackground_:Sprite;
    private var resultItems_:Vector.<PetIcon>;
    private var resultScroll_:LegacyScrollbar;
    private var isOneSelected_:Boolean;
    private var noPetsText_:TextFieldDisplayConcrete;

    private var content_:PetContent;
    private var actionEnabled_:Boolean = true;
    private var confirmDialog_:Dialog;

    public function PetsTab(gameSprite:GameSprite) {
        super(gameSprite);
        this.fetchPetsSignal_.add(this.onFetch);
        this.shape_ = new Shape();
        this.shape_.graphics.beginFill(0);
        this.shape_.graphics.drawRect(X_OFFSET + 14, Y_OFFSET + 16, 292, 500);
        this.shape_.graphics.endFill();
        this.resultMask_ = new Sprite();
        this.resultMask_.addChild(this.shape_);
        this.resultMask_.mask = this.shape_;
        addChild(this.resultMask_);
        this.resultBackground_ = new Sprite();
        this.resultMask_.addChild(this.resultBackground_);
        this.resultItems_ = new Vector.<PetIcon>();
        this.gameSprite_.gsc_.fetchPets();
        addEventListener(MouseEvent.CLICK, onClick);
    }

    private function onFetch(result:FetchPetsResult):void {
        if (result.description_ == "No pets found") {
            this.clearPreviousResults();
            this.noPetsText_ = new TextFieldDisplayConcrete().setColor(0xB3B3B3).setSize(14);
            this.noPetsText_.setAutoSize(TextFieldAutoSize.CENTER);
            this.noPetsText_.setStringBuilder(new StaticStringBuilder("You currently do not have any pets"));
            this.noPetsText_.x = WebMain.DefaultWidth / 2;
            this.noPetsText_.y = (WebMain.DefaultWidth / 2 - WebMain.DefaultWidth / 5) - 10;
            this.noPetsText_.filters = [new DropShadowFilter(0, 0, 0)];
            if (!contains(this.noPetsText_)) {
                addChild(this.noPetsText_);
            }
            return;
        }

        var i:int;
        if (this.resultScroll_ != null) {
            this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            removeChild(this.resultScroll_);
            this.resultScroll_ = null;
        }

        var item:PetIcon;
        this.clearPreviousResults();
        i = 0;
        while (i < result.petDatas_.length) {
            item = new PetIcon(this.gameSprite_, result.petDatas_[i]);
            this.resultItems_.push(item);
            i++;
        }

        this.positionIcons();
        var o:PetIcon;
        for each (o in this.resultItems_) {
            this.resultBackground_.addChild(o);
        }
        this.resultBackground_.x = X_OFFSET - 319;
        if (this.resultBackground_.numChildren > 60) {
            this.resultScroll_ = new LegacyScrollbar(16, 500, 0.3);
            this.resultScroll_.x = X_OFFSET + 322;
            this.resultScroll_.y = Y_OFFSET + 16;
            this.resultScroll_.setIndicatorSize(500, this.resultBackground_.height);
            this.resultScroll_.addEventListener(Event.CHANGE, this.onResultScrollChanged);
            addChild(this.resultScroll_);
        }
    }

    private function clearPreviousResults():void {
        var i:PetIcon;
        for each (i in this.resultItems_) {
            i.dispose();
            this.resultBackground_.removeChild(i);
            i = null;
        }
        this.resultItems_.length = 0;
    }

    private function positionIcons():void {
        var index:int;
        var i:PetIcon;
        index = 0;
        // 42x42 square size
        for each (i in this.resultItems_) {
            i.x = (50 * int(index % 6)) + X_OFFSET + 14;
            i.y = (50 * int(index / 6)) + Y_OFFSET + 17;
            index++;
        }
    }

    private function onClick(event:MouseEvent):void {
        var x:int = -1;
        var i:int;
        if (this.resultItems_ != null) {
            this.isOneSelected_ = false;
            var resultItem:PetIcon;
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
                    if (i == x) {
                        if (this.content_ != null && !contains(this.content_)) {
                            this.content_.dispose();
                            this.content_ = null;
                            break;
                        }
                        if (this.content_ == null) {
                            this.content_ = new PetContent(resultItem.gameSprite_, resultItem.petData_);
                            this.content_.finalized_.addOnce(this.addButtonsListeners);
                            this.content_.x = X_OFFSET + 354;
                            this.content_.y = Y_OFFSET + 16;
                            addChild(this.content_);
                        }
                        i++;
                        continue;
                    }
                    resultItem.removeListeners();
                    resultItem.filters = ItemTileSprite.DIM_FILTER;
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
                    this.content_.followButton_.removeEventListener(MouseEvent.CLICK, this.onFollow);
                    this.content_.releaseButton_.removeEventListener(MouseEvent.CLICK, this.onRelease);
                    this.content_.dispose();
                    if (contains(this.content_)) {
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

    private function addButtonsListeners():void {
        this.content_.followButton_.addEventListener(MouseEvent.CLICK, this.onFollow);
        this.content_.releaseButton_.addEventListener(MouseEvent.CLICK, this.onRelease);
    }

    private function onFollow(event:MouseEvent):void {
        if (this.actionEnabled_) {
            this.gameSprite_.gsc_.petFollow(this.content_.petData_);
            (parent as PetViewer).close();
        }
    }

    private function onRelease(event:MouseEvent):void {
        if (this.actionEnabled_) {
            this.confirmDialog_ = new Dialog("Release Pet",
                    "Are you sure you want to release your pet to the wild? This action cannot be undone.", "Cancel", "OK");
            addChild(this.confirmDialog_);
            this.confirmDialog_.addEventListener(Dialog.LEFT_BUTTON, onCancel);
            this.confirmDialog_.addEventListener(Dialog.RIGHT_BUTTON, onConfirm);
            this.actionEnabled_ = false;
        }
    }

    private function onConfirm(event:Event):void {
        this.gameSprite_.gsc_.deletePet(this.content_.petData_);
        (parent as PetViewer).close();
    }

    private function onCancel(event:Event):void {
        removeChild(this.confirmDialog_);
        this.actionEnabled_ = true;
        this.confirmDialog_ = null;
    }

    private function onResultScrollChanged(event:Event):void {
        this.resultBackground_.y = -this.resultScroll_.pos() * (this.resultBackground_.height - 500);
    }

    override public function dispose():void {
        this.fetchPetsSignal_.remove(this.onFetch);
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
        this.noPetsText_ = null;
        if (this.content_ != null)
            this.content_.dispose();
        this.content_ = null;
        super.dispose();
    }

}
}