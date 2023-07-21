package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;

import flash.events.MouseEvent;

import org.osflash.signals.Signal;

public class WebChangePasswordDialogForced extends Frame {

    public var cancel:Signal;
    public var change:Signal;
    public var password_:TextInputField;
    public var newPassword_:TextInputField;
    public var retypeNewPassword_:TextInputField;

    public function WebChangePasswordDialogForced() {
        super("Change your password", "", "Submit");
        this.password_ = new TextInputField("Password", true);
        addTextInputField(this.password_);
        this.newPassword_ = new TextInputField("New Password", true);
        addTextInputField(this.newPassword_);
        this.retypeNewPassword_ = new TextInputField("Retype New Password", true);
        addTextInputField(this.retypeNewPassword_);
        this.change = new Signal();
        rightButton_.addEventListener(MouseEvent.CLICK, onChange);
    }

    private function onChange(e:MouseEvent):void {
        change.dispatch();
    }

    public function clearError():void {
        this.password_.clearError();
        this.retypeNewPassword_.clearError();
        this.newPassword_.clearError();
    }


}
}
