package kabam.rotmg.fame.view {
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.TextureData;
import com.company.assembleegameclient.screens.ScoreTextLine;
import com.company.assembleegameclient.screens.ScoringBox;
import com.company.assembleegameclient.screens.TitleMenuOption;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.company.assembleegameclient.util.AnimatedChar;
import com.company.assembleegameclient.util.FameUtil;
import com.company.assembleegameclient.util.MaskedImage;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.rotmg.graphics.FameIconBackgroundDesign;
import com.company.util.BitmapUtil;
import com.gskinner.motion.GTween;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.death.model.DeathModel;
import kabam.rotmg.fame.model.FameModel;

import kabam.rotmg.fame.service.RequestCharacterFameTask;

import kabam.rotmg.legends.view.LegendsView;
import kabam.rotmg.messaging.impl.incoming.Death;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.view.components.ScreenBase;

import org.osflash.signals.Signal;

import thyrr.assets.CharacterFactory;

public class FameView extends Sprite {

    public var fameModel:FameModel = Global.fameModel;
    public var deathModel:DeathModel = Global.deathModel;
    public var task:RequestCharacterFameTask;
    public var factory:CharacterFactory = Global.characterFactory;
    private var isFreshDeath:Boolean;
    private var death:Death;
    private var infoContainer:DisplayObjectContainer;
    private var overlayContainer:Bitmap;
    private var title:TextFieldDisplayConcrete;
    private var date:TextFieldDisplayConcrete;
    private var scoringBox:ScoringBox;
    private var finalLine:ScoreTextLine;
    private var continueBtn:TitleMenuOption;
    private var isAnimation:Boolean;
    private var isFadeComplete:Boolean;
    private var isDataPopulated:Boolean;

    public function FameView() {
        addChild(new ScreenBase());
        addChild((this.infoContainer = new Sprite()));
        addChild((this.overlayContainer = new Bitmap()));
        this.continueBtn = new TitleMenuOption("continue", 36, 24);
        continueBtn.addEventListener(MouseEvent.CLICK, onClose);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        task = new RequestCharacterFameTask();
        this.setViewDataFromDeath();
        this.requestFameData();
    }

    public function destroy(e:Event):void {
        this.clearBackground();
        ((this.death) && (this.death.disposeBackground()));
        this.task.finished.removeAll();
    }

    private function setViewDataFromDeath():void {
        this.isFreshDeath = this.deathModel.getIsDeathViewPending();
        this.setIsAnimation(this.isFreshDeath);
        this.death = this.deathModel.getLastDeath();
        if (((this.death) && (this.death.background))) {
            this.setBackground(this.death.background);
        }
    }

    private function requestFameData():void {
        this.task.accountId = this.fameModel.accountId;
        this.task.charId = this.fameModel.characterId;
        this.task.finished.addOnce(this.onFameResponse);
        this.task.start();
    }

    private function onFameResponse(_arg1:RequestCharacterFameTask, _arg2:Boolean, _arg3:String = ""):void {
        var _local4:BitmapData = this.makeIcon();
        this.setCharacterInfo(_arg1.name, _arg1.level, _arg1.type);
        this.setDeathInfo(_arg1.deathDate, _arg1.killer);
        this.setIcon(_local4);
        this.setScore(_arg1.totalFame, _arg1.xml);
    }

    private function makeIcon():BitmapData {
        if (((this.isFreshDeath) && (this.death.isZombie))) {
            return (this.makeZombieTexture());
        }
        return (this.makeNormalTexture());
    }

    private function makeNormalTexture():BitmapData {
        return (this.factory.makeIcon(this.task.template, this.task.size, this.task.texture1, this.task.texture2));
    }

    private function makeZombieTexture():BitmapData {
        var _local1:TextureData = ObjectLibrary.typeToTextureData_[this.death.zombieType];
        var _local2:AnimatedChar = _local1.animatedChar_;
        var _local3:MaskedImage = _local2.imageFromDir(AnimatedChar.RIGHT, AnimatedChar.STAND, 0);
        return (TextureRedrawer.resize(_local3.image_, _local3.mask_, 250, true, this.task.texture1, this.task.texture2));
    }

    private function onClosed():void {
        if (this.isFreshDeath) {
            Global.setLegendsView();
            Global.setScreen(Global.legendsView);
        }
        else {
            Global.gotoPreviousScreen();
        }
    }

    private function onClose(e:MouseEvent):void
    {
        onClosed();
    }

    public function setIsAnimation(_arg1:Boolean):void {
        this.isAnimation = _arg1;
    }

    public function setBackground(_arg1:BitmapData):void {
        this.overlayContainer.bitmapData = _arg1;
        var _local2:GTween = new GTween(this.overlayContainer, 2, {"alpha": 0});
        _local2.onComplete = this.onFadeComplete;
        SoundEffectLibrary.play("death_screen");
    }

    public function clearBackground():void {
        this.overlayContainer.bitmapData = null;
    }

    private function onFadeComplete(_arg1:GTween):void {
        removeChild(this.overlayContainer);
        this.isFadeComplete = true;
        if (this.isDataPopulated) {
            this.makeContinueButton();
        }
    }

    public function setCharacterInfo(_arg1:String, _arg2:int, _arg3:int):void {
        this.title = new TextFieldDisplayConcrete().setSize(38).setColor(0xCCCCCC);
        this.title.setBold(true).setAutoSize(TextFieldAutoSize.CENTER);
        this.title.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
        var _local4:String = ObjectLibrary.typeToDisplayId_[_arg3];
        this.title.setStringBuilder(new LineBuilder().setParams("{name}, Level {level} {type}", {
            "name": _arg1,
            "level": _arg2,
            "type": _local4
        }));
        this.title.x = (stage.stageWidth / 2);
        this.title.y = 225;
        this.infoContainer.addChild(this.title);
    }

    public function setDeathInfo(_arg1:String, _arg2:String):void {
        this.date = new TextFieldDisplayConcrete().setSize(24).setColor(0xCCCCCC);
        this.date.setBold(true).setAutoSize(TextFieldAutoSize.CENTER);
        this.date.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
        var _local3:LineBuilder = new LineBuilder();
        if (_arg2) {
            _local3.setParams("killed on {date} by {killer}", {
                "date": _arg1,
                "killer": this.convertKillerString(_arg2)
            });
        }
        else {
            _local3.setParams("died {date}", {"date": _arg1});
        }
        this.date.setStringBuilder(_local3);
        this.date.x = (stage.stageWidth / 2);
        this.date.y = 272;
        this.infoContainer.addChild(this.date);
    }

    private function convertKillerString(_arg1:String):String {
        var _local2:Array = _arg1.split(".");
        var _local3:String = _local2[0];
        var _local4:String = _local2[1];
        if (_local4 == null) {
            _local4 = _local3;
        }
        else {
            _local4 = _local4.substr(0, (_local4.length - 1));
            _local4 = _local4.replace(/_/g, " ");
            _local4 = _local4.replace(/APOS/g, "'");
            _local4 = _local4.replace(/BANG/g, "!");
        }
        if (ObjectLibrary.getPropsFromId(_local4) != null) {
            _local4 = ObjectLibrary.getPropsFromId(_local4).displayId_;
        }
        return (_local4);
    }

    public function setIcon(_arg1:BitmapData):void {
        var _local2:Sprite;
        _local2 = new Sprite();
        var _local3:Sprite = new FameIconBackgroundDesign();
        _local3.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
        _local2.addChild(_local3);
        var _local4:Bitmap = new Bitmap(_arg1);
        _local4.x = ((_local2.width / 2) - (_local4.width / 2));
        _local4.y = ((_local2.height / 2) - (_local4.height / 2));
        _local2.addChild(_local4);
        _local2.y = 20;
        _local2.x = ((stage.stageWidth / 2) - (_local2.width / 2));
        this.infoContainer.addChild(_local2);
    }

    public function setScore(_arg1:int, _arg2:XML):void {
        this.scoringBox = new ScoringBox(new Rectangle(0, 0, Main.DefaultWidth - 16, Main.DefaultHeight / 2.8), _arg2);
        this.scoringBox.x = 8;
        this.scoringBox.y = 316;
        addChild(this.scoringBox);
        this.infoContainer.addChild(this.scoringBox);
        var _local3:BitmapData = FameUtil.getFameIcon();
        _local3 = BitmapUtil.cropToBitmapData(_local3, 6, 6, (_local3.width - 12), (_local3.height - 12));
        this.finalLine = new ScoreTextLine(24, 0xCCCCCC, 0xFFC800, "Total Fame Earned", null, 0, _arg1, "", "", new Bitmap(_local3));
        this.finalLine.x = 10;
        this.finalLine.y = Main.DefaultHeight - 130;
        this.infoContainer.addChild(this.finalLine);
        this.isDataPopulated = true;
        if (((!(this.isAnimation)) || (this.isFadeComplete))) {
            this.makeContinueButton();
        }
    }

    private function makeContinueButton():void {
        this.continueBtn.x = (stage.stageWidth / 2);
        this.continueBtn.y = Main.DefaultHeight - 50;
        this.infoContainer.addChild(this.continueBtn);
        if (this.isAnimation) {
            this.scoringBox.animateScore();
        }
        else {
            this.scoringBox.showScore();
        }
    }


}
}
