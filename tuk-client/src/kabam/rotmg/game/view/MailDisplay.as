package kabam.rotmg.game.view {
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.UIUtils;

public class MailDisplay extends Sprite {

    public static const IMAGE_NAME:String = "interfaceNew2";
    public static const IMAGE_ID:int = 0x29;

    private var background_:Sprite;
    private var bitmap_:Bitmap;
    private var mailProcessedTexture_:BitmapData;
    private var text_:TextFieldDisplayConcrete;

    public function MailDisplay() {
        super();
        mouseChildren = false;
        this.mailProcessedTexture_ = TextureRedrawer.redraw2(AssetLibrary.getImageFromSet(IMAGE_NAME, IMAGE_ID), 40, true, 0);
        this.mailProcessedTexture_ = BitmapUtil.cropToBitmapData(
                this.mailProcessedTexture_, 8, 8, this.mailProcessedTexture_.width - 16, this.mailProcessedTexture_.height - 16)
        this.background_ = UIUtils.makeStaticHUDBackground();
        this.bitmap_ = new Bitmap(this.mailProcessedTexture_);
        this.text_ = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF);
        this.text_.setStringBuilder(new LineBuilder().setParams(""));
        this.text_.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 2)];
        this.text_.setVerticalAlign(TextFieldDisplayConcrete.BOTTOM);
        this.draw();
        var _local1:Rectangle = this.bitmap_.getBounds(this);
        this.text_.x = _local1.right;
        this.text_.y = _local1.bottom - 4;
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemoved);
    }

    public function draw(text:String = ""):void {
        if (text != "") {
            this.text_.setStringBuilder(new LineBuilder().setParams(text));
            addChild(this.background_);
            addChild(this.text_);
            addChild(this.bitmap_);
        }
    }

    private function onRemoved(event:Event):void {
        this.dispose();
    }

    public function dispose():void {
        if (this.background_ && contains(this.background_))
            removeChild(this.background_);
        if (this.text_ && contains(this.text_))
            removeChild(this.text_);
        if (this.bitmap_ && contains(this.bitmap_))
            removeChild(this.bitmap_);
        this.bitmap_ = null;
        this.text_ = null;
        this.background_ = null;
    }


}
}
