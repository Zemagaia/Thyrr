package kabam.rotmg.messaging.impl.outgoing.pets {

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class FetchPets extends OutgoingMessage {

    public function FetchPets(id:uint, callback:Function) {
        super(id, callback);
    }

    override public function writeToOutput(data:ByteArray):void {
    }
}
}