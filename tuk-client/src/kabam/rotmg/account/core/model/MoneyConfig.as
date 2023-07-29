package kabam.rotmg.account.core.model {
import com.company.assembleegameclient.util.offer.Offer;

import kabam.rotmg.text.view.stringBuilder.LineBuilder;

import kabam.rotmg.text.view.stringBuilder.StringBuilder;

public class MoneyConfig {

    public function showPaymentMethods():Boolean {
        return (true);
    }

    public function showBonuses():Boolean {
        return (true);
    }

    public function parseOfferPrice(_arg1:Offer):StringBuilder {
        return (new LineBuilder().setParams("${cost}", {"cost": _arg1.price_}));
    }

    public function jsInitializeFunction():String {
        return ("rotmg.KabamPayment.setupRotmgAccount");
    }

}
}
