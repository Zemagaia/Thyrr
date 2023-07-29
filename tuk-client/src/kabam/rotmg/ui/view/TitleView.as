package kabam.rotmg.ui.view {

import com.company.assembleegameclient.mapeditor.MapEditor;
import com.company.assembleegameclient.screens.AccountScreen;
import com.company.assembleegameclient.screens.ServersScreen;
import com.company.assembleegameclient.screens.TitleMenuOption;
import com.company.assembleegameclient.ui.SoundIcon;
import com.company.assembleegameclient.ui.dialogs.ConfirmDialog;
import com.company.assembleegameclient.ui.language.LanguageOptionOverlay;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.filters.DropShadowFilter;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.account.web.view.WebLoginDialog;
import kabam.rotmg.account.web.view.WebRegisterDialog;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.application.DynamicSettings;
import kabam.rotmg.application.api.ApplicationSetup;
import kabam.rotmg.build.api.BuildData;
import kabam.rotmg.build.api.BuildEnvironment;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.core.view.Layers;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.ui.model.EnvironmentData;
import kabam.rotmg.ui.view.components.DarkLayer;
import kabam.rotmg.ui.view.components.MenuOptionsBar;

import org.osflash.signals.Signal;

import thyrr.utils.Utils;

public class TitleView extends Sprite {

    public static const MIDDLE_OF_BOTTOM_BAND:Number = Main.DefaultHeight - 11;

    private static var TitleScreenGraphic:Class = TitleView_TitleScreenGraphic;
    public static var queueEmailConfirmation:Boolean = false;
    public static var queuePasswordPrompt:Boolean = false;
    public static var queuePasswordPromptFull:Boolean = false;
    public static var queueRegistrationPrompt:Boolean = false;
    private static var supportCalledBefore:Boolean = false;
    
    public var account:Account = Global.account;
    public var playerModel:PlayerModel = Global.playerModel;
    public var setup:ApplicationSetup = Global.applicationSetup;
    public var layers:Layers = Global.layers;
    public var client:AppEngineClient = Global.appEngine;
    private var email:String;
    private var pass:String;
    private var versionText:TextFieldDisplayConcrete;
    private var copyrightText:TextFieldDisplayConcrete;
    private var menuOptionsBar:MenuOptionsBar;
    private var data:EnvironmentData;
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
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function onAdded(e:Event):void {
        this.optionalButtonsAdded.add(this.onOptionalButtonsAdded);
        this.initialize(this.makeEnvironmentData());
        this.setInfo(this.account.getUserId(), this.account.isRegistered());
        this.playClicked.add(this.handleIntentionToPlay);
        this.serversClicked.add(this.showServersScreen);
        this.accountClicked.add(this.handleIntentionToReviewAccount);
        this.legendsClicked.add(this.showLegendsScreen);
        this.supportClicked.add(this.openSupportPage);
    }

    private function openSupportPage():void {
        var _local1:URLVariables = new URLVariables();
        var _local2:URLRequest = new URLRequest();
        var _local3:Boolean;
        if (((DynamicSettings.settingExists("SalesforceMobile")) && ((DynamicSettings.getSettingValue("SalesforceMobile") == 1)))) {
            _local3 = true;
        }
        var _local4:String = this.playerModel.getSalesForceData();
        if ((((_local4 == "unavailable")) || (!(_local3)))) {
            _local1.language = "en_US";
            _local1.game = "a0Za000000jIBFUEA4";
            _local1.issue = "Other_Game_Issues";
            _local2.url = "http://rotmg.decagames.io";
            _local2.method = URLRequestMethod.GET;
            _local2.data = _local1;
            navigateToURL(_local2, "_blank");
        } else {
            if ((((Capabilities.playerType == "PlugIn")) || ((Capabilities.playerType == "ActiveX")))) {
                if (!supportCalledBefore) {
                    ExternalInterface.call("openSalesForceFirstTime", _local4);
                    supportCalledBefore = true;
                } else {
                    ExternalInterface.call("reopenSalesForce");
                }
            } else {
                _local1.data = _local4;
                _local2.url = "http://rotmg.decagames.io";
                _local2.method = URLRequestMethod.GET;
                _local2.data = _local1;
                navigateToURL(_local2, "_blank");
            }
        }
    }

    private function onOptionalButtonsAdded():void {
        this.editorClicked && this.editorClicked.add(this.showMapEditor);
        this.textureEditorClicked && this.textureEditorClicked.add(this.showSpriteEditor);
        this.quitClicked && this.quitClicked.add(this.attemptToCloseClient);
    }

    public function showLanguagesScreen():void {
        Global.setScreen(new LanguageOptionOverlay());
    }

    private function makeEnvironmentData():EnvironmentData {
        var ed:EnvironmentData = new EnvironmentData();
        var rank:int = this.playerModel.getRank();
        ed.isDesktop = Capabilities.playerType == "Desktop";
        ed.canMapEdit = rank >= this.playerModel.getMapMinRank();
        ed.canSprite = rank >= this.playerModel.getSpriteMinRank();
        ed.buildLabel = this.setup.getBuildLabel();
        return ed;
    }

    public function destroy(e:Event):void {
        this.playClicked.remove(this.handleIntentionToPlay);
        this.serversClicked.remove(this.showServersScreen);
        this.accountClicked.remove(this.handleIntentionToReviewAccount);
        this.legendsClicked.remove(this.showLegendsScreen);
        this.supportClicked.remove(this.openSupportPage);
        this.optionalButtonsAdded.remove(this.onOptionalButtonsAdded);
        this.editorClicked && this.editorClicked.remove(this.showMapEditor);
        this.textureEditorClicked && this.textureEditorClicked.remove(this.showSpriteEditor);
        this.quitClicked && this.quitClicked.remove(this.attemptToCloseClient);
    }

    private function handleIntentionToPlay():void {
        Global.enterGame();
    }

    private function showServersScreen():void {
        Global.setScreen(new ServersScreen());
    }

    private function handleIntentionToReviewAccount():void {
        Global.openAccountInfo();
    }

    private function showLegendsScreen():void {
        Global.setLegendsView();
        Global.setScreen(Global.legendsView);
    }

    private function showMapEditor():void {
        Global.setMapEditor(new MapEditor());
        Global.setScreen(Global.mapEditor);
    }

    private function showSpriteEditor():void {
        Global.setTextureView();
        Global.setScreen(Global.textureView);
    }

    private function attemptToCloseClient():void {
        dispatchEvent(new Event("APP_CLOSE_EVENT"));
    }

    private function doRegister():void {
        Global.openDialog(new WebRegisterDialog());
    }

    private function onLoginToggle():void {
        if (this.account.isRegistered()) {
            this.onLogOut();
        }
        else {
            Global.openDialog(new WebLoginDialog());
        }
    }

    private function onLogOut():void {
        Global.logout();
        this.setInfo("", false);
    }

    private function onResetComplete(isOk:Boolean, data:*):void {
        var accountData:AccountData;
        if (isOk) {
            accountData = new AccountData();
            accountData.username = this.email;
            accountData.password = this.pass;
            Global.login(accountData);
        }
    }

    private function onResetPhase1():void {
        var _local1:ConfirmDialog = new ConfirmDialog("ResetAccount", "Are you sure you want to reset your account back to realmofthemadgod.com values?", this.onResetPhase2);
        Global.openDialog(_local1);
    }

    private function onResetPhase2():void {
        var credentials:Object = this.account.getCredentials();
        this.email = this.account.getUserId();
        this.pass = this.account.getPassword();
        Global.logout();
        this.client.complete.addOnce(this.onResetComplete);
        this.client.sendRequest("/migrate/userAccountReset", credentials);
    }

    private function makeUIElements():void {
        this.makeLoginButton();
        this.makeRegisterButton();
        this.makeResetButton();
    }

    private function makeSignals():void {
        loginButton.addEventListener(MouseEvent.CLICK, onLogin);
        registerButton.addEventListener(MouseEvent.CLICK, onRegister);
        resetButton.addEventListener(MouseEvent.CLICK, onReset);
    }

    private function onLogin(e:MouseEvent):void
    {
        onLoginToggle();
    }

    private function onRegister(e:MouseEvent):void
    {
        doRegister();
    }

    private function onReset(e:MouseEvent):void
    {
        onResetPhase1();
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
        this.copyrightText.x = Main.DefaultWidth;
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
        var _local1:BuildData = Global.buildData;
        this.loginButton.setTextKey("Log out");
        if ((((_local1.getEnvironment() == BuildEnvironment.TESTING)) || ((_local1.getEnvironment() == BuildEnvironment.LOCALHOST))))
        {
            // reset, login
            addChild(this.resetButton);
            addChild(this.loginButton);
            this.resetButton.x = Main.DefaultWidth - resetButton.width - 4;
            this.resetButton.y = 10;
            this.loginButton.x = this.resetButton.x - loginButton.width - 4;
            this.loginButton.y = 10;
        }
        else
        {
            // login
            addChild(this.loginButton);
            this.loginButton.x = Main.DefaultWidth - loginButton.width - 4;
            this.loginButton.y = 10;
        }
    }

    private function showUIForGuestAccount():void {
        // register, login
        this.loginButton.setTextKey("Log in");
        addChild(this.registerButton);
        addChild(this.loginButton);
        this.registerButton.x = Main.DefaultWidth - registerButton.width - 4;
        this.registerButton.y = 10;
        this.loginButton.x = this.registerButton.x - loginButton.width - 4;
        this.loginButton.y = 10;
    }

}
}
