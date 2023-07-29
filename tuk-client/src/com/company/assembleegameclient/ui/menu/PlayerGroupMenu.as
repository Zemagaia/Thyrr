package com.company.assembleegameclient.ui.menu {
import com.company.assembleegameclient.map.AbstractMap;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.GameObjectListItem;
import com.company.assembleegameclient.ui.LineBreakDesign;

import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.chat.model.ChatMessage;

public class PlayerGroupMenu extends Menu {

    private var playerPanels_:Vector.<GameObjectListItem>;
    private var posY:uint = 4;
    public var map_:AbstractMap;
    public var players_:Vector.<Player>;
    public var teleportOption_:MenuOption;
    public var lineBreakDesign_:LineBreakDesign;

    public function PlayerGroupMenu(_arg1:AbstractMap, _arg2:Vector.<Player>) {
        this.playerPanels_ = new Vector.<GameObjectListItem>();
        super(0x2B2B2B, 0x7B7B7B);
        this.map_ = _arg1;
        this.players_ = _arg2.concat();
        this.createHeader();
        this.createPlayerList();
    }

    private function onUnableToTeleport():void {
        Global.addTextLine(ChatMessage.make(Parameters.ERROR_CHAT_NAME, "No players are eligible for teleporting"));
    }

    private function createPlayerList():void {
        var _local1:Player;
        var _local2:GameObjectListItem;
        for each (_local1 in this.players_) {
            _local2 = new GameObjectListItem(0x7B7B7B, true, _local1);
            _local2.x = 0;
            _local2.y = this.posY;
            addChild(_local2);
            this.playerPanels_.push(_local2);
            this.posY = (this.posY + 32);
        }
    }

    private function createHeader():void {
        if (this.map_.allowPlayerTeleport()) {
            this.teleportOption_ = new TeleportMenuOption(this.map_.player_);
            this.teleportOption_.x = 8;
            this.teleportOption_.y = 8;
            this.teleportOption_.addEventListener(MouseEvent.CLICK, this.onTeleport);
            addChild(this.teleportOption_);
            this.lineBreakDesign_ = new LineBreakDesign(150, 0x1C1C1C);
            this.lineBreakDesign_.x = 6;
            this.lineBreakDesign_.y = 40;
            addChild(this.lineBreakDesign_);
            this.posY = 52;
        }
    }

    private function onTeleport(_arg1:Event):void {
        var _local4:Player;
        var _local2:Player = this.map_.player_;
        var _local3:Player;
        for each (_local4 in this.players_) {
            if (_local2.isTeleportEligible(_local4)) {
                _local3 = _local4;
                if (_local4.isFellowGuild_) break;
            }
        }
        if (_local3 != null) {
            _local2.teleportTo(_local3);
        }
        else {
            onUnableToTeleport();
        }
        remove();
    }


}
}
