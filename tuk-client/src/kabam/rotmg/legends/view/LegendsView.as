package kabam.rotmg.legends.view {
import com.company.assembleegameclient.screens.TitleMenuOption;
import com.company.assembleegameclient.ui.LegacyScrollbar;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.death.model.DeathModel;

import kabam.rotmg.legends.model.Legend;
import kabam.rotmg.legends.model.LegendsModel;
import kabam.rotmg.legends.model.Timespan;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.view.components.ScreenBase;

import org.osflash.signals.Signal;

public class LegendsView extends Sprite {

    public var model:LegendsModel = Global.legendsModel;
    public var deathModel:DeathModel = Global.deathModel;
    private const items:Vector.<LegendListItem> = new <LegendListItem>[];
    private const tabs:Object = {};

    private var title:TextFieldDisplayConcrete;
    private var loadingBanner:TextFieldDisplayConcrete;
    private var noLegendsBanner:TextFieldDisplayConcrete;
    private var mainContainer:Sprite;
    private var closeButton:TitleMenuOption;
    private var scrollBar:LegacyScrollbar;
    private var listContainer:Sprite;
    private var selectedTab:LegendsTab;
    private var legends:Vector.<Legend>;
    private var count:int;

    public function LegendsView() {
        this.makeScreenBase();
        this.makeTitleText();
        this.makeLoadingBanner();
        this.makeNoLegendsBanner();
        this.makeMainContainer();
        this.makeLines();
        this.makeScrollbar();
        this.makeTimespanTabs();
        this.makeCloseButton();
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        this.onTimespanChanged(this.model.getTimespan());
    }

    private function onClose():void {
        Global.exitLegends();
    }

    public function destroy(e:Event):void {
        this.deathModel.clearPendingDeathView();
        this.model.clear();
    }

    private function onTimespanChanged(_arg1:Timespan):void {
        this.model.setTimespan(_arg1);
        if (this.model.hasLegendList()) {
            this.updateLegendList();
        }
        else {
            this.showLoadingAndRequestFameList();
        }
    }

    private function showLoadingAndRequestFameList():void {
        this.clear();
        this.showLoading();
        Global.requestFameList(this.model.getTimespan());
    }

    public function updateLegendList(_arg1:Timespan = null):void {
        _arg1 = ((_arg1) || (this.model.getTimespan()));
        this.hideLoading();
        this.setLegendsList(_arg1, this.model.getLegendList());
    }

    private function onShowCharacter(_arg1:Legend):void {
        Global.showFameView(_arg1);
    }

    private function makeScreenBase():void {
        addChild(new ScreenBase());
    }

    private function makeTitleText():void {
        this.title = new TextFieldDisplayConcrete().setSize(32).setColor(0xB3B3B3);
        this.title.setAutoSize(TextFieldAutoSize.CENTER);
        this.title.setBold(true);
        this.title.setStringBuilder(new LineBuilder().setParams("Legends"));
        this.title.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        this.title.x = Main.DefaultWidth / 2;
        this.title.y = 24;
        addChild(this.title);
    }

    private function makeLoadingBanner():void {
        this.loadingBanner = new TextFieldDisplayConcrete().setSize(22).setColor(0xB3B3B3);
        this.loadingBanner.setBold(true);
        this.loadingBanner.setAutoSize(TextFieldAutoSize.CENTER).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        this.loadingBanner.setStringBuilder(new LineBuilder().setParams("Loading..."));
        this.loadingBanner.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        this.loadingBanner.x = (Main.DefaultWidth / 2);
        this.loadingBanner.y = (Main.DefaultHeight / 2);
        this.loadingBanner.visible = false;
        addChild(this.loadingBanner);
    }

    private function makeNoLegendsBanner():void {
        this.noLegendsBanner = new TextFieldDisplayConcrete().setSize(22).setColor(0xB3B3B3);
        this.noLegendsBanner.setBold(true);
        this.noLegendsBanner.setAutoSize(TextFieldAutoSize.CENTER).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        this.noLegendsBanner.setStringBuilder(new LineBuilder().setParams("No Legends Yet!"));
        this.noLegendsBanner.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        this.noLegendsBanner.x = (Main.DefaultWidth / 2);
        this.noLegendsBanner.y = (Main.DefaultHeight / 2);
        this.noLegendsBanner.visible = false;
        addChild(this.noLegendsBanner);
    }

    private function makeMainContainer():void {
        var _local1:Shape;
        _local1 = new Shape();
        var _local2:Graphics = _local1.graphics;
        _local2.beginFill(0);
        _local2.drawRect(0, 0, LegendListItem.WIDTH, Main.DefaultHeight - 170);
        _local2.endFill();
        this.mainContainer = new Sprite();
        this.mainContainer.x = 10;
        this.mainContainer.y = 110;
        this.mainContainer.addChild(_local1);
        this.mainContainer.mask = _local1;
        addChild(this.mainContainer);
    }

    private function makeLines():void {
        var _local1:Shape = new Shape();
        addChild(_local1);
        var _local2:Graphics = _local1.graphics;
        _local2.lineStyle(2, 0x545454);
        _local2.moveTo(0, 100);
        _local2.lineTo(Main.DefaultWidth, 100);
    }

    private function makeScrollbar():void {
        this.scrollBar = new LegacyScrollbar(16, Main.DefaultHeight - 200);
        this.scrollBar.x = ((Main.DefaultWidth - this.scrollBar.width) - 4);
        this.scrollBar.y = 104;
        addChild(this.scrollBar);
    }

    private function makeTimespanTabs():void {
        var _local1:Vector.<Timespan> = Timespan.TIMESPANS;
        var _local2:int = _local1.length;
        var _local3:int;
        while (_local3 < _local2) {
            this.makeTab(_local1[_local3], _local3);
            _local3++;
        }
    }

    private function makeTab(_arg1:Timespan, _arg2:int):LegendsTab {
        var _local3:LegendsTab = new LegendsTab(_arg1);
        this.tabs[_arg1.getId()] = _local3;
        _local3.x = (20 + (_arg2 * 90));
        _local3.y = 70;
        _local3.selected.add(this.onTabSelected);
        addChild(_local3);
        return (_local3);
    }

    private function onTabSelected(_arg1:LegendsTab):void {
        if (this.selectedTab != _arg1) {
            this.updateTabAndSelectTimespan(_arg1);
        }
    }

    private function updateTabAndSelectTimespan(_arg1:LegendsTab):void {
        this.updateTabs(_arg1);
        this.onTimespanChanged(this.selectedTab.getTimespan());
    }

    private function updateTabs(_arg1:LegendsTab):void {
        ((this.selectedTab) && (this.selectedTab.setIsSelected(false)));
        this.selectedTab = _arg1;
        this.selectedTab.setIsSelected(true);
    }

    private function makeCloseButton():void {
        this.closeButton = new TitleMenuOption("Done", 32, 18);
        this.closeButton.x = Main.DefaultWidth / 2 - closeButton.width / 2;
        this.closeButton.y = Main.DefaultHeight - 50;
        addChild(this.closeButton);
        this.closeButton.addEventListener(MouseEvent.CLICK, this.onCloseClick);
    }

    private function onCloseClick(_arg1:MouseEvent):void {
        this.onClose();
    }

    public function clear():void {
        ((this.listContainer) && (this.clearLegendsList()));
        this.listContainer = null;
        this.scrollBar.visible = false;
    }

    private function clearLegendsList():void {
        var _local1:LegendListItem;
        for each (_local1 in this.items) {
            _local1.selected.remove(this.onItemSelected);
        }
        this.items.length = 0;
        this.mainContainer.removeChild(this.listContainer);
        this.listContainer = null;
    }

    public function setLegendsList(_arg1:Timespan, _arg2:Vector.<Legend>):void {
        this.clear();
        this.updateTabs(this.tabs[_arg1.getId()]);
        this.listContainer = new Sprite();
        this.legends = _arg2;
        this.count = _arg2.length;
        this.items.length = this.count;
        this.noLegendsBanner.visible = (this.count == 0);
        this.makeItemsFromLegends();
        this.mainContainer.addChild(this.listContainer);
        this.updateScrollbar();
    }

    private function makeItemsFromLegends():void {
        var _local1:int;
        while (_local1 < this.count) {
            this.items[_local1] = this.makeItemFromLegend(_local1);
            _local1++;
        }
    }

    private function makeItemFromLegend(_arg1:int):LegendListItem {
        var _local2:Legend = this.legends[_arg1];
        _local2.place = (_arg1 + 1);
        var _local3:LegendListItem = new LegendListItem(_local2);
        _local3.y = (_arg1 * LegendListItem.HEIGHT);
        _local3.selected.add(this.onItemSelected);
        this.listContainer.addChild(_local3);
        return (_local3);
    }

    private function updateScrollbar():void {
        if (this.listContainer.height > Main.DefaultHeight - 200) {
            this.scrollBar.visible = true;
            this.scrollBar.setIndicatorSize(Main.DefaultHeight - 200, this.listContainer.height);
            this.scrollBar.addEventListener(Event.CHANGE, this.onScrollBarChange);
            this.positionScrollbarToDisplayFocussedLegend();
        }
        else {
            this.scrollBar.removeEventListener(Event.CHANGE, this.onScrollBarChange);
            this.scrollBar.visible = false;
        }
    }

    private function positionScrollbarToDisplayFocussedLegend():void {
        var _local2:int;
        var _local3:int;
        var _local1:Legend = this.getLegendFocus();
        if (_local1) {
            _local2 = this.legends.indexOf(_local1);
            _local3 = ((_local2 + 0.5) * LegendListItem.HEIGHT);
            this.scrollBar.setPos(((_local3 - 200) / (this.listContainer.height - Main.DefaultHeight - 200)));
        }
    }

    private function getLegendFocus():Legend {
        var _local1:Legend;
        var _local2:Legend;
        for each (_local2 in this.legends) {
            if (_local2.isFocus) {
                _local1 = _local2;
                break;
            }
        }
        return (_local1);
    }

    private function onItemSelected(_arg1:Legend):void {
        this.onShowCharacter(_arg1);
    }

    private function onScrollBarChange(_arg1:Event):void {
        this.listContainer.y = (-(this.scrollBar.pos()) * (this.listContainer.height - 400 - (Main.DefaultHeight - 600)));
    }

    public function showLoading():void {
        this.loadingBanner.visible = true;
    }

    public function hideLoading():void {
        this.loadingBanner.visible = false;
    }


}
}
