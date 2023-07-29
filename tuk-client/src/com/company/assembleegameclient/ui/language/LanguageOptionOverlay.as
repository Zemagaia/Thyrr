package com.company.assembleegameclient.ui.language {
import com.company.assembleegameclient.screens.TitleMenuOption;

import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.core.view.Layers;

import kabam.rotmg.language.model.LanguageModel;


import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.view.TitleView;
import kabam.rotmg.ui.view.components.ScreenBase;
import kabam.rotmg.ui.view.components.dropdown.LocalizedDropDown;

import org.osflash.signals.Signal;

public class LanguageOptionOverlay extends ScreenBase {

    public var layers:Layers = Global.layers;
    public var languageModel:LanguageModel = Global.languageModel;
    private var title_:TextFieldDisplayConcrete;
    private var continueButton_:TitleMenuOption;
    private var languageDropDownLabel:TextFieldDisplayConcrete;
    private var languageDropDown:LocalizedDropDown;

    public function LanguageOptionOverlay() {
        this.title_ = this.makeTitle();
        this.continueButton_ = this.makeContinueButton();
        this.languageDropDownLabel = this.makeDropDownLabel();
        super();
        addChild(this.makeLine());
        addChild(this.title_);
        addChild(this.continueButton_);
    }

    public function initialize():void {
        this.setLanguageDropdown(this.languageModel.getLanguageNames());
        this.setSelected(this.languageModel.getNameForLanguageCode(this.languageModel.getLanguage()));
    }

    private function onBack():void {
        Global.setScreen(new TitleView());
    }

    private function onContinueClick(_arg1:MouseEvent):void {
        Global.setScreen(new TitleView());
    }

    public function setLanguageDropdown(_arg1:Vector.<String>):void {
        this.languageDropDown = new LocalizedDropDown(_arg1);
        this.languageDropDown.y = 100;
        this.languageDropDown.addEventListener(Event.CHANGE, this.onLanguageSelected);
        addChild(this.languageDropDown);
        this.languageDropDownLabel.textChanged.addOnce(this.positionDropdownLabel);
        addChild(this.languageDropDownLabel);
        this.languageDropDownLabel.y = (this.languageDropDown.y + (this.languageDropDown.getClosedHeight() / 2));
    }

    private function positionDropdownLabel():void {
        this.languageDropDown.x = ((Main.DefaultWidth / 2) - (((this.languageDropDown.width + this.languageDropDownLabel.width) + 10) / 2));
        this.languageDropDownLabel.x = ((this.languageDropDown.x + this.languageDropDown.width) + 10);
    }

    public function setSelected(_arg1:String):void {
        ((this.languageDropDown) && (this.languageDropDown.setValue(_arg1)));
    }

    private function onLanguageSelected(_arg1:Event):void {
        Global.setLanguage(this.languageModel.getLanguageCodeForName(this.languageDropDown.getValue()));
    }

    private function makeTitle():TextFieldDisplayConcrete {
        var _local1:TextFieldDisplayConcrete;
        _local1 = new TextFieldDisplayConcrete().setSize(36).setColor(0xFFFFFF);
        _local1.setBold(true);
        _local1.setStringBuilder(new LineBuilder().setParams("Languages"));
        _local1.setAutoSize(TextFieldAutoSize.CENTER);
        _local1.filters = [new DropShadowFilter(0, 0, 0)];
        _local1.x = ((Main.DefaultWidth / 2) - (_local1.width / 2));
        _local1.y = 16;
        return (_local1);
    }

    private function makeContinueButton():TitleMenuOption {
        var _local1:TitleMenuOption;
        _local1 = new TitleMenuOption("continue", 36, 24);
        _local1.addEventListener(MouseEvent.CLICK, this.onContinueClick);
        _local1.x = Main.DefaultWidth / 2;
        _local1.y = Main.DefaultHeight - 50;
        return (_local1);
    }

    private function makeDropDownLabel():TextFieldDisplayConcrete {
        var _local1:TextFieldDisplayConcrete = new TextFieldDisplayConcrete().setSize(16).setColor(0xB3B3B3).setBold(true);
        _local1.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        _local1.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
        _local1.setStringBuilder(new LineBuilder().setParams("Choose Language"));
        return (_local1);
    }

    private function makeLine():Shape {
        var _local1:Shape = new Shape();
        _local1.graphics.lineStyle(1, 0x5E5E5E);
        _local1.graphics.moveTo(0, 70);
        _local1.graphics.lineTo(Main.DefaultWidth, 70);
        _local1.graphics.lineStyle();
        return (_local1);
    }

    public function clear():void {
        if (((this.languageDropDown) && (contains(this.languageDropDown)))) {
            removeChild(this.languageDropDown);
        }
    }


}
}
