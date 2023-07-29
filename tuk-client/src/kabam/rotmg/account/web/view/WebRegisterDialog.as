package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.DeprecatedClickableText;
import com.company.util.EmailValidator;
import com.company.util.KeyCodes;

import flash.events.Event;

import flash.events.KeyboardEvent;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.lib.tasks.Task;

import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.messaging.impl.GameServerConnection;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class WebRegisterDialog extends Frame {

    private const errors:Array = [];

    private var emailInput:LabeledField;
    private var passwordInput:LabeledField;
    private var retypePasswordInput:LabeledField;
    private var signInText:DeprecatedClickableText;
    private var tosText:TextFieldDisplayConcrete;
    private var endLink:String = "</a></font>";

    public function WebRegisterDialog() {
        super("Register in order to save your progress", "Cancel", "Register", 326);
        this.makeUIElements();
        this.makeSignals();
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, initialize);
    }

    public function initialize(e:Event):void {
        Global.taskErrorSignal.add(this.onRegistrationError);
    }

    public function destroy(e:Event):void {
        Global.taskErrorSignal.remove(this.onRegistrationError);
    }

    private function onRegistrationError(_arg1:Task):void {
        this.displayServerError(_arg1.error);
        this.enable();
    }

    private function makeUIElements():void {
        this.emailInput = new LabeledField("Email", false, 275);
        this.passwordInput = new LabeledField("Password", true, 275);
        this.retypePasswordInput = new LabeledField("Retype Password", true, 275);
        addLabeledField(this.emailInput);
        addLabeledField(this.passwordInput);
        addLabeledField(this.retypePasswordInput);
        addSpace(10);
        this.makeTosText();
        addSpace(20);
        this.makeSignInText();
    }

    public function makeSignInText():void {
        this.signInText = new DeprecatedClickableText(12, false, "Already registered?  Click here to sign in!");
        addNavigationText(this.signInText);
    }

    public function makeTosText():void {
        this.tosText = new TextFieldDisplayConcrete();
        var _local1:String = (('<font color="#7777EE"><a href="' + Parameters.TERMS_OF_USE_URL) + '" target="_blank">');
        var _local2:String = (('<font color="#7777EE"><a href="' + Parameters.PRIVACY_POLICY_URL) + '" target="_blank">');
        this.tosText.setStringBuilder(new LineBuilder()
                .setParams('By clicking "Register", you are indicating that you have read and agreed to the {tou}Terms of Use{_tou} and {policy}Privacy Policy{_policy}', {
            "tou": '<b>' + _local1,
            "_tou": this.endLink + '</b>',
            "policy": '<b>' + _local2,
            "_policy": this.endLink + '</b>'
        }));
        this.configureTextAndAdd(this.tosText);
    }

    public function configureTextAndAdd(_arg1:TextFieldDisplayConcrete):void {
        _arg1.setSize(13).setColor(0xB3B3B3);
        _arg1.setTextWidth(275);
        _arg1.setMultiLine(true).setWordWrap(true).setHTML(true);
        _arg1.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(_arg1);
        positionText(_arg1, true);
    }

    private function makeSignals():void {
        rightButton_.addEventListener(MouseEvent.CLICK, this.onRegister);
        leftButton_.addEventListener(MouseEvent.CLICK, this.onCancel);
        addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        signInText.addEventListener(MouseEvent.CLICK, onSignIn);
    }

    private function onSignIn(e:MouseEvent):void
    {
        Global.openDialog(new WebLoginDialog());
    }

    private function onCancel(event:MouseEvent):void {
        Global.closeDialogs();
    }

    private function onKeyDown(event:KeyboardEvent):void {
        switch (event.keyCode) {
            case KeyCodes.ENTER:
                this.Register();
                break;
            case KeyCodes.ESCAPE:
                Global.closeDialogs();
                break;
        }
    }

    private function onRegister(_arg1:MouseEvent):void {
        this.Register();
    }

    private function Register():void {
        var _local2:Boolean = this.areInputsValid();
        this.displayErrors();
        if (_local2) {
            this.sendData();
        }
    }

    private function areInputsValid():Boolean {
        this.errors.length = 0;
        var _local1:Boolean = true;
        _local1 = ((this.isEmailValid()) && (_local1));
        _local1 = ((this.isPasswordValid()) && (_local1));
        _local1 = ((this.isPasswordVerified()) && (_local1));
        return _local1;
    }

    private function isEmailValid():Boolean {
        var _local1:Boolean = EmailValidator.isValidEmail(this.emailInput.text());
        this.emailInput.setErrorHighlight(!(_local1));
        if (!_local1) {
            this.errors.push("Not a valid email address");
        }
        return (_local1);
    }

    private function isPasswordValid():Boolean {
        var _local1:Boolean = (this.passwordInput.text().length >= 10);
        this.passwordInput.setErrorHighlight(!(_local1));
        if (!_local1) {
            this.errors.push("The password is too short");
        }
        return (_local1);
    }

    private function isPasswordVerified():Boolean {
        var _local1:Boolean = (this.passwordInput.text() == this.retypePasswordInput.text());
        this.retypePasswordInput.setErrorHighlight(!(_local1));
        if (!_local1) {
            this.errors.push("The password did not match");
        }
        return (_local1);
    }

    public function displayErrors():void {
        if (this.errors.length == 0) {
            this.clearErrors();
        }
        else {
            this.displayErrorText((((this.errors.length == 1)) ? this.errors[0] : "Please fix the errors below"));
        }
    }

    public function displayServerError(_arg1:String):void {
        this.displayErrorText(_arg1);
    }

    private function clearErrors():void {
        titleText_.setStringBuilder(new LineBuilder().setParams("Register in order to save your progress"));
        titleText_.setColor(0xB3B3B3);
    }

    private function displayErrorText(_arg1:String):void {
        titleText_.setStringBuilder(new LineBuilder().setParams(_arg1));
        titleText_.setColor(16549442);
    }

    private function sendData():void {
        var _local1:AccountData = new AccountData();
        _local1.username = this.emailInput.text();
        _local1.password = GameServerConnection.rsaEncrypt(this.passwordInput.text());
        Global.register(_local1);
    }


}
}
