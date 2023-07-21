package kabam.rotmg.game.view.components {
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class StatView extends Sprite {

    public var nameText_:TextFieldDisplayConcrete;
    public var valText_:TextFieldDisplayConcrete;
    public var redOnZero_:Boolean;
    public var val_:int = -1;
    public var boost_:int = -1;
    public var valColor_:uint = 0xB3B3B3;

    public function StatView(name:String, redOnZero:Boolean) {
        super();
        this.nameText_ = new TextFieldDisplayConcrete().setSize(11).setColor(0xB3B3B3);
        this.nameText_.setStringBuilder(new LineBuilder().setParams(name));
        this.configureTextAndAdd(this.nameText_);
        this.valText_ = new TextFieldDisplayConcrete().setSize(11).setColor(this.valColor_).setBold(true);
        this.valText_.setStringBuilder(new StaticStringBuilder("-"));
        this.configureTextAndAdd(this.valText_);
        this.redOnZero_ = redOnZero;
    }

    public function configureTextAndAdd(textField:TextFieldDisplayConcrete):void {
        textField.setAutoSize(TextFieldAutoSize.LEFT);
        textField.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(textField);
    }

    public function draw(val:int, boost:int, max:int = 1, isPercent:Boolean = false, statCap:int = 0):void {
        var color:uint;
        if ((((val == this.val_)) && ((boost == this.boost_)))) {
            return;
        }
        this.val_ = val;
        this.boost_ = boost;
        if ((val - boost) >= max) {
            color = 0xFCDF00;
        }
        else {
            if (((((this.redOnZero_) && ((this.val_ <= 0)))) || ((this.boost_ < 0)))) {
                color = 16726072;
            }
            else {
                if (this.boost_ > 0) {
                    color = 6206769;
                }
                else {
                    color = 0xB3B3B3;
                }
            }
        }
        if (this.valColor_ != color) {
            this.valColor_ = color;
            this.valText_.setColor(this.valColor_);
        }
        if (this.val_ > statCap && statCap != 0) {
            var base:int = this.val_ - this.boost_;
            this.boost_ = statCap - base;
            this.val_ = statCap;
            this.valText_.setColor(0xCAB200);
        }
        else {
            this.valText_.setColor(this.valColor_);
        }
        var text:String = this.val_.toString() + (isPercent ? "%" : "");
        if (this.boost_ != 0) {
            text = (text + (((" (" + (((this.boost_ > 0)) ? "+" : "")) + this.boost_.toString()) + ")"));
        }
        this.valText_.setStringBuilder(new StaticStringBuilder(text));
        this.valText_.x = this.nameText_.getBounds(this).right;
    }


}
}
