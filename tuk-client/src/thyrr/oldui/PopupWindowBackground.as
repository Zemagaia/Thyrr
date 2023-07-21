package thyrr.oldui {
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;

import kabam.rotmg.util.graphics.BevelRect;
import kabam.rotmg.util.graphics.GraphicsHelper;

public class PopupWindowBackground extends Sprite {

    public static const HORIZONTAL_DIVISION:String = "HORIZONTAL_DIVISION";
    public static const VERTICAL_DIVISION:String = "VERTICAL_DIVISION";
    private static const BEVEL:int = 0;
    public static const TYPE_DEFAULT_GREY:int = 0;
    public static const TYPE_TRANSPARENT_WITH_HEADER:int = 1;
    public static const TYPE_TRANSPARENT_WITHOUT_HEADER:int = 2;
    public static const TYPE_DEFAULT_BLACK:int = 3;

    public function draw(width:int, height:int, type:int = 0):void {
        var _local4:BevelRect = new BevelRect(width, height, BEVEL);
        var _local5:GraphicsHelper = new GraphicsHelper();
        graphics.lineStyle(2, 0x7B7B7B, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3);
        if (type == TYPE_TRANSPARENT_WITH_HEADER) {
            graphics.lineStyle(2, 0x2B2B2B, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3);
            graphics.beginFill(0x2B2B2B, 1);
            _local5.drawBevelRect(1, 1, new BevelRect((width - 2), 29, BEVEL), graphics);
            graphics.endFill();
            graphics.beginFill(0x2B2B2B, 1);
            graphics.drawRect(1, 15, (width - 2), 15);
            graphics.endFill();
            graphics.lineStyle(2, 0x7B7B7B, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3);
            graphics.beginFill(0x2B2B2B, 0);
            _local5.drawBevelRect(0, 0, _local4, graphics);
            graphics.endFill();
            return;
        }
        if (type == TYPE_TRANSPARENT_WITHOUT_HEADER) {
            graphics.lineStyle(2, 0x7B7B7B, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3);
            graphics.beginFill(0x2B2B2B, 0);
            _local5.drawBevelRect(0, 0, _local4, graphics);
            graphics.endFill();
            return;
        }
        if (type == TYPE_DEFAULT_GREY) {
            graphics.beginFill(0x2B2B2B);
            _local5.drawBevelRect(0, 0, _local4, graphics);
            graphics.endFill();
            return;
        }
        if (type == TYPE_DEFAULT_BLACK) {
            graphics.beginFill(0);
            _local5.drawBevelRect(0, 0, _local4, graphics);
            graphics.endFill();
        }
    }

    public function divide(division:String, pos:int):void {
        if (division == HORIZONTAL_DIVISION) {
            this.divideHorizontally(pos);
            return;
        }
        if (division == VERTICAL_DIVISION) {
            this.divideVertically(pos);
        }
    }

    private function divideHorizontally(y:int):void {
        graphics.lineStyle();
        graphics.endFill();
        graphics.moveTo(1, y);
        graphics.beginFill(0x7b7b7b, 1);
        graphics.drawRect(1, y, (width - 4), 2);
    }

    private function divideVertically(x:int):void {
        graphics.lineStyle();
        graphics.moveTo(x, 1);
        graphics.lineStyle(2, 0x7b7b7b);
        graphics.lineTo(x, (height - 1));
    }


}
}