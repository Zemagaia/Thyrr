package com.company.assembleegameclient.ui.menu {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.GameObjectListItem;
import com.company.assembleegameclient.util.GuildUtil;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.util.AssetLibrary;

import flash.display.BitmapData;

import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.chat.control.ShowChatInputSignal;
import kabam.rotmg.core.StaticInjectorContext;


public class PlayerMenu extends Menu {

    public var gs_:GameSprite;
    public var playerName_:String;
    public var player_:Player;
    public var playerPanel_:GameObjectListItem;

    public function PlayerMenu() {
        super(0x2B2B2B, 0x7B7B7B);
    }

    public function initDifferentServer(_arg1:GameSprite, _arg2:String, _arg3:Boolean = false, _arg4:Boolean = false):void {
        var _local5:MenuOption;
        this.gs_ = _arg1;
        this.playerName_ = _arg2;
        this.player_ = null;
        this.yOffset = (this.yOffset - 25);
        _local5 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x15), 0xFFFFFF, "Whisper");
        _local5.addEventListener(MouseEvent.CLICK, this.onPrivateMessage);
        addOption(_local5);
        if (_arg3) {
            _local5 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x15), 0xFFFFFF, "Guild Chat");
            _local5.addEventListener(MouseEvent.CLICK, this.onGuildMessage);
            addOption(_local5);
        }
        if (_arg4) {
            _local5 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x07), 0xFFFFFF, "Trade");
            _local5.addEventListener(MouseEvent.CLICK, this.onTradeMessage);
            addOption(_local5);
        }
    }

    public function init(_arg1:GameSprite, _arg2:Player):void {
        var _local3:MenuOption;
        this.gs_ = _arg1;
        this.playerName_ = _arg2.name_;
        this.player_ = _arg2;
        this.playerPanel_ = new GameObjectListItem(0xB3B3B3, true, this.player_, false, true);
        var bitmapData:BitmapData = (((player_.props_.portrait_) != null) ? player_.props_.portrait_.getTexture() : player_.texture_);
        this.playerPanel_.portrait.bitmapData = TextureRedrawer.resize(bitmapData, player_.mask_, ((4 / bitmapData.width) * 100), true, player_.getTex1(), player_.getTex2());
        this.playerPanel_.portrait.bitmapData = GlowRedrawer.outline(this.playerPanel_.portrait.bitmapData, 0);
        this.yOffset = (this.yOffset + 7);
        addChild(this.playerPanel_);
        if (((this.gs_.map.allowPlayerTeleport()) && (this.player_.isTeleportEligible(this.player_)))) {
            _local3 = new TeleportMenuOption(this.gs_.map.player_);
            _local3.addEventListener(MouseEvent.CLICK, this.onTeleport);
            addOption(_local3);
        }
        if ((((this.gs_.map.player_.guildRank_ >= GuildUtil.OFFICER)) && ((((_arg2.guildName_ == null)) || ((_arg2.guildName_.length == 0)))))) {
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 10), 0xFFFFFF, "Invite");
            _local3.addEventListener(MouseEvent.CLICK, this.onInvite);
            addOption(_local3);
        }
        if (!this.player_.starred_) {
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x0), 0xFFFFFF, "Lock");
            _local3.addEventListener(MouseEvent.CLICK, this.onLock);
            addOption(_local3);
        }
        else {
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x01), 0xFFFFFF, "Unlock");
            _local3.addEventListener(MouseEvent.CLICK, this.onUnlock);
            addOption(_local3);
        }
        _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x07), 0xFFFFFF, "Trade");
        _local3.addEventListener(MouseEvent.CLICK, this.onTrade);
        addOption(_local3);
        _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x15), 0xFFFFFF, "Whisper");
        _local3.addEventListener(MouseEvent.CLICK, this.onPrivateMessage);
        addOption(_local3);
        if (this.player_.isFellowGuild_) {
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x15), 0xFFFFFF, "Guild Chat");
            _local3.addEventListener(MouseEvent.CLICK, this.onGuildMessage);
            addOption(_local3);
        }
        if (!this.player_.ignored_) {
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x08), 0xFFFFFF, "Ignore");
            _local3.addEventListener(MouseEvent.CLICK, this.onIgnore);
            addOption(_local3);
        }
        else {
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x09), 0xFFFFFF, "Unignore");
            _local3.addEventListener(MouseEvent.CLICK, this.onUnignore);
            addOption(_local3);
        }
        if (((Player.isAdmin) || (Player.isMod))) {
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x0f), 0xFFFFFF, "Ban MultiBoxer");
            _local3.addEventListener(MouseEvent.CLICK, this.onBanMultiBox);
            addOption(_local3);
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x0f), 0xFFFFFF, "Ban RWT");
            _local3.addEventListener(MouseEvent.CLICK, this.onBanRWT);
            addOption(_local3);
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x0f), 0xFFFFFF, "Ban Cheat");
            _local3.addEventListener(MouseEvent.CLICK, this.onBanCheat);
            addOption(_local3);
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x04), 0xFFFFFF, "Mute");
            _local3.addEventListener(MouseEvent.CLICK, this.onMute);
            addOption(_local3);
            _local3 = new MenuOption(AssetLibrary.getImageFromSet("interfaceBig", 0x03), 0xFFFFFF, "Unmute");
            _local3.addEventListener(MouseEvent.CLICK, this.onUnMute);
            addOption(_local3);
        }
    }

    private function onBanMultiBox(_arg1:Event):void {
        this.gs_.gsc_.playerText((("/ban " + this.player_.name_) + " Multiboxing"));
        remove();
    }

    private function onBanRWT(_arg1:Event):void {
        this.gs_.gsc_.playerText((("/ban " + this.player_.name_) + " RWT"));
        remove();
    }

    private function onBanCheat(_arg1:Event):void {
        this.gs_.gsc_.playerText((("/ban " + this.player_.name_) + " Cheating"));
        remove();
    }

    private function onMute(_arg1:Event):void {
        this.gs_.gsc_.playerText(("/mute " + this.player_.name_));
        remove();
    }

    private function onUnMute(_arg1:Event):void {
        this.gs_.gsc_.playerText(("/unmute " + this.player_.name_));
        remove();
    }

    private function onPrivateMessage(_arg1:Event):void {
        var _local2:ShowChatInputSignal = StaticInjectorContext.getInjector().getInstance(ShowChatInputSignal);
        _local2.dispatch(true, (("/tell " + this.playerName_) + " "));
        remove();
    }

    private function onTradeMessage(_arg1:Event):void {
        var _local2:ShowChatInputSignal = StaticInjectorContext.getInjector().getInstance(ShowChatInputSignal);
        _local2.dispatch(true, ("/trade " + this.playerName_));
        remove();
    }

    private function onGuildMessage(_arg1:Event):void {
        var _local2:ShowChatInputSignal = StaticInjectorContext.getInjector().getInstance(ShowChatInputSignal);
        _local2.dispatch(true, "/g ");
        remove();
    }

    private function onTeleport(_arg1:Event):void {
        this.gs_.map.player_.teleportTo(this.player_);
        remove();
    }

    private function onInvite(_arg1:Event):void {
        this.gs_.gsc_.guildInvite(this.playerName_);
        remove();
    }

    private function onLock(_arg1:Event):void {
        this.gs_.map.party_.lockPlayer(this.player_);
        remove();
    }

    private function onUnlock(_arg1:Event):void {
        this.gs_.map.party_.unlockPlayer(this.player_);
        remove();
    }

    private function onTrade(_arg1:Event):void {
        this.gs_.gsc_.requestTrade(this.playerName_);
        remove();
    }

    private function onIgnore(_arg1:Event):void {
        this.gs_.map.party_.ignorePlayer(this.player_);
        remove();
    }

    private function onUnignore(_arg1:Event):void {
        this.gs_.map.party_.unignorePlayer(this.player_);
        remove();
    }


}
}
