﻿package com.company.assembleegameclient.screens {
import com.company.assembleegameclient.ui.GuildText;
import com.company.assembleegameclient.ui.RankText;
import com.company.assembleegameclient.ui.tooltip.RankToolTip;
import com.company.assembleegameclient.ui.tooltip.ToolTip;

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.core.model.PlayerModel;

import org.osflash.signals.Signal;

public class AccountScreen extends Sprite {

    public var playerModel:PlayerModel = Global.playerModel;
    private var rankLayer:Sprite;
    private var guildLayer:Sprite;
    private var guildName:String;
    private var guildRank:int;
    private var stars:int;
    private var rank:int;
    private var admin:Boolean;
    private var rankText:RankText;
    private var guildText:GuildText;

    public function AccountScreen() {
        this.makeLayers();
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void
    {
        this.setRank(this.playerModel.getNumStars(), this.playerModel.getRank(), this.playerModel.isAdmin());
        this.setGuild(this.playerModel.getGuildName(), this.playerModel.getGuildRank());
    }

    public function destroy(e:Event):void
    {
        Global.hideTooltip();
    }

    private function onTooltip(_arg1:ToolTip):void
    {
        Global.showTooltip(_arg1);
    }

    private function makeLayers():void {
        addChild((this.rankLayer = new Sprite()));
        addChild((this.guildLayer = new Sprite()));
    }

    private function returnHeaderBackground():DisplayObject {
        var _local1:Shape = new Shape();
        _local1.graphics.beginFill(0, 0.5);
        _local1.graphics.drawRect(0, 0, Main.DefaultWidth, 35);
        return (_local1);
    }

    public function setGuild(_arg1:String, _arg2:int):void {
        this.guildName = _arg1;
        this.guildRank = _arg2;
        this.makeGuildText();
    }

    private function makeGuildText():void {
        this.guildText = new GuildText(this.guildName, this.guildRank);
        this.guildText.x = 36 + this.rankText.width + 6;
        this.guildText.y = 6;
        while (this.guildLayer.numChildren > 0) {
            this.guildLayer.removeChildAt(0);
        }
        this.guildLayer.addChild(this.guildText);
    }

    public function setRank(numStars:int, rank:int, isAdmin:Boolean):void {
        this.stars = numStars;
        this.rank = rank;
        this.admin = isAdmin;
        this.makeRankText();
    }

    private function makeRankText():void {
        this.rankText = new RankText(this.stars, true, false, this.rank, this.admin);
        this.rankText.x = 36;
        this.rankText.y = 4;
        this.rankText.mouseEnabled = true;
        this.rankText.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        this.rankText.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
        while (this.rankLayer.numChildren > 0) {
            this.rankLayer.removeChildAt(0);
        }
        this.rankLayer.addChild(this.rankText);
    }

    protected function onMouseOver(_arg1:MouseEvent):void {
        onTooltip(new RankToolTip(this.stars));
    }

    protected function onRollOut(_arg1:MouseEvent):void {
        Global.hideTooltip();
    }


}
}
