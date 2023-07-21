package thyrr.mail.signals {
import kabam.rotmg.messaging.impl.incoming.mail.FetchMailResult;

import org.osflash.signals.Signal;

public class FetchMailSignal extends Signal {

    public static var instance:FetchMailSignal;

    public function FetchMailSignal() {
        super(FetchMailResult);
        instance = this;
    }

}
}