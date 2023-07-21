package thyrr.forge.signals {

import kabam.rotmg.messaging.impl.incoming.forge.CraftAnimation;

import org.osflash.signals.Signal;

public class CraftAnimationSignal extends Signal {

    public static var instance:CraftAnimationSignal;

    public function CraftAnimationSignal() {
        super(CraftAnimation);
        instance = this;
    }

}
}