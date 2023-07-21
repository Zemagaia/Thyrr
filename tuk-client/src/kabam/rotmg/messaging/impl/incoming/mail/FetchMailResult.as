package kabam.rotmg.messaging.impl.incoming.mail {

import com.company.assembleegameclient.util.FreeList;

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

import thyrr.mail.data.AccountMailsData;

public class FetchMailResult extends IncomingMessage {
    public var results_:Vector.<AccountMailsData>;
    public var description_:String;

    public function FetchMailResult(id:uint, callback:Function) {
        this.results_ = new Vector.<AccountMailsData>();
        super(id, callback);
    }

    override public function parseFromInput(data:ByteArray):void {
        var i:int;
        var len:int = data.readShort();
        i = len;
        while (i < this.results_.length) {
            FreeList.deleteObject(this.results_[i]);
            i++;
        }
        this.results_.length = Math.min(len, this.results_.length);
        while (this.results_.length < len) {
            this.results_.push(FreeList.newObject(AccountMailsData) as AccountMailsData);
        }
        i = 0;
        while (i < len) {
            this.results_[i].parseFromInput(data);
            i++;
        }
        this.description_ = data.readUTF();
    }
}
}
