package kabam.rotmg.game.view {
import com.company.assembleegameclient.ui.tooltip.TextToolTip;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

import kabam.rotmg.tooltips.HoverTooltipDelegate;

public class GiftStatusDisplay extends Sprite {

    public static const IMAGE_NAME:String = "utility";
    public static const IMAGE_ID:int = 0x16;

    public var hoverTooltipDelegate:HoverTooltipDelegate;
    private var bitmap:Bitmap;
    private var giftOpenProcessedTexture:BitmapData;
    private var tooltip:TextToolTip;

    public function GiftStatusDisplay() {
        this.hoverTooltipDelegate = new HoverTooltipDelegate();
        this.tooltip = new TextToolTip(0x2B2B2B, 0x7B7B7B, null, "New Gifts in Vault", 200);
        super();
        mouseChildren = false;
        this.giftOpenProcessedTexture = TextureRedrawer.redraw(AssetLibrary.getImageFromSet(IMAGE_NAME, IMAGE_ID), 40, true, 0);
        this.bitmap = new Bitmap(this.giftOpenProcessedTexture);
        this.hoverTooltipDelegate.setDisplayObject(this);
        this.hoverTooltipDelegate.tooltip = this.tooltip;
    }

    public function drawAsOpen():void {
        addChild(this.bitmap);
    }

    public function drawAsClosed():void {
        if (((this.bitmap) && ((this.bitmap.parent == this)))) {
            removeChild(this.bitmap);
        }
    }


}
}
