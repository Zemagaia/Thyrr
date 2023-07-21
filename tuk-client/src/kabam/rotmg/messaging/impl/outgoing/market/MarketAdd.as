package kabam.rotmg.messaging.impl.outgoing.market
{

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class MarketAdd extends OutgoingMessage
{
    public var slots_:Vector.<int>;
    public var price_:int;
    public var currency_:int;
    public var hours_:int;

    public function MarketAdd(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function writeToOutput(data:ByteArray) : void
    {
        data.writeByte(this.slots_.length);
        var i:int = 0;
        while (i < this.slots_.length)
        {
            data.writeByte(this.slots_[i]);
            i++;
        }
        data.writeInt(this.price_);
        data.writeInt(this.currency_);
        data.writeInt(this.hours_);
    }
}
}
