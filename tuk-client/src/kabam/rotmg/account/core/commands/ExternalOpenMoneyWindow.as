﻿package kabam.rotmg.account.core.commands {
import com.company.assembleegameclient.ui.dialogs.ErrorDialog;

import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.navigateToURL;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.model.JSInitializedModel;
import kabam.rotmg.account.core.model.MoneyConfig;
import kabam.rotmg.account.web.WebAccount;
import kabam.rotmg.application.api.ApplicationSetup;
import kabam.rotmg.build.api.BuildData;
import kabam.rotmg.build.api.BuildEnvironment;
import kabam.rotmg.core.model.PlayerModel;

public class ExternalOpenMoneyWindow
{

    private const TESTING_ERROR_MESSAGE:String = "You cannot purchase gold on the testing server";
    private const REGISTRATION_ERROR_MESSAGE:String = "You must be registered to buy gold";

    public var moneyWindowModel:JSInitializedModel = Global.jsInitializedModel;
    public var account:Account = Global.account;
    public var moneyConfig:MoneyConfig = Global.moneyConfig;

    public var buildData:BuildData = Global.buildData;
    public var applicationSetup:ApplicationSetup = Global.applicationSetup;
    public var playerModel:PlayerModel = Global.playerModel;


    public function ExternalOpenMoneyWindow() {
        if (((this.isGoldPurchaseEnabled()) && (this.account.isRegistered()))) {
            this.handleValidMoneyWindowRequest();
        }
        else {
            this.handleInvalidMoneyWindowRequest();
        }
    }

    private function handleInvalidMoneyWindowRequest():void {
        if (!this.isGoldPurchaseEnabled()) {
            Global.openDialog(new ErrorDialog(this.TESTING_ERROR_MESSAGE));
        }
        else {
            if (!this.account.isRegistered()) {
                Global.openDialog(new ErrorDialog(this.REGISTRATION_ERROR_MESSAGE));
            }
        }
    }

    private function handleValidMoneyWindowRequest():void {
        if ((((this.account is WebAccount)) && ((WebAccount(this.account).paymentProvider == "paymentwall")))) {
            try {
                this.openPaymentwallMoneyWindowFromBrowser(WebAccount(this.account).paymentData);
            }
            catch (e:Error) {
                openPaymentwallMoneyWindowFromStandalonePlayer(WebAccount(account).paymentData);
            }
        }
        else {
            try {
                this.openKabamMoneyWindowFromBrowser();
            }
            catch (e:Error) {
                openKabamMoneyWindowFromStandalonePlayer();
            }
        }
    }

    private function openKabamMoneyWindowFromStandalonePlayer():void {
        var _local1:String = this.applicationSetup.getAppEngineUrl(true);
        var _local2:URLVariables = new URLVariables();
        var _local3:URLRequest = new URLRequest();
        _local2.naid = this.account.getMoneyUserId();
        _local2.signedRequest = this.account.getMoneyAccessToken();
        _local2.createdat = 0;
        _local3.url = (_local1 + "/credits/kabamadd");
        _local3.method = URLRequestMethod.POST;
        _local3.data = _local2;
        navigateToURL(_local3, "_blank");
        trace("Opening window from standalone player");
    }

    private function openPaymentwallMoneyWindowFromStandalonePlayer(_arg1:String):void {
        var _local2:String = this.applicationSetup.getAppEngineUrl(true);
        var _local3:URLVariables = new URLVariables();
        var _local4:URLRequest = new URLRequest();
        _local3.iframeUrl = _arg1;
        _local4.url = (_local2 + "/credits/pwpurchase");
        _local4.method = URLRequestMethod.POST;
        _local4.data = _local3;
        navigateToURL(_local4, "_blank");
        trace("Opening window from standalone player");
    }

    private function initializeMoneyWindow():void {
        var _local1:Number = 0;
        if (!this.moneyWindowModel.isInitialized) {
            ExternalInterface.call(this.moneyConfig.jsInitializeFunction(), this.account.getMoneyUserId(), this.account.getMoneyAccessToken(), _local1);
            this.moneyWindowModel.isInitialized = true;
        }
    }

    private function openKabamMoneyWindowFromBrowser():void {
        this.initializeMoneyWindow();
        trace("Attempting External Payments");
        ExternalInterface.call("rotmg.KabamPayment.displayPaymentWall");
    }

    private function openPaymentwallMoneyWindowFromBrowser(_arg1:String):void {
        trace("Attempting External Payments via Paymentwall");
        ExternalInterface.call("rotmg.Paymentwall.showPaymentwall", _arg1);
    }

    private function isGoldPurchaseEnabled():Boolean {
        return (((!((this.buildData.getEnvironment() == BuildEnvironment.TESTING))) || (this.playerModel.isAdmin())));
    }


}
}
