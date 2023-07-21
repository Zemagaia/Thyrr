package com.company.assembleegameclient.ui {
import com.company.ui.BaseSimpleText;
import com.company.util.BitmapUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.Sprite;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsPath;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;

import com.company.assembleegameclient.objects.GameObject;
import com.company.util.GraphicsUtil;

import flash.display.LineScaleMode;
import flash.display.CapsStyle;
import flash.display.JointStyle;

import com.company.assembleegameclient.util.FilterUtil;
import com.company.assembleegameclient.game.GameSprite;

public class DamageCounterFrame extends Sprite {

    private static const CUTS:Array = [1, 1, 1, 1];
    private static const MIN_WIDTH:int = 150;

    private var fill_:GraphicsSolidFill;
    private var path_:GraphicsPath;
    private var lineStyle_:GraphicsStroke;
    private var graphicsData_:Vector.<IGraphicsData>;
    private var backgrounds:Vector.<Sprite> = new Vector.<Sprite>(1);
    private var outline:Sprite;
    public var enemy:GameObject;
    private var enemyName:BaseSimpleText;
    private var damageDealt:BaseSimpleText;
    private var width_:int = 100;
    private var height_:int = 0;
    private var portrait_:Bitmap;

    public function DamageCounterFrame(go:GameObject) {
        this.enemy = go;
        this.drawBackground();
        this.drawOverlay();
        this.drawText(false);
        this.drawDmgDealt(false);
        this.drawPortrait(false);
        this.drawBackground(false);
        this.drawOverlay(false);
        addChild(this.backgrounds[0]);
        addChild(this.outline);
        addChild(this.enemyName);
        addChild(this.damageDealt);
        addChild(this.portrait_);
        this.backgrounds[0].alpha = this.outline.alpha = 0.6;
    }

    private var portraitEnemyName_:String;

    private function drawPortrait(draw:Boolean = true):void {
        if (((this.portrait_) && (this.portrait_.parent))) {
            this.portrait_.parent.removeChild(this.portrait_);
        }
        makePortrait(draw);
        this.portraitEnemyName_ = this.enemy.getName();
    }

    private function updatePortrait(draw:Boolean = true):void {
        if (this.portraitEnemyName_ == this.enemy.getName())
            return;
        else if (this.portraitEnemyName_ != this.enemy.getName())
            this.portraitEnemyName_ = this.enemy.getName();
        if (this.portrait_ != null)
            removeChild(this.portrait_);
        if (((this.portrait_) && (this.portrait_.parent))) {
            this.portrait_.parent.removeChild(this.portrait_);
        }
        if (this.enemyName != null && this.damageDealt != null) {
            makePortrait(draw);
        }
    }

    private function makePortrait(draw:Boolean = true):void {
        this.portrait_ = new Bitmap();
        this.portrait_.x = 4;
        this.portrait_.y = (((this.enemyName.y + this.enemyName.height) - (this.damageDealt.height / 2)) + 12);
        var bitmapData:BitmapData = this.enemy.getPortrait();
        bitmapData = BitmapUtil.cropToBitmapData(bitmapData, 10, 10, (bitmapData.width - 20), (bitmapData.height - 20));
        this.portrait_.bitmapData = bitmapData;
        ((draw) && (addChild(this.portrait_)));
        filters = [];
    }

    private function drawBackground(draw:Boolean = true):void {
        if (((this.backgrounds[0]) && (this.backgrounds[0].parent))) {
            this.backgrounds[0].parent.removeChild(this.backgrounds[0]);
        }
        this.fill_ = new GraphicsSolidFill(6036765, 1);
        this.path_ = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
        this.graphicsData_ = new <IGraphicsData>[this.fill_, this.path_, GraphicsUtil.END_FILL];
        this.backgrounds[0] = new Sprite();
        GraphicsUtil.clearPath(this.path_);
        GraphicsUtil.drawCutEdgeRect(0, 0, this.width_, this.height_, 4, CUTS, this.path_);
        this.backgrounds[0].graphics.clear();
        this.backgrounds[0].graphics.drawGraphicsData(this.graphicsData_);
        ((draw) && (addChild(this.backgrounds[0])));
    }

    private function drawOverlay(draw:Boolean = true):void {
        if (((this.outline) && (this.outline.parent))) {
            this.outline.parent.removeChild(this.outline);
        }
        this.fill_ = new GraphicsSolidFill(16549442, 1);
        this.lineStyle_ = new GraphicsStroke(2, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3, this.fill_);
        this.path_ = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
        this.graphicsData_ = new <IGraphicsData>[this.lineStyle_, this.path_, GraphicsUtil.END_STROKE];
        this.outline = new Sprite();
        GraphicsUtil.clearPath(this.path_);
        GraphicsUtil.drawCutEdgeRect(0, 0, this.width_, this.height_, 4, CUTS, this.path_);
        this.outline.graphics.drawGraphicsData(this.graphicsData_);
        ((draw) && (addChild(this.outline)));
    }

    private function drawText(draw:Boolean = true):void {
        if (((this.enemyName) && (this.enemyName.parent))) {
            this.enemyName.parent.removeChild(this.enemyName);
        }
        this.enemyName = new BaseSimpleText(19, 0xB3B3B3);
        this.enemyName.htmlText = (('<p align="center">' + this.enemy.getName()) + "</p>");
        this.enemyName.updateMetrics();
        this.enemyName.x = ((width / 2) - (this.enemyName.width / 2));
        this.enemyName.filters = FilterUtil.getDmgCounterMultiFilter();
        ((draw) && (addChild(this.enemyName)));
        this.width_ = Math.max((this.enemyName.width + 8), MIN_WIDTH);
        this.height_ = (this.height_ + this.enemyName.height);
        this.updatePortrait();
    }

    private function drawDmgDealt(draw:Boolean = true):void {
        if (((this.damageDealt) && (this.damageDealt.parent))) {
            this.damageDealt.parent.removeChild(this.damageDealt);
        }
        this.damageDealt = new BaseSimpleText(17, 0xB3B3B3);
        this.damageDealt.htmlText = ((('<p align="center">' + String(int(((this.enemy.damageDealt / this.enemy.maxHP_) * 100)))) + "%") + "</p>");
        this.damageDealt.updateMetrics();
        this.damageDealt.x = ((width / 2) - (this.damageDealt.width / 2));
        this.damageDealt.y = (((this.enemyName.y + this.enemyName.height) - (this.damageDealt.height / 2)) + 16);
        this.damageDealt.filters = FilterUtil.getDmgCounterMultiFilter();
        ((draw) && (addChild(this.damageDealt)));
        this.height_ = (this.height_ + (this.damageDealt.height + 9));
    }

    public function update(go:GameObject):void {
        this.enemy = go;
        this.redraw();
    }

    private function redraw():void {
        this.height_ = 0;
        this.drawText();
        this.drawDmgDealt();
        (parent as GameSprite).repositionDamageCounter();
    }


}
}