package thyrr.mail.data {
import flash.utils.ByteArray;

public class AccountMailsData {
    public var id_:int;
    public var addTime_:int;
    public var endTime_:int;
    public var characterId_:int;
    public var priority_:int;
    public var content_:String;

    public function AccountMailsData() {
        super();
    }

    public function parseFromInput(data:ByteArray) : void
    {
        this.id_ = data.readInt();
        this.addTime_ = data.readInt();
        this.endTime_ = data.readInt();
        this.characterId_ = data.readInt();
        this.priority_ = data.readInt();
        this.content_ = data.readUTF();
    }

}
}