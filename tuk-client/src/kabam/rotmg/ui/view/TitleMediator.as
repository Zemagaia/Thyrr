package kabam.rotmg.ui.view {
import com.company.assembleegameclient.mapeditor.MapEditor;
import com.company.assembleegameclient.screens.ServersScreen;
import com.company.assembleegameclient.ui.dialogs.ConfirmDialog;
import com.company.assembleegameclient.ui.language.LanguageOptionOverlay;

import flash.events.Event;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.navigateToURL;
import flash.system.Capabilities;

import kabam.lib.tasks.Task;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.services.LoadAccountTask;
import kabam.rotmg.account.core.signals.LoginSignal;
import kabam.rotmg.account.core.signals.LogoutSignal;
import kabam.rotmg.account.core.signals.OpenAccountInfoSignal;
import kabam.rotmg.account.securityQuestions.data.SecurityQuestionsModel;
import kabam.rotmg.account.securityQuestions.view.SecurityQuestionsInfoDialog;
import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.account.web.view.WebLoginDialog;
import kabam.rotmg.account.web.view.WebRegisterDialog;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.application.DynamicSettings;
import kabam.rotmg.application.api.ApplicationSetup;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.core.signals.SetScreenSignal;
import kabam.rotmg.core.signals.SetScreenWithValidDataSignal;
import kabam.rotmg.core.view.Layers;
import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.editor.view.TextureView;
import kabam.rotmg.legends.view.LegendsView;
import kabam.rotmg.ui.model.EnvironmentData;
import kabam.rotmg.ui.signals.EnterGameSignal;

import robotlegs.bender.bundles.mvcs.Mediator;
import robotlegs.bender.framework.api.ILogger;

public class TitleMediator extends Mediator {

    private static var supportCalledBefore:Boolean = false;

    [Inject]
    public var view:TitleView;
    [Inject]
    public var account:Account;
    [Inject]
    public var playerModel:PlayerModel;
    [Inject]
    public var setScreen:SetScreenSignal;
    [Inject]
    public var setScreenWithValidData:SetScreenWithValidDataSignal;
    [Inject]
    public var enterGame:EnterGameSignal;
    [Inject]
    public var openAccountInfo:OpenAccountInfoSignal;
    [Inject]
    public var openDialog:OpenDialogSignal;
    [Inject]
    public var setup:ApplicationSetup;
    [Inject]
    public var layers:Layers;
    [Inject]
    public var securityQuestionsModel:SecurityQuestionsModel;
    [Inject]
    public var logger:ILogger;
    [Inject]
    public var client:AppEngineClient;
    [Inject]
    public var logout:LogoutSignal;
    [Inject]
    public var login:LoginSignal;
    [Inject]
    public var loadAccount:LoadAccountTask;
    private var email:String;
    private var pass:String;


    override public function initialize():void {
        this.view.optionalButtonsAdded.add(this.onOptionalButtonsAdded);
        this.view.initialize(this.makeEnvironmentData());
        this.view.setInfo(this.account.getUserId(), this.account.isRegistered());
        this.view.playClicked.add(this.handleIntentionToPlay);
        this.view.serversClicked.add(this.showServersScreen);
        this.view.accountClicked.add(this.handleIntentionToReviewAccount);
        this.view.legendsClicked.add(this.showLegendsScreen);
        this.view.supportClicked.add(this.openSupportPage);
        if (this.securityQuestionsModel.showSecurityQuestionsOnStartup) {
            this.openDialog.dispatch(new SecurityQuestionsInfoDialog());
        }
        this.view.login.add(this.onLoginToggle);
        this.view.register.add(this.onRegister);
        this.view.reset.add(this.onResetPhase1);
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
        this.view.editorClicked && this.view.editorClicked.add(this.showMapEditor);
        this.view.textureEditorClicked && this.view.textureEditorClicked.add(this.showSpriteEditor);
        this.view.quitClicked && this.view.quitClicked.add(this.attemptToCloseClient);
    }

    private function showLanguagesScreen():void {
        this.setScreen.dispatch(new LanguageOptionOverlay());
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

    override public function destroy():void {
        this.view.playClicked.remove(this.handleIntentionToPlay);
        this.view.serversClicked.remove(this.showServersScreen);
        this.view.accountClicked.remove(this.handleIntentionToReviewAccount);
        this.view.legendsClicked.remove(this.showLegendsScreen);
        this.view.supportClicked.remove(this.openSupportPage);
        this.view.optionalButtonsAdded.remove(this.onOptionalButtonsAdded);
        this.view.editorClicked && this.view.editorClicked.remove(this.showMapEditor);
        this.view.textureEditorClicked && this.view.textureEditorClicked.remove(this.showSpriteEditor);
        this.view.quitClicked && this.view.quitClicked.remove(this.attemptToCloseClient);
        this.view.login.remove(this.onLoginToggle);
        this.view.register.remove(this.onRegister);
        this.view.reset.remove(this.onResetPhase1);
    }

    private function handleIntentionToPlay():void {
        this.enterGame.dispatch();
    }

    private function showServersScreen():void {
        this.setScreen.dispatch(new ServersScreen());
    }

    private function handleIntentionToReviewAccount():void {
        this.openAccountInfo.dispatch(false);
    }

    private function showLegendsScreen():void {
        this.setScreen.dispatch(new LegendsView());
    }

    private function showMapEditor():void {
        this.setScreen.dispatch(new MapEditor());
    }

    private function showSpriteEditor():void {
        this.setScreen.dispatch(new TextureView());
    }

    private function attemptToCloseClient():void {
        dispatch(new Event("APP_CLOSE_EVENT"));
    }

    private function onRegister():void {
        this.openDialog.dispatch(new WebRegisterDialog());
    }

    private function onLoginToggle():void {
        if (this.account.isRegistered()) {
            this.onLogOut();
        }
        else {
            this.openDialog.dispatch(new WebLoginDialog());
        }
    }

    private function onLogOut():void {
        this.logout.dispatch();
        this.view.setInfo("", false);
    }

    private function onResetComplete(_arg1:Boolean, _arg2:*):void {
        var _local3:AccountData;
        if (_arg1) {
            _local3 = new AccountData();
            _local3.username = this.email;
            _local3.password = this.pass;
            this.login.dispatch(_local3);
        }
    }

    private function onResetPhase1():void {
        var _local1:ConfirmDialog = new ConfirmDialog("ResetAccount", "Are you sure you want to reset your account back to realmofthemadgod.com values?", this.onResetPhase2);
        this.openDialog.dispatch(_local1);
    }

    private function onResetPhase2():void {
        var _local1:Object = this.account.getCredentials();
        this.email = this.account.getUserId();
        this.pass = this.account.getPassword();
        this.logout.dispatch();
        this.client.complete.addOnce(this.onResetComplete);
        this.client.sendRequest("/migrate/userAccountReset", _local1);
    }

}
}