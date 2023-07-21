package thyrr.oldui {
import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

import org.osflash.signals.Signal;

public class TabSwitchButtons extends Sprite {

    private const FADE:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
    private const NORM:ColorTransform = new ColorTransform(1, 1, 1);
    public const switchTab:Signal = new Signal(int);

    private var tabR:Sprite;
    private var tabL:Sprite;
    private var tabs:int;
    private var tab:int;

    public function TabSwitchButtons() {
        this.tab = 0;
        this.makeTabR();
        this.makeTabL();
        this.updateButtons();
    }

    public function setRightButton(x:int, scale:int = 1):void
    {
        this.tabR.x = x;
        this.tabR.scaleX = this.tabR.scaleY = scale;
    }

    public function setLeftButton(x:int, scale:int = 1):void
    {
        this.tabL.x = x;
        this.tabL.scaleX = this.tabL.scaleY = scale;
    }

    public function setTab(tab:int):int {
        if (this.tabs == 0) {
            return (this.tab);
        }
        if (tab < 0) {
            tab = 0;
        }
        else {
            if (tab >= (this.tabs - 1)) {
                tab = (this.tabs - 1);
            }
        }
        this.tab = tab;
        this.updateButtons();
        return (this.tab);
    }

    public function setTabs(len:int):int {
        this.tabs = len;
        if (this.tab >= this.tabs) {
            this.tab = (this.tabs - 1);
        }
        this.updateButtons();
        return (this.tabs);
    }

    private function makeTabR():void {
        var arrow:Bitmap;
        var bitmapData:BitmapData = AssetLibrary.getImageFromSet("interfaceSmall", 0x0D);
        arrow = new Bitmap(bitmapData);
        arrow.scaleX = arrow.scaleY = 2;
        this.tabR = new Sprite();
        this.tabR.x = 16;
        this.tabR.addChild(arrow);
        this.tabR.addEventListener(MouseEvent.CLICK, this.onTabR);
        addChild(this.tabR);
    }

    private function makeTabL():void {
        var arrow:Bitmap;
        var bitmapData:BitmapData = AssetLibrary.getImageFromSet("interfaceSmall", 0x0C);
        arrow = new Bitmap(bitmapData);
        arrow.scaleX = arrow.scaleY = 2;
        this.tabL = new Sprite();
        this.tabL.addChild(arrow);
        this.tabL.addEventListener(MouseEvent.CLICK, this.onTabL);
        addChild(this.tabL);
    }

    private function onTabR(event:MouseEvent):void {
        event.stopPropagation();
        if (this.canTabR()) {
            this.switchTab.dispatch(++this.tab);
            this.updateButtons();
        }
    }

    private function canTabR():Boolean {
        return ((this.tab < (this.tabs - 1)));
    }

    private function onTabL(event:MouseEvent):void {
        event.stopPropagation();
        if (this.canTabL()) {
            this.switchTab.dispatch(--this.tab);
            this.updateButtons();
        }
    }

    private function canTabL():Boolean {
        return ((this.tab > 0));
    }

    private function updateButtons():void {
        this.tabL.transform.colorTransform = ((this.canTabL()) ? this.NORM : this.FADE);
        this.tabR.transform.colorTransform = ((this.canTabR()) ? this.NORM : this.FADE);
    }

}
}
