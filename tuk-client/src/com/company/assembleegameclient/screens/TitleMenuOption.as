package com.company.assembleegameclient.screens
{
import com.company.assembleegameclient.sound.SoundEffectLibrary;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

import org.osflash.signals.Signal;

import thyrr.ui.buttons.TextButton;

public class TitleMenuOption extends Sprite
{

    public const clicked:Signal = new Signal();
    public var button:TextButton;
    public var changed:Signal;

    private var size:int;
    private var height_:int;
    private var active:Boolean;
    private var color:uint = 0xFFFFFF;

    public function TitleMenuOption(text:String, height:int, size:int)
    {
        height_ = height;
        this.size = size;
        this.button = makeTextButton();
        this.changed = button.text_.textChanged;
        this.button.text_.setSize(size).setColor(0xFFFFFF).setBold(true);
        this.setTextKey(text);
        this.activate();
    }

    public function activate():void
    {
        this.button.clicked.add(onClick);
        this.active = true;
    }

    public function deactivate():void
    {
        this.button.clicked.remove(onClick);
        this.active = false;
    }

    public function setColor(hex:uint):void
    {
        this.button.text_.setColor(color = hex);
    }

    public function isActive():Boolean
    {
        return (this.active);
    }

    private function makeTextButton():TextButton
    {
        var textButton:TextButton;
        textButton = new TextButton(72, height_, "", size, -1);
        addChild(textButton);
        return (textButton);
    }

    public function setTextKey(text:String):void
    {
        name = text;
        this.button.text_.setStringBuilder(new LineBuilder().setParams(text));
    }

    protected function onClick():void
    {
        SoundEffectLibrary.play("button_click");
        this.clicked.dispatch();
    }

    override public function toString():String
    {
        return ((("[TitleMenuOption " + this.button.text_.getText()) + "]"));
    }

    public function createNoticeTag(text:String, size:int, color:uint, bold:Boolean):void
    {
        var textField:TextFieldDisplayConcrete = new TextFieldDisplayConcrete();
        textField.setSize(size).setColor(color).setBold(bold);
        textField.setStringBuilder(new LineBuilder().setParams(text));
        textField.x = (this.button.x - 4);
        textField.y = (this.button.y - 20);
        addChild(textField);
    }


}
}