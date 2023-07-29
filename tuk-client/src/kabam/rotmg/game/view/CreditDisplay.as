package kabam.rotmg.game.view {
import com.company.assembleegameclient.util.FameUtil;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.ui.BaseSimpleText;
import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;

import kabam.rotmg.core.model.PlayerModel;

public class CreditDisplay extends Sprite {

    private static const FONT_SIZE:int = 18;
    public static const IMAGE_NAME:String = "lofiObj3";
    public static const IMAGE_ID:int = 225;
    public var model:PlayerModel = Global.playerModel;

    private var creditsText_:BaseSimpleText;
    private var fameText_:BaseSimpleText;
    private var unholyEssenceText_:BaseSimpleText;
    private var divineEssenceText_:BaseSimpleText;
    private var coinIcon_:Bitmap;
    private var fameIcon_:Bitmap;
    private var unholyEssenceIcon_:Bitmap;
    private var divineEssenceIcon_:Bitmap;
    private var credits_:int = -1;
    private var fame_:int = -1;
    private var unholyEssence_:int = -1;
    private var divineEssence_:int = -1;
    public var _isGameSprite:Boolean;

    public function CreditDisplay(isGameSprite:Boolean = false) {
        super();
        _isGameSprite = isGameSprite;

        var icon:BitmapData = AssetLibrary.getImageFromSet("interfaceSmall", 81);
        icon = TextureRedrawer.redraw(icon, 40, true, 0);
        this.coinIcon_ = new Bitmap(icon);
        this.creditsText_ = new BaseSimpleText(FONT_SIZE, 16777215, false, 0, 0);
        this.creditsText_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 2)];
        addChild(this.coinIcon_);
        addChild(this.creditsText_);

        this.fameIcon_ = new Bitmap(FameUtil.getFameIcon());
        this.fameText_ = new BaseSimpleText(FONT_SIZE, 16777215, false, 0, 0);
        this.fameText_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 2)];
        addChild(this.fameIcon_);
        addChild(this.fameText_);

        icon = AssetLibrary.getImageFromSet("interfaceSmall", 65);
        icon = TextureRedrawer.redraw(icon, 40, true, 0);
        this.unholyEssenceIcon_ = new Bitmap(icon);
        this.unholyEssenceText_ = new BaseSimpleText(FONT_SIZE, 16777215, false, 0, 0);
        this.unholyEssenceText_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 2)];
        addChild(this.unholyEssenceIcon_);
        addChild(this.unholyEssenceText_);

        icon = AssetLibrary.getImageFromSet("interfaceSmall", 64);
        icon = TextureRedrawer.redraw(icon, 40, true, 0);
        this.divineEssenceIcon_ = new Bitmap(icon);
        this.divineEssenceText_ = new BaseSimpleText(FONT_SIZE, 16777215, false, 0, 0);
        this.divineEssenceText_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 2)];
        addChild(this.divineEssenceIcon_);
        addChild(this.divineEssenceText_);

        this.draw(0, 0, 0, 0);
        mouseEnabled = false;
        doubleClickEnabled = false;
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        this.model.creditsChanged.add(this.onCreditsChanged);
        this.model.fameChanged.add(this.onFameChanged);
        this.model.unholyEssenceChanged.add(this.onUnholyEssenceChanged);
        this.model.divineEssenceChanged.add(this.onDivineEssenceChanged);
    }

    public function destroy(e:Event):void {
        this.model.creditsChanged.remove(this.onCreditsChanged);
        this.model.fameChanged.remove(this.onFameChanged);
        this.model.unholyEssenceChanged.remove(this.onUnholyEssenceChanged);
        this.model.divineEssenceChanged.remove(this.onDivineEssenceChanged);
    }

    private function onCreditsChanged(_arg1:int):void {
        this.draw(_arg1, this.model.getFame(), this.model.getUnholyEssence(), this.model.getDivineEssence());
    }

    private function onFameChanged(_arg1:int):void {
        this.draw(this.model.getCredits(), _arg1, this.model.getUnholyEssence(), this.model.getDivineEssence());
    }

    private function onUnholyEssenceChanged(_arg1:int):void {
        this.draw(this.model.getCredits(), this.model.getFame(), _arg1, this.model.getDivineEssence());
    }

    private function onDivineEssenceChanged(_arg1:int):void {
        this.draw(this.model.getCredits(), this.model.getFame(), this.model.getUnholyEssence(), _arg1);
    }

    private function onOpenAccountDialog():void {
        Global.openMoneyWindow();
    }

    public function draw(credits:int, fame:int, uhEssence:int, dvEssence:int):void {
        if (credits == this.credits_ && fame == this.fame_ && uhEssence == this.unholyEssence_ && dvEssence == this.divineEssence_) {
            return;
        }
        this.credits_ = credits;
        this.fame_ = fame;
        this.unholyEssence_ = uhEssence;
        this.divineEssence_ = dvEssence;
        this.creditsText_.text = this.credits_.toString();
        this.creditsText_.updateMetrics();
        this.fameText_.text = this.fame_.toString();
        this.fameText_.updateMetrics();
        this.unholyEssenceText_.text = this.unholyEssence_.toString();
        this.unholyEssenceText_.updateMetrics();
        this.divineEssenceText_.text = this.divineEssence_.toString();
        this.divineEssenceText_.updateMetrics();

        if (!_isGameSprite) {
            this.divineEssenceIcon_.x = -this.divineEssenceIcon_.width;
            this.divineEssenceText_.x = this.divineEssenceIcon_.x - this.divineEssenceText_.width + 8;
            this.divineEssenceText_.y = this.divineEssenceIcon_.height / 2 - this.divineEssenceText_.height / 2;

            this.unholyEssenceIcon_.x = this.divineEssenceText_.x - this.unholyEssenceIcon_.width;
            this.unholyEssenceText_.x = this.unholyEssenceIcon_.x - this.unholyEssenceText_.width + 8;
            this.unholyEssenceText_.y = this.unholyEssenceIcon_.height / 2 - this.unholyEssenceText_.height / 2;

            this.coinIcon_.x = this.unholyEssenceText_.x - this.coinIcon_.width;
            this.creditsText_.x = this.coinIcon_.x - this.creditsText_.width + 8;
            this.creditsText_.y = this.coinIcon_.height / 2 - this.creditsText_.height / 2;

            this.fameIcon_.x = this.creditsText_.x - this.fameIcon_.width;
            this.fameText_.x = this.fameIcon_.x - this.fameText_.width + 8;
            this.fameText_.y = this.fameIcon_.height / 2 - this.fameText_.height / 2;
        }
        else {
            this.coinIcon_.y = 0;
            this.creditsText_.x = 32;
            this.creditsText_.y = this.coinIcon_.height / 2 - this.creditsText_.height / 2;

            this.fameIcon_.y = 24;
            this.fameText_.x = 32;
            this.fameText_.y = this.fameIcon_.y + this.fameIcon_.height / 2 - this.fameText_.height / 2;

            this.unholyEssenceIcon_.y = 48;
            this.unholyEssenceText_.x = 32;
            this.unholyEssenceText_.y = this.unholyEssenceIcon_.y + this.unholyEssenceIcon_.height / 2 - this.unholyEssenceText_.height / 2;

            this.divineEssenceIcon_.y = 72;
            this.divineEssenceText_.x = 32;
            this.divineEssenceText_.y = this.divineEssenceIcon_.y + this.divineEssenceIcon_.height / 2 - this.divineEssenceText_.height / 2;
        }
        }
    }
}

