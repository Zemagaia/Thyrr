package thyrr.pets.signals {

import kabam.rotmg.messaging.impl.incoming.pets.FetchPetsResult;

import org.osflash.signals.Signal;

public class FetchPetsSignal extends Signal {

    public static var instance:FetchPetsSignal;

    public function FetchPetsSignal() {
        super(FetchPetsResult);
        instance = this;
    }

}
}