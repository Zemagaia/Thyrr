package kabam.rotmg.messaging.impl.incoming {
import flash.utils.ByteArray;

public class VerifyEmail extends IncomingMessage {

    public function VerifyEmail(_arg1:uint, _arg2:Function) {
        super(_arg1, _arg2);
    }

    override public function parseFromInput(_arg1:ByteArray):void {
    }

    override public function toString():String {
        return (formatToString("VERIFYEMAIL", "asdf", "asdf"));
    }


}
}
