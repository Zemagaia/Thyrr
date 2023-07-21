package kabam.rotmg.messaging.impl.outgoing.mail {

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class FetchMail extends OutgoingMessage {

    public function FetchMail(id:uint, callback:Function) {
        super(id, callback);
    }

    override public function writeToOutput(data:ByteArray):void {
    }
}
}