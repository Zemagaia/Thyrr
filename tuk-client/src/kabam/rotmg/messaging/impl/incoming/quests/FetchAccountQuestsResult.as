package kabam.rotmg.messaging.impl.incoming.quests {

import com.company.assembleegameclient.util.FreeList;
import com.company.util.ConversionUtil;

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

import thyrr.quests.data.AcceptedQuestData;

public class FetchAccountQuestsResult extends IncomingMessage {
    public var results_:Vector.<AcceptedQuestData>;
    public var description_:String;

    public function FetchAccountQuestsResult(id:uint, callback:Function) {
        this.results_ = new Vector.<AcceptedQuestData>();
        super(id, callback);
    }

    override public function parseFromInput(data:ByteArray):void {
        this.results_ = ConversionUtil.acceptedQuestDataFromBytes(data);
        this.description_ = data.readUTF();
    }
}
}
