package thyrr.ui.buttons
{

import flash.events.MouseEvent;

import org.osflash.signals.Signal;

import thyrr.ui.items.FlexibleBox;
import thyrr.ui.interfaces.IButton;
import thyrr.utils.Utils;

public class HoldableButton extends FlexibleBox implements IButton
{
    public var clicked:Signal;
    private var selected_:Boolean;
    public var changeColorOnToggle:Boolean = true;

    public function HoldableButton(width:int, height:int, color:uint = 0xAEA9A9, texIndex:int = 0, bottomLine:Boolean = true)
    {
        clicked = new Signal();
        super(width, height, color, texIndex, bottomLine);

        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.ROLL_OUT, onRollOut);
    }

    public function setSelected(selected:Boolean, drawBottomLine:Boolean = false):void
    {
        if (!changeColorOnToggle) return;
        var color:uint = selected && origColor_ == 0xAEA9A9 ? Utils.color(origColor_, 1.3) : origColor_;
        toggle(color, !selected);
    }

    private function onMouseDown(e:MouseEvent):void
    {
        clicked.dispatch();
        setSelected(selected_ = true);
    }

    private function onMouseUp(e:MouseEvent):void
    {
        if (selected_)
            setSelected(selected_ = false);
    }

    private function onRollOut(e:MouseEvent):void
    {
        if (selected_)
            setSelected(selected_ = false);
    }

    public override function dispose():void
    {
        removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
        super.dispose();
    }
}
}
