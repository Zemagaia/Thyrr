package thyrr.utils
{

import flash.utils.ByteArray;

public class ItemData
{

    public var ObjectType:int = -1;
    public var Soulbound:Boolean = false;
    public var Quality:Number = 0;
    public var Quantity:int = 0;
    public var MaxQuantity:int = 0;
    public var Runes:Vector.<int> = null;
    public var DamageBoosts:Vector.<int> = null;
    public var StatBoosts:Vector.<Object> = null;
    public var TexFile:String = null;
    public var TexIndex:int = 0;
    public var MaskFile:String = null;
    public var MaskIndex:int = 0;
    public var Tex1:int = 0;
    public var Tex2:int = 0;

    public function ItemData(data:ByteArray)
    {
        if (data == null)
            return;

        data.endian = "littleEndian";
        var key:uint = data.readUnsignedInt();
        var key2:uint = data.readUnsignedInt();
        var i:int;
        var j:int;
        var len:int;
        ObjectType = data.readUnsignedShort();
        if (ObjectType == 0xFFFF) ObjectType = -1;
        i = 0;
        while (i < 32)
        {
            if ((key & 1 << i) == 0)
            {
                i++;
                continue;
            }
            switch (i)
            {
                case 1:
                    Soulbound = data.readBoolean();
                    break;
                case 2:
                    Quality = data.readFloat();
                    break;
                case 3:
                    Quantity = data.readInt();
                    break;
                case 4:
                    MaxQuantity = data.readInt();
                    break;
                case 5:
                    len = data.readShort();
                    Runes = new Vector.<int>(len);
                    j = 0;
                    while (j < len)
                    {
                        Runes[j] = data.readUnsignedShort();
                        j++;
                    }
                    break;
                case 6:
                    len = data.readShort();
                    DamageBoosts = new Vector.<int>(len);
                    j = 0;
                    while (j < len)
                    {
                        DamageBoosts[j] = data.readInt();
                        j++;
                    }
                    break;
                case 7:
                    len = data.readShort();
                    StatBoosts = new Vector.<Object>(len);
                    j = 0;
                    while (j < len)
                    {
                        StatBoosts[j] = {"Key": data.readByte(), "Value": data.readShort()};
                        j++;
                    }
                    break;
                case 8:
                    TexFile = data.readUTF();
                    break;
                case 9:
                    TexIndex = data.readInt();
                    break;
                case 10:
                    MaskFile = data.readUTF();
                    break;
                case 11:
                    MaskIndex = data.readInt();
                    break;
                case 12:
                    Tex1 = data.readInt();
                    break;
                case 13:
                    Tex2 = data.readInt();
                    break;
            }
            i++;
        }
    }
}
}