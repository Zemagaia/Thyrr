package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;


import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;
import kabam.rotmg.ui.view.SignalWaiter;

import org.osflash.signals.Signal;

import thyrr.ui.items.FlexibleBox;

import thyrr.utils.Utils;

public class PlayerInfoPanel extends Sprite {

    public const _resized:Signal = new Signal();

    private var _height:Number;
    private var _extraNameWidth:Boolean;
    private var _player:Player;
    private var _nameText:TextFieldDisplayConcrete;
    private var _guildText:TextFieldDisplayConcrete;
    private var rankText_:TextFieldDisplayConcrete;
    private var background:FlexibleBox;

    public function PlayerInfoPanel(player:Player) {
        _player = player;
        drawHeader();
        _height = height;
        drawRest();
    }

    private function drawHeader():void {
        background = new FlexibleBox(24, 24, Utils.color(0xaea9a9, 1/1.35), -1, false);
        addChild(background);
        var icon:Bitmap;
        var text:TextFieldDisplayConcrete;
        var bitmapData:BitmapData = AssetLibrary.getImageFromSet("ui", 0x0a);
        icon = new Bitmap(bitmapData);
        icon.scaleX = icon.scaleY = 2;
        icon.filters = [Utils.OutlineFilter];
        addChild(icon);
        icon.x = icon.y = 4;
        text = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setBold(true).setMultiLine(true);
        text.setStringBuilder(new LineBuilder().setParams("Player Info"));
        text.mouseEnabled = true;
        text.filters = [Utils.OutlineFilter];
        text.x = 20;
        text.y = 4;
        addChild(text);
    }

    private function drawRest():void {
        var waiter:SignalWaiter = new SignalWaiter();
        addNameIfAble(waiter);
        addRankIfAble(waiter);
        addGuildInfoIfAble(waiter);
        if (waiter.isEmpty()) {
            this.updateBackground();
        }
        else {
            waiter.complete.addOnce(this.updateBackground);
        }
    }

    private function addNameIfAble(waiter:SignalWaiter):void {
        var titleText:TextFieldDisplayConcrete;
        titleText = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setMultiLine(true);
        titleText.setStringBuilder(new LineBuilder().setParams("Name:"));
        titleText.filters = [Utils.OutlineFilter];
        titleText.x = 10;
        titleText.y = 25;
        addChild(titleText);
        _nameText = new TextFieldDisplayConcrete().setSize(16).setColor(16777103).setTextWidth(130).setBold(true).setMultiLine(true);
        _nameText.setStringBuilder(new LineBuilder().setParams("{name}", {"name": _player.name_}));
        _nameText.filters = [Utils.OutlineFilter];
        _nameText.x = 10;
        _nameText.y = titleText.height + titleText.y + 16;
        addChild(_nameText);
        _height = _nameText.height + _nameText.y + 24;
        if (_player.name_.length > 8)
            _extraNameWidth = true;
    }

    private function addRankIfAble(waiter:SignalWaiter):void {
        var titleText:TextFieldDisplayConcrete;
        titleText = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setMultiLine(true);
        titleText.setStringBuilder(new LineBuilder().setParams("Rank:"));
        titleText.filters = [Utils.OutlineFilter];
        titleText.x = 10;
        titleText.y = _nameText.height + _nameText.y + 24;
        addChild(titleText);
        var rankSuffix:String = _player.rank_ < 100 ? (_player.rank_ < 50 ?
                (_player.rank_ < 10 ? "Player" : "Elite") : "Staff") : "Administrator";
        this.rankText_ = new TextFieldDisplayConcrete();
        this.rankText_.setSize(16).setColor(16777103).setHTML(true);
        this.rankText_.setStringBuilder(new LineBuilder().setParams(_player.rank_ + " {f}({suffix}){_f}", {
            "f":"<font size='12' color='#ffffff'>",
            "_f":"</font>",
            "suffix": rankSuffix
        }));
        this.rankText_.x = 10;
        this.rankText_.y = titleText.y + 16;
        this.rankText_.filters = [Utils.OutlineFilter];
        addChild(this.rankText_);
        _height = this.rankText_.y + 24;
    }

    private function addGuildInfoIfAble(waiter:SignalWaiter):void {
        var headerText:TextFieldDisplayConcrete;
        var titleText:TextFieldDisplayConcrete;
        var icon:Bitmap;
        if (_player.guildRank_ >= 0) {
            var bitmapData:BitmapData = TextureRedrawer.redraw(AssetLibrary.getImageFromSet("interfaceBig", 41), 20, true, 0);
            icon = new Bitmap(bitmapData);
            icon.x = -8;
            icon.y = this.rankText_.y + 12;
            addChild(icon);
            headerText = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setBold(true).setMultiLine(true);
            headerText.setStringBuilder(new LineBuilder().setParams("Guild Info"));
            headerText.filters = [Utils.OutlineFilter];
            headerText.x = 20;
            headerText.y = this.rankText_.y + 24;
            addChild(headerText);
            titleText = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setBold(true).setMultiLine(true);
            titleText.setStringBuilder(new LineBuilder().setParams("{guildName}", {"guildName": _player.guildName_}));
            titleText.filters = [Utils.OutlineFilter];
            titleText.x = 10;
            titleText.y = headerText.height + headerText.y + 21;
            addChild(titleText);
            var rankText:String = _player.guildRank_ < 40 ? (_player.guildRank_ < 30 ? (_player.guildRank_ < 20 ? (_player.guildRank_ < 10 ?
                    "Initiate" : "Member") : "Officer") : "Leader") : "Founder";
            _guildText = new TextFieldDisplayConcrete().setSize(16).setColor(16777103).setBold(true).setMultiLine(true);
            _guildText.setStringBuilder(new LineBuilder().setParams("{guildRank}", {"guildRank": rankText}));
            _guildText.filters = [Utils.OutlineFilter];
            _guildText.x = 10;
            _guildText.y = titleText.height + titleText.y + 16;
            bitmapData = TextureRedrawer.redraw(AssetLibrary.getImageFromSet("interfaceBig", 0x14 - _player.guildRank_ / 10), 20, true, 0);
            icon = new Bitmap(bitmapData);
            icon.x = 114;
            icon.y = headerText.height + headerText.y + 27;
            addChild(icon);
            addChild(_guildText);
            _height = _guildText.y + _guildText.height + 24;
        }
    }

    private function updateBackground():void {
        background.modify(150 + (_extraNameWidth ? 12 : 0), _height, 2);
        _resized.dispatch();
    }

}
}
