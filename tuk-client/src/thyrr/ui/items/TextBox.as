package thyrr.ui.items
{

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

import thyrr.utils.Utils;

public class TextBox extends FlexibleBox
{
    private const SIZE:int = 12;
    public var text_:TextFieldDisplayConcrete;
    private var textString_:String;
    private var size_:int;
    protected var baseWidth_:int;

    public function TextBox(width:int, height:int, text:String, size:int, texIndex:int = -1, color:uint = 0xAEA9A9, drawBottomLine:Boolean = true, texFile:String = "ui")
    {
        text_ = new TextFieldDisplayConcrete().setColor(0xffffff).setSize(size);
        text_.setStringBuilder(new LineBuilder().setParams(text == null ? "" : text));
        text_.filters = [Utils.OutlineFilter];
        text_.textChanged.add(onTextChanged);
        textString_ = text;
        size_ = size;
        baseWidth_ = width;
        super(width, height, color, texIndex, drawBottomLine, texFile);
    }

    public function setText(text:String, size:int, color:uint = 0xAEA9A9):void
    {
        if (text && text != textString_)
            this.text_.setStringBuilder(new LineBuilder().setParams(text)).setColor(color);
        if (size != size_)
            this.text_.setSize(size);

        textString_ = text;
        size_ = size;
        color_ = color;
        toggle(color, drawBottomLine_);
    }

    protected override function draw(yPlus:int, outline:int):void
    {
        super.draw(yPlus, outline);
        var xIncrease:int = 0;
        var sSize:int = width_ > height_ ? height_ / SIZE : width_ / SIZE;
        if (bitmap_ && text_)
        {
            xIncrease += bitmap_.width + 4;
            bitmap_.x = 2 * sSize;
            bitmap_.y = height_ / 2 - bitmap_.width / 2;
        }

        if (text_)
        {
            if (xIncrease > 0)
                text_.x = 2 * sSize + xIncrease;
            else
                text_.x = width_ / 2 - text_.width / 2;
            text_.y = height_ / 2 - text_.height / 2;
            if (!contains(text_))
                addChild(text_);
        }
    }

    private function onTextChanged():void
    {
        var sSize:int = width_ > height_ ? height_ / SIZE : width_ / SIZE;
        width_ += (text_.x + text_.width + 4 * sSize) - width_;
        if (width_ < baseWidth_)
            width_ = baseWidth_;
        text_.x = width_ / 2 - text_.width / 2;
        text_.y = height_ / 2 - text_.height / 2;
        if (bitmap_)
        {
            bitmap_.x = 2 * sSize;
            bitmap_.y = height_ / 2 - bitmap_.width / 2;
            text_.x = bitmap_.width + 4;
        }
        draw(0, outlineSize_);
    }
}
}
