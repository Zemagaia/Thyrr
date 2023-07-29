package kabam.rotmg.game.view.components {
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import thyrr.ui.items.SimpleBox;
import thyrr.utils.Utils;

public class Stat extends Sprite {

    public var nameText_:TextFieldDisplayConcrete;
    public var valText_:TextFieldDisplayConcrete;
    public var total_:int = -1;

    public function Stat(name:String) {
        super();
        var box:SimpleBox = new SimpleBox(44, 24, 0x807D7D).setOutline(0xaea9a9);
        addChild(box);
        box = new SimpleBox(36, 24, 0x807D7D).setOutline(0xaea9a9);
        box.x = 44;
        addChild(box);
        this.nameText_ = new TextFieldDisplayConcrete().setSize(12).setColor(0xB3B3B3).setBold(true);
        this.nameText_.setStringBuilder(new LineBuilder().setParams(name));
        nameText_.x = 22;
        nameText_.y = 6;
        this.configureTextAndAdd(this.nameText_);
        this.valText_ = new TextFieldDisplayConcrete().setSize(12).setColor(0xFFFF8F).setBold(true).setBold(true);
        valText_.x = 62;
        valText_.y = 6;
        this.configureTextAndAdd(this.valText_);
    }

    public function configureTextAndAdd(textField:TextFieldDisplayConcrete):void {
        textField.setAutoSize(TextFieldAutoSize.CENTER);
        textField.filters = [Utils.OutlineFilter];
        textField.mouseEnabled = false;
        textField.mouseChildren = false;
        addChild(textField);
    }

    public function draw(val:int, boost:int, isPercent:Boolean = false, statCap:int = 0, ignoreValue:Boolean = false):void
    {
        if (ignoreValue)
            val = 0;
        if (val + boost == this.total_)
            return;
        var color:uint = 0xFFFF8F;
        this.total_ = val + boost;
        if (this.total_ < 0)
            color = 0xFFFF8F;
        if (this.total_ > statCap && statCap != 0)
        {
            this.total_ = statCap;
            color = 0xFCDF00;
        }
        var text:String = this.total_.toString() + (isPercent ? "%" : "");
        if (color != 0)
            valText_.setColor(color);
        this.valText_.setStringBuilder(new StaticStringBuilder(text));
    }


}
}
