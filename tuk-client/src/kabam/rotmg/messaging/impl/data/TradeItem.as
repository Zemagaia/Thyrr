package kabam.rotmg.messaging.impl.data {
import flash.utils.ByteArray;

import thyrr.utils.ItemData;

import thyrr.utils.ItemData;

public class TradeItem {

    public var itemData_:ItemData;
    public var slotType_:int;
    public var tradeable_:Boolean;
    public var included_:Boolean;


    public function parseFromInput(_arg1:ByteArray):void {
        this.itemData_ = new ItemData(_arg1);
        this.slotType_ = _arg1.readInt();
        this.tradeable_ = _arg1.readBoolean();
        this.included_ = _arg1.readBoolean();
    }

    public function toString():String {
        return "itemData: " + this.itemData_ + " slotType: " + this.slotType_ + " tradeable: " + this.tradeable_ + " included:" + this.included_;
    }


}
}
