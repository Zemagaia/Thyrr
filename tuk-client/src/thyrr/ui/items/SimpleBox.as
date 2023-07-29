package thyrr.ui.items
{

import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.ColorTransform;

import thyrr.ui.utils.UIElement;

import thyrr.utils.Utils;

public class SimpleBox extends UIElement
{
    private const SIZE:int = 12;
    public var origColor_:uint;
    protected var color_:int;
    protected var bitmap_:Bitmap;
    protected var width_:int;
    protected var height_:int;
    protected var texIndex_:int;
    protected var texFile_:String;
    protected var outlineColor_:int = -1;

    public function SimpleBox(width:int, height:int, color:uint = 0xAEA9A9, texIndex:int = -1, texFile:String = "ui")
    {
        width_ = width;
        height_ = height;
        origColor_ = color_ = color;
        if (color == 0x807D7D)
            outlineColor_ = 0xaea9a9;
        texIndex_ = texIndex;
        texFile_ = texFile;
        draw();
    }

    public function setOutline(color:int):SimpleBox
    {
        outlineColor_ = color;
        draw();
        return this;
    }

    public function modify(width:int, height:int):void
    {
        width_ = width;
        height_ = height;
        draw();
    }

    public function toggle(color:uint):void
    {
        color_ = color;
        draw();
    }

    protected function draw():void
    {
        var oColor:uint = outlineColor_;
        var tColor:uint = color_;
        var sSize:int = Math.min((width_ > height_ ? height_ : width_) / SIZE, 2);
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
