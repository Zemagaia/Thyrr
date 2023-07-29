package kabam.rotmg.death.control {
import com.company.assembleegameclient.sound.Music;

import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.death.model.DeathModel;
import kabam.rotmg.messaging.impl.incoming.Death;

public class HandleDeath
{

    public var model:DeathModel = Global.deathModel;
    public var player:PlayerModel = Global.playerModel;


    public function HandleDeath(death:Death) {
        Music.load(player.getDeadMusic());
        Global.closeDialogs();
        if (this.isZombieDeathPending()) {
            this.passPreviousDeathToFameView();
        }
        else {
            this.updateModelAndHandleDeath(death);
        }
    }

    private function isZombieDeathPending():Boolean {
        return (this.model.getIsDeathViewPending());
    }

    private function passPreviousDeathToFameView():void {
        Global.handleNormalDeath(this.model.getLastDeath());
    }

    private function updateModelAndHandleDeath(death:Death):void {
        this.model.setLastDeath(death);
        Global.handleNormalDeath(death);
    }


}
}
