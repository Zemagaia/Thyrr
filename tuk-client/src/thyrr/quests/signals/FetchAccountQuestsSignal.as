package thyrr.quests.signals {

import kabam.rotmg.messaging.impl.incoming.quests.FetchAccountQuestsResult;

import org.osflash.signals.Signal;

public class FetchAccountQuestsSignal extends Signal {

    public static var instance:FetchAccountQuestsSignal;

    public function FetchAccountQuestsSignal() {
        super(FetchAccountQuestsResult);
        instance = this;
    }

}
}