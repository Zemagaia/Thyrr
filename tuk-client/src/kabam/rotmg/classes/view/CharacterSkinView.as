﻿package kabam.rotmg.classes.view {
import com.company.assembleegameclient.constants.ScreenTypes;
import com.company.assembleegameclient.screens.AccountScreen;
import com.company.assembleegameclient.screens.NewCharacterScreen;
import com.company.assembleegameclient.screens.TitleMenuOption;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.game.model.GameInitData;
import kabam.rotmg.game.view.CreditDisplay;
import kabam.rotmg.ui.view.SignalWaiter;
import kabam.rotmg.ui.view.components.ScreenBase;

public class CharacterSkinView extends Sprite {

    public var model:PlayerModel = Global.playerModel;
    private const base:ScreenBase = makeScreenBase();
    private const account:AccountScreen = makeAccountScreen();
    private const lines:Shape = makeLines();
    private const creditsDisplay:CreditDisplay = makeCreditDisplay();
    private const playBtn:TitleMenuOption = makePlayButton();
    private const backBtn:TitleMenuOption = makeBackButton();
    private const list:CharacterSkinListView = makeListView();
    public const detail:ClassDetailView = makeClassDetailView();
    public const waiter:SignalWaiter = makeSignalWaiter();

    public function CharacterSkinView()
    {
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        var hasAvailableCharSlot:Boolean = this.model.hasAvailableCharSlot();
        this.setPlayButtonEnabled(hasAvailableCharSlot);
        if (hasAvailableCharSlot) {
            playBtn.addEventListener(MouseEvent.CLICK, onPlay);
        }
        backBtn.addEventListener(MouseEvent.CLICK, onBack);
    }

    public function destroy(e:Event):void {
        playBtn.removeEventListener(MouseEvent.CLICK, onPlay);
        backBtn.removeEventListener(MouseEvent.CLICK, onBack);
    }

    private function onBack(e:MouseEvent):void {
        Global.setScreen(new NewCharacterScreen());
    }

    private function onPlay(e:MouseEvent):void {
        var _local1:GameInitData = new GameInitData();
        _local1.createCharacter = true;
        _local1.charId = this.model.getNextCharId();
        _local1.keyTime = -1;
        _local1.isNewGame = true;
        Global.playGame(_local1);
    }

    private function makeScreenBase():ScreenBase {
        var _local1:ScreenBase = new ScreenBase();
        addChild(_local1);
        return (_local1);
    }

    private function makeAccountScreen():AccountScreen {
        var _local1:AccountScreen = new AccountScreen();
        addChild(_local1);
        return (_local1);
    }

    private function makeCreditDisplay():CreditDisplay {
        var _local1:CreditDisplay;
        _local1 = new CreditDisplay(false);
        var _local2:PlayerModel = Global.playerModel;
        if (_local2 != null) {
            _local1.draw(_local2.getCredits(), _local2.getFame(), _local2.getUnholyEssence(), _local2.getDivineEssence());
        }
        _local1.x = Main.DefaultWidth;
        _local1.y = 20;
        addChild(_local1);
        return (_local1);
    }

    private function makeLines():Shape {
        var _local1:Shape = new Shape();
        _local1.graphics.clear();
        _local1.graphics.lineStyle(2, 0x545454);
        _local1.graphics.moveTo(0, 105);
        _local1.graphics.lineTo(Main.DefaultWidth, 105);
        _local1.graphics.moveTo(346, 105);
        _local1.graphics.lineTo(346, Main.DefaultHeight - 86);
        _local1.graphics.moveTo(0, Main.DefaultHeight - 86);
        _local1.graphics.lineTo(Main.DefaultWidth, Main.DefaultHeight - 86);
        addChild(_local1);
        return (_local1);
    }

    private function makePlayButton():TitleMenuOption {
        var _local1:TitleMenuOption;
        _local1 = new TitleMenuOption(ScreenTypes.PLAY, 32, 18);
        _local1.x = (400 - (_local1.width / 2));
        _local1.y = Main.DefaultHeight - 50;
        addChild(_local1);
        return (_local1);
    }

    private function makeBackButton():TitleMenuOption {
        var _local1:TitleMenuOption;
        _local1 = new TitleMenuOption(ScreenTypes.BACK, 32, 18);
        _local1.x = 30;
        _local1.y = Main.DefaultHeight - 50;
        addChild(_local1);
        return (_local1);
    }

    private function makeListView():CharacterSkinListView {
        var _local1:CharacterSkinListView;
        _local1 = new CharacterSkinListView();
        _local1.x = 351;
        _local1.y = 110;
        addChild(_local1);
        return (_local1);
    }

    private function makeClassDetailView():ClassDetailView {
        var _local1:ClassDetailView;
        _local1 = new ClassDetailView();
        _local1.x = 5;
        _local1.y = 110;
        addChild(_local1);
        return (_local1);
    }

    public function setPlayButtonEnabled(_arg1:Boolean):void {
        if (!_arg1) {
            this.playBtn.deactivate();
        }
    }

    private function makeSignalWaiter():SignalWaiter {
        var _local1:SignalWaiter = new SignalWaiter();
        _local1.push(this.playBtn.changed);
        _local1.complete.add(this.positionOptions);
        return (_local1);
    }

    private function positionOptions():void {
        this.playBtn.x = (stage.stageWidth / 2);
    }


}
}
