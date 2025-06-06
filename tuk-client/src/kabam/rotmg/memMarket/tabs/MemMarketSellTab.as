﻿package kabam.rotmg.memMarket.tabs
{

import kabam.rotmg.memMarket.signals.MemMarketAddSignal;
import kabam.rotmg.memMarket.signals.MemMarketRemoveSignal;
import kabam.rotmg.memMarket.signals.MemMarketMyOffersSignal;
import kabam.rotmg.memMarket.content.MemMarketInventoryItem;

import com.company.assembleegameclient.account.ui.MarketInput;
import com.company.assembleegameclient.ui.dropdown.DropDown;
import com.company.assembleegameclient.ui.DeprecatedTextButton;

import flash.display.Shape;
import flash.display.Sprite;

import kabam.rotmg.memMarket.content.MemMarketSellItem;

import com.company.assembleegameclient.ui.LegacyScrollbar;

import kabam.rotmg.memMarket.content.MemMarketItem;

import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.memMarket.utils.SortUtils;

import com.company.assembleegameclient.game.GameSprite;

import kabam.rotmg.memMarket.utils.DialogUtils;

import com.company.assembleegameclient.util.Currency;

import kabam.rotmg.messaging.impl.incoming.market.MarketAddResult;
import kabam.rotmg.messaging.impl.incoming.market.MarketRemoveResult;
import kabam.rotmg.messaging.impl.data.MarketData;
import kabam.rotmg.messaging.impl.incoming.market.MarketMyOffersResult;

public class MemMarketSellTab extends MemMarketTab
{

    private static const SLOT_X_OFFSET:int = 33;
    private static const SLOT_Y_OFFSET:int = 109;
    private static const RESULT_X_OFFSET:int = 270;
    private static const RESULT_Y_OFFSET:int = 105;

    private static const HOURS_24:String = "1 Day";
    private static const HOURS_72:String = "3 Days";
    private static const HOURS_120:String = "5 Days";
    private static const UPTIME_CHOICES:Vector.<String> = new <String>
    [
        HOURS_24,
        HOURS_72,
        HOURS_120
    ];

    public const addSignal_:MemMarketAddSignal = new MemMarketAddSignal();
    public const removeSignal_:MemMarketRemoveSignal = new MemMarketRemoveSignal();
    public const myOffersSignal_:MemMarketMyOffersSignal = new MemMarketMyOffersSignal();

    private var inventorySlots_:Vector.<MemMarketInventoryItem>;
    private var priceField_:MarketInput;
    private var uptimeChoice_:DropDown;
    private var sellButton_:DeprecatedTextButton;
    private var shape_:Shape;
    private var resultMask_:Sprite;
    private var resultBackground_:Sprite;
    private var resultItems_:Vector.<MemMarketSellItem>;
    private var resultScroll_:LegacyScrollbar;
    private var sortChoices_:DropDown;
    private var uptime_:int;
    private var slots_:Vector.<int>;
    private var price_:int;

    public function MemMarketSellTab(gameSprite:GameSprite)
    {
        var space:int;
        var o:MemMarketInventoryItem;
        var item:MemMarketInventoryItem;
        super(gameSprite);
        this.addSignal_.add(this.onAdd);
        this.removeSignal_.add(this.onRemove);
        this.myOffersSignal_.add(this.onMyOffers);
        this.inventorySlots_ = new Vector.<MemMarketInventoryItem>();
        var i:int = 4;
        while (i < this.gameSprite_.map.player_.equipment_.length)
        {
            item = new MemMarketInventoryItem(this.gameSprite_, this.gameSprite_.map.player_.equipment_[i], i);
            this.inventorySlots_.push(item);
            i++;
        }
        space = 0;
        var index:int = 0;
        for each (o in this.inventorySlots_)
        {
            o.x = ((MemMarketItem.SLOT_WIDTH * int((index % 4))) + SLOT_X_OFFSET);
            o.y = (((MemMarketItem.SLOT_HEIGHT * int((index / 4))) + SLOT_Y_OFFSET) + space);
            index++;
            if ((index % 8) == 0)
            {
                space = 20;
            }
            addChild(o);
        }
        this.priceField_ = new MarketInput("", false, "");
        this.priceField_.inputText_.restrict = "0-9";
        this.priceField_.x = 13;
        this.priceField_.y = 304;

        addChild(this.priceField_);

        this.uptimeChoice_ = new DropDown(UPTIME_CHOICES, 176, 26, "Uptime");
        this.uptimeChoice_.x = 10;
        this.uptimeChoice_.y = 368;
        this.uptimeChoice_.setValue(HOURS_72);
        this.uptimeChoice_.addEventListener(Event.CHANGE, this.onUptimeChanged);

        addChild(this.uptimeChoice_);

        this.uptime_ = this.getHours();
        this.sellButton_ = new DeprecatedTextButton(16, "Sell", 243);
        this.sellButton_.x = 10;
        this.sellButton_.y = 397;
        this.sellButton_.addEventListener(MouseEvent.CLICK, this.onSell);

        addChild(this.sellButton_);

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
        this.resultItems_ = new Vector.<MemMarketSellItem>();
        this.sortChoices_ = new DropDown(SortUtils.SORT_CHOICES, 200, 26);
        this.sortChoices_.x = 597;
        this.sortChoices_.y = 71;
        this.sortChoices_.setValue(SortUtils.JUST_ADDED);
        this.sortChoices_.addEventListener(Event.CHANGE, this.onSortChoicesChanged);

        addChild(this.sortChoices_);

        this.gameSprite_.gsc_.marketMyOffers();
    }

    private function onSortChoicesChanged(event:Event):void
    {
        this.sortOffers();
    }

    private function onSell(event:MouseEvent):void
    {
        var i:MemMarketInventoryItem;
        this.price_ = int(this.priceField_.text());
        if (this.price_ <= 0)
        {
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", "Invalid price.");
            return;
        }
        this.slots_ = new Vector.<int>();
        for each (i in this.inventorySlots_)
        {
            if ((!(i.selected_)))
            {
            }
            else
            {
                this.slots_.push(i.slot_);
            }
        }
        if (this.slots_.length <= 0)
        {
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", "You must select at least 1 item.");
            return;
        }

        DialogUtils.makeCallbackDialog(this.gameSprite_, "Verification", "Are you sure you want to sell these items?", "Yes", "No", this.onVerified);
    }

    private function onVerified(event:Event):void
    {
        this.gameSprite_.gsc_.marketAdd(this.slots_, this.price_, Currency.FAME, this.uptime_);
    }

    private function onUptimeChanged(event:Event):void
    {
        this.uptime_ = this.getHours();
    }

    private function getHours():int
    {
        var hours:int;
        switch (UPTIME_CHOICES[this.uptimeChoice_.getIndex()])
        {
            case HOURS_24:
                hours = 24;
                break;
            case HOURS_120:
                hours = 120;
                break;
            default:
                hours = 72;
                break;
        }
        return hours;
    }

    private function onAdd(result:MarketAddResult):void
    {
        var i:MemMarketInventoryItem;
        var x:int;
        if (result.code_ != -1)
        {
            this.slots_.length = 0;
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", result.description_);
            return;
        }
        for each (i in this.inventorySlots_)
        {
            for each (x in this.slots_)
            {
                if (i.slot_ == x)
                {
                    i.reset();
                }
            }
        }
        this.slots_.length = 0;
        this.gameSprite_.gsc_.marketMyOffers();
        DialogUtils.makeSimpleDialog(this.gameSprite_, "Success", result.description_);
    }

    private function onRemove(result:MarketRemoveResult):void
    {
        if (result.description_ != "")
        {
            DialogUtils.makeSimpleDialog(this.gameSprite_, "Error", result.description_);
        }
    }

    private function onMyOffers(result:MarketMyOffersResult):void
    {
        var i:MarketData;
        var o:MemMarketSellItem;
        var item:MemMarketSellItem;
        if (this.resultScroll_ != null)
        {
            this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            removeChild(this.resultScroll_);
            this.resultScroll_ = null;
        }
        this.clearPreviousResults();
        for each (i in result.results_)
        {
            item = new MemMarketSellItem(this.gameSprite_, i);
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

    private function clearPreviousResults():void
    {
        var i:MemMarketSellItem;
        for each (i in this.resultItems_)
        {
            i.dispose();
            this.resultBackground_.removeChild(i);
            i = null;
        }
        this.resultItems_.length = 0;
    }

    private function sortOffers():void
    {
        var i:MemMarketSellItem;
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
        var index:int = 0;
        for each (i in this.resultItems_)
        {
            i.x = ((MemMarketItem.OFFER_WIDTH * int((index % 10))) + RESULT_X_OFFSET);
            i.y = ((MemMarketItem.OFFER_HEIGHT * int((index / 10))) + RESULT_Y_OFFSET);
            index++;
        }
    }

    override public function dispose():void
    {
        var i:MemMarketInventoryItem;
        this.addSignal_.remove(this.onAdd);
        this.removeSignal_.remove(this.onRemove);
        this.myOffersSignal_.remove(this.onMyOffers);

        for each (i in this.inventorySlots_)
        {
            i.dispose();
            i = null;
        }

        this.inventorySlots_.length = 0;
        this.inventorySlots_ = null;

        this.priceField_ = null;
        this.uptimeChoice_.removeEventListener(Event.CHANGE, this.onUptimeChanged);
        this.uptimeChoice_ = null;
        this.sellButton_.removeEventListener(MouseEvent.CLICK, this.onSell);
        this.sellButton_ = null;
        this.shape_.parent.removeChild(this.shape_);
        this.shape_ = null;

        this.clearPreviousResults();

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
        if (this.slots_ != null)
        {
            this.slots_.length = 0;
            this.slots_ = null;
        }
        super.dispose();
    }


}
}