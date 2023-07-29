package kabam.rotmg.maploading.view {
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.ui.BaseSimpleText;
import com.company.util.AssetLibrary;
import com.gskinner.motion.GTween;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.account.core.view.ConfirmEmailModal;
import kabam.rotmg.account.web.view.WebLoginDialogForced;
import kabam.rotmg.account.web.view.WebRegisterDialog;
import kabam.rotmg.maploading.commands.CharacterAnimationFactory;
import kabam.rotmg.messaging.impl.incoming.MapInfo;

import thyrr.assets.Animation;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.view.TitleView;

public class MapLoading extends Sprite {

    public static const FADE_OUT_TIME:Number = 0.58;

    public var characterAnimationFactory:CharacterAnimationFactory = Global.characterAnimationFactory;
    private var _indicators:Vector.<Bitmap>;
    private var _mapNameField:TextFieldDisplayConcrete = new TextFieldDisplayConcrete();
    private var _mapDifficultyText:BaseSimpleText = new BaseSimpleText(18, 0xFFFFFF);
    private var _mapName:String;
    private var _name:String;
    private var _difficulty:int;
    private var animation:Animation;

    public function MapLoading():void {
        addBackground();
        makeLoadingScreen();
        this.showAnimation(this.characterAnimationFactory.make());
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }

    public function onMapLoaded(_arg1:MapInfo):void {
        this.showMap(_arg1.displayName_, _arg1.name_, _arg1.difficulty_);
    }

    public function onHide():void {
        this.disable();
    }

    private function addBackground():void {
        var bg:Sprite = new Sprite();
        bg.graphics.beginFill(0);
        bg.graphics.drawRect(0, 0, Main.STAGE.stageWidth, Main.STAGE.stageHeight);
        bg.graphics.endFill();
        addChild(bg);
    }

    private function makeLoadingScreen():void {
        _mapNameField.setSize(30).setColor(0xFFFFFF);
        _mapNameField.setBold(true);
        _mapNameField.setAutoSize(TextFieldAutoSize.CENTER);
        _mapNameField.x = Main.DefaultWidth / 2;
        _mapNameField.y = Main.DefaultHeight / 2 - 20;

        _mapDifficultyText.setBold(true);
        _mapDifficultyText.setAutoSize(TextFieldAutoSize.CENTER);
        _mapDifficultyText.x = Main.DefaultWidth / 2;
        _mapDifficultyText.y = Main.DefaultHeight / 2 + 10;

        _indicators = new Vector.<Bitmap>;

        addChild(_mapNameField);
        addChild(_mapDifficultyText);
        setValues();
    }

    public function showMap(displayName:String, name:String, difficulty:int):void {
        _mapName = ((displayName) ? displayName : name);
        _name = name;
        _difficulty = difficulty;
        setValues();
    }

    private function setValues():void {
        _mapNameField.setStringBuilder(new LineBuilder().setParams(_mapName));
        var difficultyText:String = _difficulty > 10 ? "Treacherous" : _difficulty > 5 ? "Hostile" : _difficulty > 0 ? "Hazardous" : "Peaceful";
        if (_name == "Realm") {
            difficultyText = "Hostile";
        }
        _mapDifficultyText.text = difficultyText;

        var difficultyMult:int = int(_difficulty / 5);
        var getIcon:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x20 + difficultyMult - 1);
        var data:BitmapData = TextureRedrawer.redraw(getIcon, 40, true, 0);
        if (_difficulty > 0)
        {
            var i:int = 0;
            while (i < 5)
            {
                _indicators[i] = new Bitmap(data);
                _indicators[i].x = Main.DefaultWidth / 2.2 + 20 * i;
                _indicators[i].y = Main.DefaultHeight / 2 + 24;
                _indicators[i].alpha = i >= int(_difficulty % 5) ? 0.5 : 1;
                addChild(_indicators[i]);
                i++;
            }
        }
    }

    public function showAnimation(_arg1:Animation):void {
        if (_arg1 == null) return;
        animation = _arg1;
        addChild(_arg1);
        _arg1.start();
        _arg1.x = ((Main.STAGE.stageWidth / 2 - (_arg1.width * 0.5)) + 5);
        _arg1.y = (Main.STAGE.stageHeight * 0.4 - (_arg1.height * 0.5));
    }

    public function disable():void {
        beginFadeOut();
    }

    public function disableNoFadeOut():void {
        ((parent) && (parent.removeChild(this)));
    }

    private function beginFadeOut():void {
        if (TitleView.queueEmailConfirmation) {
            Global.openDialog(new ConfirmEmailModal());
            TitleView.queueEmailConfirmation = false;
        }
        else {
            if (TitleView.queuePasswordPrompt) {
                Global.openDialog(new WebLoginDialogForced());
                TitleView.queuePasswordPrompt = false;
            }
            else {
                if (TitleView.queuePasswordPromptFull) {
                    Global.openDialog(new WebLoginDialogForced(true));
                    TitleView.queuePasswordPromptFull = false;
                }
                else {
                    if (TitleView.queueRegistrationPrompt) {
                        Global.openDialog(new WebRegisterDialog());
                        TitleView.queueRegistrationPrompt = false;
                    }
                }
            }
        }
        var _local1:GTween = new GTween(this, FADE_OUT_TIME, {"alpha": 0});
        _local1.onComplete = onFadeOutComplete;
        mouseEnabled = false;
        mouseChildren = false;
    }

    private function onFadeOutComplete(_arg1:GTween):void {
        ((parent) && (parent.removeChild(this)));
    }

    private function onRemovedFromStage(_arg1:Event):void {
        if (this.animation)
            animation.dispose();
    }


}
}
