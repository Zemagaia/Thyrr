package thyrr.quests.data
{

import com.company.util.ConversionUtil;

import flash.utils.ByteArray;

import thyrr.utils.ItemData;

public class AcceptedQuestData
{

    public var id_:int;
    public var addTime_:int;
    public var endTime_:int;
    public var icon_:int;
    public var title_:String;
    public var description_:String = "";
    public var rewards_:Vector.<int>;
    public var slay_:Vector.<int>;
    public var slayAmounts_:Vector.<int>;
    public var dungeons_:Vector.<String>;
    public var dungeonAmounts_:Vector.<int>;
    public var experience_:int;
    public var expReward_:int;
    public var deliver_:Vector.<int>;
    public var deliverDatas_:Vector.<ItemData>;
    public var scout_:String;
    public var dungsCompleted_:Vector.<int>;
    public var slainAmounts_:Vector.<int>;
    public var expGained_:int;
    public var delivered_:Vector.<int>;
    public var scouted_:Boolean;
    public var dailyQuest_:Boolean;

    public function AcceptedQuestData(data:ByteArray)
    {
        this.rewards_ = new Vector.<int>();
        this.slay_ = new Vector.<int>();
        this.slayAmounts_ = new Vector.<int>();
        this.dungeons_ = new Vector.<String>();
        this.dungeonAmounts_ = new Vector.<int>();
        this.deliver_ = new Vector.<int>();
        this.deliverDatas_ = new Vector.<ItemData>();
        this.dungsCompleted_ = new Vector.<int>();
        this.slainAmounts_ = new Vector.<int>();
        this.delivered_ = new Vector.<int>();
        var i:int;
        var j:int;
        var len:int;
        var key:uint = data.readUnsignedInt();
        var key2:uint = data.readUnsignedInt();
        i = 0;
        while (i < 32)
        {
            if ((key & 1 << i) == 0)
            {
                i++;
                continue;
            }
            j = 0;
            switch (i)
            {
                case 0:
                    this.id_ = data.readInt();
                    break;
                case 1:
                    this.addTime_ = data.readInt();
                    break;
                case 2:
                    this.endTime_ = data.readInt();
                    break;
                case 3:
                    this.icon_ = data.readByte();
                    break;
                case 4:
                    this.title_ = data.readUTF();
                    break;
                case 5:
                    this.description_ = data.readUTF();
                    break;
                case 6:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.rewards_.push(data.readUnsignedShort());
                        j++;
                    }
                    break;
                case 7:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.slay_.push(data.readUnsignedShort());
                        j++;
                    }
                    break;
                case 8:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.slayAmounts_.push(data.readInt());
                        j++;
                    }
                    break;
                case 9:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.dungeons_.push(data.readUTF());
                        j++;
                    }
                    break;
                case 10:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.dungeonAmounts_.push(data.readInt());
                        j++;
                    }
                    break;
                case 11:
                    this.experience_ = data.readInt();
                    break;
                case 12:
                    this.expReward_ = data.readInt();
                    break;
                case 13:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.deliver_.push(data.readUnsignedShort());
                        j++;
                    }
                    break;
                case 14:
                    this.deliverDatas_ = ConversionUtil.itemDataFromBytes(data);
                    break;
                case 15:
                    this.scout_ = data.readUTF();
                    break;
                case 16:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.slainAmounts_.push(data.readInt());
                        j++;
                    }
                    break;
                case 17:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.dungsCompleted_.push(data.readUnsignedShort());
                        j++;
                    }
                    break;
                case 18:
                    this.expGained_ = data.readInt();
                    break;
                case 19:
                    len = data.readShort();
                    while (j < len)
                    {
                        this.delivered_.push(data.readBoolean());
                        j++;
                    }
                    break;
                case 20:
                    this.scouted_ = data.readBoolean();
                    break;
                case 21:
                    this.dailyQuest_ = data.readBoolean();
                    break;
                    // 31 reserved
            }
            i++;
        }
    }

}
}