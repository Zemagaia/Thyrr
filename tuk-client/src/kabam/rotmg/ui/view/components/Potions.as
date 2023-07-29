package kabam.rotmg.ui.view.components
{
import com.company.assembleegameclient.objects.Player;

import flash.display.Sprite;

import thyrr.utils.Utils;

public class Potions extends Sprite
{
    private const Width:int = 264;
    private var leftSlot:PotionSlot;
    private var rightSlot:PotionSlot;

    public function Potions()
    {
        leftSlot = new PotionSlot(0);
        rightSlot = new PotionSlot(1);
        leftSlot.filters = [Utils.OutlineFilter];
        rightSlot.filters = [Utils.OutlineFilter];
        addChild(leftSlot);
        addChild(rightSlot);
        leftSlot.x = Width / 2 - 78;
        rightSlot.x = Width / 2 + 26;
    }

    public function initialize(player:Player):void
    {
        leftSlot.initializeData(player);
        rightSlot.initializeData(player);
    }

    public function update(player:Player):void
    {
        leftSlot.update(player);
        rightSlot.update(player);
    }
}
}
