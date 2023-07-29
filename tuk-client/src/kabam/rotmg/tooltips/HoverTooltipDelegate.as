package kabam.rotmg.tooltips {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class HoverTooltipDelegate {

    public var tooltip:Sprite;
    private var displayObject:DisplayObject;

    public function setDisplayObject(_arg1:DisplayObject):void {
        this.displayObject = _arg1;
        this.displayObject.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        this.displayObject.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        this.displayObject.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    public function removeDisplayObject():void {
        if (this.displayObject != null) {
            this.displayObject.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
            this.displayObject.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            this.displayObject.removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
            this.displayObject = null;
        }
    }

    public function getDisplayObject():DisplayObject {
        return (this.displayObject);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        if (((!((this.tooltip == null))) && (!((this.tooltip.parent == null))))) {
            Global.hideTooltip();
        }
        this.displayObject.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        this.displayObject.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        this.displayObject.removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function onMouseOut(_arg1:MouseEvent):void {
        Global.hideTooltip();
    }

    private function onMouseOver(_arg1:MouseEvent):void {
        Global.showTooltip(this.tooltip);
    }


}
}
