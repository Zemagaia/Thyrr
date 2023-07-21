package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;

import flash.events.MouseEvent;

import org.osflash.signals.Signal;

public class WebChangePasswordDialog extends Frame {

    public var cancel:Signal;
    public var change:Signal;
    public var password_:TextInputField;
    public var newPassword_:TextInputField;
    public var retypeNewPassword_:TextInputField;

    public function WebChangePasswordDialog() {
        super("Change your password", "Cancel", "Submit");
        this.password_ = new TextInputField("Password", true);
        addTextInputField(this.password_);
        this.newPassword_ = new TextInputField("New Password", true);
        addTextInputField(this.newPassword_);
        this.retypeNewPassword_ = new TextInputField("Retype New Password", true);
        addTextInputField(this.retypeNewPassword_);
        this.cancel = new Signal();
        this.change = new Signal();
        leftButton_.addEventListener(MouseEvent.CLICK, onLeftBtn);
        rightButton_.addEventListener(MouseEvent.CLICK, onRightBtn);
    }

    private function onLeftBtn(e:MouseEvent):void
    {
        this.cancel.dispatch();
    }

    private function onRightBtn(e:MouseEvent):void
    {
        change.dispatch();
    }

    public function setError(_arg1:String):void {
        this.password_.setError(_arg1);
    }

    public function clearError():void {
        this.password_.clearError();
        this.retypeNewPassword_.clearError();
        this.newPassword_.clearError();
    }


}
}
