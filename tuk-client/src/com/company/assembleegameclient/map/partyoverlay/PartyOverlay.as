package com.company.assembleegameclient.map.partyoverlay {
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.map.Quest;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.tooltip.QuestToolTip;

import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;

public class PartyOverlay extends Sprite {

    public var map_:Map;
    public var questArrow_:QuestArrow;
    public var questToolTip_:QuestToolTip;

    public function PartyOverlay(_arg1:Map) {
        super();
        this.map_ = _arg1;
        this.questArrow_ = new QuestArrow(this.map_);
        this.questToolTip_ = new QuestToolTip(this.map_);
        this.questToolTip_.mouseChildren = false;
        this.questToolTip_.mouseEnabled = false;
        addChild(this.questArrow_);
        addChild(this.questToolTip_);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        GameObjectArrow.removeMenu();
    }

    public function draw(camera:Camera, time:int):void {
        var quest:Quest = this.map_.quest_;
        var questGO:GameObject = quest.getObject(time);
        if (this.map_.player_ == null || this.map_ == null || quest == null || questGO == null) {
            this.questToolTip_.setGameObject(null);
            this.questArrow_.setGameObject(null);
            return;
        }

        var mscale:Number = Parameters.data_.mscale;
        var distX:Number = (this.map_.player_.x_ - questGO.x_);
        var distY:Number = (this.map_.player_.y_ - questGO.y_);
        if (distX * distX + distY * distY < 96 / mscale)
            this.questArrow_.setGameObject(null);
        else
            this.questArrow_.draw(time, camera);
        if (stage != null) {
            if (stage.scaleMode == StageScaleMode.NO_SCALE) {
                this.questToolTip_.x = (-639 * WebMain.sWidth / WebMain.DefaultWidth) / Parameters.data_.mscale;
                this.questToolTip_.y = (-210 * WebMain.sHeight / WebMain.DefaultHeight) / Parameters.data_.mscale;
            }
            else {
                this.questToolTip_.x = -639;
                this.questToolTip_.y = -210;
            }
        }
        this.questToolTip_.draw(time);
    }

}
}
