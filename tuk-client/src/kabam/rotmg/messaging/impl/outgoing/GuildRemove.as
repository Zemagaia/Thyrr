﻿package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.ByteArray;

public class GuildRemove extends OutgoingMessage {

    public var name_:String;

    public function GuildRemove(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }

    override public function writeToOutput(_arg1:ByteArray):void {
        _arg1.writeUTF(this.name_);
    }

    override public function toString():String {
        return (formatToString("GUILDREMOVE", "name_"));
    }


}
}
