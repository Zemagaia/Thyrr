package kabam.rotmg.messaging.impl.incoming {
import flash.utils.ByteArray;

public class CurrentTime extends IncomingMessage {

    public var hour_:int;

    public function CurrentTime(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }

    override public function parseFromInput(_arg1:ByteArray):void {
        this.hour_ = _arg1.readInt();
    }

}
}
