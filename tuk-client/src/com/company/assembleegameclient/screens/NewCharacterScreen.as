﻿package com.company.assembleegameclient.screens {
import com.company.assembleegameclient.appengine.SavedCharactersList;
import com.company.assembleegameclient.constants.ScreenTypes;
import com.company.assembleegameclient.objects.ObjectLibrary;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.game.view.CreditDisplay;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.ui.view.components.ScreenBase;

import org.osflash.signals.Signal;

public class NewCharacterScreen extends Sprite {

    private var backButton_:TitleMenuOption;
    private var creditDisplay_:CreditDisplay;
    private var boxes_:Object;
    public var tooltip:Signal;
    public var close:Signal;
    public var selected:Signal;
    public var buy:Signal;
    private var isInitialized:Boolean = false;

    public function NewCharacterScreen() {
        this.boxes_ = {};
        super();
        this.tooltip = new Signal(Sprite);
        this.selected = new Signal(int);
        this.close = new Signal();
        this.buy = new Signal(int);
        addChild(new ScreenBase());
        addChild(new AccountScreen());
    }

    public function initialize(_arg1:PlayerModel):void {
        var _local2:int;
        var _local3:XML;
        var _local4:int;
        var _local5:String;
        var _local6:Boolean;
        var _local7:CharacterBox;
        if (this.isInitialized) {
            return;
        }
        this.isInitialized = true;
        this.backButton_ = new TitleMenuOption(ScreenTypes.BACK, 32, 18);
        this.backButton_.addEventListener(MouseEvent.CLICK, this.onBackClick);
        addChild(this.backButton_);
        this.creditDisplay_ = new CreditDisplay();
        this.creditDisplay_.draw(_arg1.getCredits(), _arg1.getFame(), _arg1.getUnholyEssence(), _arg1.getDivineEssence());
        addChild(this.creditDisplay_);
        _local2 = 0;
        var magic:int = Math.floor((WebMain.DefaultWidth - 75) / 105);
        while (_local2 < ObjectLibrary.playerChars_.length) {
            _local3 = ObjectLibrary.playerChars_[_local2];
            _local4 = int(_local3.@type);
            _local5 = _local3.@id;
            if (!_arg1.isClassAvailability(_local5, SavedCharactersList.UNAVAILABLE)) {
                _local6 = _arg1.isClassAvailability(_local5, SavedCharactersList.UNRESTRICTED);
                _local7 = new CharacterBox(_local3, _arg1.getCharStats()[_local4], _arg1, _local6);
                _local7.x = 25 + (((50 + (110 * int((_local2 % magic)))) + 70) - (_local7.width));
                _local7.y = (88 + (110 * int((_local2 / magic))));
                this.boxes_[_local4] = _local7;
                _local7.addEventListener(MouseEvent.ROLL_OVER, this.onCharBoxOver);
                _local7.addEventListener(MouseEvent.ROLL_OUT, this.onCharBoxOut);
                _local7.characterSelectClicked_.add(this.onCharBoxClick);
                addChild(_local7);
            }
            _local2++;
        }
        this.backButton_.x = ((stage.stageWidth / 2) - (this.backButton_.width / 2));
        this.backButton_.y = WebMain.DefaultHeight - 50;
        this.creditDisplay_.x = stage.stageWidth;
        this.creditDisplay_.y = 20;
    }

    private function onBackClick(_arg1:Event):void {
        this.close.dispatch();
    }

    private function onCharBoxOver(_arg1:MouseEvent):void {
        var _local2:CharacterBox = (_arg1.currentTarget as CharacterBox);
        _local2.setOver(true);
        this.tooltip.dispatch(_local2.getTooltip());
    }

    private function onCharBoxOut(_arg1:MouseEvent):void {
        var _local2:CharacterBox = (_arg1.currentTarget as CharacterBox);
        _local2.setOver(false);
        this.tooltip.dispatch(null);
    }

    private function onCharBoxClick(_arg1:MouseEvent):void {
        this.tooltip.dispatch(null);
        var _local2:CharacterBox = (_arg1.currentTarget.parent as CharacterBox);
        if (!_local2.available_) {
            return;
        }
        var _local3:int = _local2.objectType();
        this.selected.dispatch(_local3);
    }

    public function updateCreditsAndFame(_arg1:int, _arg2:int, _arg3:int, _arg4:int):void {
        this.creditDisplay_.draw(_arg1, _arg2, _arg3, _arg4);
    }

    public function update(_arg1:PlayerModel):void {
        var _local3:XML;
        var _local4:int;
        var _local5:String;
        var _local6:Boolean;
        var _local7:CharacterBox;
        var _local2:int;
        while (_local2 < ObjectLibrary.playerChars_.length) {
            _local3 = ObjectLibrary.playerChars_[_local2];
            _local4 = int(_local3.@type);
            _local5 = String(_local3.@id);
            if (!_arg1.isClassAvailability(_local5, SavedCharactersList.UNAVAILABLE)) {
                _local6 = _arg1.isClassAvailability(_local5, SavedCharactersList.UNRESTRICTED);
                _local7 = this.boxes_[_local4];
                if (_local7) {
                    if (((_local6) || (_arg1.isLevelRequirementsMet(_local4)))) {
                        _local7.unlock();
                    }
                }
            }
            _local2++;
        }
    }

}
}
