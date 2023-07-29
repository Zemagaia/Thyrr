package thyrr.ui.buttons
{

import flash.events.MouseEvent;

import org.osflash.signals.Signal;

import thyrr.ui.items.FlexibleBox;
import thyrr.ui.interfaces.IButton;
import thyrr.ui.items.TextBox;
import thyrr.utils.Utils;

public class TextButton extends TextBox implements IButton
{
    public var clicked:Signal;
    private var selected_:Boolean;

    public function TextButton(width:int, height:int, text:String, size:int, texIndex:int = 0, color:uint = 0xAEA9A9,
                               bottomLine:Boolean = true, textFile:String = "ui")
    {
        clicked = new Signal();
        super(width, height, text, size, texIndex, color, bottomLine, textFile);

        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.ROLL_OUT, onRollOut);
    }

    public function setSelected(selected:Boolean, drawBottomLine:Boolean = false):void
    {
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
