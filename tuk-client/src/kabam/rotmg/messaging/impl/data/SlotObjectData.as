﻿package kabam.rotmg.messaging.impl.data {
import flash.utils.ByteArray;
import flash.utils.ByteArray;

public class SlotObjectData {

    public var objectId_:int;
    public var slotId_:int;
    public var objectType_:int;


    public function parseFromInput(_arg1:ByteArray):void {
        this.objectId_ = _arg1.readInt();
        this.slotId_ = _arg1.readUnsignedByte();
        this.objectType_ = _arg1.readInt();
    }

    public function writeToOutput(_arg1:ByteArray):void {
        _arg1.writeInt(this.objectId_);
        _arg1.writeByte(this.slotId_);
        _arg1.writeInt(this.objectType_);
    }

    public function toString():String {
        return (((((("objectId_: " + this.objectId_) + " slotId_: ") + this.slotId_) + " objectType_: ") + this.objectType_));
    }


}
}
