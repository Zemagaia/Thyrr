package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.tooltip.PlayerToolTip;
import com.company.ui.BaseSimpleText;
import com.company.util.MoreColorUtil;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.ColorTransform;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.tooltips.HoverTooltipDelegate;

public class PlayerGameObjectListItem extends GameObjectListItem {

    public const hoverTooltipDelegate:HoverTooltipDelegate = new HoverTooltipDelegate();

    private var enabled:Boolean = true;
    private var starred:Boolean = false;

    private var _partyPlayerInfoImg:DisplayObject = new PartyPlayerInfo();
    private var _hpBar:StatusBar;
    private var _mpBar:StatusBar;
    private var _partyText:BaseSimpleText;

    public function PlayerGameObjectListItem(color:uint, isLongVersion:Boolean, go:GameObject) {
        addChild(_partyPlayerInfoImg);
        _hpBar = new StatusBar(86, 14, 0xC93038, 0xaea9a9, null, -1, true);
        _hpBar.x = 23;
        _hpBar.y = 25;
        _mpBar = new StatusBar(86, 14, 0x852D66, 0xaea9a9, null, -1, true);
        _mpBar.x = 23;
        _mpBar.y = 45;
        addChild(_hpBar);
        addChild(_mpBar);
        super(color, isLongVersion, go, false, false, false, true);
        var player:Player = (go as Player);
        if (player)
            this.starred = player.starred_;
        _partyText = new BaseSimpleText(13, color, false, 150);
        _partyText.y = 4;
        _partyText.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(_partyText);
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function onAddedToStage(_arg1:Event):void {
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        this.hoverTooltipDelegate.setDisplayObject(this);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function onMouseOver(_arg1:MouseEvent):void {
        this.hoverTooltipDelegate.tooltip = ((this.enabled) ? new PlayerToolTip(Player(go)) : null);
    }

    public function setEnabled(_arg1:Boolean):void {
        if (((!((this.enabled == _arg1))) && (!((Player(go) == null))))) {
            this.enabled = _arg1;
            this.hoverTooltipDelegate.tooltip = ((this.enabled) ? new PlayerToolTip(Player(go)) : null);
            if (!this.enabled) {
                Global.showTooltip(this.hoverTooltipDelegate.tooltip);
            }
        }
    }

    private var _p:Player;
    override public function draw(go:GameObject, colorTransform:ColorTransform = null, isParty:Boolean = false):void {
        _p = go as Player;
        if (_p) {
            _hpBar.draw(_p.hp_, _p.maxHP_, _p.maxHPBoost_, _p.maxHPMax_);
            _mpBar.draw(_p.mp_, _p.maxMP_, _p.maxMPBoost_, _p.maxMPMax_);
            _partyText.text = _p.getName();
            _partyText.setColor(this.getDrawColor());
            _partyText.setSize(13);
            if (_p.name_.length > 8)
                _partyText.setSize(11);
            _partyText.setAutoSize(TextFieldAutoSize.LEFT);
            _partyText.setBold(true);
            _partyText.useTextDimensions();
            _partyText.updateMetrics();
            _partyText.x = 6 + ((100 / 2) - (_partyText.width / 2));
        }
        if (_p && this.starred != _p.starred_) {
            transform.colorTransform = ((colorTransform) || (MoreColorUtil.identity));
            this.starred = _p.starred_;
        }
        super.draw(go, colorTransform, isParty);
    }

    private function getDrawColor():int {
        if (_p.isFellowGuild_) {
            return Parameters.FELLOW_GUILD_COLOR;
        }
        if (_p.nameChosen_) {
            return Parameters.NAME_CHOSEN_COLOR;
        }
        return 0xFFFFFF;
    }


}
}
