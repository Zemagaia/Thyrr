package kabam.rotmg.messaging.impl.incoming.quests {

import com.company.assembleegameclient.util.FreeList;
import com.company.util.ConversionUtil;

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

import thyrr.quests.data.QuestData;

public class FetchAvailableQuestsResult extends IncomingMessage {
    public var results_:Vector.<QuestData>;
    public var description_:String;

    public function FetchAvailableQuestsResult(id:uint, callback:Function) {
        this.results_ = new Vector.<QuestData>();
        super(id, callback);
    }

    override public function parseFromInput(data:ByteArray):void {
        this.results_ = ConversionUtil.questDataFromBytes(data);
        this.description_ = data.readUTF();
    }
}
}
