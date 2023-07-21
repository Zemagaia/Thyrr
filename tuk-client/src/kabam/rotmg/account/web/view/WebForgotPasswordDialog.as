package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;
import com.company.assembleegameclient.ui.DeprecatedClickableText;

import flash.events.MouseEvent;

import org.osflash.signals.Signal;

public class WebForgotPasswordDialog extends Frame {

    public var cancel:Signal;
    public var submit:Signal;
    public var register:Signal;
    private var emailInput:TextInputField;
    private var registerText:DeprecatedClickableText;

    public function WebForgotPasswordDialog() {
        super("Forgot your password? We'll email it.", "Cancel", "Submit");
        this.emailInput = new TextInputField("Email", false);
        addTextInputField(this.emailInput);
        this.registerText = new DeprecatedClickableText(12, false, "New user?  Click here to Register");
        addNavigationText(this.registerText);
        rightButton_.addEventListener(MouseEvent.CLICK, this.onSubmit);
        this.cancel = new Signal();
        this.register = new Signal();
        this.submit = new Signal(String);
        leftButton_.addEventListener(MouseEvent.CLICK, onLeftBtn);
        rightButton_.addEventListener(MouseEvent.CLICK, onRightBtn);
    }

    private function onLeftBtn(e:MouseEvent):void
    {
        cancel.dispatch();
    }

    private function onRightBtn(e:MouseEvent):void
    {
        register.dispatch();
    }

    private function onSubmit(_arg1:MouseEvent):void {
        if (this.isEmailValid()) {
            disable();
            this.submit.dispatch(this.emailInput.text());
        }
    }

    private function isEmailValid():Boolean {
        var _local1:Boolean = !((this.emailInput.text() == ""));
        if (!_local1) {
            this.emailInput.setError("Not a valid email address");
        }
        return (_local1);
    }

    public function showError(_arg1:String):void {
        this.emailInput.setError(_arg1);
    }


}
}
