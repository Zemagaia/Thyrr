package com.company.assembleegameclient.ui {
import com.company.util.GraphicsUtil;

import flash.display.GraphicsPath;
import flash.display.GraphicsPathWinding;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.Shape;

public class LineBreakDesign extends Shape {

    private var designFill_:GraphicsSolidFill = new GraphicsSolidFill(0xFFFFFF, 1);
    private var designPath_:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>(), GraphicsPathWinding.NON_ZERO);

    private const designGraphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[designFill_, designPath_, GraphicsUtil.END_FILL];

    public function LineBreakDesign(length:int, color:uint, vertical:Boolean = false) {
        super();
        this.setLengthColor(length, color, vertical);
    }

    public function setLengthColor(length:int, color:uint, vertical:Boolean):void {
        graphics.clear();
        this.designFill_.color = color;
        GraphicsUtil.clearPath(this.designPath_);
        GraphicsUtil.drawRect(0, -1, !vertical ? length : 2, vertical ? length : 2, this.designPath_);
        graphics.drawGraphicsData(this.designGraphicsData_);
    }


}
}
