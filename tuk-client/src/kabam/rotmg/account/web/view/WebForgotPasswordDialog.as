package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;
import com.company.assembleegameclient.ui.DeprecatedClickableText;

import flash.events.Event;

import flash.events.MouseEvent;

import kabam.lib.tasks.Task;

import org.osflash.signals.Signal;

public class WebForgotPasswordDialog extends Frame {

    private var emailInput:TextInputField;
    private var registerText:DeprecatedClickableText;

    public function WebForgotPasswordDialog() {
        super("Forgot your password? We'll email it.", "Cancel", "Submit");
        this.emailInput = new TextInputField("Email", false);
        addTextInputField(this.emailInput);
        this.registerText = new DeprecatedClickableText(12, false, "New user? Click here to Register");
        addNavigationText(this.registerText);
        rightButton_.addEventListener(MouseEvent.CLICK, this.onSubmit);
        leftButton_.addEventListener(MouseEvent.CLICK, onLeftBtn);
        rightButton_.addEventListener(MouseEvent.CLICK, onRightBtn);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        Global.taskErrorSignal.add(this.onFailedToSend);
    }

    public function destroy(e:Event):void {
        Global.taskErrorSignal.add(this.onFailedToSend);
    }

    private function onEnable():void {
        this.enable();
    }

    private function onClose():void {
        this.parent.removeChild(this);
    }

    private function submit(_arg1:String):void {
        Global.sendPasswordReminder(_arg1);
    }

    private function onRegister():void {
        Global.openDialog(new WebRegisterDialog());
    }

    private function onCancel():void {
        Global.openDialog(new WebLoginDialog());
    }

    private function onFailedToSend(_arg1:Task):void {
        this.showError(_arg1.error);
        this.enable();
    }

    private function onLeftBtn(e:MouseEvent):void
    {
        onCancel();
    }

    private function onRightBtn(e:MouseEvent):void
    {
        onRegister();
    }

    private function onSubmit(_arg1:MouseEvent):void {
        if (this.isEmailValid()) {
            disable();
            this.submit(this.emailInput.text());
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
