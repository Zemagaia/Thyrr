package thyrr.oldui {
import com.company.util.GraphicsUtil;

import flash.display.GraphicsPath;
import flash.display.GraphicsPathWinding;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.Sprite;
import flash.geom.ColorTransform;

public class DefaultArrow extends Sprite {

    private var designFill_:GraphicsSolidFill = new GraphicsSolidFill(0xFFFFFF, 1);
    private var designPath_:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>(), GraphicsPathWinding.NON_ZERO);

    private const designGraphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[designFill_, designPath_, GraphicsUtil.END_FILL];

    public function DefaultArrow(lineWidth:int = 24, lineHeight:int = 19) {
        super();
        this.recolorAndResize(0x666666, lineWidth, lineHeight);
    }

    public function recolorAndResize(color:uint, lineWidth:Number, lineHeight:Number):void {
        graphics.clear();
        GraphicsUtil.clearPath(this.designPath_);
        this.designFill_.color = color;
        this.drawArrow(lineWidth, lineHeight);
        GraphicsUtil.drawRect(lineWidth, lineHeight / 1.2, lineWidth, lineHeight / 2, this.designPath_);
        graphics.drawGraphicsData(this.designGraphicsData_);
    }

    public function highlight(_arg1:Boolean):void {
        var _local2:ColorTransform = transform.colorTransform;
        _local2.color = ((_arg1) ? 16777103 : 0x545454);
        transform.colorTransform = _local2;
    }

    private function drawArrow(lineWidth:Number, lineHeight:Number):void {
        this.designPath_.moveTo(0, lineHeight);
        this.designPath_.lineTo(lineWidth, 0);
        this.designPath_.lineTo(lineWidth, lineHeight * 2);
        this.designPath_.lineTo(0, lineHeight);
        graphics.drawGraphicsData(this.designGraphicsData_);
    }


}
}
