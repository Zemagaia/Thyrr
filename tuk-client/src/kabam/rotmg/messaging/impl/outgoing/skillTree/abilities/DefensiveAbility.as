package kabam.rotmg.messaging.impl.outgoing.skillTree.abilities {
import kabam.rotmg.messaging.impl.outgoing.*;

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.data.SlotObjectData;
import kabam.rotmg.messaging.impl.data.WorldPosData;

public class DefensiveAbility extends OutgoingMessage {

    public var time_:int;
    public var usePos_:WorldPosData;
    public var angle_:Number;

    public function DefensiveAbility(_arg1:uint, _arg2:Function) {
        this.usePos_ = new WorldPosData();
        super(_arg1, _arg2);
    }

    override public function writeToOutput(data:ByteArray):void {
        data.writeInt(this.time_);
        this.usePos_.writeToOutput(data);
        data.writeFloat(this.angle_);
    }

    override public function toString():String {
        return (formatToString("DEFENSIVE_ABILITY", "usePos_", "angle_"));
    }


}
}
