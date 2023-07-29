package kabam.rotmg.core.view {
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import kabam.rotmg.dialogs.Dialogs;
import kabam.rotmg.tooltips.Tooltips;

public class Layers extends Sprite {

    public var menu:ScreensView;
    public var overlay:DisplayObjectContainer;
    public var tooltips:Tooltips;
    public var top:DisplayObjectContainer;
    public var mouseDisabledTop:DisplayObjectContainer;
    public var dialogs:Dialogs;
    public var api:DisplayObjectContainer;
    public var console:DisplayObjectContainer;

    public function Layers() {
        addChild((this.menu = new ScreensView()));
        addChild((this.overlay = new Sprite()));
        addChild((this.top = new Sprite()));
        addChild((this.mouseDisabledTop = new Sprite()));
        this.mouseDisabledTop.mouseEnabled = false;
        addChild((this.dialogs = new Dialogs()));
        addChild((this.tooltips = new Tooltips()));
        addChild((this.api = new Sprite()));
        addChild((this.console = new Sprite()));
    }

}
}
