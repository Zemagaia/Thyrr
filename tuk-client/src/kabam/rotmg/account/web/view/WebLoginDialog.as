package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.CheckBoxField;
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;
import com.company.assembleegameclient.ui.DeprecatedClickableText;
import com.company.util.KeyCodes;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import kabam.lib.tasks.Task;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.web.WebAccount;

import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.messaging.impl.GameServerConnection;

import org.osflash.signals.Signal;

public class WebLoginDialog extends Frame {

    public var account:Account = Global.account;
    private var email:TextInputField;
    private var password:TextInputField;
    private var forgotText:DeprecatedClickableText;
    private var registerText:DeprecatedClickableText;
    private var rememberMeCheckbox:CheckBoxField;

    public function WebLoginDialog() {
        super("Sign in", "Cancel", "Sign in");
        this.makeUI();
        leftButton_.addEventListener(MouseEvent.CLICK, this.onCancel);
        forgotText.addEventListener(MouseEvent.CLICK, onForgot);
        registerText.addEventListener(MouseEvent.CLICK, onRegister);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        Global.taskErrorSignal.add(this.onLoginError);
    }

    public function destroy(e:Event):void {
        Global.taskErrorSignal.remove(this.onLoginError);
    }

    private function signIn(_arg1:AccountData):void {
        if ((this.account is WebAccount)) {
            WebAccount(this.account).rememberMe = this.isRememberMeSelected();
        }
        this.disable();
        Global.login(_arg1);
    }

    private function onRegister(e:MouseEvent):void {
        Global.openDialog(new WebRegisterDialog());
    }

    private function onCancel(e:Event):void {
        Global.closeDialogs();
    }

    private function onForgot(e:MouseEvent):void {
        Global.openDialog(new WebForgotPasswordDialog());
    }

    private function onLoginError(_arg1:Task):void {
        this.setError(_arg1.error);
        this.enable();
    }

    private function makeUI():void {
        this.email = new TextInputField("Email", false);
        addTextInputField(this.email);
        this.password = new TextInputField("Password", true);
        addTextInputField(this.password);
        this.rememberMeCheckbox = new CheckBoxField("Remember me", false);
        this.rememberMeCheckbox.text_.y = 4;
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

    private function onKeyDown(event:KeyboardEvent):void {
        switch (event.keyCode) {
            case KeyCodes.ENTER:
                this.onSignInSub();
                break;
            case KeyCodes.ESCAPE:
                this.onCancel(event);
                break;
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
            this.signIn(_local1);
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

    public function isRememberMeSelected():Boolean {
        return (true);
    }

    public function setError(_arg1:String):void {
        this.password.setError(_arg1);
    }

    public function setEmail(_arg1:String):void {
        this.email.inputText_.text = _arg1;
    }


}
}
