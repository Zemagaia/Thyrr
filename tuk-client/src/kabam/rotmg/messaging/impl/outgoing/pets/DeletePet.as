package kabam.rotmg.messaging.impl.outgoing.pets {

import flash.utils.ByteArray;

import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;

import thyrr.pets.data.PetData;

public class DeletePet extends OutgoingMessage {

    public var petData_:PetData;

    public function DeletePet(id:uint, callback:Function) {
        super(id, callback);
    }

    override public function writeToOutput(data:ByteArray):void {
        this.petData_.writeToOutput(data);
    }
}
}