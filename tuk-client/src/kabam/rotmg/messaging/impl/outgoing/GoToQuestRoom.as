﻿package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.ByteArray;

public class GoToQuestRoom extends OutgoingMessage {

    public function GoToQuestRoom(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }

    override public function writeToOutput(_arg1:ByteArray):void {
    }

    override public function toString():String {
        return (formatToString("GoToQuestRoom"));
    }


}
}
