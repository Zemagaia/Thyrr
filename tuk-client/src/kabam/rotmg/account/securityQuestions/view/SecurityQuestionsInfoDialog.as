package kabam.rotmg.account.securityQuestions.view {
import com.company.assembleegameclient.account.ui.Frame;

import flash.filters.DropShadowFilter;


import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class SecurityQuestionsInfoDialog extends Frame {

    private var infoText:TextFieldDisplayConcrete;

    public function SecurityQuestionsInfoDialog() {
        super("New Account Security Feature - Read carefully", "", "Continue");
        this.displayPopupText();
    }

    private function displayPopupText():void {
        this.infoText = new TextFieldDisplayConcrete();
        this.infoText.setStringBuilder(new LineBuilder()
                .setParams("To better protect your account, please answer the following security questions in the next screen." +
                        "\n\nThese questions will be used to verify your account ownership in case there is a dispute or you lose access to your email." +
                        "\n\n<font color=\"#7777EE\">Note:</font> Once set, you will not be able to change your answers. Be sure to make the answers easy to remember but hard to guess. You will need to remember the answers for all questions."));
        this.infoText.setSize(12).setColor(0xB3B3B3).setBold(true);
        this.infoText.setTextWidth(250);
        this.infoText.setMultiLine(true).setWordWrap(true).setHTML(true);
        this.infoText.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.infoText);
        this.infoText.y = 40;
        this.infoText.x = 17;
        h_ = 260;
    }

    public function dispose():void {
    }


}
}
