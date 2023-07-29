package thyrr.forge.animations {
import flash.geom.Point;

import thyrr.forge.tabs.*;

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.util.FilterUtil;
import com.company.ui.BaseSimpleText;
import com.gskinner.motion.GTween;

import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.geom.Matrix;

import thyrr.assets.utility.EmbeddedAssets_StarburstSpinner;

import kabam.rotmg.messaging.impl.incoming.forge.CraftAnimation;

import thyrr.forge.Forge;

import thyrr.oldui.DefaultTab;

public class ForgeAnimation extends DefaultTab {

    private static const CENTER_X:int = Main.DefaultWidth / 2;
    private static const CENTER_Y:int = Main.DefaultHeight / 2;
    private static const ITEM_CENTER_X:int = CENTER_X - 21; // 42 / 2
    private static const RESULT_CENTER_Y:int = CENTER_Y - 80;

    private var animationTweens_:Vector.<GTween>;
    private var packet_:CraftAnimation;
    private var spinner_:EmbeddedAssets_StarburstSpinner;

    public function ForgeAnimation(gs:GameSprite, packet:CraftAnimation) {
        this.packet_ = packet;
        super(gs);

        // make items to fuse and initialize their tweens
        makeInitial();
        // start animations: move items to fuse to middle
        startTweening();
    }

    private function makeInitial():void {
        this.animationTweens_ = new Vector.<GTween>(this.packet_.active_.length + 1);
        var i:int = 0;
        while (i < this.packet_.active_.length) {
            var pos:Point = ForgeTab.getPosition(i);
            var item:Bitmap = new Bitmap(ObjectLibrary.getRedrawnTextureFromType(this.packet_.active_[i], 80, true, false));
            item.x = pos.x + 20;
            item.y = pos.y * 1.2;
            this.animationTweens_[i] = new GTween(item, 0.25, {
                "x": ITEM_CENTER_X + 30,
                "y": RESULT_CENTER_Y + 45,
                "alpha": 0,
                "scaleX": 0.5,
                "scaleY": 0.5
            });
            addChild(item);
            i++;
        }
    }

    private function startTweening():void {
        var len:int = this.packet_.active_.length;
        var i:int = 0;
        while (i < len) {
            this.animationTweens_[i].delay = 0.25 * i;
            this.animationTweens_[i].init();
            i++;
        }
        this.animationTweens_[len - 1].onComplete = fuseItems;
    }

    private function fuseItems(tween:GTween):void {
        // final animation: delete items to fuse, add crafted item,
        // some extra decorations and close button
        var len:int = this.packet_.active_.length;
        removeChildren(0, len - 1);
        // add item name on top
        var objectId:String = ObjectLibrary.typeToObjId_[this.packet_.objectType_];
        var itemName:BaseSimpleText = new BaseSimpleText(30, 0xB3B3B3);
        itemName.setBold(true);
        itemName.text = objectId;
        itemName.updateMetrics();
        itemName.x = ITEM_CENTER_X + 24 - itemName.width / 2;
        itemName.y = RESULT_CENTER_Y - 160;
        itemName.alpha = 0;
        itemName.filters = FilterUtil.getDmgCounterMultiFilter();
        addChild(itemName);
        // add item icon on middle
        var itemBitmap:Bitmap;
        itemBitmap = new Bitmap(ObjectLibrary.getRedrawnTextureFromType(this.packet_.objectType_, 160, true, false));
        itemBitmap.x = ITEM_CENTER_X - 20;
        itemBitmap.y = RESULT_CENTER_Y + 12;
        itemBitmap.alpha = 0;
        addChild(itemBitmap);
        new GTween(itemBitmap, 0.3, {
            "alpha": 1
        });
        new GTween(itemName, 0.3, {
            "alpha": 1
        });
        // add spinner around icon and start rotating
        this.spinner_ = new EmbeddedAssets_StarburstSpinner();
        this.spinner_.x = ITEM_CENTER_X - this.spinner_.width / 3 - 32;
        this.spinner_.y = RESULT_CENTER_Y - this.spinner_.height / 3;
        this.spinner_.alpha = 0;
        addChild(this.spinner_);
        new GTween(this.spinner_, 1, {
            "alpha": 1
        });
        this.animationTweens_[0] = new GTween(null, 0.01);
        this.animationTweens_[0].onComplete = rotateloop;
        var closeButton:DeprecatedTextButton = new DeprecatedTextButton(18, "Close");
        closeButton.x = CENTER_X - 28;
        closeButton.y = RESULT_CENTER_Y + 250;
        addChild(closeButton);
        closeButton.addEventListener(MouseEvent.CLICK, onClose);
    }

    private function rotateloop(tween:GTween):void {
        rotateAroundCenter(1.5);
        this.animationTweens_[0] = new GTween(null, 0.025);
        this.animationTweens_[0].onComplete = rotateloop;
    }

    // https://stackoverflow.com/a/15789937 (Modified)
    private var centerX_:Number = NaN;
    private var centerY_:Number = NaN;
    public function rotateAroundCenter(angleDegrees:Number):void {
        if (this.spinner_.rotation == angleDegrees) {
            return;
        }

        var matrix:Matrix = this.spinner_.transform.matrix;
        // rotation bug lol, make sure this shit doesn't change after first rotation...
        if (isNaN(this.centerX_) || isNaN(this.centerY_)) {
            var rect:flash.geom.Rectangle = this.spinner_.getBounds(this.spinner_.parent);
            this.centerX_ = rect.left + (rect.width / 2);
            this.centerY_ = rect.top + (rect.height / 2);
        }
        matrix.translate(-this.centerX_, -this.centerY_);
        matrix.rotate((angleDegrees / 180) * Math.PI);
        matrix.translate(this.centerX_, this.centerY_);
        this.spinner_.transform.matrix = matrix;
    }

    private function onClose(event:MouseEvent):void {
        (parent as Forge).close();
    }

}
}
