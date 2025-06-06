﻿
//kabam.rotmg.memMarket.tabs.MemMarketBuyTab

package kabam.rotmg.memMarket.tabs
{
import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.memMarket.signals.MemMarketBuySignal;
    import kabam.rotmg.memMarket.signals.MemMarketSearchSignal;
    import com.company.assembleegameclient.account.ui.MarketInput;
    import flash.display.Shape;
    import flash.display.Sprite;
    import kabam.rotmg.memMarket.content.MemMarketItem;
    import com.company.assembleegameclient.ui.LegacyScrollbar;
    import kabam.rotmg.memMarket.content.MemMarketBuyItem;
    import com.company.assembleegameclient.ui.dropdown.DropDown;
    import flash.events.KeyboardEvent;
    import kabam.rotmg.memMarket.utils.SortUtils;
    import flash.events.Event;
    import com.company.assembleegameclient.game.GameSprite;
    import com.company.util.KeyCodes;
    import flash.events.MouseEvent;
    import mx.utils.StringUtil;
    import com.company.assembleegameclient.objects.ObjectLibrary;
    import kabam.rotmg.memMarket.utils.ItemUtils;
    import kabam.rotmg.memMarket.utils.DialogUtils;
    import kabam.rotmg.messaging.impl.incoming.market.MarketBuyResult;
    import kabam.rotmg.messaging.impl.data.MarketData;
    import kabam.rotmg.messaging.impl.incoming.market.MarketSearchResult;

import thyrr.utils.ItemData;

public class MemMarketBuyTab extends MemMarketTab
    {

        private static const SEARCH_X_OFFSET:int = 4;
        private static const SEARCH_Y_OFFSET:int = 170;
        private static const SEARCH_ITEM_SIZE:int = 50;
        private static const RESULT_X_OFFSET:int = 270;
        private static const RESULT_Y_OFFSET:int = 105;

        public const buySignal_:MemMarketBuySignal = new MemMarketBuySignal();
        public const searchSignal_:MemMarketSearchSignal = new MemMarketSearchSignal();

        private var searchField_:MarketInput;
        private var shape_:Shape;
        private var searchMask_:Sprite;
        private var searchBackground:Sprite;
        private var searchItems:Vector.<MemMarketItem>;
        private var searchScroll:LegacyScrollbar;
        private var resultMask_:Sprite;
        private var resultBackground_:Sprite;
        private var resultItems_:Vector.<MemMarketBuyItem>;
        private var resultScroll_:LegacyScrollbar;
        private var sortChoices_:DropDown;

        public function MemMarketBuyTab(gameSprite:GameSprite)
        {
            super(gameSprite);
            this.buySignal_.add(this.onBuy);
            this.searchSignal_.add(this.onSearch);
            this.searchField_ = new MarketInput("Search", false, "");
            this.searchField_.x = (SEARCH_X_OFFSET + 9);
            this.searchField_.y = 101;
            this.searchField_.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
            addChild(this.searchField_);
            this.shape_ = new Shape();
            this.shape_.graphics.beginFill(0);
            this.shape_.graphics.drawRect(SEARCH_X_OFFSET, SEARCH_Y_OFFSET, 250, 350);
            this.shape_.graphics.endFill();
            this.searchMask_ = new Sprite();
            this.searchMask_.addChild(this.shape_);
            this.searchMask_.mask = this.shape_;
            addChild(this.searchMask_);
            this.searchBackground = new Sprite();
            this.searchMask_.addChild(this.searchBackground);
            this.searchItems = new Vector.<MemMarketItem>();
            this.shape_ = new Shape();
            this.shape_.graphics.beginFill(0);
            this.shape_.graphics.drawRect(RESULT_X_OFFSET, RESULT_Y_OFFSET, 1000, 415);
            this.shape_.graphics.endFill();
            this.resultMask_ = new Sprite();
            this.resultMask_.addChild(this.shape_);
            this.resultMask_.mask = this.shape_;
            addChild(this.resultMask_);
            this.resultBackground_ = new Sprite();
            this.resultMask_.addChild(this.resultBackground_);
            this.resultItems_ = new Vector.<MemMarketBuyItem>();
            this.sortChoices_ = new DropDown(SortUtils.SORT_CHOICES, 200, 26);
            this.sortChoices_.x = 597;
            this.sortChoices_.y = 71;
            this.sortChoices_.setValue(SortUtils.LOWEST_TO_HIGHEST);
            this.sortChoices_.addEventListener(Event.CHANGE, this.onSortChoicesChanged);
            addChild(this.sortChoices_);
            this.searchItemsFunc(true);
        }

        private function onSortChoicesChanged(event:Event):void
        {
            this.sortOffers();
        }

        private function onKeyUp(event:KeyboardEvent):void
        {
            if (event.keyCode == KeyCodes.ENTER)
            {
                this.searchItemsFunc();
            }
        }

        private function onSearchClick(event:MouseEvent):void
        {
            var item:MemMarketItem = (event.currentTarget as MemMarketItem);
            this.gameSprite_.gsc_.marketSearch(item.itemType_);
        }

        private function onSearchScrollChanged(event:Event):void
        {
            this.searchBackground.y = (-(this.searchScroll.pos()) * (this.searchBackground.height - 356));
        }

        private function clearPreviousResults(result:Boolean):void
        {
            var i:MemMarketBuyItem;
            var o:MemMarketItem;
            if (result)
            {
                for each (i in this.resultItems_)
                {
                    i.dispose();
                    this.resultBackground_.removeChild(i);
                    i = null;
                }
                this.resultItems_.length = 0;
            }
            else
            {
                for each (o in this.searchItems)
                {
                    o.removeEventListener(MouseEvent.CLICK, this.onSearchClick);
                    o.dispose();
                    this.searchBackground.removeChild(o);
                    o = null;
                }
                this.searchItems.length = 0;
            }
        }

        private function removeOffer(id:int):void
        {
            var o:MemMarketBuyItem;
            var index:int = 0;
            for each (o in this.resultItems_)
            {
                if (o.id_ == id)
                {
                    this.resultItems_.splice(index, 1);
                    o.dispose();
                    o.parent.removeChild(o);
                    o = null;
                    break;
                }
                index++;
            }
            this.sortOffers();
        }

        private function sortOffers():void
        {
            var index:int;
            var i:MemMarketBuyItem;
            switch (SortUtils.SORT_CHOICES[this.sortChoices_.getIndex()])
            {
                case SortUtils.LOWEST_TO_HIGHEST:
                    this.resultItems_.sort(SortUtils.lowestToHighest);
                    break;
                case SortUtils.HIGHEST_TO_LOWEST:
                    this.resultItems_.sort(SortUtils.highestToLowest);
                    break;
                case SortUtils.JUST_ADDED:
                    this.resultItems_.sort(SortUtils.justAdded);
                    break;
                case SortUtils.ENDING_SOON:
                    this.resultItems_.sort(SortUtils.endingSoon);
                    break;
            }
            index = 0;
            for each (i in this.resultItems_)
            {
                i.x = ((MemMarketItem.OFFER_WIDTH * int((index % 10))) + RESULT_X_OFFSET);
                i.y = ((MemMarketItem.OFFER_HEIGHT * int((index / 10))) + RESULT_Y_OFFSET);
                index++;
            }
        }

        private function searchItemsFunc(first:Boolean = false):void {
            var x:MemMarketItem;
            var w:String;
            var preloaded:MemMarketItem;
            var i:String;
            var item:MemMarketItem;
            if (this.searchScroll != null) {
                this.searchScroll.removeEventListener(Event.CHANGE, this.onSearchScrollChanged);
                removeChild(this.searchScroll);
                this.searchScroll = null;
            }
            if (((!(StringUtil.trim(this.searchField_.text()))) && (!(first)))) {
                this.clearPreviousResults(false);
                return;
            }
            this.clearPreviousResults(false);
            var index:int = 0;
            if (first)
            {
                for each (w in ObjectLibrary.preloadedCustom_)
                {
                    var preData:ItemData = new ItemData(null);
                    preData.ObjectType = ObjectLibrary.idToTypeItems_[w];
                    if (!ItemUtils.isBanned(preData))
                    {
                        preloaded = new MemMarketItem(this.gameSprite_, SEARCH_ITEM_SIZE, SEARCH_ITEM_SIZE, 80, preData, null);
                        preloaded.x = ((SEARCH_ITEM_SIZE * int((index % 5))) + SEARCH_X_OFFSET);
                        preloaded.y = ((SEARCH_ITEM_SIZE * int((index / 5))) + SEARCH_Y_OFFSET);
                        preloaded.addEventListener(MouseEvent.CLICK, this.onSearchClick);
                        this.searchItems.push(preloaded);
                        index++;
                    }
                }
            }
            else
            {
                for each (i in ObjectLibrary.typeToIdItems_)
                {
                    if (i.indexOf(this.searchField_.text().toLowerCase()) >= 0)
                    {
                        var data:ItemData = new ItemData(null);
                        data.ObjectType = ObjectLibrary.idToTypeItems_[i];
                        if (!ItemUtils.isBanned(data))
                        {
                            item = new MemMarketItem(this.gameSprite_, SEARCH_ITEM_SIZE, SEARCH_ITEM_SIZE, 80, data, null);
                            item.x = ((SEARCH_ITEM_SIZE * int((index % 5))) + SEARCH_X_OFFSET);
                            item.y = ((SEARCH_ITEM_SIZE * int((index / 5))) + SEARCH_Y_OFFSET);
                            item.addEventListener(MouseEvent.CLICK, this.onSearchClick);
                            this.searchItems.push(item);
                            index++;
                        }
                    }
                }
            }
            for each (x in this.searchItems)
            {
                this.searchBackground.addChild(x);
            }
            this.searchBackground.y = 0;
            if (this.searchBackground.height > 350)
            {
                this.searchScroll = new LegacyScrollbar(6, 350, 0.3);
                this.searchScroll.x = 258;
                this.searchScroll.y = SEARCH_Y_OFFSET;
                this.searchScroll.setIndicatorSize(350, this.searchBackground.height);
                this.searchScroll.addEventListener(Event.CHANGE, this.onSearchScrollChanged);
                addChild(this.searchScroll);
            }
        }

        private function refreshOffers():void
        {
            var o:MemMarketBuyItem;
            for each (o in this.resultItems_)
            {
                o.updateButton();
            }
        }

        private function onBuy(result:MarketBuyResult):void
        {
            if (result.code_ != -1)
            {
                DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", result.description_);
                return;
            }
            this.removeOffer(result.offerId_);
            this.refreshOffers();
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Success", result.description_);
        }

        private function onSearch(result:MarketSearchResult):void
        {
            var i:MarketData;
            var o:MemMarketBuyItem;
            var item:MemMarketBuyItem;
            if (result.description_ != "")
            {
                this.clearPreviousResults(true);
                DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", result.description_);
                return;
            }
            if (this.resultScroll_ != null)
            {
                this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
                removeChild(this.resultScroll_);
                this.resultScroll_ = null;
            }
            this.clearPreviousResults(true);
            for each (i in result.results_)
            {
                item = new MemMarketBuyItem(this.gameSprite_, i);
                this.resultItems_.push(item);
            }
            this.sortOffers();
            for each (o in this.resultItems_)
            {
                this.resultBackground_.addChild(o);
            }
            this.resultBackground_.y = 0;
            if (this.resultBackground_.height > 436)
            {
                this.resultScroll_ = new LegacyScrollbar(22, 415);
                this.resultScroll_.x = 774;
                this.resultScroll_.y = RESULT_Y_OFFSET;
                this.resultScroll_.setIndicatorSize(415, this.resultBackground_.height);
                this.resultScroll_.addEventListener(Event.CHANGE, this.onResultScrollChanged);
                addChild(this.resultScroll_);
            }
        }

        private function onResultScrollChanged(event:Event):void
        {
            this.resultBackground_.y = (-(this.resultScroll_.pos()) * (this.resultBackground_.height - 418));
        }

        override public function dispose():void
        {
            this.buySignal_.remove(this.onBuy);
            this.searchSignal_.remove(this.onSearch);
            this.searchField_.removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
            this.searchField_ = null;
            this.shape_.parent.removeChild(this.shape_);
            this.shape_ = null;
            this.clearPreviousResults(false);
            this.searchItems = null;
            this.searchMask_.removeChild(this.searchBackground);
            this.searchMask_ = null;
            this.searchBackground = null;
            if (this.searchScroll != null)
            {
                this.searchScroll.removeEventListener(Event.CHANGE, this.onSearchScrollChanged);
                this.searchScroll = null;
            }
            this.clearPreviousResults(true);
            this.resultItems_ = null;
            this.resultMask_.removeChild(this.resultBackground_);
            this.resultMask_ = null;
            this.resultBackground_ = null;
            if (this.resultScroll_ != null)
            {
                this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
                this.resultScroll_ = null;
            }
            this.sortChoices_.removeEventListener(Event.CHANGE, this.onSortChoicesChanged);
            this.sortChoices_ = null;
            super.dispose();
        }


    }
}//package kabam.rotmg.memMarket.tabs

