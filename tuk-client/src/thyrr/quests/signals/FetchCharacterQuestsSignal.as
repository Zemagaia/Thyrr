package thyrr.quests.signals {

import kabam.rotmg.messaging.impl.incoming.quests.FetchCharacterQuestsResult;

import org.osflash.signals.Signal;

public class FetchCharacterQuestsSignal extends Signal {

    public static var instance:FetchCharacterQuestsSignal;

    public function FetchCharacterQuestsSignal() {
        super(FetchCharacterQuestsResult);
        instance = this;
    }

}
}