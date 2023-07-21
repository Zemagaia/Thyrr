package kabam.rotmg.ui.view {

import com.company.assembleegameclient.screens.AccountScreen;
import com.company.assembleegameclient.screens.TitleMenuOption;
import com.company.assembleegameclient.ui.SoundIcon;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.build.api.BuildData;

import kabam.rotmg.build.api.BuildEnvironment;
import kabam.rotmg.core.StaticInjectorContext;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.ui.model.EnvironmentData;
import kabam.rotmg.ui.view.components.DarkLayer;
import kabam.rotmg.ui.view.components.MenuOptionsBar;

import org.osflash.signals.Signal;

import thyrr.utils.Utils;

public class TitleView extends Sprite {

    public static const MIDDLE_OF_BOTTOM_BAND:Number = WebMain.DefaultHeight - 11;

    private static var TitleScreenGraphic:Class = TitleView_TitleScreenGraphic;
    public static var queueEmailConfirmation:Boolean = false;
    public static var queuePasswordPrompt:Boolean = false;
    public static var queuePasswordPromptFull:Boolean = false;
    public static var queueRegistrationPrompt:Boolean = false;

    private var versionText:TextFieldDisplayConcrete;
    private var copyrightText:TextFieldDisplayConcrete;
    private var menuOptionsBar:MenuOptionsBar;
    private var data:EnvironmentData;
    private var _login:Signal;
    private var _register:Signal;
    private var _reset:Signal;
    private var registerButton:TitleMenuOption;
    private var loginButton:TitleMenuOption;
    private var resetButton:TitleMenuOption;
    public var playClicked:Signal;
    public var serversClicked:Signal;
    public var accountClicked:Signal;
    public var legendsClicked:Signal;
    public var supportClicked:Signal;
    public var editorClicked:Signal;
    public var textureEditorClicked:Signal;
    public var quitClicked:Signal;
    public var optionalButtonsAdded:Signal;

    public function TitleView() {
        this.menuOptionsBar = this.makeMenuOptionsBar();
        this.optionalButtonsAdded = new Signal();
        super();
        addChild(new DarkLayer());
        addChild(new TitleScreenGraphic());
        addChild(this.menuOptionsBar);
        addChild(new AccountScreen());
        this.makeChildren();
        addChild(new SoundIcon());
        this.makeUIElements();
        this.makeSignals();
    }

    public function get login():Signal {
        return (this._login);
    }

    public function get register():Signal {
        return (this._register);
    }

    public function get reset():Signal {
        return (this._reset);
    }

    private function makeUIElements():void {
        this.makeLoginButton();
        this.makeRegisterButton();
        this.makeResetButton();
    }

    private function makeSignals():void {
        this._login = new Signal();
        this._register = new Signal();
        this._reset = new Signal();
        loginButton.addEventListener(MouseEvent.CLICK, onLogin);
        registerButton.addEventListener(MouseEvent.CLICK, onRegister);
        resetButton.addEventListener(MouseEvent.CLICK, onReset);
    }

    private function onLogin(e:MouseEvent):void
    {
        _login.dispatch();
    }

    private function onRegister(e:MouseEvent):void
    {
        _register.dispatch();
    }

    private function onReset(e:MouseEvent):void
    {
        _reset.dispatch();
    }

    private function makeMenuOptionsBar():MenuOptionsBar {
        var play:TitleMenuOption = ButtonFactory.getPlayButton();
        this.playClicked = play.clicked;

        var server:TitleMenuOption = ButtonFactory.getServersButton();
        this.serversClicked = server.clicked;

        var account:TitleMenuOption = ButtonFactory.getAccountButton();
        this.accountClicked = account.clicked;

        var legends:TitleMenuOption = ButtonFactory.getLegendsButton();
        this.legendsClicked = legends.clicked;

        var support:TitleMenuOption = ButtonFactory.getSupportButton();
        this.supportClicked = support.clicked;

        var bar:MenuOptionsBar = new MenuOptionsBar();
        bar.addButton(play, MenuOptionsBar.CENTER);
        bar.addButton(server, MenuOptionsBar.LEFT);
        bar.addButton(account, MenuOptionsBar.RIGHT);
        bar.addButton(legends, MenuOptionsBar.RIGHT);
        return bar;
    }

    private function makeChildren():void {
        this.versionText = this.makeText().setHTML(true).setAutoSize(TextFieldAutoSize.LEFT).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        this.versionText.y = MIDDLE_OF_BOTTOM_BAND;
        addChild(this.versionText);
        this.copyrightText = this.makeText().setAutoSize(TextFieldAutoSize.RIGHT).setVerticalAlign(TextFieldDisplayConcrete.MIDDLE);
        this.copyrightText.setStringBuilder(new LineBuilder().setParams("2022 - Thyrr"));
        this.copyrightText.filters = [Utils.OutlineFilter];
        this.copyrightText.x = WebMain.DefaultWidth;
        this.copyrightText.y = MIDDLE_OF_BOTTOM_BAND;
        addChild(this.copyrightText);
    }

    public function makeText():TextFieldDisplayConcrete {
        var _local1:TextFieldDisplayConcrete = new TextFieldDisplayConcrete().setSize(12).setColor(0xffffff);
        _local1.filters = [new DropShadowFilter(0, 0, 0)];
        return (_local1);
    }

    public function initialize(_arg1:EnvironmentData):void {
        this.data = _arg1;
        this.updateVersionText();
        this.handleOptionalButtons();
    }

    public function putNoticeTagToOption(_arg1:TitleMenuOption, _arg2:String, _arg3:int = 14, _arg4:uint = 10092390, _arg5:Boolean = true):void {
        _arg1.createNoticeTag(_arg2, _arg3, _arg4, _arg5);
    }

    private function updateVersionText():void {
        this.versionText.setStringBuilder(new StaticStringBuilder(this.data.buildLabel));
    }

    private function handleOptionalButtons():void {
        this.data.canMapEdit && this.createEditorButton();
        this.optionalButtonsAdded.dispatch();
    }

    private function createEditorButton():void {
        var _local1:TitleMenuOption = ButtonFactory.getEditorButton();
        this.menuOptionsBar.addButton(_local1, MenuOptionsBar.LEFT);
        this.editorClicked = _local1.clicked;
    }


    private function makeLoginButton():void {
        this.loginButton = new TitleMenuOption("Log in", 24, 16);
    }

    private function makeResetButton():void {
        this.resetButton = new TitleMenuOption("Reset", 24, 16);
    }

    private function makeRegisterButton():void {
        this.registerButton = new TitleMenuOption("Register", 24, 16);
    }

    public function setInfo(_arg1:String, _arg2:Boolean):void {
        this.updateUI(_arg1, _arg2);
    }

    private function updateUI(_arg1:String, _arg2:Boolean):void {
        if (_arg2) {
            this.showUIForRegisteredAccount();
        }
        else {
            this.showUIForGuestAccount();
        }
    }

    private function showUIForRegisteredAccount():void {
        var _local1:BuildData = StaticInjectorContext.getInjector().getInstance(BuildData);
        this.loginButton.setTextKey("Log out");
        if ((((_local1.getEnvironment() == BuildEnvironment.TESTING)) || ((_local1.getEnvironment() == BuildEnvironment.LOCALHOST))))
        {
            // reset, login
            addChild(this.resetButton);
            addChild(this.loginButton);
            this.resetButton.x = WebMain.DefaultWidth - resetButton.width - 4;
            this.resetButton.y = 10;
            this.loginButton.x = this.resetButton.x - loginButton.width - 4;
            this.loginButton.y = 10;
        }
        else
        {
            // login
            addChild(this.loginButton);
            this.loginButton.x = WebMain.DefaultWidth - loginButton.width - 4;
            this.loginButton.y = 10;
        }
    }

    private function showUIForGuestAccount():void {
        // register, login
        this.loginButton.setTextKey("Log in");
        addChild(this.registerButton);
        addChild(this.loginButton);
        this.registerButton.x = WebMain.DefaultWidth - registerButton.width - 4;
        this.registerButton.y = 10;
        this.loginButton.x = this.registerButton.x - loginButton.width - 4;
        this.loginButton.y = 10;
    }

}
}
