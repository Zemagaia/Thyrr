package kabam.rotmg.messaging.impl.incoming.pets {

import com.company.util.ConversionUtil;

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.incoming.IncomingMessage;

import thyrr.pets.data.PetData;

public class FetchPetsResult extends IncomingMessage {
    public var petDatas_:Vector.<PetData>;
    public var description_:String;

    public function FetchPetsResult(id:uint, callback:Function) {
        super(id, callback);
    }

    override public function parseFromInput(data:ByteArray):void {
        this.petDatas_ = ConversionUtil.petDataFromBytes(data);
        this.description_ = data.readUTF();
    }
}
}
