package kabam.rotmg.messaging.impl.incoming.forge {
import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

public class CraftAnimation extends IncomingMessage {

    public var objectType_:int;
    public var active_:Vector.<int>;

    public function CraftAnimation(_arg1:uint, _arg2:Function) {
        this.active_ = new Vector.<int>();
        super(_arg1, _arg2);
    }

    override public function parseFromInput(data:ByteArray):void {
        this.objectType_ = data.readInt();
        this.active_.length = 0;
        var len:int = data.readShort();
        var i:int = 0;
        while (i < len) {
            this.active_.push(data.readInt());
            i++;
        }
    }


}
}
