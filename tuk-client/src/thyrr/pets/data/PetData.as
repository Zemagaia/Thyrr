package thyrr.pets.data
{
import flash.utils.ByteArray;

public class PetData
{
    public var Id:int;
    public var ObjectType:int;

    public function PetData(data:ByteArray)
    {
        if (data == null)
            return;

        data.endian = "littleEndian";
        Id = data.readInt();
        ObjectType = data.readUnsignedShort();
    }

    public function writeToOutput(data:ByteArray):void
    {
        data.writeInt(Id);
        data.writeInt(ObjectType);
    }
}
}
