package thyrr.forge {

import com.company.assembleegameclient.game.GameSprite;
import com.company.util.AssetLibrary;

import flash.display.BitmapData;

import flash.events.MouseEvent;

import flash.events.Event;

import kabam.rotmg.messaging.impl.incoming.forge.CraftAnimation;

import thyrr.forge.tabs.ForgeTab;
import thyrr.forge.tabs.RecipesTab;
import thyrr.forge.tabs.RuneTab;

import thyrr.oldui.DefaultFrame;
import thyrr.oldui.DefaultFrameTab;
import thyrr.oldui.DefaultTab;
import thyrr.utils.Utils;

public class Forge extends DefaultFrame {

    private static const FORGE:String = "Forge";
    private static const RECIPES:String = "Recipes";
    private static const RUNES:String = "Runes";
    private static const FORGEBITMAP:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x26);
    private static const RECIPESBITMAP:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x26);
    private static const RUNESBITMAP:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x26);
    private static const BITMAPS:Vector.<BitmapData> = new <BitmapData>[FORGEBITMAP, RECIPESBITMAP, RUNESBITMAP];
    private static const TABS:Vector.<String> = new <String>[FORGE, RECIPES, RUNES];

    private var content_:Vector.<DefaultTab>;
    private var selectedTab_:DefaultFrameTab;

    public function Forge(gameSprite:GameSprite) {
        var bitmaps:Vector.<BitmapData> = Utils.getBitmapDatas(TABS.length, BITMAPS);
        super(gameSprite, TABS, bitmaps, 590, 360);
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
            case FORGE:
                resizeBackground(590, 360);
                this.addContent(new ForgeTab(this.gameSprite_));
                break;
            case RECIPES:
                resizeBackground(590, 600);
                this.addContent(new RecipesTab(this.gameSprite_));
                break;
            case RUNES:
                resizeBackground(590, 360);
                this.addContent(new RuneTab(this.gameSprite_));
                break;
        }
    }

    public function addAnimation(tab:DefaultTab):void {
        removeLastContent();
        var i:int = (numChildren - 1);
        while (i >= 0) {
            removeChildAt(i);
            i--;
        }
        addContent(tab);
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