package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.Panel;
import com.company.assembleegameclient.ui.tooltip.TextToolTip;
import com.company.assembleegameclient.ui.tooltip.ToolTip;

import kabam.rotmg.game.view.TextPanel;


public class ClosedGiftChest extends GameObject implements IInteractiveObject {

    public function ClosedGiftChest(_arg1:XML) {
        super(_arg1);
        isInteractive_ = true;
    }

    public function getTooltip():ToolTip {
        return (new TextToolTip(0x2B2B2B, 0x7B7B7B, "Gift Chest", "Gift Chest Is Empty", 200));
    }

    public function getPanel(_arg1:GameSprite):Panel {
        Global.textPanelUpdate("Gift Chest Is Empty");
        return (new TextPanel(_arg1));
    }


}
}
