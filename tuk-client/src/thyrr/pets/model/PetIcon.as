package thyrr.pets.model {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.BitmapUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.display.Sprite;

import kabam.rotmg.util.components.DialogBackground;

import thyrr.pets.tabs.PetsTab;
import thyrr.pets.data.PetData;

public class PetIcon extends Sprite {

    public var gameSprite_:GameSprite;
    public var icon_:Bitmap;
    public var background_:DialogBackground = new DialogBackground();
    public var selected_:Boolean = false;
    public var petData_:PetData;

    public function PetIcon(gameSprite:GameSprite, petData:PetData) {
        this.gameSprite_ = gameSprite;
        this.petData_ = petData;
        draw();
    }

    private function draw():void {
        // make then add background
        makeBackground(40, 40);
        addChild(this.background_);
        // add pet icon
        addIcon();
        // finally add event listeners
        addListeners();
    }

    private function addIcon():void {
        var getIcon:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.petData_.ObjectType, 80, true, false);
        getIcon = BitmapUtil.cropToBitmapData(getIcon, 8, 8, getIcon.width - 16, getIcon.height - 16);
        this.icon_ = new Bitmap(getIcon);
        addChild(this.icon_);
    }

    private function makeBackground(w:int, h:int, lineColor:uint = 0x545454):void {
        lineColor = isSelected() ? 0xD37337 : lineColor;
        var backColor:uint = isSelected() ? 0x3F1D10 : lineColor;
        this.background_.graphics.clear();
        this.background_.draw(w, h, 0, lineColor, backColor);
    }

    public function addListeners():void {
        if (!isSelected()) {
            addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        }
        addEventListener(MouseEvent.CLICK, this.onClick);
    }

    public function removeListeners():void {
        if (!isSelected()) {
            removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        }
        removeEventListener(MouseEvent.CLICK, this.onClick);
    }

    private function isSelected():Boolean {
        var petData:PetData = this.gameSprite_.map.player_.petData_;
        return petData && petData.Id == this.petData_.Id;
    }

    public function onMouseOver(me:MouseEvent):void {
        this.drawBgOver();
    }

    public function onMouseOut(me:MouseEvent):void {
        this.drawBgOut();
    }

    private function drawBgOver():void {
        makeBackground(40, 40, 0x676767);
    }

    private function drawBgOut():void {
        makeBackground(40, 40, 0x545454);
    }

    public function onClick(me:MouseEvent):void {
        this.selected_ = !this.selected_;
        if (this.selected_) {
            this.drawBgOver();
            removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
            return;
        }
        this.drawBgOut();
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
    }

    public function dispose():void {
        this.gameSprite_ = null;
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