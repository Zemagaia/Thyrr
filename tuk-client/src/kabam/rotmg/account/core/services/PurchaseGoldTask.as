package kabam.rotmg.account.core.services {
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.PaymentMethod;
import com.company.assembleegameclient.util.offer.Offer;
import com.company.assembleegameclient.util.offer.Offers;

import flash.net.URLRequest;

import flash.net.navigateToURL;

import kabam.lib.tasks.BaseTask;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.model.OfferModel;

public class PurchaseGoldTask extends BaseTask {

    public var account:Account = Global.account;
    public var offer:Offer;
    public var offersModel:OfferModel = Global.offerModel;
    public var paymentMethod:String;

    public function PurchaseGoldTask(offer:Offer, paymentMethod:String)
    {
        this.offer = offer;
        this.paymentMethod = paymentMethod;
    }

    override protected function startTask():void {
        Parameters.data_.paymentMethod = this.paymentMethod;
        Parameters.save();
        var _local1:Offers = this.offersModel.offers;
        var _local2:PaymentMethod = PaymentMethod.getPaymentMethodByLabel(this.paymentMethod);
        var _local3:String = _local2.getURL(_local1.tok, _local1.exp, this.offer);
        navigateToURL(new URLRequest(_local3), "_blank");
        completeTask(true);
    }

}
}
