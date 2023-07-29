package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.ui.DeprecatedClickableText;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class WebAccountDetailDialog extends Frame {

    public var account:Account = Global.account;
    private var loginText:TextFieldDisplayConcrete;
    private var emailText:TextFieldDisplayConcrete;
    private var verifyEmail:DeprecatedClickableText;
    private var changeText:DeprecatedClickableText;
    private var logoutText:DeprecatedClickableText;
    private var headerText:String;

    public function WebAccountDetailDialog(_arg1:String = "Current account", _arg2:String = "Currently logged in as:") {
        super(_arg1, "", "Continue");
        this.headerText = _arg2;
        this.makeLoginText();
        this.makeEmailText();
        h_ = (h_ + 88);
        //Global.appEngine.setDataFormat(URLLoaderDataFormat.BINARY);
        this.rightButton_.addEventListener(MouseEvent.CLICK, this.onContinue);
        setUserInfo(this.account.getUserName(), this.account.isVerified());
    }

    private function change():void {
        Global.openDialog(new WebChangePasswordDialog());
    }

    private function logout():void {
        this.account.clear();
        Global.openDialog(new WebLoginDialog());
    }

    private function onDone():void {
        Global.closeDialogs();
    }

    private function onVerify():void {
        var appEngine:AppEngineClient = Global.appEngine;
        appEngine.complete.addOnce(this.onComplete);
        appEngine.sendRequest("/account/sve", this.account.getCredentials());
    }

    private function onComplete(isOk:Boolean, data:*):void {
        if (isOk) {
            this.onSent();
        }
        else {
            this.onError(data);
        }
    }

    private function onSent():void {
    }

    private function onError(ignored:String):void {
        this.account.clear();
    }

    public function setUserInfo(_arg1:String, _arg2:Boolean):void {
        this.emailText.setStringBuilder(new StaticStringBuilder(_arg1));
        if (!_arg2) {
            this.makeVerifyEmailText();
        }
        this.makeChangeText();
        this.makeLogoutText();
    }

    private function makeVerifyEmailText():void {
        if (this.verifyEmail != null) {
            removeChild(this.verifyEmail);
        }
        this.verifyEmail = new DeprecatedClickableText(12, false, "Email not verified.  Click here to resend email.");
        addNavigationText(this.verifyEmail);
        this.verifyEmail.addEventListener(MouseEvent.CLICK, this.onVerifyEmail);
    }

    private function makeChangeText():void {
        if (this.changeText != null) {
            removeChild(this.changeText);
        }
        this.changeText = new DeprecatedClickableText(12, false, "Click here to change password");
        this.changeText.addEventListener(MouseEvent.CLICK, this.onChange);
        addNavigationText(this.changeText);
    }

    private function onChange(_arg1:MouseEvent):void {
        this.change();
    }

    private function makeLogoutText():void {
        if (this.logoutText != null) {
            removeChild(this.logoutText);
        }
        this.logoutText = new DeprecatedClickableText(12, false, "Not you?  Click here");
        this.logoutText.addEventListener(MouseEvent.CLICK, this.onLogout);
        addNavigationText(this.logoutText);
    }

    private function onContinue(event:MouseEvent):void {
        onDone();
    }

    private function onLogout(_arg1:MouseEvent):void {
        this.logout();
    }

    private function makeLoginText():void {
        this.loginText = new TextFieldDisplayConcrete().setSize(18).setColor(0xB3B3B3);
        this.loginText.setBold(true);
        this.loginText.setStringBuilder(new LineBuilder().setParams(this.headerText));
        this.loginText.filters = [new DropShadowFilter(0, 0, 0)];
        this.loginText.y = (h_ - 60);
        this.loginText.x = 17;
        addChild(this.loginText);
    }

    private function makeEmailText():void {
        this.emailText = new TextFieldDisplayConcrete().setSize(16).setColor(0xB3B3B3);
        this.emailText.y = (h_ - 30);
        this.emailText.x = 17;
        addChild(this.emailText);
    }

    private function onVerifyEmail(_arg1:MouseEvent):void {
        this.onVerify();
        this.verifyEmail.makeStatic("Sent...");
    }


}
}
