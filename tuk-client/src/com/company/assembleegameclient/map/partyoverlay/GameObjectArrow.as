package com.company.assembleegameclient.map.partyoverlay {
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.menu.Menu;
import com.company.util.RectangleUtil;
import com.company.util.Trig;

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

public class GameObjectArrow extends Sprite {

    public static const SMALL_SIZE:int = 8;
    public static const BIG_SIZE:int = 11;
    public static const DIST:int = 3;

    private static var menu_:Menu = null;

    public var menuLayer:DisplayObjectContainer;
    public var lineColor_:uint;
    public var fillColor_:uint;
    public var go_:GameObject = null;
    public var extraGOs_:Vector.<GameObject>;
    private var big_:Boolean;
    private var arrow_:Shape;
    private var tempPoint:Point;

    public function GameObjectArrow(_arg1:uint, _arg2:uint, _arg3:Boolean) {
        this.extraGOs_ = new Vector.<GameObject>();
        this.arrow_ = new Shape();
        this.tempPoint = new Point();
        super();
        this.lineColor_ = _arg1;
        this.fillColor_ = _arg2;
        this.big_ = _arg3;
        addChild(this.arrow_);
        this.drawArrow();
        filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8)];
        visible = false;
    }

    public static function removeMenu():void {
        if (menu_ != null) {
            if (menu_.parent != null) {
                menu_.parent.removeChild(menu_);
            }
            menu_ = null;
        }
    }

    public function setGameObject(_arg1:GameObject):void {
        if (this.go_ != _arg1) {
            this.go_ = _arg1;
        }
        this.extraGOs_.length = 0;
        if (this.go_ == null) {
            visible = false;
        }
    }

    public function addGameObject(_arg1:GameObject):void {
        this.extraGOs_.push(_arg1);
    }

    public function correctQuestNote(_arg_1:Rectangle):Rectangle {
        var _local_2:Rectangle = _arg_1.clone();
        if (stage.scaleMode == StageScaleMode.NO_SCALE) {
            this.scaleY = this.scaleX = ((stage.stageWidth < stage.stageHeight ? stage.stageWidth : stage.stageHeight) / WebMain.DefaultHeight) / Parameters.data_["mscale"];
        }
        else {
            this.scaleX = 1;
            this.scaleY = 1;
        }
        _local_2.right = _local_2.right - ((WebMain.DefaultWidth - this.go_.map_.gs_.hudView.x) * stage.stageWidth / WebMain.DefaultWidth) / Parameters.data_["mscale"];
        _local_2.top /= 3;
        _local_2.left /= 4;
        _local_2.bottom /= 3;
        _local_2.right /= 4;
        return _local_2;
    }

    public function draw(_arg_1:int, _arg_2:Camera):void {
        var _local_3:Rectangle;
        var _local_4:Number;
        var _local_5:Number;
        if (this.go_ == null) {
            visible = false;
            return;
        }
        this.go_.computeSortVal(_arg_2);
        _local_3 = correctQuestNote(_arg_2.clipRect_);
        _local_4 = this.go_.posS_[0];
        _local_5 = this.go_.posS_[1];
        if (!RectangleUtil.lineSegmentIntersectXY(_local_3, 0, 0, _local_4, _local_5, this.tempPoint)) {
            this.go_ = null;
            visible = false;
            return;
        }
        x = this.tempPoint.x;
        y = this.tempPoint.y;
        var _local_6:Number = Trig.boundTo180((270 - (Trig.toDegrees * Math.atan2(_local_4, _local_5))));
        if (this.tempPoint.x < (_local_3.left + 5)) {
            if (_local_6 > 45) {
                _local_6 = 45;
            }
            if (_local_6 < -45) {
                _local_6 = -45;
            }
        }
        else {
            if (this.tempPoint.x > (_local_3.right - 5)) {
                if (_local_6 > 0) {
                    if (_local_6 < 135) {
                        _local_6 = 135;
                    }
                }
                else {
                    if (_local_6 > -135) {
                        _local_6 = -135;
                    }
                }
            }
        }
        if (this.tempPoint.y < (_local_3.top + 5)) {
            if (_local_6 < 45) {
                _local_6 = 45;
            }
            if (_local_6 > 135) {
                _local_6 = 135;
            }
        }
        else {
            if (this.tempPoint.y > (_local_3.bottom - 5)) {
                if (_local_6 > -45) {
                    _local_6 = -45;
                }
                if (_local_6 < -135) {
                    _local_6 = -135;
                }
            }
        }
        this.arrow_.rotation = _local_6;
        visible = true;
    }

    private function drawArrow():void {
        var _local_1:Graphics = this.arrow_.graphics;
        _local_1.clear();
        var _local_2:int = (this.big_ ? BIG_SIZE : SMALL_SIZE);
        _local_1.lineStyle(1, this.lineColor_);
        _local_1.beginFill(this.fillColor_);
        _local_1.moveTo(DIST, 0);
        _local_1.lineTo((_local_2 + DIST), _local_2);
        _local_1.lineTo((_local_2 + DIST), -(_local_2));
        _local_1.lineTo(DIST, 0);
        _local_1.endFill();
        _local_1.lineStyle();
    }
}
}
