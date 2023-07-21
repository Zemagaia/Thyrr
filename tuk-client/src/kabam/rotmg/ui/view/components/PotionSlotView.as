package kabam.rotmg.ui.view.components {
import com.company.assembleegameclient.objects.ObjectLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.utils.Timer;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import org.osflash.signals.Signal;

public class PotionSlotView extends Sprite {

    private static const DOUBLE_CLICK_PAUSE:uint = 250;
    private static const DRAG_DIST:int = 3;

    public static var BUTTON_WIDTH:int = 38;
    public static var BUTTON_HEIGHT:int = 23;
    private static var LEFT_ICON_X:int = -6;

    public var position:int;
    public var objectType:int;
    public var buyUse:Signal;
    public var drop:Signal;
    private var text:TextFieldDisplayConcrete;
    private var potionIconDraggableSprite:Sprite;
    private var potionIcon:Bitmap;
    private var bg:Sprite;
    private var doubleClickTimer:Timer;
    private var dragStart:Point;
    private var pendingSecondClick:Boolean;
    private var isDragging:Boolean;

    public function PotionSlotView(_arg2:int) {
        this.y -= 4;
        super();
        mouseChildren = false;
        this.position = _arg2;
        this.text = new TextFieldDisplayConcrete().setSize(13).setColor(0xFFFFFF).setTextWidth(BUTTON_WIDTH).setTextHeight(BUTTON_HEIGHT);
        this.text.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 2)];
        this.text.y = 4;
        this.bg = new Sprite();
        addChild(this.bg);
        addChild(this.text);
        this.potionIconDraggableSprite = new Sprite();
        this.doubleClickTimer = new Timer(DOUBLE_CLICK_PAUSE, 1);
        this.doubleClickTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onDoubleClickTimerComplete);
        addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        this.buyUse = new Signal();
        this.drop = new Signal(DisplayObject);
    }

    public function setData(_arg1:int, _arg2:int = -1):void {
        var _local7:BitmapData;
        var _local8:Bitmap;
        if (_arg2 != -1) {
            this.objectType = _arg2;
            if (this.potionIcon != null) {
                removeChild(this.potionIcon);
            }
            _local7 = ObjectLibrary.getRedrawnTextureFromType(_arg2, 40, false);
            this.potionIcon = new Bitmap(_local7);
            this.potionIcon.x = -8;
            this.potionIcon.y = -8;
            addChild(this.potionIcon);
            _local7 = ObjectLibrary.getRedrawnTextureFromType(_arg2, 80, true);
            _local8 = new Bitmap(_local7);
            _local8.x = (_local8.x - 30);
            _local8.y = (_local8.y - 30);
            this.potionIconDraggableSprite.addChild(_local8);
        }
        this.setTextString(String(_arg1));
        var inColor:uint = _arg1 > 0 ? 0x545454 : 0x2B2B2B;
        var outColor:uint = 0x2B2B2B;
        this.bg.graphics.clear();
        this.bg.graphics.beginFill(outColor);
        this.bg.graphics.drawRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
        this.bg.graphics.endFill();
        this.bg.graphics.beginFill(inColor);
        this.bg.graphics.drawRect(2, 2, BUTTON_WIDTH - 4, BUTTON_HEIGHT - 4);
        this.bg.graphics.endFill();
        this.text.x = ((BUTTON_WIDTH / 2) + 5);
        this.text.setColor(0xFFFFFF);
    }

    public function setTextString(_arg1:String):void {
        this.text.setStringBuilder(new StaticStringBuilder(_arg1));
    }

    private function onMouseOut(_arg1:MouseEvent):void {
        this.setPendingDoubleClick(false);
    }

    private function onMouseUp(_arg1:MouseEvent):void {
        if (this.isDragging) {
            return;
        }
        if (_arg1.shiftKey) {
            this.setPendingDoubleClick(false);
            this.buyUse.dispatch();
        }
        else {
            if (!this.pendingSecondClick) {
                this.setPendingDoubleClick(true);
            }
            else {
                this.setPendingDoubleClick(false);
                this.buyUse.dispatch();
            }
        }
    }

    private function onMouseDown(_arg1:MouseEvent):void {
        this.beginDragCheck(_arg1);
    }

    private function setPendingDoubleClick(_arg1:Boolean):void {
        this.pendingSecondClick = _arg1;
        if (this.pendingSecondClick) {
            this.doubleClickTimer.reset();
            this.doubleClickTimer.start();
        }
        else {
            this.doubleClickTimer.stop();
        }
    }

    private function beginDragCheck(_arg1:MouseEvent):void {
        this.dragStart = new Point(_arg1.stageX, _arg1.stageY);
        addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveCheckDrag);
        addEventListener(MouseEvent.MOUSE_OUT, this.cancelDragCheck);
        addEventListener(MouseEvent.MOUSE_UP, this.cancelDragCheck);
    }

    private function cancelDragCheck(_arg1:MouseEvent):void {
        removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMoveCheckDrag);
        removeEventListener(MouseEvent.MOUSE_OUT, this.cancelDragCheck);
        removeEventListener(MouseEvent.MOUSE_UP, this.cancelDragCheck);
    }

    private function onMouseMoveCheckDrag(_arg1:MouseEvent):void {
        var _local2:Number = (_arg1.stageX - this.dragStart.x);
        var _local3:Number = (_arg1.stageY - this.dragStart.y);
        var _local4:Number = Math.sqrt(((_local2 * _local2) + (_local3 * _local3)));
        if (_local4 > DRAG_DIST) {
            this.cancelDragCheck(null);
            this.setPendingDoubleClick(false);
            this.beginDrag();
        }
    }

    private function onDoubleClickTimerComplete(_arg1:TimerEvent):void {
        this.setPendingDoubleClick(false);
    }

    private function beginDrag():void {
        this.isDragging = true;
        this.potionIconDraggableSprite.startDrag(true);
        stage.addChild(this.potionIconDraggableSprite);
        this.potionIconDraggableSprite.addEventListener(MouseEvent.MOUSE_UP, this.endDrag);
    }

    private function endDrag(_arg1:MouseEvent):void {
        this.isDragging = false;
        this.potionIconDraggableSprite.stopDrag();
        this.potionIconDraggableSprite.x = this.dragStart.x;
        this.potionIconDraggableSprite.y = this.dragStart.y;
        stage.removeChild(this.potionIconDraggableSprite);
        this.potionIconDraggableSprite.removeEventListener(MouseEvent.MOUSE_UP, this.endDrag);
        this.drop.dispatch(this.potionIconDraggableSprite.dropTarget);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        this.setPendingDoubleClick(false);
        this.cancelDragCheck(null);
        if (this.isDragging) {
            this.potionIconDraggableSprite.stopDrag();
        }
    }


}
}
