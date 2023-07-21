package kabam.rotmg.messaging.impl.data
{
import com.company.assembleegameclient.util.FreeList;
import flash.utils.ByteArray;
import flash.utils.ByteArray;

public class ObjectStatusData
{
    public var objectId_:int;
    public var pos_:WorldPosData = new WorldPosData();
    public var stats_:Vector.<StatData> = new Vector.<StatData>();
    public var damageDealt:int;

    public function parseFromInput(data:ByteArray):void
    {
        var s:int;
        var len:int;
        try
        {
            s = 0;
            this.objectId_ = data.readInt();
            this.pos_.parseFromInput(data);
            len = data.readShort();
            s = len;
            while (s < this.stats_.length)
            {
                FreeList.deleteObject(this.stats_[s]);
                s = (s + 1);
            }
            this.stats_.length = Math.min(len, this.stats_.length);
            while (this.stats_.length < len)
            {
                this.stats_.push((FreeList.newObject(StatData) as StatData));
            }
            s = 0;
            while (s < len)
            {
                this.stats_[s].parseFromInput(data);
                s = (s + 1);
            }
            this.damageDealt = data.readInt();
        }
        catch(e:Error)
        {
        }
    }

    public function writeToOutput(_arg1:ByteArray):void
    {
        _arg1.writeInt(this.objectId_);
        this.pos_.writeToOutput(_arg1);
        _arg1.writeShort(this.stats_.length);
        var _local2:int;
        while (_local2 < this.stats_.length)
        {
            this.stats_[_local2].writeToOutput(_arg1);
            _local2++;
        }
        _arg1.writeInt(this.damageDealt);
    }

    public function toString():String
    {
        return "objectId_: " + objectId_ + " pos_: " + pos_ + " stats_: " + stats_ + " damageDealt: " + damageDealt;
    }


}
}