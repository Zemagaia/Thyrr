package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.ByteArray;

public class PlayerText extends OutgoingMessage {

    public var text_:String;

    public function PlayerText(_arg1:uint, _arg2:Function) {
        this.text_ = new String();
        super(_arg1, _arg2);
    }

    override public function writeToOutput(_arg1:ByteArray):void {
        _arg1.writeUTF(this.text_);
    }

    override public function toString():String {
        return (formatToString("PLAYERTEXT", "text_"));
    }


}
}
