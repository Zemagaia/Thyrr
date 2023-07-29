package com.company.assembleegameclient.ui.tooltip {
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.GameObjectListItem;
import com.company.assembleegameclient.ui.StatusBar;

import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.filters.DropShadowFilter;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class QuestToolTip extends Sprite {

    private var _map:Map;
    private var _title:TextFieldDisplayConcrete;
    private var _name:TextFieldDisplayConcrete;
    private var _enemyGOLI:GameObjectListItem;
    private var _hpBar:StatusBar;
    private var _go:GameObject;

    public function QuestToolTip(map:Map) {
        _map = map;
        _title = new TextFieldDisplayConcrete();
        _name = new TextFieldDisplayConcrete();
        _enemyGOLI = new GameObjectListItem(0xB3B3B3, true, _go);
        _hpBar = new StatusBar(168, 16, 0xe03434, 6036765);
    }

    public function draw(time:int):void {
        var go:GameObject = _map.quest_.getObject(time);
        if (_go != null)
            _hpBar.draw(_go.hp_, _go.maxHP_, 0);
        if (stage != null) {
            if (stage.scaleMode == StageScaleMode.NO_SCALE) {
                this.scaleY = this.scaleX = ((stage.stageWidth < stage.stageHeight ? stage.stageWidth : stage.stageHeight) / Main.DefaultHeight) / Parameters.data_["mscale"];
            }
            else {
                this.scaleX = 1;
                this.scaleY = 1;
            }
        }
        if (go != _go) {
            setGameObject(go);
        }
        else {
            return;
        }
        if (contains(_title) && contains(_name) && contains(_enemyGOLI) && contains(_hpBar)) {
            graphics.clear();
            removeChild(_title);
            removeChild(_name);
            removeChild(_enemyGOLI);
            removeChild(_hpBar);
        }
        drawBackground();
        _enemyGOLI = new GameObjectListItem(0xB3B3B3, true, _go);
        addChild(_title);
        addChild(_name);
        addChild(_enemyGOLI);
        addChild(_hpBar);
        _title.setSize(22).setColor(16549442).setBold(true);
        _title.setStringBuilder(new LineBuilder().setParams("Quest!"));
        _name.setSize(13).setColor(0xB3B3B3).setBold(true).setWordWrap(true).setTextWidth(128);
        _name.setStringBuilder(new LineBuilder().setParams(_go.getName()));
        _name.filters = _title.filters = [new DropShadowFilter(0, 0, 0)];
        _enemyGOLI.setManualText(true);
        _hpBar.showPercentages(true);
        _hpBar.draw(_go.hp_, _go.maxHP_, 0);
        _title.x = 172 / 2 - _title.width / 2;
        _title.y = 2;
        _name.x = 40;
        _name.y = 28;
        _enemyGOLI.x = 4;
        _enemyGOLI.y = 26;
        _hpBar.x = 4;
        _hpBar.y = 70;
        _name.filters = _title.filters = [new DropShadowFilter(0,0,0)];
        _hpBar.alpha = 0.6;
    }

    private function drawBackground():void {
        graphics.lineStyle(2, 16549442, 0.8);
        graphics.beginFill(6036765, 0.6);
        graphics.drawRect(0, 0, 176, 90);
        graphics.endFill();
    }

    public function setGameObject(go:GameObject):void {
        if (_go != go) {
            _go = go;
            visible = true;
        }
        if (_go == null) {
            visible = false;
        }
    }

}
}
