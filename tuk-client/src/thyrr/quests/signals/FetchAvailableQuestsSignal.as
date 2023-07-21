package thyrr.quests.signals {

import kabam.rotmg.messaging.impl.incoming.quests.FetchAvailableQuestsResult;

import org.osflash.signals.Signal;

public class FetchAvailableQuestsSignal extends Signal {

    public static var instance:FetchAvailableQuestsSignal;

    public function FetchAvailableQuestsSignal() {
        super(FetchAvailableQuestsResult);
        instance = this;
    }

}
}