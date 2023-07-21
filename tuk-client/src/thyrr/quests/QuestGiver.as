package thyrr.quests {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;

import flash.display.BitmapData;

import flash.events.MouseEvent;

import flash.events.Event;

import thyrr.quests.tabs.AcceptedQuestsTab;
import thyrr.quests.tabs.AvailableQuestsTab;

import thyrr.oldui.DefaultTab;
import thyrr.oldui.DefaultFrame;
import thyrr.oldui.DefaultFrameTab;
import thyrr.utils.Utils;

public class QuestGiver extends DefaultFrame {

    private static const AVAILABLE:String = "Available";
    private static const ACCEPTED:String = "Accepted";
    private static const ACCOUNT:String = "Account Quests";
    private static const AVAILABLEBITMAP:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x26);
    private static const ACCEPTEDBITMAP:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x27);
    private static const ACCOUNTBITMAP:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x28);
    private static const BITMAPS:Vector.<BitmapData> = new <BitmapData>[AVAILABLEBITMAP, ACCEPTEDBITMAP, ACCOUNTBITMAP];
    private static const TABS:Vector.<String> = new <String>[AVAILABLE, ACCEPTED, ACCOUNT];

    private var content_:Vector.<DefaultTab>;
    private var selectedTab_:DefaultFrameTab;

    public function QuestGiver(gameSprite:GameSprite) {
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
            case AVAILABLE:
                this.addContent(new AvailableQuestsTab(this.gameSprite_));
                break;
            case ACCEPTED:
                this.addContent(new AcceptedQuestsTab(this.gameSprite_, true));
                break;
            case ACCOUNT:
                this.addContent(new AcceptedQuestsTab(this.gameSprite_, false));
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