package thyrr.ui.buttons
{

import flash.events.MouseEvent;

import thyrr.ui.items.FlexibleBox;
import thyrr.ui.interfaces.IButton;
import thyrr.utils.Utils;

public class ToggleableButton extends FlexibleBox implements IButton
{
    protected var selected_:Boolean;

    public function ToggleableButton(width:int, height:int, color:uint = 0xAEA9A9, texIndex:int = 0, bottomLine:Boolean = true)
    {
        super(width, height, color, texIndex, bottomLine);

        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    public function setSelected(selected:Boolean, drawBottomLine:Boolean = false):void
    {
        var color:uint = selected && origColor_ == 0xAEA9A9 ? Utils.color(origColor_, 1.3) : origColor_;
        toggle(color, drawBottomLine ? true : !selected, int(!drawBottomLine) * 2);
    }

    private function onMouseDown(e:MouseEvent):void
    {
        setSelected(selected_ = !selected_);
    }

    public function removeListeners():void
    {
        if (hasEventListener(MouseEvent.MOUSE_DOWN))
            removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    public override function dispose():void
    {
        removeListeners();
        super.dispose();
    }
}
}
