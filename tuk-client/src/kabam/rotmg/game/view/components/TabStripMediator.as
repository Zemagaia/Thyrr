package kabam.rotmg.game.view.components {
import com.company.assembleegameclient.objects.ImageFactory;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.icons.IconButtonFactory;

import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.model.TabStripModel;
import kabam.rotmg.ui.signals.UpdateBackpackTabSignal;
import kabam.rotmg.ui.signals.UpdateHUDSignal;

import robotlegs.bender.bundles.mvcs.Mediator;

public class TabStripMediator extends Mediator {

    [Inject]
    public var view:TabStripView;
    [Inject]
    public var hudModel:HUDModel;
    [Inject]
    public var tabStripModel:TabStripModel;
    [Inject]
    public var updateHUD:UpdateHUDSignal;
    [Inject]
    public var updateBackpack:UpdateBackpackTabSignal;
    [Inject]
    public var imageFactory:ImageFactory;
    [Inject]
    public var iconButtonFactory:IconButtonFactory;
    [Inject]
    public var statsTabHotKeyInput:TabStripSwapTabSignal;
    [Inject]
    public var openDialog:OpenDialogSignal;


    override public function initialize():void {
        this.view.imageFactory = this.imageFactory;
        this.view.iconButtonFactory = this.iconButtonFactory;
        this.view.tabSelected.add(this.onTabSelected);
        this.updateHUD.addOnce(this.addTabs);
        this.statsTabHotKeyInput.add(this.onTabHotkey);
    }

    private function onTabHotkey():void {
        var _local1:int = (this.view.currentTabIndex + 1);
        _local1 = (_local1 % this.view.tabs.length);
        this.view.setSelectedTab(_local1);
    }

    override public function destroy():void {
        this.view.tabSelected.remove(this.onTabSelected);
        this.updateBackpack.remove(this.onUpdateBackPack);
    }

    private function addTabs(_arg1:Player):void {
        if (_arg1 == null) {
            return;
        }
        this.view.InventoryTab = new InventoryTabContent(_arg1);
        this.view.addTab(TabConstants.INVENTORY_ICON_ID, this.view.InventoryTab);
        if (_arg1.hasBackpack_) {
            this.view.BackpackTab = new BackpackTabContent(_arg1);
            this.view.addTab(TabConstants.BACKPACK_ICON_ID, this.view.BackpackTab);
        }
        else {
            this.updateBackpack.add(this.onUpdateBackPack);
        }
    }

    private function clearTabs():void {
        this.view.clearTabs();
    }

    private function onTabSelected(_arg1:String):void {
        this.tabStripModel.currentSelection = _arg1;
    }

    private function onUpdateBackPack(_arg1:Boolean):void {
        var _local2:Player;
        if (_arg1) {
            _local2 = this.hudModel.gameSprite.map.player_;
            this.view.addTab(TabConstants.BACKPACK_ICON_ID, new BackpackTabContent(_local2));
            this.updateBackpack.remove(this.onUpdateBackPack);
        }
    }


}
}
