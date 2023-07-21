package com.company.assembleegameclient.screens.charrects {
import com.company.assembleegameclient.appengine.CharacterStats;
import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.screens.events.DeleteCharacterEvent;
import com.company.assembleegameclient.ui.tooltip.MyPlayerToolTip;
import com.company.assembleegameclient.util.FameUtil;
import com.company.rotmg.graphics.DeleteXGraphic;
import com.company.util.BitmapUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.classes.model.CharacterClass;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

import org.osflash.signals.Signal;

import thyrr.pets.data.PetData;

public class CurrentCharacterRect extends CharacterRect {

    public const selected:Signal = new Signal();
    public const deleteCharacter:Signal = new Signal();
    public const showToolTip:Signal = new Signal(Sprite);
    public const hideTooltip:Signal = new Signal();

    public var charName:String;
    public var charStats:CharacterStats;
    public var char:SavedCharacter;
    public var myPlayerToolTipFactory:MyPlayerToolTipFactory;
    private var charType:CharacterClass;
    private var deleteButton:Sprite;
    public var Icon:DisplayObject;
    private var pet_:Bitmap;

    public function CurrentCharacterRect(_arg1:String, _arg2:CharacterClass, _arg3:SavedCharacter, _arg4:CharacterStats) {
        this.myPlayerToolTipFactory = new MyPlayerToolTipFactory();
        super();
        this.charName = _arg1;
        this.charType = _arg2;
        this.char = _arg3;
        this.charStats = _arg4;
        var className:String = _arg2.name;
        var level:int = _arg3.charXML_.Level;
        super.className = new LineBuilder().setParams("{className} {level}", {
            "className": className,
            "level": level
        });
        super.color = 0x5C5C5C;
        super.overColor = 0x7F7F7F;
        super.init();
        this.makeTagline();
        this.makeDeleteButton();
        this.addEventListeners();
    }

    private function addEventListeners():void {
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        selectContainer.addEventListener(MouseEvent.CLICK, this.onSelect);
        this.deleteButton.addEventListener(MouseEvent.CLICK, this.onDelete);
    }

    private function onSelect(_arg1:MouseEvent):void {
        this.selected.dispatch(this.char);
    }

    private function onDelete(_arg1:MouseEvent):void {
        this.deleteCharacter.dispatch(this.char);
    }

    public function setIcon(_arg1:DisplayObject):void {
        ((Icon) && (selectContainer.removeChild(Icon)));
        Icon = _arg1;
        Icon.x = CharacterRectConstants.ICON_POS_X;
        Icon.y = CharacterRectConstants.ICON_POS_Y;
        ((Icon) && (selectContainer.addChild(Icon)));
    }

    private function makeTagline():void {
        if (this.getNextStarFame() > 0) {
            super.makeTaglineIcon();
            super.makeTaglineText(new LineBuilder().setParams("Class Quest: {fame} of {nextStarFame} Fame", {
                "fame": this.char.fame(),
                "nextStarFame": this.getNextStarFame()
            }));
            taglineText.x = (taglineText.x + taglineIcon.width);
        }
        else {
            super.makeTaglineIcon();
            super.makeTaglineText(new LineBuilder().setParams("{fame} Fame", {"fame": this.char.fame()}));
            taglineText.x = (taglineText.x + taglineIcon.width);
        }
    }

    private function getNextStarFame():int {
        return (FameUtil.nextStarFame((((this.charStats == null)) ? 0 : this.charStats.bestFame()), this.char.fame()));
    }

    private function makeDeleteButton():void {
        this.deleteButton = new DeleteXGraphic();
        this.deleteButton.addEventListener(MouseEvent.MOUSE_DOWN, this.onDeleteDown);
        this.deleteButton.x = (WIDTH - 40);
        this.deleteButton.y = ((HEIGHT - this.deleteButton.height) * 0.5);
        addChild(this.deleteButton);
    }

    public function makePetIcon(petData:PetData):void {
        if (petData.Id == 0 || petData == null) {
            return;
        }
        var objType:int = petData.ObjectType;
        var size:int = 80;
        var bitmapData:BitmapData = ObjectLibrary.getRedrawnTextureFromType(objType, size, true, false);
        bitmapData = BitmapUtil.cropToBitmapData(bitmapData, 8, 8, bitmapData.width - 16, bitmapData.height - 16);
        this.pet_ = new Bitmap(bitmapData);
        this.pet_.x = Icon.x + Icon.width;
        this.pet_.y = 14;
        this.pet_.scaleX = 1 / int(this.pet_.width / 40);
        this.pet_.scaleY = 1 / int(this.pet_.width / 40);
        this.taglineText.x += 40;
        this.taglineIcon.x += 40;
        this.classNameText.x += 40;
        addChild(this.pet_);
    }

    override protected function onMouseOver(_arg1:MouseEvent):void {
        super.onMouseOver(_arg1);
        this.removeToolTip();
        var toolTip:MyPlayerToolTip = this.myPlayerToolTipFactory.create(this.charName, this.char.charXML_, this.charStats);
        toolTip.createUI();
        this.showToolTip.dispatch(toolTip);
    }

    override protected function onRollOut(_arg1:MouseEvent):void {
        super.onRollOut(_arg1);
        this.removeToolTip();
    }

    private function onRemovedFromStage(_arg1:Event):void {
        this.removeToolTip();
    }

    private function removeToolTip():void {
        this.hideTooltip.dispatch();
    }

    private function onDeleteDown(_arg1:MouseEvent):void {
        _arg1.stopImmediatePropagation();
        dispatchEvent(new DeleteCharacterEvent(this.char));
    }


}
}
