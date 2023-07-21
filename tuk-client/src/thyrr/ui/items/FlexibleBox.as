package thyrr.ui.items
{

import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.ColorTransform;

import thyrr.ui.utils.UIElement;

import thyrr.utils.Utils;

public class FlexibleBox extends UIElement
{
    private const SIZE:int = 12;
    public var origColor_:uint;
    protected var color_:uint;
    protected var bitmap_:Bitmap;
    protected var width_:int;
    protected var height_:int;
    protected var texIndex_:int;
    protected var texFile_:String;
    protected var drawBottomLine_:Boolean;
    protected var toggleBottomLine_:Boolean;
    protected var outline_:int;

    public function FlexibleBox(width:int, height:int, color:uint = 0xAEA9A9, texIndex:int = 0, drawBottomLine:Boolean = true, texFile:String = "ui", outline:int = -1)
    {
        width_ = width;
        height_ = height;
        origColor_ = color_ = color;
        texIndex_ = texIndex;
        toggleBottomLine_ = drawBottomLine_ = drawBottomLine;
        texFile_ = texFile;
        outline_ = outline;
        draw(2, outline);
    }

    public function modify(width:int, height:int, outline:int = -1):void
    {
        width_ = width;
        height_ = height;
        outline_ = outline;
        draw(0, outline_);
    }

    public function toggle(color:uint, bottomLine:Boolean = true, yPlus:int = 2):void
    {
        color_ = color;
        toggleBottomLine_ = bottomLine;
        draw(yPlus, outline_);
    }

    protected function draw(yPlus:int, outline:int):void
    {
        var oColor:uint = color_ == Utils.color(0xaea9a9, 1/1.3) ? 0xaea9a9 : color_;
        var tColor:uint = Utils.color(color_, 1 / 1.3);
        var sSize:int = (width_ > height_ ? height_ : width_) / SIZE;
        if (outline > 0)
            sSize = outline;
        graphics.clear();
        // background
        graphics.beginFill(tColor);
        graphics.drawRect(0, 0, width_, height_);
        // outline
        graphics.beginFill(oColor);
        graphics.drawRect(sSize, 0, width_ - 2 * sSize, sSize);
        graphics.drawRect(0, sSize, sSize, height_ - 2 * sSize);
        graphics.drawRect(sSize, height_ - sSize, width_ - 2 * sSize, sSize);
        graphics.drawRect(width_ - sSize, sSize, sSize, height_ - 2 * sSize);
        graphics.endFill();
        // bottom line
        if (drawBottomLine_)
        {
            if (toggleBottomLine_)
            {
                graphics.beginFill(Utils.color(tColor, 1 / 1.3));
                graphics.drawRect(0, height_, width_, 2 * sSize);
                graphics.endFill();
                y -= yPlus * sSize;
            }
            else
            {
                y += yPlus * sSize;
            }
        }

        if (texFile_ && texIndex_ >= 0)
        {
            if (bitmap_)
            {
                bitmap_.bitmapData.dispose();
                removeChild(bitmap_);
            }

            var data:BitmapData = AssetLibrary.getImageFromSet(texFile_, texIndex_).clone();
            if (data)
            {
                bitmap_ = new Bitmap(data);
                bitmap_.transform.colorTransform = new ColorTransform(((oColor & 0xff0000) >> 16) / 255,
                        ((oColor & 0x00ff00) >> 8) / 255, ((oColor & 0x0000ff) >> 0) / 255);
                bitmap_.scaleX = bitmap_.scaleY = sSize;
                bitmap_.x = width_ / 2 - bitmap_.width / 2;
                bitmap_.y = height_ / 2 - bitmap_.height / 2;
                addChild(bitmap_);
            }
        }
    }

    public override function dispose():void
    {
        if (this.bitmap_)
            this.bitmap_.bitmapData.dispose();
    }
}
}
