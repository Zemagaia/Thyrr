package kabam.rotmg.text.view {
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class TextFieldConcreteBuilder {

    private var containerWidth_:int = -1;
    private var containerMargin_:int = -1;

    public function getLocalizedTextObject(text:String, x:int = -1, y:int = -1, size:int = 16, color:int = 0xFFFFFF, cWidth:int = -1, cMargin:int = -1):TextFieldDisplayConcrete {
        var textField:TextFieldDisplayConcrete = new TextFieldDisplayConcrete();
        textField.setStringBuilder(new LineBuilder().setParams(text));
        return (this.defaultFormatTFDC(textField, x, y, size, color, cWidth, cMargin));
    }

    public function getLiteralTextObject(text:String, x:int = -1, y:int = -1, size:int = 16, color:int = 0xFFFFFF, cWidth:int = -1, cMargin:int = -1):TextFieldDisplayConcrete {
        var textField:TextFieldDisplayConcrete = new TextFieldDisplayConcrete();
        textField.setStringBuilder(new StaticStringBuilder(text));
        return (this.defaultFormatTFDC(textField, x, y, size, color, cWidth, cMargin));
    }

    public function getBlankFormattedTextObject(x:int = -1, y:int = -1, size:int = 16, color:int = 0xFFFFFF, cWidth:int = -1, cMargin:int = -1):TextFieldDisplayConcrete {
        var textField:TextFieldDisplayConcrete = new TextFieldDisplayConcrete();
        return (this.defaultFormatTFDC(textField, x, y, size, color, cWidth, cMargin));
    }

    public function formatExistingTextObject(textField:TextFieldDisplayConcrete, x:int = -1, y:int = -1, size:int = 16, color:int = 0xFFFFFF, cWidth:int = -1, cMargin:int = -1):TextFieldDisplayConcrete {
        return (this.defaultFormatTFDC(textField, x, y, size, color, cWidth, cMargin));
    }

    private function defaultFormatTFDC(textField:TextFieldDisplayConcrete, x:int = -1, y:int = -1, size:int = 16, color:int = 0xFFFFFF, cWidth:int = -1, cMargin:int = -1):TextFieldDisplayConcrete {
        textField.setSize(size).setColor(color);
        if (((!((cWidth == -1))) && (!((cMargin == -1))))) {
            textField.setTextWidth((cWidth - (cMargin * 2)));
        }
        else {
            if (((!((this.containerWidth == -1))) && (!((this.containerMargin == -1))))) {
                textField.setTextWidth((this.containerWidth - (this.containerMargin * 2)));
            }
        }
        textField.setBold(true);
        textField.setWordWrap(true);
        textField.setMultiLine(true);
        textField.setAutoSize(TextFieldAutoSize.CENTER);
        textField.setHorizontalAlign(TextFormatAlign.CENTER);
        textField.filters = [new DropShadowFilter(0, 0, 0)];
        if (x != -1) {
            textField.x = x;
        }
        if (y != -1) {
            textField.y = y;
        }
        return (textField);
    }

    public function get containerWidth():int {
        return (this.containerWidth_);
    }

    public function set containerWidth(containerWidth:int):void {
        this.containerWidth_ = containerWidth;
    }

    public function get containerMargin():int {
        return (this.containerMargin_);
    }

    public function set containerMargin(containerMargin:int):void {
        this.containerMargin_ = containerMargin;
    }


}
}
