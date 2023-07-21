package thyrr.forge.model {
import com.company.assembleegameclient.objects.ObjectLibrary;

import flash.display.Sprite;

import kabam.rotmg.util.ItemWithTooltip;

import thyrr.oldui.DefaultArrow;

import thyrr.utils.Utils;

public class ForgeRecipe extends Sprite {

    public var background_:Sprite;
    public var result_:String;
    public var width_:int;

    public function ForgeRecipe(items:Vector.<String>, result:String) {
        this.draw(items, result);
    }

    private function draw(items:Vector.<String>, result:String):void {
        this.result_ = result;
        this.background_ = new Sprite();
        var xOffset:int = 0;
        var recipes:Vector.<ItemWithTooltip> = new Vector.<ItemWithTooltip>(items.length);
        var resultItem:ItemWithTooltip = new ItemWithTooltip(ObjectLibrary.idToType_[result], 80);
        var arrow:DefaultArrow;
        items.sort(Utils.sortStrings);
        addChild(this.background_);
        var i:int = 0;
        while (i < recipes.length) {
            recipes[i] = new ItemWithTooltip(ObjectLibrary.idToType_[items[i]], 80);
            recipes[i].x = xOffset;
            xOffset += 48;
            addChild(recipes[i]);
            i++;
        }
        arrow = new DefaultArrow();
        arrow.recolorAndResize(0xFFFFFF, 22, 10);
        arrow.scaleX = -1;
        arrow.x = xOffset + 53;
        arrow.y = 18;
        addChild(arrow);
        xOffset += 48;
        resultItem.x = xOffset;
        addChild(resultItem);
        xOffset += 48;
        this.width_ = xOffset;
    }
}
}
