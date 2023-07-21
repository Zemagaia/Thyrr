package kabam.rotmg.ui.model {
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.osflash.signals.Signal;

public class PotionModel {

    public var objectId:uint;
    private var _costs:Array;
    private var _priceCooldownMillis:uint;
    public var _purchaseCooldownMillis:uint;
    public var maxPotionCount:int;
    public var position:int;
    public var available:Boolean;
    private var costIndex:int;
    private var costCoolDownTimer:Timer;
    private var purchaseCoolDownTimer:Timer;
    public var update:Signal;

    public function PotionModel() {
        this.update = new Signal(int);
        this.available = true;
    }

    public function set costs(_arg1:Array):void {
        this._costs = _arg1;
        if (((!((_arg1 == null))) && ((_arg1.length > 0)))) {
            this.costIndex = 0;
        }
    }

    public function get costs():Array {
        return (this._costs);
    }

    public function set priceCooldownMillis(_arg1:uint):void {
        this._priceCooldownMillis = _arg1;
        this.costCoolDownTimer = new Timer(_arg1, 0);
        this.costCoolDownTimer.addEventListener(TimerEvent.TIMER, coolDownPrice);
    }

    public function set purchaseCooldownMillis(_arg1:uint):void {
        this._purchaseCooldownMillis = _arg1;
        this.purchaseCoolDownTimer = new Timer(_arg1, 0);
        this.purchaseCoolDownTimer.addEventListener(TimerEvent.TIMER, coolDownPurchase);
    }

    public function purchasedPot():void {
        if (this.available) {
            this.costCoolDownTimer.reset();
            this.costCoolDownTimer.start();
            this.purchaseCoolDownTimer.reset();
            this.purchaseCoolDownTimer.start();
            this.available = false;
            if (this.costIndex < (this.costs.length - 1)) {
                this.costIndex++;
            }
            this.update.dispatch(this.position);
        }
    }

    private function coolDownPurchase(_arg1:TimerEvent):void {
        if (this.costIndex == 0) {
            this.purchaseCoolDownTimer.stop();
        }
        this.available = true;
        this.update.dispatch(this.position);
    }

    private function coolDownPrice(_arg1:TimerEvent):void {
        this.costIndex--;
        if (this.costIndex == 0) {
            this.costCoolDownTimer.stop();
        }
        this.update.dispatch(this.position);
    }


}
}
