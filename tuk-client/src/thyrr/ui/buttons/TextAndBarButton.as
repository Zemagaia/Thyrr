package thyrr.ui.buttons
{
import thyrr.utils.Utils;

public class TextAndBarButton extends TextButton
{
    private const SIZE:int = 12;
    private var centeredText_:Boolean;

    public function TextAndBarButton(width:int, height:int, text:String, size:int, texIndex:int = 0, color:uint = 0xAEA9A9,
                                     bottomLine:Boolean = true, textFile:String = "ui")
    {
        super(width, height, text, size, texIndex, color, bottomLine, textFile);
    }

    public function setCentered(centered:Boolean):void
    {
        centeredText_ = centered;
    }

    protected override function draw(yPlus:int, outline:int):void
    {
        super.draw(yPlus, outline);
        var sSize:int = width_ > height_ ? height_ / SIZE : width_ / SIZE;
        graphics.beginFill(color_);
        graphics.drawRect(11 * sSize, 0, 2 * sSize, height_);
        graphics.beginFill(Utils.color(color_, 1 / 1.3));
        graphics.drawRect(11 * sSize, 0, 2 * sSize, 1 * sSize);
        graphics.drawRect(11 * sSize, height_ - 1 * sSize, 2 * sSize, 1 * sSize);
        graphics.endFill();
        if (text_)
        {
            text_.x = 14 * sSize;
            var w:int = text_.x + text_.width + 4 * sSize;
            if (w < width_ && centeredText_)
                text_.x += (width_ - text_.x - 1 * sSize) / 2 - text_.width / 2;
        }
    }
}
}
