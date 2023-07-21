package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.ByteArray;

public class Buy extends OutgoingMessage {

    public var objectId_:int;

    public function Buy(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }

    override public function writeToOutput(_arg1:ByteArray):void {
        _arg1.writeInt(this.objectId_);
    }

    override public function toString():String {
        return (formatToString("BUY", "objectId_"));
    }


}
}
