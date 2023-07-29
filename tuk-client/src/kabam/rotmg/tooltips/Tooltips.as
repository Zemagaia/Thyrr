package kabam.rotmg.tooltips
{

import flash.display.DisplayObject;
import flash.display.Sprite;

public class Tooltips extends Sprite
{
    private var toolTip:DisplayObject;

    public function showTooltip(obj:DisplayObject):void
    {
        this.hideTooltip();
        this.toolTip = obj;
        if (obj != null)
            addChild(obj);
    }

    public function hideTooltip():void
    {
        if (this.toolTip != null && this.toolTip.parent != null)
            this.toolTip.parent.removeChild(this.toolTip);
        this.toolTip = null;
    }
}
}