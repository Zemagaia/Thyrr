package kabam.rotmg.classes.view {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;

import kabam.lib.ui.api.Size;
import kabam.rotmg.classes.model.CharacterClass;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.util.components.VerticalScrollingList;

public class CharacterSkinListView extends Sprite {

    public static const PADDING:int = 5;
    public static const WIDTH:int = Main.DefaultWidth - 358;
    public static const HEIGHT:int = Main.DefaultHeight - 200;

    private const list:VerticalScrollingList = makeList();

    private var items:Vector.<DisplayObject>;

    public var model:ClassesModel = Global.classesModel;
    public var factory:CharacterSkinListItemFactory = Global.characterSkinListItemFactory;

    public function CharacterSkinListView():void
    {
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        this.model.selected.add(this.setSkins);
        this.setSkins(this.model.getSelected());
    }

    public function destroy(e:Event):void {
        this.model.selected.remove(this.setSkins);
    }

    private function setSkins(characterClass:CharacterClass):void {
        var skins:Vector.<DisplayObject> = this.factory.make(characterClass.skins);
        this.setItems(skins);
    }

    private function makeList():VerticalScrollingList {
        var list:VerticalScrollingList = new VerticalScrollingList();
        list.setSize(new Size(WIDTH, HEIGHT));
        list.scrollStateChanged.add(this.onScrollStateChanged);
        list.setPadding(PADDING);
        addChild(list);
        return (list);
    }

    public function setItems(items:Vector.<DisplayObject>):void {
        this.items = items;
        this.list.setItems(items);
        this.onScrollStateChanged(this.list.isScrollbarVisible());
    }

    private function onScrollStateChanged(hasScrollBar:Boolean):void {
        var item:CharacterSkinListItem;
        var width:int = CharacterSkinListItem.WIDTH;
        if (!hasScrollBar) {
            width = (width + VerticalScrollingList.SCROLLBAR_GUTTER);
        }
        for each (item in this.items) {
            item.setWidth(width);
        }
    }

    public function getListHeight():Number {
        return (this.list.getListHeight());
    }


}
}
