package thyrr.quests.model {
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;

import flash.display.BitmapData;
import flash.display.Sprite;

import com.company.assembleegameclient.game.GameSprite;

import flash.display.Bitmap;

import flash.events.MouseEvent;

import kabam.rotmg.util.components.DialogBackground;

import thyrr.quests.data.AcceptedQuestData;

import thyrr.quests.data.QuestData;

public class QuestIconBuilder extends Sprite {

    public var icon_:Bitmap;
    public var background_:DialogBackground = new DialogBackground();
    public var selected_:Boolean = false;
    public var availableQuestData_:QuestData;
    public var questData_:AcceptedQuestData;

    private var w_:int;
    private var h_:int;

    public function QuestIconBuilder(availableQuestData:QuestData, questData:AcceptedQuestData, width:int, height:int) {
        this.availableQuestData_ = availableQuestData;
        this.questData_ = questData;
        this.w_ = width;
        this.h_ = height;

        var data:Object = this.questData_ == null ? this.availableQuestData_ : this.questData_;

        var getIcon:BitmapData = AssetLibrary.getImageFromSet("interfaceNew", 0x11 + data.icon_); // temp icon
        var bitmapData:BitmapData = TextureRedrawer.redraw2(getIcon, 80, true, 0);

        drawDialogRect(this.w_, this.h_);
        addChild(this.background_);
        this.icon_ = new Bitmap(bitmapData);
        this.icon_.y = -2;
        addChild(this.icon_);
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        addEventListener(MouseEvent.CLICK, this.onClick);
    }

    private function drawDialogRect(w:int, h:int, lineColor:uint = 0x545454, fillColor:uint = 0x333333):void {
        this.background_.graphics.clear();
        this.background_.draw(w, h, 4, lineColor, fillColor);
    }

    public function onMouseOver(me:MouseEvent):void {
        this.drawBgOver();
    }

    public function onMouseOut(me:MouseEvent):void {
        this.drawBgOut();
    }

    public function onClick(me:MouseEvent):void {
        this.selected_ = !this.selected_;
        if (this.selected_) {
            this.drawBgOver();
            removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        }
        else {
            this.drawBgOut();
            addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        }
    }

    private function drawBgOver():void {
        this.background_.graphics.clear();
        this.background_.draw(this.w_, this.h_, 4, 0x676767, 0x454545);
    }

    private function drawBgOut():void {
        this.background_.graphics.clear();
        this.background_.draw(this.w_, this.h_, 4, 0x545454, 0x333333);
    }

    public function addListeners():void {
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        addEventListener(MouseEvent.CLICK, this.onClick);
    }

    public function removeListeners():void {
        removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        removeEventListener(MouseEvent.CLICK, this.onClick);
        this.background_.graphics.clear();
        this.background_.draw(this.w_, this.h_, 4, 0x545454, 0x333333);
    }

    public function dispose():void {
        this.background_ = null;
        this.icon_ = null;
        var i:int = (numChildren - 1);
        while (i >= 0) {
            removeChildAt(i);
            i--;
        }
        removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        removeEventListener(MouseEvent.CLICK, this.onClick);
    }

}
}