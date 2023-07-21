package com.company.assembleegameclient.map.partyoverlay {
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.objects.GameObject;

public class QuestArrow extends GameObjectArrow {

    public var map_:Map;

    public function QuestArrow(map:Map) {
        super(16352321, 12919330, true);
        this.map_ = map;
    }

    override public function draw(_arg1:int, _arg2:Camera):void {
        var _local3:GameObject = this.map_.quest_.getObject(_arg1);
        if (_local3 != go_) {
            setGameObject(_local3);
        }
        super.draw(_arg1, _arg2);
    }


}
}
