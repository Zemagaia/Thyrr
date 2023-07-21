package thyrr.oldui {
import com.company.ui.BaseSimpleText;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.filters.DropShadowFilter;

import kabam.rotmg.util.components.DialogBackground;

public class DefaultFrameTab extends DialogBackground {

    public var width_:int;
    public var text_:String;
    public var title_:BaseSimpleText;
    public var icon_:Bitmap;

    public function DefaultFrameTab(data:BitmapData, text:String) {
        this.text_ = text;
        this.icon_ = new Bitmap(data);
        this.title_ = new BaseSimpleText(14, 0xB3B3B3).setBold(true);
        this.title_.text = text;
        this.title_.filters = [new DropShadowFilter(0, 0, 0)];
        this.title_.updateMetrics();

        this.icon_.x = 8;
        this.icon_.y = 2;
        this.width_ = 40;
        this.title_.x = this.icon_.width + this.icon_.x + 4;
        this.title_.y = this.icon_.height / 2 - 6;
        this.width_ += this.title_.width + 12;

        draw(this.width_, 30, 0);
        addChild(this.icon_);
        addChild(this.title_);
        setSelected(false);
    }

    public function setSelected(selected:Boolean):void {
        if (parent is DefaultFrame) {
            (parent as DefaultFrame).update(this.text_, selected);
        }
    }
}
}
