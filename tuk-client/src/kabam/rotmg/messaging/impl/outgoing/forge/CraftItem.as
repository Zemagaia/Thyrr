package kabam.rotmg.messaging.impl.outgoing.forge
{

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class CraftItem extends OutgoingMessage
{
    public var id_:int;
    public var itemSlot_:int;
    public var runeSlot_:int;
    public var slots_:Vector.<int>;

    public function CraftItem(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function writeToOutput(data:ByteArray) : void
    {
        data.writeInt(this.id_);
        data.writeInt(this.itemSlot_);
        data.writeInt(this.runeSlot_);
        data.writeByte(this.slots_.length);
        var i:int = 0;
        while (i < this.slots_.length)
        {
            data.writeByte(this.slots_[i]);
            i++;
        }
    }
}
}
