package thyrr.quests.signals {

import kabam.rotmg.messaging.impl.incoming.quests.DeliverItemsResult;

import org.osflash.signals.Signal;

public class DeliverItemsSignal extends Signal {

    public static var instance:DeliverItemsSignal;

    public function DeliverItemsSignal() {
        super(DeliverItemsResult);
        instance = this;
    }

}
}