package kabam.rotmg.game.view.components {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.InventoryGrid;

import flash.display.Sprite;

import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.ui.model.TabStripModel;

import thyrr.utils.Utils;

public class BackpackTabContent extends Sprite {

    private var backpackContent:Sprite;
    public var inv:InventoryGrid;

    public function BackpackTabContent(_arg1:Player) {
        this.backpackContent = new Sprite();
        super();
        this.init(_arg1);
        this.addChildren();
        this.positionChildren();
    }

    private function init(_arg1:Player):void {
        this.backpackContent.name = TabStripModel.BACKPACK;
        inv = new InventoryGrid(_arg1, _arg1, (GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS), true);
        inv.filters = [Utils.OutlineFilter];
        inv.x -= 2;
        inv.y -= 2;
    }

    private function positionChildren():void {
        this.backpackContent.x = 7;
        this.backpackContent.y = 7;
    }

    private function addChildren():void {
        this.backpackContent.addChild(inv);
        addChild(this.backpackContent);
    }


}
}
