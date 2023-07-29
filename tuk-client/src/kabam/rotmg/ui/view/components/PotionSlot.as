package kabam.rotmg.ui.view.components {
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InteractiveItemTile;
import com.company.assembleegameclient.util.DisplayHierarchy;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;

import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.game.model.PotionInventoryModel;

import kabam.rotmg.game.model.UseBuyPotionVO;
import kabam.rotmg.messaging.impl.GameServerConnection;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.model.PotionModel;

import thyrr.ui.items.SimpleBox;

import thyrr.utils.ItemData;
import thyrr.utils.Utils;

public class PotionSlot extends Sprite {

    private static const DOUBLE_CLICK_PAUSE:uint = 250;
    private static const DRAG_DIST:int = 3;

    public static var BUTTON_WIDTH:int = 24;
    public static var BUTTON_HEIGHT:int = 24;
    private static var LEFT_ICON_X:int = -6;

    public var position:int;
    public var objectType:int;
    public var hudModel:HUDModel = Global.hudModel;
    public var potionInventoryModel:PotionInventoryModel = Global.potionInventoryModel;
    private var blockingUpdate:Boolean = false;
    private var text:TextFieldDisplayConcrete;
    private var potionIconDraggableSprite:Sprite;
    private var potionIcon:Bitmap;
    private var leftBg:SimpleBox;
    private var rightBg:SimpleBox;
    private var doubleClickTimer:Timer;
    private var dragStart:Point;
    private var pendingSecondClick:Boolean;
    private var isDragging:Boolean;

    public function PotionSlot(_arg2:int) {
        super();
        mouseChildren = false;
        this.position = _arg2;
        this.text = new TextFieldDisplayConcrete().setSize(13).setColor(0xFFFFFF).setTextWidth(BUTTON_WIDTH).setTextHeight(BUTTON_HEIGHT);
        this.text.setBold(true);
        this.text.filters = [Utils.OutlineFilter];
        this.text.x = 6 + (position % 2 == 0 ? 24 : 0);
        this.text.y = 5;
        this.leftBg = new SimpleBox(BUTTON_WIDTH, BUTTON_HEIGHT, 0x807D7D);
        this.rightBg = new SimpleBox(BUTTON_WIDTH, BUTTON_HEIGHT, 0x807D7D);
        addChild(this.leftBg);
        addChild(this.rightBg);
        rightBg.x = BUTTON_WIDTH;
        addChild(this.text);
        this.potionIconDraggableSprite = new Sprite();
        this.doubleClickTimer = new Timer(DOUBLE_CLICK_PAUSE, 1);
        this.doubleClickTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onDoubleClickTimerComplete);
        addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    public function initializeData(_arg1:Player):void {
        var _local2:PotionModel = this.potionInventoryModel.potionModels[this.position];
        var _local3:int = _arg1.getPotionCount(_local2.objectId);
        this.setData(_local3, _local2.objectId);
    }

    public function update(_arg1:Player):void {
        var _local2:PotionModel;
        var _local3:int;
        if ((((((this.objectType == PotionInventoryModel.HEALTH_POTION_ID)) || ((this.objectType == PotionInventoryModel.MAGIC_POTION_ID)))) && (!(this.blockingUpdate)))) {
            _local2 = this.potionInventoryModel.getPotionModel(this.objectType);
            _local3 = _arg1.getPotionCount(_local2.objectId);
            this.setData(_local3);
        }
    }

    private function onDrop(_arg1:DisplayObject):void {
        var _local4:InteractiveItemTile;
        var _local2:Player = this.hudModel.gameSprite.map.player_;
        var _local3:* = DisplayHierarchy.getParentWithTypeArray(_arg1, InteractiveItemTile, Map);
        if ((((_local3 is Map)) || (((Parameters.isGpuRender()) && ((_local3 == null)))))) {
            GameServerConnection.instance.invDrop(_local2, PotionInventoryModel.getPotionSlot(this.objectType), this.objectType);
        }
        else {
            if ((_local3 is InteractiveItemTile)) {
                _local4 = (_local3 as InteractiveItemTile);
                if ((((_local4.getItemId() == ItemConstants.NO_ITEM)) && (!((_local4.ownerGrid.owner == _local2))))) {
                    var data:ItemData = new ItemData(null);
                    data.ObjectType = this.objectType;
                    GameServerConnection.instance.invSwapPotion(_local2, _local2, PotionInventoryModel.getPotionSlot(this.objectType), data, _local4.ownerGrid.owner, _local4.tileId, new ItemData(null));
                }
            }
        }
    }

    private function onBuyUse():void {
        var _local2:UseBuyPotionVO;
        var _local1:PotionModel = this.potionInventoryModel.potionModels[this.position];
        if (_local1.available) {
            _local2 = new UseBuyPotionVO(_local1.objectId, UseBuyPotionVO.SHIFTCLICK);
            Global.useBuyPotion(_local2);
        }
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
            this.potionIcon.x = -8 + (position % 2 != 0 ? 24 : 0);
            this.potionIcon.y = -8;
            addChild(this.potionIcon);
            _local7 = ObjectLibrary.getRedrawnTextureFromType(_arg2, 80, true);
            _local8 = new Bitmap(_local7);
            _local8.x = (_local8.x - 30);
            _local8.y = (_local8.y - 30);
            this.potionIconDraggableSprite.addChild(_local8);
        }
        this.setTextString(String(_arg1));
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
            onBuyUse();
        }
        else {
            if (!this.pendingSecondClick) {
                this.setPendingDoubleClick(true);
            }
            else {
                this.setPendingDoubleClick(false);
                onBuyUse();
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
        onDrop(this.potionIconDraggableSprite.dropTarget);
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
