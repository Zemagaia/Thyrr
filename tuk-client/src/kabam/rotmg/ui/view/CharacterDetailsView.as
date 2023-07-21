package kabam.rotmg.ui.view {
import com.company.assembleegameclient.objects.ImageFactory;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.BoostPanelButton;
import com.company.assembleegameclient.ui.ExperienceBoostTimerPopup;
import com.company.assembleegameclient.ui.icons.IconButton;
import com.company.assembleegameclient.ui.icons.IconButtonFactory;
import com.company.assembleegameclient.util.AnimatedChar;
import com.company.assembleegameclient.util.MaskedImage;
import com.company.assembleegameclient.util.TextureRedrawer;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;

import org.osflash.signals.Signal;

import thyrr.utils.Utils;

public class CharacterDetailsView extends Sprite {

    public static const NEXUS_BUTTON:String = "NEXUS_BUTTON";
    public static const OPTIONS_BUTTON:String = "OPTIONS_BUTTON";
    public static const IMAGE_SET_NAME:String = "interfaceBig";
    public static const NEXUS_IMAGE_ID:int = 6;
    public static const OPTIONS_IMAGE_ID:int = 5;

    public var gotoNexus:Signal;
    public var gotoOptions:Signal;
    public var iconButtonFactory:IconButtonFactory;
    public var imageFactory:ImageFactory;
    private var portrait_:Bitmap;
    private var button:IconButton;
    private var boostPanelButton:BoostPanelButton;
    private var expTimer:ExperienceBoostTimerPopup;

    public function CharacterDetailsView() {
        this.gotoNexus = new Signal();
        this.gotoOptions = new Signal();
        this.portrait_ = new Bitmap(null);
        super();
    }

    public function init(_arg1:String, _arg2:String):void {
        this.createPortrait();
        this.createButton(_arg2);
    }

    private function createButton(_arg1:String):void {
        if (_arg1 == NEXUS_BUTTON) {
            this.button = this.iconButtonFactory.create(this.imageFactory.getImageFromSet(IMAGE_SET_NAME, NEXUS_IMAGE_ID), "", "Realm", "escapeToRealm");
            this.button.addEventListener(MouseEvent.CLICK, onNexusClick);
        }
        else {
            if (_arg1 == OPTIONS_BUTTON) {
                this.button = this.iconButtonFactory.create(this.imageFactory.getImageFromSet(IMAGE_SET_NAME, OPTIONS_IMAGE_ID), "", "Options", "options");
                this.button.addEventListener(MouseEvent.CLICK, onOptionsClick);
            }
        }
        this.button.x = -17;
        this.button.y = 7;
        addChild(this.button);
    }

    private function createPortrait():void {
        this.portrait_.x = 117;
        this.portrait_.y = 180;
        addChild(this.portrait_);
    }

    public function update(_arg1:Player):void {
        this.portrait_.bitmapData = this.getPortrait(_arg1);
        this.filters = [Utils.OutlineFilter];
    }

    protected var portraitData_:BitmapData = null;
    private function getPortrait(player:Player):BitmapData {
        var maskedImg:MaskedImage;
        var size:int;
        if (portraitData_ == null) {
            maskedImg = player.animatedChar_.imageFromDir(AnimatedChar.LEFT, AnimatedChar.STAND, 0);
            size = ((2 / maskedImg.image_.width) * 180);
            portraitData_ = TextureRedrawer.resize(maskedImg.image_, maskedImg.mask_, size, true, player.getTex1(), player.getTex2());
        }
        return (portraitData_);
    }

    public function draw(_arg1:Player):void {
        if (this.expTimer) {
            this.expTimer.update(_arg1.xpTimer);
        }
        if (boostPanelButton == null && (_arg1.tierBoost != 0 || _arg1.dropBoost != 0)) {
            this.boostPanelButton = ((this.boostPanelButton) || (new BoostPanelButton(_arg1)));
            this.boostPanelButton.x = 8;
            this.boostPanelButton.y = 38;
            addChild(this.boostPanelButton);
        }
        else {
            if (this.boostPanelButton) {
                removeChild(this.boostPanelButton);
                this.boostPanelButton = null;
            }
        }
    }

    private function onNexusClick(_arg1:MouseEvent):void {
        this.gotoNexus.dispatch();
    }

    private function onOptionsClick(_arg1:MouseEvent):void {
        this.gotoOptions.dispatch();
    }


}
}
