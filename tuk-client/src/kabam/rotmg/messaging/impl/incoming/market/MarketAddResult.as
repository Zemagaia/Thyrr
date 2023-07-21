package kabam.rotmg.messaging.impl.incoming.market
{

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

public class MarketAddResult  extends IncomingMessage
{
    public var code_:int;
    public var description_:String;

    public function MarketAddResult(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function parseFromInput(data:ByteArray) : void
    {
        this.code_ = data.readInt();
        this.description_ = data.readUTF();
    }
}
}
