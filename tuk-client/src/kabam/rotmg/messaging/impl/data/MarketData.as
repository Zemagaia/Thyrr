package kabam.rotmg.messaging.impl.data
{
   import flash.utils.ByteArray;

import thyrr.utils.ItemData;

import thyrr.utils.ItemData;

public class MarketData
   {
      public var id_:int;
      public var itemData_:ItemData;
      public var sellerName_:String;
      public var sellerId_:int;
      public var currency_:int;
      public var price_:int;
      public var startTime_:int;
      public var timeLeft_:int;

      public function MarketData()
      {
         super();
      }
      
      public function parseFromInput(data:ByteArray) : void
      {
         this.id_ = data.readInt();
         this.itemData_ = new ItemData(data);
         this.sellerName_ = data.readUTF();
         this.sellerId_ = data.readInt();
         this.currency_ = data.readInt();
         this.price_ = data.readInt();
         this.startTime_ = data.readInt();
         this.timeLeft_ = data.readInt();
      }
   }
}
