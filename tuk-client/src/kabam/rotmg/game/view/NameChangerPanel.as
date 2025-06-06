﻿package kabam.rotmg.game.view {
import com.company.assembleegameclient.account.ui.ChooseNameFrame;
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.ui.RankText;
import com.company.assembleegameclient.ui.panels.Panel;
import com.company.assembleegameclient.util.Currency;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFormatAlign;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.view.RegisterPromptDialog;

import kabam.rotmg.account.web.WebAccount;


import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;
import kabam.rotmg.util.components.LegacyBuyButton;

public class NameChangerPanel extends Panel {

    public var account:Account = Global.account;
    public var buy_:Boolean;
    private var title_:TextFieldDisplayConcrete;
    private var button_:Sprite;

    public function NameChangerPanel(_arg1:GameSprite, _arg2:int) {
        var _local3:Player;
        var _local4:String;
        super(_arg1);
        if (this.hasMapAndPlayer()) {
            _local3 = gs_.map.player_;
            this.buy_ = _local3.nameChosen_;
            _local4 = this.createNameText();
            if (this.buy_) {
                this.handleAlreadyHasName(_local4);
            }
            else {
                if (_local3.numStars_ < _arg2) {
                    this.handleInsufficientRank(_arg2);
                }
                else {
                    this.handleNoName();
                }
            }
        }
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
    }

    private function onChooseName():void {
        if (this.account.isRegistered()) {
            Global.openDialog(new ChooseNameFrame(this.gs_, this.buy_));
        }
        else {
            Global.openDialog(new RegisterPromptDialog("In order to choose an account name, you must be registered"));
        }
    }

    public function onNameChanged(_arg1:String):void {
        if ((this.account is WebAccount)) {
            WebAccount(this.account).userDisplayName = _arg1;
        }
        this.updateName(_arg1);
    }

    private function onAddedToStage(_arg1:Event):void {
        if (this.button_) {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        }
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function hasMapAndPlayer():Boolean {
        return (((gs_.map) && (gs_.map.player_)));
    }

    private function createNameText():String {
        var _local1:String;
        _local1 = gs_.model.getName();
        this.title_ = new TextFieldDisplayConcrete().setSize(18).setColor(0xFFFFFF).setTextWidth(WIDTH);
        this.title_.setBold(true).setWordWrap(true).setMultiLine(true).setHorizontalAlign(TextFormatAlign.CENTER);
        this.title_.filters = [new DropShadowFilter(0, 0, 0)];
        return (_local1);
    }

    private function handleAlreadyHasName(_arg1:String):void {
        this.title_.setStringBuilder(this.makeNameText(_arg1));
        this.title_.y = 0;
        addChild(this.title_);
        var _local2:LegacyBuyButton = new LegacyBuyButton("Change {cost}", 16, Parameters.NAME_CHANGE_PRICE, Currency.FAME);
        _local2.readyForPlacement.addOnce(this.positionButton);
        this.button_ = _local2;
        addChild(this.button_);
        this.addListeners();
    }

    private function positionButton():void {
        this.button_.x = ((WIDTH / 2) - (this.button_.width / 2));
        this.button_.y = ((HEIGHT - (this.button_.height / 2)) - 17);
    }

    private function handleNoName():void {
        this.title_.setStringBuilder(new LineBuilder().setParams("Choose Account Name"));
        this.title_.y = 6;
        addChild(this.title_);
        var _local1:DeprecatedTextButton = new DeprecatedTextButton(16, "Choose");
        _local1.textChanged.addOnce(this.positionTextButton);
        this.button_ = _local1;
        addChild(this.button_);
        this.addListeners();
    }

    private function positionTextButton():void {
        this.button_.x = ((WIDTH / 2) - (this.button_.width / 2));
        this.button_.y = ((HEIGHT - this.button_.height) - 4);
    }

    private function addListeners():void {
        this.button_.addEventListener(MouseEvent.CLICK, this.onButtonClick);
    }

    private function handleInsufficientRank(_arg1:int):void {
        var _local2:Sprite;
        var _local4:Sprite;
        this.title_.setStringBuilder(new LineBuilder().setParams("Choose Account Name"));
        addChild(this.title_);
        _local2 = new Sprite();
        var _local3:TextFieldDisplayConcrete = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF);
        _local3.setBold(true);
        _local3.setStringBuilder(new LineBuilder().setParams("Rank Required"));
        _local3.filters = [new DropShadowFilter(0, 0, 0)];
        _local2.addChild(_local3);
        _local4 = new RankText(_arg1, false, false);
        _local4.x = (_local3.width + 4);
        _local4.y = ((_local3.height / 2) - (_local4.height / 2));
        _local2.addChild(_local4);
        _local2.x = ((WIDTH / 2) - (_local2.width / 2));
        _local2.y = ((HEIGHT - (_local2.height / 2)) - 20);
        addChild(_local2);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
    }

    private function makeNameText(_arg1:String):StringBuilder {
        return (new LineBuilder().setParams("Your name is:\n{name}", {"name": _arg1}));
    }

    private function onKeyDown(_arg1:KeyboardEvent):void {
        if ((((_arg1.keyCode == Parameters.data_.interact)) && ((stage.focus == null)))) {
            this.onChooseName();
        }
    }

    private function onButtonClick(_arg1:MouseEvent):void {
        this.onChooseName();
    }

    public function updateName(_arg1:String):void {
        this.title_.setStringBuilder(this.makeNameText(_arg1));
        this.title_.y = 0;
    }


}
}
