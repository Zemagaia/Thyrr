package thyrr.ui.items
{

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import thyrr.ui.buttons.HoldableButton;
import thyrr.ui.utils.UIElement;
import thyrr.utils.Utils;

public class Scrollbar extends UIElement
{

    private var width_:int;
    private var height_:int;
    private var speed_:Number;
    private var indicatorRect_:Rectangle;
    private var jumpDist_:Number;
    private var background_:Sprite;
    private var upArrow_:HoldableButton;
    private var downArrow_:HoldableButton;
    private var posIndicator_:FlexibleBox;
    private var targets_:Vector.<Sprite>;
    private var lastUpdateTime_:int;
    private var change_:Number;
    private var objectHeight_:Number = -1;

    public function Scrollbar(width:int, height:int, speed:Number = 1.5, ... targets)
    {
        super();
        this.targets_ = new Vector.<Sprite>();
        var i:int = 0;
        while (i < targets.length)
        {
            if (targets[i] is Sprite)
                targets_.push(targets[i]);
            i++;
        }
        this.background_ = new Sprite();
        this.background_.addEventListener(MouseEvent.MOUSE_DOWN, this.onBackgroundDown);
        addChild(this.background_);
        this.resize(width, height, speed);
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    public function pos():Number
    {
        return (this.posIndicator_.y - this.indicatorRect_.y) / (this.indicatorRect_.height - this.posIndicator_.height);
    }

    public function setIndicatorSize(height:Number, objectHeight:Number, resetPos:Boolean = true):void
    {
        this.objectHeight_ = objectHeight;
        var h:int = objectHeight == 0 ? this.indicatorRect_.height : (height / objectHeight) * this.indicatorRect_.height;
        h = Math.min(this.indicatorRect_.height, Math.max(this.width_, h));
        if (contains(posIndicator_))
        {
            posIndicator_.dispose();
            removeChild(posIndicator_);
        }
        this.posIndicator_ = this.getIndicator(4, h);
        addChild(this.posIndicator_);
        this.jumpDist_ = (height / (objectHeight - height)) * (speed_ / 10);
        if (resetPos)
        {
            this.setPos(0);
        }
    }

    public function setPos(pos:Number):void
    {
        pos = Math.max(0, Math.min(1, pos));
        this.posIndicator_.y = ((pos * (this.indicatorRect_.height - this.posIndicator_.height)) + this.indicatorRect_.y);
        this.sendPos();
    }

    public function jumpUp():void
    {
        this.setPos((this.pos() - this.jumpDist_));
    }

    public function jumpDown():void
    {
        this.setPos((this.pos() + this.jumpDist_));
    }

    private function getIndicator(icon:int, height:int):FlexibleBox
    {
        var box:FlexibleBox = new FlexibleBox(width_, height, 0xaea9a9, icon, false);
        box.addEventListener(MouseEvent.MOUSE_DOWN, this.onStartIndicatorDrag);
        return box;
    }

    private function getArrow(icon:int, func:Function, rotation:int):HoldableButton
    {
        var box:HoldableButton = new HoldableButton(width_, width_, 0xaea9a9, icon, false);
        box.addEventListener(MouseEvent.MOUSE_DOWN, func);
        box.rotation = rotation;
        return box;
    }

    private function onBackgroundDown(e:MouseEvent):void
    {
        if (e.localY < this.posIndicator_.y)
        {
            this.jumpUp();
        }
        else
        {
            this.jumpDown();
        }
    }

    protected function onAddedToStage(e:Event):void
    {
        if (this.targets_.length > 0)
        {
            var i:int = 0;
            while (i < targets_.length)
            {
                this.targets_[i].addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
                i++;
            }
        }
        else
        {
            WebMain.STAGE.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
        }
    }

    protected function onRemovedFromStage(e:Event):void
    {
        dispose();
    }

    protected function onMouseWheel(e:MouseEvent):void
    {
        if (e.delta > 0)
        {
            this.jumpUp();
            if (pos() < 0)
                setPos(0);
        }
        else if (e.delta < 0)
        {
            this.jumpDown();
            if (pos() < 0)
                setPos(0);
        }
    }

    private function onUpArrowDown(e:MouseEvent):void
    {
        addEventListener(Event.ENTER_FRAME, this.onArrowFrame);
        addEventListener(MouseEvent.MOUSE_UP, this.onArrowUp);
        addEventListener(MouseEvent.ROLL_OUT, this.onArrowRollOut);
        this.lastUpdateTime_ = getTimer();
        this.change_ = -(this.speed_);
    }

    private function onDownArrowDown(e:MouseEvent):void
    {
        addEventListener(Event.ENTER_FRAME, this.onArrowFrame);
        addEventListener(MouseEvent.MOUSE_UP, this.onArrowUp);
        addEventListener(MouseEvent.ROLL_OUT, this.onArrowRollOut);
        this.lastUpdateTime_ = getTimer();
        this.change_ = this.speed_;
    }

    private function onArrowFrame(e:Event):void
    {
        var time:int = getTimer();
        var delta:Number = (time - this.lastUpdateTime_) / 1000;
        var h:Number = objectHeight_ > 0 ? height_ * (height_ / objectHeight_) : height_;
        var jumpDist:Number = (h - this.width_ * 3) * delta * this.change_;
        this.setPos((this.posIndicator_.y + jumpDist - this.indicatorRect_.y) / (this.indicatorRect_.height - this.posIndicator_.height));
        this.lastUpdateTime_ = time;
    }

    private function onArrowUp(e:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, this.onArrowFrame);
        removeEventListener(MouseEvent.MOUSE_UP, this.onArrowUp);
        removeEventListener(MouseEvent.ROLL_OUT, this.onArrowRollOut);
    }

    private function onArrowRollOut(e:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, this.onArrowFrame);
        removeEventListener(MouseEvent.MOUSE_UP, this.onArrowUp);
        removeEventListener(MouseEvent.ROLL_OUT, this.onArrowRollOut);
    }

    private function onStartIndicatorDrag(e:MouseEvent):void
    {
        this.posIndicator_.startDrag(false, new Rectangle(0, this.indicatorRect_.y, 0, (this.indicatorRect_.height - this.posIndicator_.height)));
        stage.addEventListener(MouseEvent.MOUSE_UP, this.onStopIndicatorDrag);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onDragMove);
        this.sendPos();
    }

    private function onStopIndicatorDrag(e:MouseEvent):void
    {
        stage.removeEventListener(MouseEvent.MOUSE_UP, this.onStopIndicatorDrag);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onDragMove);
        this.posIndicator_.stopDrag();
        this.sendPos();
    }

    private function onDragMove(e:MouseEvent):void
    {
        this.sendPos();
    }

    private function sendPos():void
    {
        dispatchEvent(new Event(Event.CHANGE));
    }

    public function resize(width:int, height:int, speed:Number = 1):void
    {
        if (this.upArrow_)
        {
            upArrow_.dispose();
            downArrow_.dispose();
            posIndicator_.dispose();
            removeChild(this.upArrow_);
            removeChild(this.downArrow_);
            removeChild(this.posIndicator_);
        }
        this.width_ = width;
        this.height_ = height;
        this.speed_ = speed;
        this.indicatorRect_ = new Rectangle(0, width_, this.width_, this.height_ - width_ * 2);
        var g:Graphics = this.background_.graphics;
        g.clear();
        g.beginFill(Utils.color(0xAEA9A9, 1 / (1.3 * 1.3)), 1);
        g.drawRect(this.indicatorRect_.x, this.indicatorRect_.y, this.indicatorRect_.width, this.indicatorRect_.height);
        g.endFill();
        this.upArrow_ = this.getArrow(3, this.onUpArrowDown, 0);
        this.downArrow_ = this.getArrow(3, this.onDownArrowDown, 180);
        this.posIndicator_ = this.getIndicator(4, height_ - width_ * 2);
        addChild(this.upArrow_);
        addChild(this.downArrow_);
        addChild(this.posIndicator_);
        this.posIndicator_.y = this.upArrow_.height;
        this.downArrow_.x = this.downArrow_.width;
        this.downArrow_.y = this.height_;
    }

    public override function dispose():void
    {
        if (posIndicator_)
            posIndicator_.dispose();
        if (downArrow_)
            downArrow_.dispose();
        if (upArrow_)
            upArrow_.dispose();
        if (this.targets_.length > 0)
        {
            var i:int = 0;
            while (i < targets_.length)
            {
                this.targets_[i].removeEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
                i++;
            }
        }
        else
        {
            WebMain.STAGE.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
        }
        removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

}
}