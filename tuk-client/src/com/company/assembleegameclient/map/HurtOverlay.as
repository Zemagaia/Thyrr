package com.company.assembleegameclient.map {
import com.company.util.GraphicsUtil;

import flash.display.GradientType;
import flash.display.GraphicsGradientFill;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import flash.display.Shape;

public class HurtOverlay extends Shape {

    private const s:Number = (Main.DefaultHeight / Math.sin((Math.PI / 4)));
    private const gradientFill_:GraphicsGradientFill = new GraphicsGradientFill(GradientType.RADIAL, [0xFFFFFF, 0xFFFFFF, 0xFFFFFF], [0, 0, 0.92], [0, 155, 0xFF], GraphicsUtil.getGradientMatrix(s, s, 0, ((Main.DefaultHeight - s) / 2), ((Main.DefaultHeight - s) / 2)));
    private const gradientPath_:GraphicsPath = GraphicsUtil.getRectPath(0, 0, Main.DefaultHeight, Main.DefaultHeight);
    private const gradientGraphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[gradientFill_, gradientPath_, GraphicsUtil.END_FILL];

    public function HurtOverlay() {
        graphics.drawGraphicsData(this.gradientGraphicsData_);
        visible = false;
    }

}
}
