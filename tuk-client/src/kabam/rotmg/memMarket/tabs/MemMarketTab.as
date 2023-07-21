package kabam.rotmg.memMarket.tabs {

import com.company.assembleegameclient.game.GameSprite;

import thyrr.oldui.DefaultTab;

public class MemMarketTab extends DefaultTab {

    public function MemMarketTab(gameSprite:GameSprite) {
        super(gameSprite);
        graphics.clear();
        graphics.lineStyle(1, 0x5E5E5E);
        graphics.moveTo(265, 100);
        graphics.lineTo(265, 525);
        graphics.lineStyle();
    }

}
}