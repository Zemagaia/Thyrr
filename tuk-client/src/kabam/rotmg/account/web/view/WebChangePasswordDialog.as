package kabam.rotmg.account.web.view {
import com.company.assembleegameclient.account.ui.Frame;
import com.company.assembleegameclient.account.ui.TextInputField;

import flash.events.Event;

import flash.events.MouseEvent;

import kabam.lib.tasks.Task;
import kabam.rotmg.account.web.model.ChangePasswordData;
import kabam.rotmg.messaging.impl.GameServerConnection;

import org.osflash.signals.Signal;

public class WebChangePasswordDialog extends Frame {

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
        leftButton_.addEventListener(MouseEvent.CLICK, onLeftBtn);
        rightButton_.addEventListener(MouseEvent.CLICK, onRightBtn);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    private function onLeftBtn(e:MouseEvent):void
    {
        onCancel();
    }

    private function onRightBtn(e:MouseEvent):void
    {
        onChange();
    }

    public function setError(_arg1:String):void {
        this.password_.setError(_arg1);
    }

    public function clearError():void {
        this.password_.clearError();
        this.retypeNewPassword_.clearError();
        this.newPassword_.clearError();
    }

    public function initialize(e:Event):void {
        Global.taskErrorSignal.add(this.onError);
    }

    public function destroy(e:Event):void {
        Global.taskErrorSignal.remove(this.onError);
    }

    private function onCancel():void {
        Global.openDialog(new WebAccountDetailDialog());
    }

    private function onChange():void {
        var _local1:ChangePasswordData;
        if (((((this.isCurrentPasswordValid()) && (this.isNewPasswordValid()))) && (this.isNewPasswordVerified()))) {
            this.disable();
            this.clearError();
            _local1 = new ChangePasswordData();
            _local1.currentPassword = GameServerConnection.rsaEncrypt(this.password_.text());
            _local1.newPassword = GameServerConnection.rsaEncrypt(this.newPassword_.text());
            Global.changePassword(_local1);
        }
    }

    private function isCurrentPasswordValid():Boolean {
        var _local1:Boolean = (this.password_.text().length >= 10);
        if (!_local1) {
            this.password_.setError("Password does not match");
        }
        return (_local1);
    }

    private function isNewPasswordValid():Boolean {
        var _local1:Boolean = (this.newPassword_.text().length >= 10);
        if (!_local1) {
            this.newPassword_.setError("Password must be at least 10 characters");
        }
        return (_local1);
    }

    private function isNewPasswordVerified():Boolean {
        var _local1:Boolean = (this.newPassword_.text() == this.retypeNewPassword_.text());
        if (!_local1) {
            this.retypeNewPassword_.setError("Password does not match");
        }
        return (_local1);
    }

    private function onError(_arg1:Task):void {
        this.setError(_arg1.error);
        this.enable();
    }


}
}
