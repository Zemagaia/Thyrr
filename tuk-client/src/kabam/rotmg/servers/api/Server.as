package kabam.rotmg.servers.api {
public class Server {

    public var name:String;
    public var address:String;
    public var port:int;
    public var latLong:LatLong;
    public var usage:int;
    public var maxPlayers:int;
    public var isAdminOnly:Boolean;


    public function setName(_arg1:String):Server {
        this.name = _arg1;
        return (this);
    }

    public function setAddress(_arg1:String):Server {
        this.address = _arg1;
        return (this);
    }

    public function setPort(_arg1:int):Server {
        this.port = _arg1;
        return (this);
    }

    public function setLatLong(_arg1:Number, _arg2:Number):Server {
        this.latLong = new LatLong(_arg1, _arg2);
        return (this);
    }

    public function setUsage(_arg1:int):Server {
        this.usage = _arg1;
        return (this);
    }

    public function setMaxPlayers(_arg1:int):Server {
        this.maxPlayers = _arg1;
        return (this);
    }

    public function setIsAdminOnly(_arg1:Boolean):Server {
        this.isAdminOnly = _arg1;
        return (this);
    }

    public function priority():int {
        if (this.isAdminOnly) {
            return (2);
        }
        if (this.isCrowded()) {
            return (1);
        }
        return (0);
    }

    public function isCrowded():Boolean {
        return (this.usage > this.maxPlayers * 0.66);
    }

    public function isFull():Boolean {
        return (this.usage >= this.maxPlayers);
    }

    /*public function toString():String {
        return ((((((((((((("[" + this.name) + ": ") + this.address) + ":") + this.port) + ":") + this.latLong) + ":") + this.usage) + ":") + this.isAdminOnly) + "]"));
    }*/


}
}
