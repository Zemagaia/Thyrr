package kabam.rotmg.game.view.components {
import com.company.assembleegameclient.objects.Player;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.model.TabStripModel;

import org.osflash.signals.Signal;

import thyrr.ui.buttons.ToggleableButton;
import thyrr.utils.Utils;

public class TabStrip extends Sprite {

    public const tabSelected:Signal = new Signal(String);
    private const tabSprite:Sprite = new Sprite();
    private const containerSprite:Sprite = new Sprite();

    public var hudModel:HUDModel = Global.hudModel;
    public var tabStripModel:TabStripModel = Global.tabStripModel;
    public var tabs:Vector.<TabView>;
    public var stats:Stats;
    private var contents:Vector.<Sprite>;
    public var currentTabIndex:int;
    public var InventoryTab:InventoryTabContent;
    public var BackpackTab:BackpackTabContent;
    private var tabsInitialized:Boolean = false;
    private var detachedTabIndex:int;
    public var detachedTabs:Vector.<TabView>;
    private var currentDetachedTab:Sprite;

    public function TabStrip() {
        this.tabs = new Vector.<TabView>();
        this.detachedTabs = new Vector.<TabView>();
        this.contents = new Vector.<Sprite>();
        super();
        this.tabSprite.addEventListener(MouseEvent.CLICK, this.onTabClicked);
        addChild(this.tabSprite);
        addChild(this.containerSprite);
        this.containerSprite.y = TabConstants.TAB_TOP_OFFSET;
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        this.tabSelected.add(this.onTabSelected);
    }

    public function onTabHotkey():void {
        var _local1:int = (this.currentTabIndex + 1);
        _local1 = (_local1 % this.tabs.length);
        this.setSelectedTab(_local1);
    }

    public function destroy(e:Event):void {
        this.tabSelected.remove(this.onTabSelected);
    }

    public function addTabs(_arg1:Player):void {
        if (tabsInitialized || _arg1 == null) {
            return;
        }
        tabsInitialized = true;
        this.InventoryTab = new InventoryTabContent(_arg1);
        this.addTab(TabConstants.INVENTORY_ICON_ID, this.InventoryTab);
        if (_arg1.hasBackpack_) {
            this.BackpackTab = new BackpackTabContent(_arg1);
            this.addTab(TabConstants.BACKPACK_ICON_ID, this.BackpackTab);
        }
        addDetachedTabs();
    }

    private function addDetachedTabs():void
    {
        var statsTab:TabIconView = addIconTab(0, 0x0f);
        statsTab.x = 55 + (statsTab.width + 4) * 4;
        statsTab.y = 3;
        statsTab.name = TabStripModel.STATS;
        detachedTabs.push(statsTab);
        addChild(detachedTabs[0]);
        statsTab.addEventListener(MouseEvent.CLICK, onStats);
    }

    private function onTabSelected(_arg1:String):void {
        this.tabStripModel.currentSelection = _arg1;
    }

    private function onTabClicked(_arg1:MouseEvent):void {
        this.selectTab((_arg1.target.parent as TabView));
    }

    public function setSelectedTab(_arg1:uint):void {
        this.selectTab(this.tabs[_arg1]);
    }

    private function selectTab(_arg1:TabView):void {
        var _local2:TabView;
        if (_arg1) {
            _local2 = this.tabs[this.currentTabIndex];
            if (_local2.index != _arg1.index) {
                _local2.setSelected(false);
                _arg1.setSelected(true);
                this.showContent(_arg1.index);
                this.tabSelected.dispatch(this.contents[_arg1.index].name);
            }
        }
    }

    private function onStats(e:MouseEvent):void
    {
        if (currentDetachedTab != null && contains(currentDetachedTab))
            return;
        stats = new Stats(this);
        currentDetachedTab = stats;
        addChild(currentDetachedTab);
        currentDetachedTab.filters = [Utils.OutlineFilter];
        currentDetachedTab.x = 5;
        currentDetachedTab.y = 31;
        selectDetachedTab(e);
    }

    private function selectDetachedTab(e:MouseEvent):void
    {
        var tab:TabView = e.currentTarget as TabView;
        var current:TabView;
        if (tab == null) return;
        current = this.detachedTabs[this.detachedTabIndex];
        if (current.index != tab.index || (!tab.isSelected && this.detachedTabIndex == tab.index))
        {
            current.setSelected(false);
            tab.setSelected(true);
            this.detachedTabIndex = tab.index;
        }
    }

    public function clearTabs():void {
        if (!tabsInitialized) return;
        tabsInitialized = false;
        var _local1:uint;
        this.currentTabIndex = 0;
        var _local2:uint = this.tabs.length;
        _local1 = 0;
        while (_local1 < _local2) {
            this.tabSprite.removeChild(this.tabs[_local1]);
            this.containerSprite.removeChild(this.contents[_local1]);
            _local1++;
        }
        this.tabs = new Vector.<TabView>();
        this.contents = new Vector.<Sprite>();
    }

    public function addTab(iconId:int, _arg2:Sprite):void {
        var _local3:int = this.tabs.length;
        var _local4:TabView = this.addIconTab(_local3, iconId);
        this.tabs.push(_local4);
        this.tabSprite.addChild(_local4);
        this.contents.push(_arg2);
        this.containerSprite.addChild(_arg2);
        if (_local3 > 0) {
            _arg2.visible = false;
        }
        else {
            _local4.setSelected(true);
            this.showContent(0);
            this.tabSelected.dispatch(_arg2.name);
        }
    }

    public function removeTab():void {
    }

    private function addIconTab(index:int, iconId:int):TabIconView {
        var tabIcon:TabIconView;
        var button:ToggleableButton = new ToggleableButton(24, 24, 0xAEA9A9, iconId, false);
        tabIcon = new TabIconView(index, button);
        tabIcon.x = 55 + (tabIcon.width + 4) * index;
        tabIcon.y = 3;
        return (tabIcon);
    }

    private function showContent(_arg1:int):void {
        var _local2:Sprite;
        var _local3:Sprite;
        if (_arg1 != this.currentTabIndex) {
            _local2 = this.contents[this.currentTabIndex];
            _local3 = this.contents[_arg1];
            _local2.visible = false;
            _local3.visible = true;
            this.currentTabIndex = _arg1;
        }
    }


}
}
