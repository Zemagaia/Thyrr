package kabam.rotmg.messaging.impl.outgoing.market
{

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

public class MarketMyOffers extends OutgoingMessage
{

    public function MarketMyOffers(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function writeToOutput(data:ByteArray) : void
    {
    }
}
}
