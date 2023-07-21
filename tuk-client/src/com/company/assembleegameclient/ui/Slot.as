package com.company.assembleegameclient.ui
{
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.filters.ColorMatrixFilter;
import com.company.util.MoreColorUtil;
import flash.display.Bitmap;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import com.company.util.GraphicsUtil;
import flash.geom.Point;
import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.text.view.BitmapTextFactory;
import flash.display.BitmapData;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class Slot extends Sprite
{

    public static const IDENTITY_MATRIX:Matrix = new Matrix();
    public static const WIDTH:int = 40;
    public static const HEIGHT:int = 40;
    public static const BORDER:int = 4;
    private static const greyColorFilter:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.singleColorFilterMatrix(0x363636));

    public var type_:int;
    public var cuts_:Array;
    public var backgroundImage_:Bitmap;
    protected var fill_:GraphicsSolidFill = new GraphicsSolidFill(0x545454, 0);
    protected var path_:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
    private var graphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[fill_, path_, GraphicsUtil.END_FILL];

    public function Slot(_arg_1:int, _arg_2:int, _arg_3:Array)
    {
        this.type_ = _arg_1;
        this.cuts_ = _arg_3;
        this.drawBackground();
    }

    protected function drawBackground():void
    {
        GraphicsUtil.clearPath(this.path_);
        GraphicsUtil.drawCutEdgeRect(0, 0, WIDTH, HEIGHT, 4, this.cuts_, this.path_);
        graphics.clear();
        graphics.drawGraphicsData(this.graphicsData_);
        var _local_1:BitmapData = ItemConstants.itemTypeToBaseSprite(this.type_);
        if (this.backgroundImage_ == null)
        {
            if (_local_1 != null)
            {
                this.backgroundImage_ = new Bitmap(_local_1);
                this.backgroundImage_.x = (BORDER);
                this.backgroundImage_.y = (BORDER);
                this.backgroundImage_.scaleX = 4;
                this.backgroundImage_.scaleY = 4;
                this.backgroundImage_.filters = [greyColorFilter];
                addChild(this.backgroundImage_);
            }
        }
    }


}
}