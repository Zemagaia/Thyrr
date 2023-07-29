package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;
import com.company.assembleegameclient.ui.DeprecatedClickableText;
import com.company.util.KeyCodes;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

import kabam.rotmg.account.core.Account;

import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.messaging.impl.GameServerConnection;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class WebLoginDialogForced extends Frame {

    public var account:Account = Global.account;
    public var email:TextInputField;
    private var password:TextInputField;
    private var forgotText:DeprecatedClickableText;
    private var registerText:DeprecatedClickableText;

    public function WebLoginDialogForced(_arg1:Boolean = false) {
        super("Sign in", "", "Sign in");
        this.makeUI();
        if (_arg1) {
            addChild(this.getText("Attention!", -165, -85).setColor(0xFF0000));
            addChild(this.getText("A new password was sent to your Sign In Email Address.", -165, -65));
            addChild(this.getText("Please use the new password to Sign In.", -165, -45));
        }
        forgotText.addEventListener(MouseEvent.CLICK, onForgot);
        registerText.addEventListener(MouseEvent.CLICK, onRegister);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy)
    }

    public function initialize(e:Event):void {
        Global.taskErrorSignal.add(this.onLoginError);
    }

    public function destroy(e:Event):void {
        Global.taskErrorSignal.remove(this.onLoginError);
    }

    private function signIn(_arg1:AccountData):void {
        var appEngine:AppEngineClient;
        this.email.clearError();
        this.disable();
        if (this.account.getUserId().toLowerCase() == _arg1.username.toLowerCase()) {
            appEngine = Global.appEngine;
            appEngine.sendRequest("/account/verify", {
                "guid": _arg1.username,
                "password": _arg1.password,
                "fromResetFlow": "yes"
            });
            appEngine.complete.addOnce(this.onComplete);
        }
        else {
            this.email.setError("Email does not match current session");
            this.enable();
        }
    }

    private function register():void {
        Global.openDialog(new WebRegisterDialog());
    }

    private function forgot():void {
        Global.openDialog(new WebForgotPasswordDialog());
    }

    private function onComplete(_arg1:Boolean, _arg2:*):void {
        if (!_arg1) {
            this.onLoginError(_arg2);
        }
        else {
            Global.openDialog(new WebChangePasswordDialogForced());
        }
    }

    private function onLoginError(_arg1:String):void {
        this.setError(_arg1);
        this.enable();
    }

    private function onForgot(e:MouseEvent):void
    {
        this.forgot();
    }

    private function onRegister(e:MouseEvent):void
    {
        this.register();
    }

    private function makeUI():void {
        this.email = new TextInputField("Email", false);
        addTextInputField(this.email);
        this.password = new TextInputField("Password", true);
        addTextInputField(this.password);
        this.forgotText = new DeprecatedClickableText(12, false, "Forgot your password?  Click here");
        addNavigationText(this.forgotText);
        this.registerText = new DeprecatedClickableText(12, false, "New user?  Click here to Register");
        addNavigationText(this.registerText);
        rightButton_.addEventListener(MouseEvent.CLICK, this.onSignIn);
        addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function onKeyDown(_arg1:KeyboardEvent):void {
        if (_arg1.keyCode == KeyCodes.ENTER) {
            this.onSignInSub();
        }
    }

    private function onSignIn(_arg1:MouseEvent):void {
        this.onSignInSub();
    }

    private function onSignInSub():void {
        var _local1:AccountData;
        if (((this.isEmailValid()) && (this.isPasswordValid()))) {
            _local1 = new AccountData();
            _local1.username = this.email.text();
            _local1.password = GameServerConnection.rsaEncrypt(this.password.text());
            signIn(_local1);
        }
    }

    private function isPasswordValid():Boolean {
        var _local1:Boolean = !((this.password.text() == ""));
        if (!_local1) {
            this.password.setError("Password too short");
        }
        return (_local1);
    }

    private function isEmailValid():Boolean {
        var _local1:Boolean = !((this.email.text() == ""));
        if (!_local1) {
            this.email.setError("Not a valid email address");
        }
        return (_local1);
    }

    public function setError(_arg1:String):void {
        this.password.setError(_arg1);
    }

    public function getText(_arg1:String, _arg2:int, _arg3:int):TextFieldDisplayConcrete {
        var _local4:TextFieldDisplayConcrete = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setTextWidth(Main.DefaultHeight);
        _local4.setBold(true);
        _local4.setStringBuilder(new StaticStringBuilder(_arg1));
        _local4.setSize(16).setColor(0xFFFFFF);
        _local4.setWordWrap(true);
        _local4.setMultiLine(true);
        _local4.setAutoSize(TextFieldAutoSize.CENTER);
        _local4.setHorizontalAlign(TextFormatAlign.CENTER);
        _local4.filters = [new DropShadowFilter(0, 0, 0)];
        _local4.x = _arg2;
        _local4.y = _arg3;
        return (_local4);
    }


}
}
