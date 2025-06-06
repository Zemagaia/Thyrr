﻿package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.Panel;
import com.company.assembleegameclient.ui.tooltip.ToolTip;

import flash.display.BitmapData;

import kabam.rotmg.game.view.SellableObjectPanel;

public class SellableObject extends GameObject implements IInteractiveObject {

    public var price_:int = 0;
    public var currency_:int = -1;
    public var rankReq_:int = 0;
    public var guildRankReq_:int = -1;

    public function SellableObject(_arg1:XML) {
        super(_arg1);
        isInteractive_ = true;
    }

    public function setPrice(_arg1:int):void {
        this.price_ = _arg1;
    }

    public function setCurrency(_arg1:int):void {
        this.currency_ = _arg1;
    }

    public function setRankReq(_arg1:int):void {
        this.rankReq_ = _arg1;
    }

    public function soldObjectName():String {
        return (null);
    }

    public function soldObjectInternalName():String {
        return (null);
    }

    public function getTooltip():ToolTip {
        return (null);
    }

    public function getIcon():BitmapData {
        return (null);
    }

    public function getSellableType():int {
        return (-1);
    }

    public function getPanel(_arg1:GameSprite):Panel {
        return (new SellableObjectPanel(_arg1, this));
    }


}
}
