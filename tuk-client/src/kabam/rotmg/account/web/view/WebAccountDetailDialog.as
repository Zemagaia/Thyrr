package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.ui.DeprecatedClickableText;
import com.company.util.KeyCodes;

import flash.events.KeyboardEvent;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import org.osflash.signals.Signal;

public class WebAccountDetailDialog extends Frame {

    public var cancel:Signal;
    public var change:Signal;
    public var logout:Signal;
    public var verify:Signal;
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
        this.cancel = new Signal();
        this.change = new Signal();
        this.logout = new Signal();
        this.verify = new Signal();
        this.rightButton_.addEventListener(MouseEvent.CLICK, this.onContinue);
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
        this.change.dispatch();
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
        this.cancel.dispatch();
    }

    private function onLogout(_arg1:MouseEvent):void {
        this.logout.dispatch();
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
        this.verify.dispatch();
        this.verifyEmail.makeStatic("Sent...");
    }


}
}
