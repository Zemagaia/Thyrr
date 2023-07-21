package thyrr.pets {

import com.company.assembleegameclient.game.GameSprite;
import com.company.util.AssetLibrary;

import flash.display.BitmapData;

import flash.events.MouseEvent;

import flash.events.Event;

import thyrr.pets.tabs.PetsTab;

import thyrr.oldui.DefaultFrame;
import thyrr.oldui.DefaultFrameTab;
import thyrr.oldui.DefaultTab;
import thyrr.utils.Utils;

public class PetViewer extends DefaultFrame {

    private static const PETS:String = "Pets";
    private static const PETSBITMAP:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x26);
    private static const BITMAPS:Vector.<BitmapData> = new <BitmapData>[PETSBITMAP];
    private static const TABS:Vector.<String> = new <String>[PETS];

    private var content_:Vector.<DefaultTab>;
    private var selectedTab_:DefaultFrameTab;

    public function PetViewer(gameSprite:GameSprite) {
        var bitmaps:Vector.<BitmapData> = Utils.getBitmapDatas(TABS.length, BITMAPS);
        super(gameSprite, TABS, bitmaps);
        for each(var tab:DefaultFrameTab in this.tabs_) {
            tab.addEventListener(MouseEvent.CLICK, this.onTab);
        }
        this.content_ = new Vector.<DefaultTab>();
        this.setTab(this.tabs_[0]);
    }

    private function onTab(event:MouseEvent):void {
        var tab:DefaultFrameTab = (event.currentTarget as DefaultFrameTab);
        this.setTab(tab);
    }

    private function setTab(tab:DefaultFrameTab):void {
        if (tab == this.selectedTab_) {
            return;
        }
        if (this.selectedTab_ != null) {
            this.selectedTab_.setSelected(false);
        }
        this.selectedTab_ = tab;
        this.selectedTab_.setSelected(true);
        this.removeLastContent();
        switch (this.selectedTab_.text_) {
            case PETS:
                this.addContent(new PetsTab(this.gameSprite_));
                break;
        }
    }

    private function removeLastContent():void {
        var i:DefaultTab;
        for each (i in this.content_) {
            i.dispose();
            removeChild(i);
        }
        this.content_.length = 0;
    }

    private function addContent(content:DefaultTab):void {
        addChild(content);
        this.content_.push(content);
    }

    protected override function onClose(event:Event):void
    {
        var tab:DefaultFrameTab;
        var content:DefaultTab;
        for each (tab in this.tabs_)
        {
            tab.removeEventListener(MouseEvent.CLICK, this.onTab);
        }
        this.tabs_.length = 0;
        this.tabs_ = null;
        for each (content in this.content_)
        {
            content.dispose();
        }
        this.selectedTab_ = null;
        this.content_.length = 0;
        this.content_ = null;
        super.close();
    }


}
}