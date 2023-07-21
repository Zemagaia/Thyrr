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

import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.messaging.impl.GameServerConnection;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import org.osflash.signals.Signal;

public class WebLoginDialogForced extends Frame {

    public var signInForced:Signal;
    public var forgot:Signal;
    public var register:Signal;
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
        this.forgot = new Signal();
        this.register = new Signal();
        this.signInForced = new Signal(AccountData);
        forgotText.addEventListener(MouseEvent.CLICK, onForgot);
        registerText.addEventListener(MouseEvent.CLICK, onRegister);
    }

    private function onForgot(e:MouseEvent):void
    {
        this.forgot.dispatch();
    }

    private function onRegister(e:MouseEvent):void
    {
        this.register.dispatch();
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
            this.signInForced.dispatch(_local1);
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
        var _local4:TextFieldDisplayConcrete = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setTextWidth(WebMain.DefaultHeight);
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
