package kabam.rotmg.messaging.impl.incoming.market
{

import com.company.assembleegameclient.util.FreeList;

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.data.MarketData;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

public class MarketSearchResult  extends IncomingMessage
{
    public var results_:Vector.<MarketData>;
    public var description_:String;

    public function MarketSearchResult(id:uint, callback:Function)
    {
        this.results_ = new Vector.<MarketData>();
        super(id,callback);
    }

    override public function parseFromInput(data:ByteArray) : void
    {
        var i:int = 0;
        var len:int = data.readShort();
        while ((i = len) < this.results_.length)
        {
            FreeList.deleteObject(this.results_[i]);
            i++;
        }
        this.results_.length = Math.min(len,this.results_.length);
        while(this.results_.length < len)
        {
            this.results_.push(FreeList.newObject(MarketData) as MarketData);
        }
        while ((i = 0) < len)
        {
            this.results_[i].parseFromInput(data);
            i++;
        }
        this.description_ = data.readUTF();
    }
}
}
