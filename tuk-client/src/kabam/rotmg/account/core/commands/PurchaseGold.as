package kabam.rotmg.account.core.commands {
import com.company.assembleegameclient.util.offer.Offer;

import kabam.lib.tasks.DispatchFunctionTask;
import kabam.lib.tasks.TaskMonitor;
import kabam.lib.tasks.TaskSequence;
import kabam.rotmg.account.core.services.PurchaseGoldTask;

public class PurchaseGold
{
    public var monitor:TaskMonitor = Global.taskMonitor;

    public function PurchaseGold(offer:Offer, paymentMethod:String) {
        trace("purchasing gold");
        var sequence:TaskSequence = new TaskSequence();
        sequence.add(new PurchaseGoldTask(offer, paymentMethod));
        sequence.add(new DispatchFunctionTask(Global.closeDialogs));
        this.monitor.add(sequence);
        sequence.start();
    }
}
}
