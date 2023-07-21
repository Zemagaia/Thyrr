package kabam.rotmg.messaging.impl.incoming {
import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.data.WorldPosData;

public class ServerPlayerShoot extends IncomingMessage {

    public var ownerId_:int;
    public var containerType_:int;
    public var bulletIds_:Vector.<uint>;
    public var damages_:Vector.<int>;
    public var damageTypes_:Vector.<int>;
    public var startingPos_:WorldPosData;

    public function ServerPlayerShoot(_arg1:uint, _arg2:Function) {
        this.startingPos_ = new WorldPosData();
        this.bulletIds_ = new Vector.<uint>();
        this.damages_ = new Vector.<int>();
        this.damageTypes_ = new Vector.<int>();
        super(_arg1, _arg2);
    }

    override public function parseFromInput(data:ByteArray):void {
        this.ownerId_ = data.readInt();
        this.containerType_ = data.readInt();
        var i:int;
        var len:int = data.readShort();
        this.bulletIds_.length = 0;
        i = 0;
        while (i < len)
        {
            this.bulletIds_.push(data.readByte());
            i++;
        }
        len = data.readShort();
        this.damages_.length = 0;
        i = 0;
        while (i < len)
        {
            this.damages_.push(data.readShort());
            i++;
        }
        len = data.readShort();
        this.damageTypes_.length = 0;
        i = 0;
        while (i < len)
        {
            this.damageTypes_.push(data.readByte());
            i++;
        }
        this.startingPos_.parseFromInput(data);
    }

    override public function toString():String {
        return (formatToString("SHOOT", "bulletId_", "ownerId_", "containerType_", "startingPos_", "angle_", "damage_", "damageType_"));
    }


}
}
