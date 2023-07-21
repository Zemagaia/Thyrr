package kabam.rotmg.game.view.components {
import com.company.assembleegameclient.objects.ImageFactory;
import com.company.assembleegameclient.ui.icons.IconButtonFactory;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;

import kabam.rotmg.stage3D.Object3D.Util;

import org.osflash.signals.Signal;

import thyrr.ui.buttons.ToggleableButton;

import thyrr.ui.items.Box;
import thyrr.utils.Utils;

public class TabStripView extends Sprite {

    public const tabSelected:Signal = new Signal(String);
    private const tabSprite:Sprite = new Sprite();
    private const containerSprite:Sprite = new Sprite();

    public var iconButtonFactory:IconButtonFactory;
    public var imageFactory:ImageFactory;
    public var tabs:Vector.<TabView>;
    private var contents:Vector.<Sprite>;
    public var currentTabIndex:int;
    public var InventoryTab:InventoryTabContent;
    public var BackpackTab:BackpackTabContent;

    public function TabStripView() {
        this.tabs = new Vector.<TabView>();
        this.contents = new Vector.<Sprite>();
        super();
        this.tabSprite.addEventListener(MouseEvent.CLICK, this.onTabClicked);
        addChild(this.tabSprite);
        addChild(this.containerSprite);
        this.containerSprite.y = TabConstants.TAB_TOP_OFFSET;
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

    public function clearTabs():void {
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
        button.filters = [Utils.OutlineFilter];
        var backpackButton:ToggleableButton = new ToggleableButton(24, 24, 0xAEA9A9, 0x08, false);
        backpackButton.filters = [Utils.OutlineFilter];
        var statButton:ToggleableButton = new ToggleableButton(24, 24, 0xAEA9A9, 0x0F,false);
        statButton.filters = [Utils.OutlineFilter];
        var petButton:ToggleableButton = new ToggleableButton(24, 24, 0xAEA9A9, 0x10, false);
        petButton.filters = [Utils.OutlineFilter];
        var charInfobutton:ToggleableButton = new ToggleableButton(24, 24, 0xAeA9A9, 0x0A, false);
        charInfobutton.filters = [Utils.OutlineFilter];
        var skillButton:ToggleableButton = new ToggleableButton(24, 24, 0xAEA9A9, 0x11, false);
        skillButton.filters = [Utils.OutlineFilter];
        tabIcon = new TabIconView(index, button);
        tabIcon.x = -tabIcon.button.width + 79;
        tabIcon.y = 3 + index * tabIcon.button.height;
        backpackButton.x = tabIcon.x + 28;
        backpackButton.y = tabIcon.y;
        statButton.x = backpackButton.x + 28;
        statButton.y = backpackButton.y;
        petButton.x = statButton.x + 28;
        petButton.y = statButton.y;
        skillButton.x = petButton.x + 28;
        skillButton.y = petButton.y;
        charInfobutton.x = skillButton.x + 28;
        charInfobutton.y = skillButton.y;
        addChild(backpackButton);
        addChild(statButton);
        addChild(petButton);
        addChild(charInfobutton);
        addChild(skillButton);
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
