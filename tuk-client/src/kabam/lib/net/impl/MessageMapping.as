package kabam.lib.net.impl {
import kabam.lib.net.api.*;
import kabam.lib.net.impl.MessagePool;
import kabam.lib.net.impl.MethodHandlerProxy;

public class MessageMapping {

    private const nullHandler:NullHandlerProxy = new NullHandlerProxy();

    private var id:int;
    private var messageType:Class;
    private var population:int = 1;
    private var handler:MessageHandlerProxy;

    public function MessageMapping() {
        this.handler = this.nullHandler;
    }

    public function setID(_arg1:int):MessageMapping {
        this.id = _arg1;
        return (this);
    }

    public function toMessage(_arg1:Class):MessageMapping {
        this.messageType = _arg1;
        return (this);
    }

    public function toMethod(_arg1:Function):MessageMapping {
        this.handler = new MethodHandlerProxy().setMethod(_arg1);
        return (this);
    }

    public function setPopulation(_arg1:int):MessageMapping {
        this.population = _arg1;
        return (this);
    }

    public function makePool():MessagePool {
        var _local1:MessagePool = new MessagePool(this.id, this.messageType, this.handler.getMethod());
        _local1.populate(this.population);
        return (_local1);
    }


}
}

import kabam.lib.net.api.MessageHandlerProxy;

class NullHandlerProxy implements MessageHandlerProxy {


    public function getMethod():Function {
        return (null);
    }


}

