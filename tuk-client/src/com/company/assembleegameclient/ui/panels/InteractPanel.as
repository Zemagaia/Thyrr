﻿package com.company.assembleegameclient.ui.panels {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.IInteractiveObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.ItemGrid;

import flash.display.Sprite;
import flash.events.Event;

import kabam.rotmg.core.model.MapModel;

public class InteractPanel extends Sprite {

    public static const MAX_DIST:Number = 1;

    public var mapModel:MapModel = Global.mapModel;
    private var currentInteractive:IInteractiveObject;
    public var gs_:GameSprite;
    public var player_:Player;
    public var w_:int;
    public var h_:int;
    public var currentPanel:Panel = null;
    public var currObj_:IInteractiveObject = null;
    private var overridePanel_:Panel;
    public var requestInteractive:Function;

    public function InteractPanel(_arg1:GameSprite, _arg2:Player, _arg3:int, _arg4:int) {
        this.gs_ = _arg1;
        this.player_ = _arg2;
        this.w_ = _arg3;
        this.h_ = _arg4;
        addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    public function initialize(e:Event):void {
        this.requestInteractive = this.provideInteractive;
    }

    public function provideInteractive():IInteractiveObject {
        if (!this.isMapNameYardName()) {
            return (this.mapModel.currentInteractiveTarget);
        }
        return (this.currentInteractive);
    }

    private function isMapNameYardName():Boolean {
        return (this.gs_.map.isPetYard);
    }

    public function setOverride(_arg1:Panel):void {
        if (this.overridePanel_ != null) {
            this.overridePanel_.removeEventListener(Event.COMPLETE, this.onComplete);
        }
        this.overridePanel_ = _arg1;
        this.overridePanel_.addEventListener(Event.COMPLETE, this.onComplete);
    }

    public function redraw():void {
        if (this.currentPanel != null)
            this.currentPanel.draw();
    }

    public function draw():void {
        var _local1:IInteractiveObject;
        var _local2:Panel;
        if (this.overridePanel_ != null) {
            this.setPanel(this.overridePanel_);
            this.currentPanel.draw();
            return;
        }
        _local1 = this.requestInteractive();
        if ((((this.currentPanel == null)) || (!((_local1 == this.currObj_))))) {
            this.currObj_ = _local1;
            if (this.currObj_ != null)
                _local2 = this.currObj_.getPanel(this.gs_);
            this.setPanel(_local2);
        }
        if (this.currentPanel != null) {
            this.currentPanel.draw();
        }
    }

    private function onComplete(_arg1:Event):void {
        if (this.overridePanel_ != null) {
            this.overridePanel_.removeEventListener(Event.COMPLETE, this.onComplete);
            this.overridePanel_ = null;
        }
        this.setPanel(null);
        this.draw();
    }

    public function setPanel(_arg1:Panel):void {
        if (_arg1 != this.currentPanel) {
            ((this.currentPanel != null) && (removeChild(this.currentPanel)));
            this.currentPanel = _arg1;
            ((this.currentPanel != null) && (this.positionPanelAndAdd()));
        }
    }

    private function positionPanelAndAdd():void {
        addChild(this.currentPanel);
    }


}
}
