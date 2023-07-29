package com.company.assembleegameclient.ui.guild {
import com.company.assembleegameclient.ui.LegacyScrollbar;
import com.company.assembleegameclient.util.GuildUtil;
import com.company.ui.BaseSimpleText;
import com.company.util.MoreObjectUtil;

import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class GuildPlayerList extends Sprite {

    private var num_:int;
    private var offset_:int;
    private var myName_:String;
    private var myRank_:int;
    private var listClient_:AppEngineClient;
    private var loadingText_:TextFieldDisplayConcrete;
    private var titleText_:BaseSimpleText;
    private var guildFameText_:BaseSimpleText;
    private var guildFameIcon_:Bitmap;
    private var lines_:Shape;
    private var mainSprite_:Sprite;
    private var listSprite_:Sprite;
    private var openSlotsText_:TextFieldDisplayConcrete;
    private var scrollBar_:LegacyScrollbar;

    public function GuildPlayerList(num:int, offset:int, myName:String = "", myRank:int = 0) {
        this.num_ = num;
        this.offset_ = offset;
        this.myName_ = myName;
        this.myRank_ = myRank;
        this.loadingText_ = new TextFieldDisplayConcrete().setSize(22).setColor(0xB3B3B3);
        this.loadingText_.setBold(true);
        this.loadingText_.setStringBuilder(new LineBuilder().setParams("Loading..."));
        this.loadingText_.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        this.loadingText_.setAutoSize(TextFieldAutoSize.CENTER).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        this.loadingText_.x = (Main.DefaultWidth / 2);
        this.loadingText_.y = Main.DefaultHeight - 50;
        addChild(this.loadingText_);
        var _local5:Account = Global.account;
        var _local6:Object = {
            "num": num,
            "offset": offset
        };
        MoreObjectUtil.addToObject(_local6, _local5.getCredentials());
        this.listClient_ = Global.appEngine;
        this.listClient_.setMaxRetries(2);
        this.listClient_.complete.addOnce(this.onComplete);
        this.listClient_.sendRequest("/guild/listMems", _local6);
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        if (_arg1) {
            this.onGenericData(_arg2);
        }
        else {
            this.onTextError(_arg2);
        }
    }

    private function onGenericData(_arg1:String):void {
        this.build(XML(_arg1));
    }

    private function onTextError(_arg1:String):void {
    }

    private function build(guild:XML):void {
        var _local2:Graphics;
        var _local5:XML;
        var openSlots:int;
        var _local7:Boolean;
        var _local8:int;
        var _local9:MemberListLine;
        removeChild(this.loadingText_);
        this.titleText_ = new BaseSimpleText(32, 0xB3B3B3, false, 0, 0);
        this.titleText_.setBold(true);
        this.titleText_.text = guild.@name;
        this.titleText_.useTextDimensions();
        this.titleText_.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        this.titleText_.y = 24;
        this.titleText_.x = ((Main.DefaultWidth / 2) - (this.titleText_.width / 2));
        addChild(this.titleText_);
        this.guildFameText_ = new BaseSimpleText(22, 0xFFFFFF, false, 0, 0);
        this.guildFameText_.text = guild.CurrentFame;
        this.guildFameText_.useTextDimensions();
        this.guildFameText_.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        this.guildFameText_.x = (Main.DefaultWidth - 32 - this.guildFameText_.width);
        this.guildFameText_.y = ((32 / 2) - (this.guildFameText_.height / 2));
        addChild(this.guildFameText_);
        this.guildFameIcon_ = new Bitmap(GuildUtil.guildFameIcon(40));
        this.guildFameIcon_.x = Main.DefaultWidth - 40;
        this.guildFameIcon_.y = ((32 / 2) - (this.guildFameIcon_.height / 2));
        addChild(this.guildFameIcon_);
        this.lines_ = new Shape();
        _local2 = this.lines_.graphics;
        _local2.clear();
        _local2.lineStyle(2, 0x545454);
        _local2.moveTo(0, 100);
        _local2.lineTo(stage.stageWidth, 100);
        _local2.lineStyle();
        addChild(this.lines_);
        this.mainSprite_ = new Sprite();
        this.mainSprite_.x = 10;
        this.mainSprite_.y = 110;
        var _local3:Shape = new Shape();
        _local2 = _local3.graphics;
        _local2.beginFill(0);
        _local2.drawRect(0, 0, MemberListLine.WIDTH, Main.DefaultHeight - 370);
        _local2.endFill();
        this.mainSprite_.addChild(_local3);
        this.mainSprite_.mask = _local3;
        addChild(this.mainSprite_);
        this.listSprite_ = new Sprite();
        var _local4:int;
        for each (_local5 in guild.Member) {
            _local7 = (this.myName_ == _local5.Name);
            _local8 = _local5.Rank;
            _local9 = new MemberListLine(((this.offset_ + _local4) + 1), _local5.Name, _local5.Rank, _local5.Fame, _local7, this.myRank_);
            _local9.y = (_local4 * MemberListLine.HEIGHT);
            this.listSprite_.addChild(_local9);
            _local4++;
        }
        var guildLevel:int = int(guild.@level);
        var maxMembers:int;
        switch (guildLevel){
            case 2:
                maxMembers = 60;
                break;
            case 3:
                maxMembers = 75;
                break;
            default:
                maxMembers = 50;
        }
        openSlots = maxMembers - (this.offset_ + _local4);
        this.openSlotsText_ = new TextFieldDisplayConcrete().setSize(22).setColor(0xB3B3B3);
        this.openSlotsText_.setStringBuilder(new LineBuilder().setParams("{openSlots} open slots", {"openSlots": openSlots}));
        this.openSlotsText_.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        this.openSlotsText_.setAutoSize(TextFieldAutoSize.CENTER);
        this.openSlotsText_.x = (MemberListLine.WIDTH / 2);
        this.openSlotsText_.y = (_local4 * MemberListLine.HEIGHT);
        this.listSprite_.addChild(this.openSlotsText_);
        this.mainSprite_.addChild(this.listSprite_);
        if (this.listSprite_.height > 400) {
            this.scrollBar_ = new LegacyScrollbar(16, 400);
            this.scrollBar_.x = ((Main.DefaultWidth - this.scrollBar_.width) - 4);
            this.scrollBar_.y = 104;
            this.scrollBar_.setIndicatorSize(400, this.listSprite_.height);
            this.scrollBar_.addEventListener(Event.CHANGE, this.onScrollBarChange);
            addChild(this.scrollBar_);
        }
    }

    private function onScrollBarChange(_arg1:Event):void {
        this.listSprite_.y = (-(this.scrollBar_.pos()) * (this.listSprite_.height - 400));
    }


}
}
