package thyrr.oldui {
import flash.display.Sprite;

import org.osflash.signals.Signal;

import thyrr.ui.buttons.HoldableButton;

public class TabSwitchButtons extends Sprite {

    public const switchTab:Signal = new Signal(int);

    private var tabR:HoldableButton;
    private var tabL:HoldableButton;
    private var tabs:int;
    private var tab:int;

    public function TabSwitchButtons() {
        this.tab = 0;
        this.makeTabR();
        this.makeTabL();
    }

    public function setRightButton(x:int, scale:Number = 1):void
    {
        this.tabR.x = x;
        this.tabR.scaleX = this.tabR.scaleY = scale;
    }

    public function setLeftButton(x:int, scale:Number = 1):void
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
        return (this.tab);
    }

    public function setTabs(len:int):int {
        this.tabs = len;
        if (this.tab >= this.tabs) {
            this.tab = (this.tabs - 1);
        }
        return (this.tabs);
    }

    private function makeTabR():void {
        this.tabR = new HoldableButton(24, 24, 0xaea9a9, 0x03, false);
        this.tabR.rotation = 90;
        this.tabR.y -= 24;
        this.tabR.clicked.add(onTabR);
        addChild(this.tabR);
    }

    private function makeTabL():void {
        this.tabL = new HoldableButton(24, 24, 0xaea9a9, 0x03, false);
        this.tabL.rotation = -90;
        this.tabL.clicked.add(this.onTabL);
        addChild(this.tabL);
    }

    private function onTabR():void {
        if (this.canTabR()) {
            this.switchTab.dispatch(++this.tab);
        }
    }

    private function canTabR():Boolean {
        return ((this.tab < (this.tabs - 1)));
    }

    private function onTabL():void {
        if (this.canTabL()) {
            this.switchTab.dispatch(--this.tab);
        }
    }

    private function canTabL():Boolean {
        return ((this.tab > 0));
    }

}
}
