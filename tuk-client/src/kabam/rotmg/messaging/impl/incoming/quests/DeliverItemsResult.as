package kabam.rotmg.messaging.impl.incoming.quests {

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

public class DeliverItemsResult extends IncomingMessage {
    public var delivered_:Vector.<Boolean>;

    public function DeliverItemsResult(id:uint, callback:Function) {
        this.delivered_ = new Vector.<Boolean>();
        super(id, callback);
    }

    override public function parseFromInput(data:ByteArray):void {
        this.delivered_.length = 0;
        var len:int = data.readShort();
        var i:int = 0;
        while (i < len) {
            this.delivered_.push(data.readBoolean());
            i++;
        }
    }
}
}
