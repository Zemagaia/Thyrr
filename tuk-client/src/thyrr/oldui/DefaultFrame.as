package thyrr.oldui
{
import thyrr.utils.*;

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;

import flash.display.BitmapData;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.util.components.DialogBackground;

import thyrr.oldui.closeButton.DialogCloseButton;

public class DefaultFrame extends Sprite
{

    private static const WIDTH:int = Main.DefaultWidth / 2;
    private static const HEIGHT:int = WIDTH - 54;

    protected var gameSprite_:GameSprite;
    protected var closeButton_:DialogCloseButton;
    public var background_:DialogBackground = new DialogBackground();
    public var tabs_:Vector.<DefaultFrameTab>;

    public function DefaultFrame(gameSprite:GameSprite, tabs:Vector.<String>, bitmapDatas:Vector.<BitmapData>, width:int = 0, height:int = 0)
    {
        super();
        drawDarkLayer();
        drawBackground(width == 0 ? WIDTH : width, height == 0 ? HEIGHT : height);
        this.gameSprite_ = gameSprite;
        this.closeButton_ = new DialogCloseButton();
        this.closeButton_.x = this.background_.x + this.background_.width - this.closeButton_.width - 6;
        this.closeButton_.y = this.background_.y + 4;
        this.closeButton_.addEventListener(MouseEvent.CLICK, this.onClose);
        this.tabs_ = new Vector.<DefaultFrameTab>(tabs.length);
        var i:int = 0;
        while (i < this.tabs_.length)
        {
            this.tabs_[i] = new DefaultFrameTab(bitmapDatas[i], tabs[i]);
            positionTab(i);
            addChild(this.tabs_[i]);
            i++;
        }
        addChild(this.background_);
        addChild(this.closeButton_);
    }

    public function update(text:String, selected:Boolean):void
    {
        for each (var tab:DefaultFrameTab in this.tabs_)
        {
            if (tab.text_ == text && selected)
                tab.filters = [];
            else
                tab.filters = ItemTileSprite.DIM_FILTER;
        }
    }

    private function drawBackground(width:int, height:int):void
    {
        this.background_.graphics.clear();
        this.background_.draw(width, height, 0);
        this.background_.x = Main.DefaultWidth / 2 - width / 2;
        this.background_.y = Main.DefaultHeight / 2 - (height - 30) / 2;
    }

    private function drawDarkLayer():void
    {
        graphics.clear();
        graphics.beginFill(0x2B2B2B, 0.8);
        graphics.drawRect(0, 0, Main.DefaultWidth, Main.DefaultHeight);
        graphics.endFill();
    }

    // redraw background graphic & reposition tabs
    public function resizeBackground(width:int, height:int):void
    {
        this.drawBackground(width, height);
        this.closeButton_.x = this.background_.x + this.background_.width - this.closeButton_.width - 6;
        this.closeButton_.y = this.background_.y + 4;
        var i:int = 0;
        while (i < this.tabs_.length)
        {
            positionTab(i);
            i++;
        }
    }

    private function positionTab(i:int):void
    {
        this.tabs_[i].x = i - 1 < 0 ? this.background_.x : this.tabs_[i - 1].x + this.tabs_[i - 1].width_ + 6;
        this.tabs_[i].y = this.background_.y - 30;
    }

    protected function onClose(event:Event):void
    {
        this.close();
    }

    public function close():void
    {
        var i:int = 0;
        this.gameSprite_.mui_.setEnablePlayerInput(true);
        this.gameSprite_ = null;
        this.closeButton_.removeEventListener(MouseEvent.CLICK, this.onClose);
        this.closeButton_ = null;
        while (i < numChildren)
        {
            removeChildAt(i);
            i++;
        }
        this.background_ = null;
        stage.focus = null;
        parent.removeChild(this);
    }
}
}