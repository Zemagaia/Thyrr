package kabam.rotmg.messaging.impl.incoming {
import flash.utils.ByteArray;

import kabam.lib.net.impl.Message;

public class IncomingMessage extends Message {

    public function IncomingMessage(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }

    final override public function writeToOutput(_arg1:ByteArray):void {
        throw (new Error((("Client should not send " + id) + " messages")));
    }


}
}
