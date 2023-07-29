package com.company.assembleegameclient.ui.panels {
import com.company.assembleegameclient.account.ui.CreateGuildFrame;
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.ui.dialogs.Dialog;
import com.company.assembleegameclient.util.Currency;
import com.company.assembleegameclient.util.GuildUtil;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.view.SignalWaiter;
import kabam.rotmg.util.components.LegacyBuyButton;

public class GuildRegisterPanel extends Panel {

    public var hudModel:HUDModel = Global.hudModel;
    public const waiter:SignalWaiter = new SignalWaiter();

    private var title_:TextFieldDisplayConcrete;
    private var button_:Sprite;

    public function GuildRegisterPanel(_arg1:GameSprite) {
        var _local2:Player;
        var _local3:String;
        var _local4:LegacyBuyButton;
        super(_arg1);
        if ((((gs_.map == null)) || ((gs_.map.player_ == null)))) {
            return;
        }
        _local2 = gs_.map.player_;
        this.title_ = new TextFieldDisplayConcrete().setSize(18).setColor(0xFFFFFF).setTextWidth(WIDTH).setWordWrap(true).setMultiLine(true).setAutoSize(TextFieldAutoSize.CENTER).setHTML(true);
        this.title_.filters = [new DropShadowFilter(0, 0, 0)];
        if (((!((_local2.guildName_ == null))) && ((_local2.guildName_.length > 0)))) {
            _local3 = GuildUtil.rankToString(_local2.guildRank_);
            this.title_.setStringBuilder(new LineBuilder().setParams("{rank} of \n{guildName}", {
                "rank": _local3,
                "guildName": _local2.guildName_
            }).setPrefix('<p align="center">').setPostfix("</p>"));
            this.title_.y = 0;
            addChild(this.title_);
            this.button_ = new DeprecatedTextButton(16, "Renounce");
            this.button_.addEventListener(MouseEvent.CLICK, this.onRenounceClick);
            this.waiter.push(DeprecatedTextButton(this.button_).textChanged);
            addChild(this.button_);
        }
        else {
            this.title_.setStringBuilder(new LineBuilder().setParams("Create a Guild").setPrefix('<p align="center">').setPostfix("</p>"));
            this.title_.y = 0;
            addChild(this.title_);
            _local4 = new LegacyBuyButton("Create {cost}", 16, Parameters.GUILD_CREATION_PRICE, Currency.FAME);
            _local4.addEventListener(MouseEvent.CLICK, this.onCreateClick);
            this.waiter.push(_local4.readyForPlacement);
            addChild(_local4);
            this.button_ = _local4;
        }
        this.waiter.complete.addOnce(this.alignUI);
    }

    private function onRenounceClick(_arg1:MouseEvent):void {
        var _local1:GameSprite = this.hudModel.gameSprite;
        if ((((_local1.map == null)) || ((_local1.map.player_ == null)))) {
            return;
        }
        var _local2:Player = _local1.map.player_;
        var _local3:Dialog = new Dialog("Renounce Guild", "Are you sure you want to quit:\n{guildName}", "Yes, I'll quit", "No, I'll stay", "/renounceGuild");
        _local3.setTextParams("Are you sure you want to quit:\n{guildName}", {"guildName": _local2.guildName_});
        _local3.addEventListener(Dialog.LEFT_BUTTON, this.onRenounce);
        _local3.addEventListener(Dialog.RIGHT_BUTTON, this.onCancel);
        Global.openDialog(_local3);
    }

    private function onCancel(_arg1:Event):void {
        Global.closeDialogs();
    }

    private function onRenounce(_arg1:Event):void {
        var _local2:GameSprite = this.hudModel.gameSprite;
        if ((((_local2.map == null)) || ((_local2.map.player_ == null)))) {
            return;
        }
        var _local3:Player = _local2.map.player_;
        _local2.gsc_.guildRemove(_local3.name_);
        Global.closeDialogs();
    }

    private function alignUI():void {
        this.button_.x = ((WIDTH / 2) - (this.button_.width / 2));
        this.button_.y = (((this.button_ is LegacyBuyButton)) ? ((HEIGHT - (this.button_.height / 2)) - 31) : ((HEIGHT - this.button_.height) - 4));
    }

    public function onCreateClick(_arg1:MouseEvent):void {
        visible = false;
        Global.openDialog(new CreateGuildFrame(this.hudModel.gameSprite));
    }


}
}
