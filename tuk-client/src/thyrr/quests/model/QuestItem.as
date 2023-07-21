package thyrr.quests.model {
import flash.display.Sprite;
import flash.events.Event;

import kabam.rotmg.util.ItemWithTooltip;

import thyrr.utils.ItemData;

public class QuestItem extends Sprite {
    private var itemWithTooltip_:ItemWithTooltip;

    public function QuestItem(itemType:int, itemData:ItemData) {
        this.itemWithTooltip_ = new ItemWithTooltip(itemType, 60, true, null, itemData);
        addChild(this.itemWithTooltip_);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage)
    }

    private function onRemovedFromStage(e:Event):void {
        this.itemWithTooltip_.dispose();
        this.itemWithTooltip_ = null;
    }
}
}