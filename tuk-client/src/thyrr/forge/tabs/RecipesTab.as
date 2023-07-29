package thyrr.forge.tabs {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.ui.LegacyScrollbar;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;

import thyrr.forge.model.ForgeRecipe;

import thyrr.oldui.DefaultTab;

public class RecipesTab extends DefaultTab {

    private static const TOP_Y:int = Main.DefaultHeight / 2 - 290;
    private static const CENTERED_X:int = Main.DefaultWidth / 2;
    private static const LEFT_X:int = CENTERED_X - 295;

    private var shape_:Shape;
    private var resultMask_:Sprite;
    private var resultBackground_:Sprite;
    private var resultItems_:Vector.<ForgeRecipe>;
    private var resultScroll_:LegacyScrollbar;

    public function RecipesTab(gameSprite:GameSprite) {
        super(gameSprite);
        this.gameSprite_ = gameSprite;
        this.shape_ = new Shape();
        this.shape_.graphics.beginFill(0);
        this.shape_.graphics.drawRect(LEFT_X, TOP_Y + 16, 580, 580);
        this.shape_.graphics.endFill();
        this.resultMask_ = new Sprite();
        this.resultMask_.addChild(this.shape_);
        this.resultMask_.mask = this.shape_;
        addChild(this.resultMask_);
        this.resultBackground_ = new Sprite();
        this.resultMask_.addChild(this.resultBackground_);
        this.resultItems_ = new Vector.<ForgeRecipe>();
        this.draw();
    }

    private function draw():void {
        if (this.resultScroll_ != null) {
            this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            removeChild(this.resultScroll_);
            this.resultScroll_ = null;
        }

        for each (var r:* in ObjectLibrary.forgeRecipes_) {
            var recipe:Vector.<String> = r["key"];
            var result:String = r["value"];
            var forgeRecipe:ForgeRecipe = new ForgeRecipe(recipe, result);
            this.resultItems_.push(forgeRecipe);
        }

        this.positionIcons();

        var o:ForgeRecipe;
        for each (o in this.resultItems_) {
            this.resultBackground_.addChild(o);
        }
        this.resultBackground_.x = LEFT_X;
        if (this.resultBackground_.numChildren > 12) {
            this.resultScroll_ = new LegacyScrollbar(16, 565, 0.3);
            this.resultScroll_.x = Main.DefaultWidth / 2 + this.shape_.width / 2 - 18;
            this.resultScroll_.y = TOP_Y + 36;
            this.resultScroll_.setIndicatorSize(580, this.resultBackground_.height);
            this.resultScroll_.addEventListener(Event.CHANGE, this.onResultScrollChanged);
            addChild(this.resultScroll_);
        }
    }

    private function positionIcons():void {
        var index:int;
        var i:ForgeRecipe;
        index = 0;
        for each (i in this.resultItems_) {
            i.x = Main.DefaultWidth / 4 - i.width_ / 2 - 42;
            i.y = 82 + (48 * index);
            i.background_.graphics.clear();
            i.background_.graphics.beginFill(0xFFFFFF);
            i.background_.graphics.drawRect(-(Main.DefaultWidth / 4 - i.width_ / 2 - 42) + 30, 50, 500, 2);
            i.background_.graphics.endFill();
            index++;
        }
    }

    private function onResultScrollChanged(event:Event):void {
        this.resultBackground_.y = -this.resultScroll_.pos() * (this.resultBackground_.height - 580);
    }

    public override function dispose():void {
        super.dispose();
        this.shape_.parent.removeChild(this.shape_);
        this.shape_ = null;
        this.resultItems_ = null;
        this.resultMask_.removeChild(this.resultBackground_);
        this.resultMask_ = null;
        this.resultBackground_ = null;
        if (this.resultScroll_ != null) {
            this.resultScroll_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            this.resultScroll_ = null;
        }
    }

}
}