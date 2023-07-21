package com.company.assembleegameclient.screens {
import com.company.assembleegameclient.constants.ScreenTypes;
import com.company.assembleegameclient.screens.charrects.CharacterRect;
import com.company.assembleegameclient.ui.DeprecatedClickableText;
import com.company.assembleegameclient.ui.LegacyScrollbar;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.game.view.CreditDisplay;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.ui.view.ButtonFactory;
import kabam.rotmg.ui.view.components.MenuOptionsBar;
import kabam.rotmg.ui.view.components.ScreenBase;

import org.osflash.signals.Signal;

import thyrr.ui.items.Scrollbar;

public class CharacterSelectionAndNewsScreen extends Sprite {

    private static const NEWS_X:int = WebMain.DefaultWidth - 325;
    private static const TAB_UNSELECTED:uint = 0xB3B3B3;
    private static const TAB_SELECTED:uint = 0xFFFFFF;

    private const SCROLLBAR_REQUIREMENT_HEIGHT:Number = WebMain.DefaultHeight - 200;
    private const CHARACTER_LIST_Y_POS:int = 108;
    private const CHARACTER_LIST_X_POS:int = 18;
    private const DROP_SHADOW:DropShadowFilter = new DropShadowFilter(0, 0, 0, 1, 8, 8);

    public var close:Signal;
    public var showClasses:Signal;
    public var newCharacter:Signal;
    public var chooseName:Signal;
    public var playGame:Signal;
    private var model:PlayerModel;
    private var isInitialized:Boolean;
    private var nameText:TextFieldDisplayConcrete;
    private var nameChooseLink_:DeprecatedClickableText;
    private var creditDisplay:CreditDisplay;
    private var openCharactersText:TextFieldDisplayConcrete;
    private var openGraveYardText:TextFieldDisplayConcrete;
    private var newsText:TextFieldDisplayConcrete;
    private var characterList:CharacterList;
    private var characterListType:int = 1;
    private var characterListHeight:Number;
    private var scrollBar:Scrollbar;
    private var playButton:TitleMenuOption;
    private var classesButton:TitleMenuOption;
    private var backButton:TitleMenuOption;
    private var menuOptionsBar:MenuOptionsBar;

    public function CharacterSelectionAndNewsScreen() {
        this.newCharacter = new Signal();
        this.chooseName = new Signal();
        this.playGame = new Signal();
        this.playButton = ButtonFactory.getPlayButton();
        this.classesButton = ButtonFactory.getClassesButton();
        this.backButton = ButtonFactory.getBackButton();
        super();
        this.close = this.backButton.clicked;
        this.showClasses = this.classesButton.clicked;
        addChild(new ScreenBase());
        addChild(new AccountScreen());
    }

    public function initialize(_arg1:PlayerModel):void {
        if (this.isInitialized) {
            return;
        }
        this.isInitialized = true;
        this.model = _arg1;
        this.createDisplayAssets(_arg1);
    }

    private function createDisplayAssets(_arg1:PlayerModel):void {
        this.createNameText();
        this.createCreditDisplay();
        this.createOpenCharactersText();
        var _local2:GraveYard = new GraveYard(_arg1);
        if (_local2.hasCharacters()) {
            this.openCharactersText.setColor(TAB_SELECTED);
            this.createOpenGraveYardText();
        }
        this.createCharacterListChar();
        this.makeMenuOptionsBar();
        if (!_arg1.isNameChosen()) {
            this.createChooseNameLink();
        }
    }

    private function makeMenuOptionsBar():void {
        this.playButton.clicked.add(this.onPlayClick);
        this.menuOptionsBar = new MenuOptionsBar();
        this.menuOptionsBar.addButton(this.playButton, MenuOptionsBar.CENTER);
        this.menuOptionsBar.addButton(this.backButton, MenuOptionsBar.LEFT);
        this.menuOptionsBar.addButton(this.classesButton, MenuOptionsBar.RIGHT);
        addChild(this.menuOptionsBar);
    }

    private function createScrollbar():void {
        this.scrollBar = new Scrollbar(16, CharacterList.HEIGHT);
        this.scrollBar.x = CharacterRect.WIDTH + 22;
        this.scrollBar.y = 113;
        this.scrollBar.setIndicatorSize(CharacterList.HEIGHT, this.characterList.height);
        this.scrollBar.addEventListener(Event.CHANGE, this.onScrollBarChange);
        addChild(this.scrollBar);
    }

    private function createCharacterListChar():void {
        this.characterListType = CharacterList.TYPE_CHAR_SELECT;
        this.characterList = new CharacterList(this.model, CharacterList.TYPE_CHAR_SELECT);
        this.characterList.x = this.CHARACTER_LIST_X_POS;
        this.characterList.y = this.CHARACTER_LIST_Y_POS;
        this.characterListHeight = this.characterList.height;
        if (this.characterListHeight > this.SCROLLBAR_REQUIREMENT_HEIGHT) {
            this.createScrollbar();
        }
        addChild(this.characterList);
    }

    private function createCharacterListGrave():void {
        this.characterListType = CharacterList.TYPE_GRAVE_SELECT;
        this.characterList = new CharacterList(this.model, CharacterList.TYPE_GRAVE_SELECT);
        this.characterList.x = this.CHARACTER_LIST_X_POS;
        this.characterList.y = this.CHARACTER_LIST_Y_POS;
        this.characterListHeight = this.characterList.height;
        if (this.characterListHeight > this.SCROLLBAR_REQUIREMENT_HEIGHT) {
            this.createScrollbar();
        }
        addChild(this.characterList);
    }

    private function removeCharacterList():void {
        if (this.characterList != null) {
            removeChild(this.characterList);
            this.characterList = null;
        }
        if (this.scrollBar != null) {
            removeChild(this.scrollBar);
            this.scrollBar = null;
        }
    }

    private function createOpenCharactersText():void {
        this.openCharactersText = new TextFieldDisplayConcrete().setSize(18).setColor(TAB_UNSELECTED);
        this.openCharactersText.setBold(true);
        this.openCharactersText.setStringBuilder(new LineBuilder().setParams("Characters"));
        this.openCharactersText.filters = [this.DROP_SHADOW];
        this.openCharactersText.x = this.CHARACTER_LIST_X_POS;
        this.openCharactersText.y = 79;
        this.openCharactersText.addEventListener(MouseEvent.CLICK, this.onOpenCharacters);
        addChild(this.openCharactersText);
    }

    private function onOpenCharacters(_arg1:MouseEvent):void {
        if (this.characterListType != CharacterList.TYPE_CHAR_SELECT) {
            this.removeCharacterList();
            this.openCharactersText.setColor(TAB_SELECTED);
            this.openGraveYardText.setColor(TAB_UNSELECTED);
            this.createCharacterListChar();
        }
    }

    private function createOpenGraveYardText():void {
        this.openGraveYardText = new TextFieldDisplayConcrete().setSize(18).setColor(TAB_UNSELECTED);
        this.openGraveYardText.setBold(true);
        this.openGraveYardText.setStringBuilder(new LineBuilder().setParams("Graveyard"));
        this.openGraveYardText.filters = [this.DROP_SHADOW];
        this.openGraveYardText.x = (this.CHARACTER_LIST_X_POS + 150);
        this.openGraveYardText.y = 79;
        this.openGraveYardText.addEventListener(MouseEvent.CLICK, this.onOpenGraveYard);
        addChild(this.openGraveYardText);
    }

    private function onOpenGraveYard(_arg1:MouseEvent):void {
        if (this.characterListType != CharacterList.TYPE_GRAVE_SELECT) {
            this.removeCharacterList();
            this.openCharactersText.setColor(TAB_UNSELECTED);
            this.openGraveYardText.setColor(TAB_SELECTED);
            this.createCharacterListGrave();
        }
    }

    private function createCreditDisplay():void {
        this.creditDisplay = new CreditDisplay();
        this.creditDisplay.draw(this.model.getCredits(), this.model.getFame(), this.model.getUnholyEssence(), this.model.getDivineEssence());
        this.creditDisplay.x = this.getReferenceRectangle().width;
        this.creditDisplay.y = 20;
        addChild(this.creditDisplay);
    }

    private function createChooseNameLink():void {
        this.nameChooseLink_ = new DeprecatedClickableText(16, false, "choose name");
        this.nameChooseLink_.y = 50;
        this.nameChooseLink_.setAutoSize(TextFieldAutoSize.CENTER);
        this.nameChooseLink_.x = (this.getReferenceRectangle().width / 2);
        this.nameChooseLink_.addEventListener(MouseEvent.CLICK, this.onChooseName);
        addChild(this.nameChooseLink_);
    }

    private function createNameText():void {
        this.nameText = new TextFieldDisplayConcrete().setSize(22).setColor(0xB3B3B3);
        this.nameText.setBold(true).setAutoSize(TextFieldAutoSize.CENTER);
        this.nameText.setStringBuilder(new StaticStringBuilder(this.model.getName()));
        this.nameText.filters = [this.DROP_SHADOW];
        this.nameText.y = 24;
        this.nameText.x = ((this.getReferenceRectangle().width - this.nameText.width) / 2);
        addChild(this.nameText);
    }

    private function getReferenceRectangle():Rectangle {
        var _local1:Rectangle = new Rectangle();
        if (stage) {
            _local1 = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        }
        return (_local1);
    }

    private function onChooseName(_arg1:MouseEvent):void {
        this.chooseName.dispatch();
    }

    private function onScrollBarChange(_arg1:Event):void {
        if (this.characterList != null) {
            this.characterList.setPos((-(this.scrollBar.pos()) * (this.characterListHeight - CharacterList.HEIGHT)));
        }
    }

    private function onPlayClick():void {
        if (this.model.getCharacterCount() == 0) {
            this.newCharacter.dispatch();
        }
        else {
            this.playGame.dispatch();
        }
    }

    public function setName(_arg1:String):void {
        this.nameText.setStringBuilder(new StaticStringBuilder(this.model.getName()));
        this.nameText.x = ((this.getReferenceRectangle().width - this.nameText.width) * 0.5);
        if (this.nameChooseLink_) {
            removeChild(this.nameChooseLink_);
            this.nameChooseLink_ = null;
        }
    }


}
}
