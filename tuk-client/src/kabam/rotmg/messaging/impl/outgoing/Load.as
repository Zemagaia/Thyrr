package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.ByteArray;

public class Load extends OutgoingMessage {

    public var charId_:int;

    public function Load(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }

    override public function writeToOutput(_arg1:ByteArray):void {
        _arg1.writeInt(this.charId_);
    }

    override public function toString():String {
        return (formatToString("LOAD", "charId_"));
    }


}
}
