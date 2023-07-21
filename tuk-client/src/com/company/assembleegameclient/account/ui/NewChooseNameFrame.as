package com.company.assembleegameclient.account.ui {
import flash.events.MouseEvent;



import org.osflash.signals.Signal;

public class NewChooseNameFrame extends Frame {

    public const choose:Signal = new Signal();
    public const cancel:Signal = new Signal();

    private var name_:TextInputField;

    public function NewChooseNameFrame() {
        super("Choose a unique account name", "Cancel", "Choose");
        this.name_ = new TextInputField("Name", false);
        this.name_.inputText_.restrict = "A-Za-z";
        var _local1:int = 10;
        this.name_.inputText_.maxChars = _local1;
        addTextInputField(this.name_);
        addPlainText("Maximum {maxChars} characters", {"maxChars": _local1});
        addPlainText("No numbers, spaces or punctuation");
        addPlainText("Racism or profanity gets you banned");
        leftButton_.addEventListener(MouseEvent.CLICK, this.onCancel);
        rightButton_.addEventListener(MouseEvent.CLICK, this.onChoose);
    }

    private function onChoose(_arg1:MouseEvent):void {
        this.choose.dispatch(this.name_.text());
    }

    private function onCancel(_arg1:MouseEvent):void {
        this.cancel.dispatch();
    }

    public function setError(_arg1:String):void {
        this.name_.setError(_arg1);
    }


}
}
