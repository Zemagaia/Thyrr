package thyrr.ui.items
{

import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.ColorTransform;

import thyrr.ui.utils.UIElement;

import thyrr.utils.Utils;

public class Box extends UIElement
{
    private const SIZE:int = 12;
    private var color_:uint;
    private var bitmap_:Bitmap;
    private var scale_:int;
    private var texIndex_:int;
    private var texFile_:String;
    private var drawBottomLine_:Boolean;

    public function Box(scale:int = 2, color:uint = 0xAEA9A9, texIndex:int = 0, drawBottomLine:Boolean = true, texFile:String = "ui")
    {
        scale_ = scale <= 0 ? 1 : scale;
        color_ = color;
        texIndex_ = texIndex;
        drawBottomLine_ = drawBottomLine;
        texFile_ = texFile;
        draw();

        WebMain.STAGE.addEventListener(Event.RESIZE, onResize);
    }

    public function modify(color:uint, drawBottomLine:Boolean = true)
    {
        color_ = color;
        drawBottomLine_ = drawBottomLine;
        draw();
    }

    private function draw():void
    {
        var oColor:uint = color_;
        var tColor:uint = Utils.color(color_, 1 / 1.3);
        var s:int = SIZE * scale_;
        graphics.clear();
        // background
        graphics.beginFill(tColor);
        graphics.drawRect(0, 0, s, s);
        // outline
        graphics.beginFill(oColor);
        graphics.drawRect(1 * scale_, 0, s - 2 * scale_, 1 * scale_);
        graphics.drawRect(0, 1 * scale_, 1 * scale_, s - 2 * scale_);
        graphics.drawRect(1 * scale_, s - 1 * scale_, s - 2 * scale_, 1 * scale_);
        graphics.drawRect(s - 1 * scale_, 1 * scale_, 1 * scale_, s - 2 * scale_);
        graphics.endFill();
        // bottom line
        if (drawBottomLine_)
        {
            y -= 2 * scale_;
            graphics.beginFill(Utils.color(tColor, 1 / 1.3));
            graphics.drawRect(0, s, s, 2 * scale_);
            graphics.endFill();
        }
        else
        {
            y += 2 * scale_;
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
                bitmap_.scaleX = bitmap_.scaleY = scale_;
                bitmap_.x = 2 * scale_;
                bitmap_.y = 2 * scale_;
                addChild(bitmap_);
            }
        }
    }

    public override function dispose():void
    {
        if (this.bitmap_)
            this.bitmap_.bitmapData.dispose();
        WebMain.STAGE.removeEventListener(Event.RESIZE, onResize);
    }
}
}
