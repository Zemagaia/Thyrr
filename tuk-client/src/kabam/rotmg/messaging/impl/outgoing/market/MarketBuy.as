package kabam.rotmg.messaging.impl.outgoing.market
{

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class MarketBuy extends OutgoingMessage
{
    public var id_:int;

    public function MarketBuy(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function writeToOutput(data:ByteArray) : void
    {
        data.writeInt(this.id_);
    }
}
}
