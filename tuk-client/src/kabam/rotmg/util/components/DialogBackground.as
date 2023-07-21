package kabam.rotmg.util.components {
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;

import kabam.rotmg.util.graphics.BevelRect;
import kabam.rotmg.util.graphics.GraphicsHelper;

public class DialogBackground extends Sprite {

    private static const BEVEL:int = 4;

    public function draw(width:int, height:int, bevel:int = BEVEL, lineColor:uint = 0x7B7B7B, backColor:uint = 0x363636):void {
        var rect:BevelRect = new BevelRect(width, height, bevel);
        var helper:GraphicsHelper = new GraphicsHelper();
        graphics.lineStyle(2, lineColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3);
        graphics.beginFill(backColor);
        helper.drawBevelRect(0, 0, rect, graphics);
        graphics.endFill();
    }


}
}
