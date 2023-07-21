package kabam.rotmg.game.view.components {
import com.company.assembleegameclient.objects.Player;

import kabam.rotmg.ui.signals.UpdateHUDSignal;

import robotlegs.bender.bundles.mvcs.Mediator;

public class StatsMediator extends Mediator {

    [Inject]
    public var view:StatsView;
    [Inject]
    public var updateHUD:UpdateHUDSignal;

    override public function initialize():void {
        this.view.tabButtons.switchTab.add(onTabSwitched);
        this.updateHUD.add(this.onUpdateHUD);
    }

    override public function destroy():void {
        this.view.tabButtons.switchTab.remove(onTabSwitched);
        this.updateHUD.remove(this.onUpdateHUD);
    }

    private function onUpdateHUD(_arg1:Player):void {
        this.view.draw(_arg1);
    }

    private function onTabSwitched(tab:int):void
    {
        switch (tab)
        {
            case 0:
                this.view.containerSprite.visible = true;
                this.view.containerSprite2.visible = false;
                this.view.containerSprite3.visible = false;
                break;
            case 1:
                this.view.containerSprite.visible = false;
                this.view.containerSprite2.visible = true;
                this.view.containerSprite3.visible = false;
                break;
            case 2:
                this.view.containerSprite.visible = false;
                this.view.containerSprite2.visible = false;
                this.view.containerSprite3.visible = true;
                break;
        }
    }

}
}
