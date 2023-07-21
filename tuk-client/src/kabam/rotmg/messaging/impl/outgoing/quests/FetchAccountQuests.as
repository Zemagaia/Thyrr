package kabam.rotmg.messaging.impl.outgoing.quests {

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class FetchAccountQuests extends OutgoingMessage {

    public function FetchAccountQuests(id:uint, callback:Function) {
        super(id, callback);
    }

    override public function writeToOutput(data:ByteArray):void {
    }
}
}