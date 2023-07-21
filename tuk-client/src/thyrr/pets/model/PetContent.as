package thyrr.pets.model {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.ui.LegacyScrollbar;
import com.company.ui.BaseSimpleText;
import com.company.util.BitmapUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.CapsStyle;
import flash.display.DisplayObject;

import flash.display.JointStyle;
import flash.display.LineScaleMode;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.view.SignalWaiter;

import kabam.rotmg.util.graphics.BevelRect;

import kabam.rotmg.util.graphics.GraphicsHelper;

import org.osflash.signals.Signal;

import thyrr.pets.data.PetData;

public class PetContent extends Sprite {

    private static const WIDTH:int = 260;
    private static const INNER_HEIGHT:int = HEIGHT - 4;
    private static const INNER_WIDTH:int = WIDTH - 4;
    private static const HEIGHT:int = 500;

    private var shape_:Shape;
    private var mask_:Sprite;
    private var background_:Sprite;
    private var scrollbar_:LegacyScrollbar;
    private var items_:Vector.<Object>;
    private var bgRect_:Sprite;
    private var height_:int;

    public var petData_:PetData;
    private var gameSprite_:GameSprite;
    private var xml_:XML;

    public var followButton_:DeprecatedTextButton;
    public var releaseButton_:DeprecatedTextButton;

    public const waiter_:SignalWaiter = new SignalWaiter();
    public const finalized_:Signal = new Signal();
    private var description_:TextFieldDisplayConcrete;
    private var family_:TextFieldDisplayConcrete;
    private var petName_:TextFieldDisplayConcrete;

    public function PetContent(gameSprite:GameSprite, petData:PetData) {
        this.petData_ = petData;
        this.gameSprite_ = gameSprite;
        this.shape_ = new Shape();
        this.bgRect_ = new Sprite();
        addChild(this.bgRect_);
        this.shape_.graphics.beginFill(0);
        this.shape_.graphics.drawRect(0, 0, WIDTH, INNER_HEIGHT);
        this.shape_.graphics.endFill();
        this.mask_ = new Sprite();
        this.mask_.addChild(this.shape_);
        this.mask_.mask = this.shape_;
        addChild(this.mask_);
        this.background_ = new Sprite();
        this.mask_.addChild(this.background_);
        this.items_ = new Vector.<Object>();
        this.mask_.y += 4;
        this.xml_ = ObjectLibrary.xmlLibrary_[petData.ObjectType];
        make();
        this.waiter_.complete.addOnce(this.alignAndDraw);
    }

    private function make():void {
        if (this.scrollbar_ != null) {
            this.scrollbar_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            removeChild(this.scrollbar_);
            this.scrollbar_ = null;
        }

        clearPreviousResults();

        addStuff();

        var o:DisplayObject;
        for each (o in this.items_) {
            this.background_.addChild(o);
        }
    }

    private function addStuff():void {
        addIconAndName();
        addFamilyAndDescription();
    }

    private function addIconAndName():void {
        // add pet icon
        var icon:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.petData_.ObjectType, 80, true, false);
        icon = BitmapUtil.cropToBitmapData(icon, 8, 8, icon.width - 16, icon.height - 16);
        var petIcon:Bitmap = new Bitmap(icon);
        petIcon.x = 8;
        this.background_.addChild(petIcon);
        // add name and position besides icon
        this.petName_ = new TextFieldDisplayConcrete();
        this.petName_.setBold(true).setColor(0xB3B3B3).setSize(17).setTextWidth(190);
        this.petName_.setStringBuilder(new LineBuilder().setParams(ObjectLibrary.typeToDisplayId_[this.petData_.ObjectType]));
        this.petName_.setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        this.petName_.x = 8 + petIcon.x + petIcon.width;
        this.petName_.y = petIcon.height / 2;
        this.petName_.filters = [new DropShadowFilter(0, 0, 0)];
        this.background_.addChild(this.petName_);
        this.height_ += 50;
        this.waiter_.push(this.petName_.textChanged);
    }

    private function addFamilyAndDescription():void {
        if (!this.xml_.hasOwnProperty("PetDesc")) {
            return;
        }

        // add description
        if (String(this.xml_.PetDesc.Description) != "") {
            this.description_ = new TextFieldDisplayConcrete();
            this.description_.setSize(14).setColor(0xB3B3B3).setTextWidth(WIDTH - 36);
            this.description_.setWordWrap(true).setHTML(true);
            this.description_.setStringBuilder(new LineBuilder().setParams(this.xml_.PetDesc.Description));
            this.description_.filters = [new DropShadowFilter(0, 0, 0)];
            this.background_.addChild(this.description_);
            this.waiter_.push(this.description_.textChanged);
        }

        // add family text. By default it's ???
        var family:String = String(this.xml_.PetDesc.@family) == "" ? "???" : String(this.xml_.PetDesc.@family);
        this.family_ = new TextFieldDisplayConcrete();
        this.family_.setSize(14).setColor(0xFFFFFF).setHTML(true);
        this.family_.setStringBuilder(new LineBuilder().setParams("<b>Family:</b> {family}", {
            "family": family
        }));
        this.family_.filters = [new DropShadowFilter(0, 0, 0)];
        this.background_.addChild(this.family_);
        this.waiter_.push(this.family_.textChanged);
    }

    private function addButtons():void {
        this.releaseButton_ = new DeprecatedTextButton(16, "Release");
        this.releaseButton_.x = 20;
        this.releaseButton_.y = this.height_;
        this.background_.addChild(this.releaseButton_);
        this.followButton_ = new DeprecatedTextButton(16, "Follow");
        this.followButton_.textChanged.addOnce(this.positionFollowButtonX);
        var petData:PetData = this.gameSprite_.map.player_.petData_;
        if (petData && petData.Id == this.petData_.Id) {
            this.followButton_.setText("Unfollow");
        }
        this.followButton_.y = this.height_;
        this.background_.addChild(this.followButton_);
        this.height_ += 40;
        this.finalized_.dispatch();
    }

    private function positionFollowButtonX():void {
        this.followButton_.x = WIDTH - this.followButton_.width - 20;
    }

    private function drawBackground(height:Number):void {
        this.bgRect_.graphics.clear();
        var rect:BevelRect = new BevelRect(INNER_WIDTH, height > HEIGHT ? HEIGHT : height, 4);
        var helper:GraphicsHelper = new GraphicsHelper();
        this.bgRect_.graphics.lineStyle(2, 0x676767, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3);
        this.bgRect_.graphics.beginFill(0x454545);
        helper.drawBevelRect(2, 2, rect, this.bgRect_.graphics);
        this.bgRect_.graphics.endFill();
    }

    private function clearPreviousResults():void {
        var object:DisplayObject;
        for each (object in this.background_) {
            this.background_.removeChild(object);
            object = null;
        }
    }

    private function onResultScrollChanged(event:Event):void {
        this.background_.y = -this.scrollbar_.pos() * (this.height_ - 500);
    }

    private function alignAndDraw():void {
        // position name
        this.petName_.resize();
        this.petName_.x += 98 - this.petName_.width / 2;
        // position description
        this.description_.x = 8;
        this.description_.y = this.height_ - 4;
        this.height_ += this.description_.height;
        // position family
        this.family_.x = 8;
        this.family_.y = this.height_;
        this.height_ += this.family_.height * 2;
        // add and position buttons
        addButtons();
        // add background & scroll bar (if needed)
        this.drawBackground(this.height_);
        if (this.height_ > 500) {
            this.followButton_.x -= 10;
            this.scrollbar_ = new LegacyScrollbar(16, 490, 0.5);
            this.scrollbar_.x = WIDTH - 24;
            this.scrollbar_.y = 5;
            this.scrollbar_.setIndicatorSize(500, this.height_);
            this.scrollbar_.addEventListener(Event.CHANGE, this.onResultScrollChanged);
            addChild(this.scrollbar_);
        }
    }

    public function dispose():void {
        this.shape_.parent.removeChild(this.shape_);
        this.shape_ = null;
        this.items_ = null;
        this.mask_.removeChild(this.background_);
        this.mask_ = null;
        this.background_.graphics.clear();
        this.background_ = null;
        if (this.scrollbar_ != null) {
            this.scrollbar_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            this.scrollbar_ = null;
        }
        removeChild(this.bgRect_);
        this.bgRect_ = null
        this.gameSprite_ = null;
        this.petData_ = null;
    }

}
}