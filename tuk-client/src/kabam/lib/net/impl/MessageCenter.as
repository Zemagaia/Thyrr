package kabam.lib.net.impl {

public class MessageCenter {

    private static const MAX_ID:int = 0x0100;

    private const maps:Vector.<MessageMapping> = new Vector.<MessageMapping>(MAX_ID, true);
    private const pools:Vector.<MessagePool> = new Vector.<MessagePool>(MAX_ID, true);

    public function map(_arg1:int):MessageMapping {
        return ((this.maps[_arg1] = ((this.maps[_arg1]) || (this.makeMapping(_arg1)))));
    }

    public function unmap(_arg1:int):void {
        ((this.pools[_arg1]) && (this.pools[_arg1].dispose()));
        this.pools[_arg1] = null;
        this.maps[_arg1] = null;
    }

    private function makeMapping(_arg1:int):MessageMapping {
        return new MessageMapping().setID(_arg1) as MessageMapping;
    }

    public function require(_arg1:int):Message {
        var _local2:MessagePool = (this.pools[_arg1] = ((this.pools[_arg1]) || (this.makePool(_arg1))));
        return (_local2.require());
    }

    private function makePool(_arg1:uint):MessagePool {
        var _local2:MessageMapping = this.maps[_arg1];
        return (((_local2) ? _local2.makePool() : null));
    }


}
}
