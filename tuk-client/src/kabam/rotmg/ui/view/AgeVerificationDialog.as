﻿package kabam.rotmg.ui.view {
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.dialogs.Dialog;

import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.account.ui.components.DateField;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

import org.osflash.signals.Signal;

public class AgeVerificationDialog extends Dialog {

    private static const WIDTH:int = 300;

    private const BIRTH_DATE_BELOW_MINIMUM_ERROR:String = "You must be at least 13 years of age";
    private const BIRTH_DATE_INVALID_ERROR:String = "Birthdate is not a valid date.";
    private const MINIMUM_AGE:uint = 13;

    private var ageVerificationField:DateField;
    private var errorLabel:TextFieldDisplayConcrete;

    public function AgeVerificationDialog() {
        super("Terms and Privacy Update", "", "No way", "I agree", "/ageVerificationDialog");
        addEventListener(Dialog.LEFT_BUTTON, this.onCancel);
        addEventListener(Dialog.RIGHT_BUTTON, this.onVerify);
    }

    override protected function makeUIAndAdd():void {
        this.makeAgeVerificationAndErrorLabel();
        this.addChildren();
    }

    private function makeAgeVerificationAndErrorLabel():void {
        this.makeAgeVerificationField();
        this.makeErrorLabel();
    }

    private function addChildren():void {
        uiWaiter.pushArgs(this.ageVerificationField.getTextChanged());
        box_.addChild(this.ageVerificationField);
        box_.addChild(this.errorLabel);
    }

    override protected function initText(_arg1:String):void {
        textText_ = new TextFieldDisplayConcrete().setSize(14).setColor(0xB3B3B3);
        textText_.setTextWidth((WIDTH - 40));
        textText_.x = 20;
        textText_.setMultiLine(true).setWordWrap(true).setHTML(true);
        textText_.setAutoSize(TextFieldAutoSize.LEFT);
        textText_.mouseEnabled = true;
        textText_.filters = [new DropShadowFilter(0, 0, 0, 1, 6, 6, 1)];
        this.setText();
    }

    private function setText():void {
        var _local1:String = (('<font color="#7777EE"><a href="' + Parameters.TERMS_OF_USE_URL) + '" target="_blank">');
        var _local2:String = (('<font color="#7777EE"><a href="' + Parameters.PRIVACY_POLICY_URL) + '" target="_blank">');
        var _local3:String = "</a></font>";
        textText_.setStringBuilder(new LineBuilder().setParams("You must be at least 13 years of age", {
            "tou": _local1,
            "_tou": _local3,
            "policy": _local2,
            "_policy": _local3
        }));
    }

    override protected function drawAdditionalUI():void {
        this.ageVerificationField.y = (textText_.getBounds(box_).bottom + 8);
        this.ageVerificationField.x = 20;
        this.errorLabel.y = ((this.ageVerificationField.y + this.ageVerificationField.height) + 8);
        this.errorLabel.x = 20;
    }

    private function makeAgeVerificationField():void {
        this.ageVerificationField = new DateField();
        this.ageVerificationField.setTitle("Birthday");
    }

    private function makeErrorLabel():void {
        this.errorLabel = new TextFieldDisplayConcrete().setSize(12).setColor(16549442);
        this.errorLabel.setMultiLine(true);
        this.errorLabel.filters = [new DropShadowFilter(0, 0, 0, 0.5, 12, 12)];
    }

    private function onCancel(_arg1:Event):void {
        onResponse(false);
    }

    private function onResponse(_arg1:Boolean):void {
        if (_arg1) {
            this.handleAccepted();
        }
        else {
            this.handleRejected();
        }
    }

    private function handleAccepted():void {
        Global.verifyAge();
        Global.closeDialogs();
    }

    private function handleRejected():void {
        Global.closeDialogs();
    }

    private function onVerify(_arg1:Event):void {
        var _local3:Boolean;
        var _local2:uint = this.getPlayerAge();
        var _local4:String;
        if (!this.ageVerificationField.isValidDate()) {
            _local4 = this.BIRTH_DATE_INVALID_ERROR;
            _local3 = true;
        }
        else {
            if ((((_local2 < this.MINIMUM_AGE)) && (!(_local3)))) {
                _local4 = this.BIRTH_DATE_BELOW_MINIMUM_ERROR;
                _local3 = true;
            }
            else {
                _local4 = "";
                _local3 = false;
                onResponse(true);
            }
        }
        this.errorLabel.setStringBuilder(new LineBuilder().setParams(_local4));
        this.ageVerificationField.setErrorHighlight(_local3);
        drawButtonsAndBackground();
    }

    private function getPlayerAge():uint {
        var _local1:Date = new Date(this.getBirthDate());
        var _local2:Date = new Date();
        var _local3:uint = (Number(_local2.fullYear) - Number(_local1.fullYear));
        if ((((_local1.month > _local2.month)) || ((((_local1.month == _local2.month)) && ((_local1.date > _local2.date)))))) {
            _local3--;
        }
        return (_local3);
    }

    private function getBirthDate():Number {
        return (Date.parse(this.ageVerificationField.getDate()));
    }


}
}
