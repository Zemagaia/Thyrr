package kabam.rotmg.game.view.components {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.InventoryGrid;

import flash.display.Sprite;

import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.ui.model.TabStripModel;

public class BackpackTabContent extends Sprite {

    private var backpackContent:Sprite;
    public var Backpack:InventoryGrid;

    public function BackpackTabContent(_arg1:Player) {
        this.backpackContent = new Sprite();
        super();
        this.init(_arg1);
        this.addChildren();
        this.positionChildren();
    }

    private function init(_arg1:Player):void {
        this.backpackContent.name = TabStripModel.BACKPACK;
        Backpack = new InventoryGrid(_arg1, _arg1, (GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS), true);
    }

    private function positionChildren():void {
        this.backpackContent.x = 7;
        this.backpackContent.y = 7;
    }

    private function addChildren():void {
        this.backpackContent.addChild(Backpack);
        addChild(this.backpackContent);
    }


}
}
