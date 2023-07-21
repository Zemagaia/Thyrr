package kabam.rotmg.messaging.impl.outgoing.quests {

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class AcceptQuest extends OutgoingMessage {

    public var id_:int;
    public var type_:int;

    public static const Accept:int = 0;
    public static const Dismiss:int = 1;
    public static const Delete:int = 2;
    public static const Deliver:int = 3;
    public static const Scout:int = 4;
    public static const Delete_Account:int = 5;
    public static const Deliver_Account:int = 6;
    public static const Scout_Account:int = 7;

    public function AcceptQuest(id:uint, callback:Function) {
        super(id, callback);
    }

    override public function writeToOutput(data:ByteArray):void {
        data.writeInt(this.id_);
        data.writeInt(this.type_);
    }
}
}