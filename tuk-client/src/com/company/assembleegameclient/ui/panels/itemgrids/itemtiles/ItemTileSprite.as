package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles
{

import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.animation.Animations;
import com.company.assembleegameclient.objects.animation.AnimationsData;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.utils.getTimer;

import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.text.view.BitmapTextFactory;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import thyrr.utils.ItemData;

public class ItemTileSprite extends Sprite
{

    public static const DIM_FILTER:Array = [new ColorMatrixFilter([0.4, 0, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 0, 1, 0])];
    private static const IDENTITY_MATRIX:Matrix = new Matrix();

    private static function matrixTranslate(x:int, y:int):Matrix
    {
        var matrix:Matrix = new Matrix();
        matrix.translate(x, y);
        return matrix;
    }

    public var item:ItemData;
    public var itemBitmap:Bitmap;
    private var bitmapFactory:BitmapTextFactory;
    private var player_:Player;
    private var unusable:Bitmap;
    private var animations_:Animations;
    private var size_:int;
    private var levelReqIcon:Bitmap;

    public function ItemTileSprite(player:Player)
    {
        this.player_ = player;
        this.itemBitmap = new Bitmap();
        addChild(this.itemBitmap);
        this.item = ItemConstants.DEFAULT_ITEM;
    }

    public function setDim(_arg1:Boolean):void
    {
        filters = ((_arg1) ? DIM_FILTER : null);
    }

    public function setType(item:ItemData, size:int = 80):void
    {
        this.item = item;
        this.size_ = size;
        this.drawTile();
    }

    public function drawTile():void
    {
        var tex:BitmapData;
        var item:XML;
        var data:BitmapData;
        var itemId:int = this.item != null ? this.item.ObjectType : -1;
        var usableIcon:BitmapData = AssetLibrary.getImageFromSet("interfaceNew", 0x00);
        if (itemId != ItemConstants.NO_ITEM)
        {
            if ((((itemId >= 0x9000)) && ((itemId < 0xF000))))
            {
                itemId = 36863;
            }
            tex = ObjectLibrary.getRedrawnTextureFromType(itemId, this.size_, true, true, 5, this.item).clone();
            item = ObjectLibrary.xmlLibrary_[itemId];
            if ((item != null && item.hasOwnProperty("Quantity") || (this.item && this.item.Quantity)) && this.bitmapFactory)
            {
                var quantity:int = item.Quantity;
                if (this.item && this.item.Quantity)
                {
                    quantity = this.item.Quantity;
                }
                data = this.bitmapFactory.make(new StaticStringBuilder(String(quantity)), 12, 0xFFFFFF, false, IDENTITY_MATRIX, false);
                tex.draw(data, matrixTranslate(10, 8));
            }
            var usable:Boolean = true;
            this.itemBitmap.bitmapData = tex;
            this.itemBitmap.x = (-(tex.width) / 2);
            this.itemBitmap.y = (-(tex.height) / 2);
            if (item != null)
            {
                if (unusable == null && !(ObjectLibrary.isUsableByPlayer(itemId, this.player_)))
                {
                    data = TextureRedrawer.redraw(usableIcon, 20, true, 0);
                    unusable = new Bitmap(data);
                    unusable.x = itemBitmap.x + 20;
                    unusable.y = itemBitmap.y + 20;
                    addChild(unusable);
                    usable = false;
                }
                if (levelReqIcon == null && this.player_ != null && this.player_.level_ < item.LevelReq)
                {
                    usableIcon = AssetLibrary.getImageFromSet("interfaceNew", 0x02);
                    data = TextureRedrawer.redraw(usableIcon, 20, true, 0);
                    levelReqIcon = new Bitmap(data);
                    levelReqIcon.x = itemBitmap.x + 20;
                    levelReqIcon.y = itemBitmap.y + (usable ? 20 : 8);
                    addChild(levelReqIcon);
                }
            }

            var animationsData:AnimationsData = ObjectLibrary.typeToAnimationsData_[itemId];
            this.animations_ = animationsData == null ? null : new Animations(animationsData);
            visible = true;
        }
        else
        {
            visible = false;
        }
    }

    public function setBitmapFactory(_arg1:BitmapTextFactory):void
    {
        this.bitmapFactory = _arg1;
    }

    public function updateLevelReqIconVisibility(player:Player):void
    {
        var item:XML = ObjectLibrary.xmlLibrary_[this.item.ObjectType];
        if (item == null)
            return;
        if (player.level_ > int(item.levelReq) && levelReqIcon != null)
        {
            levelReqIcon.visible = false;
        }
    }

    private var animCache:BitmapData;
    public function tickSprite():void
    {
        var anim:Animations = this.animations_;
        if (anim == null)
        {
            return;
        }
        var timer:int = getTimer();
        var texture:BitmapData = anim.getTexture(timer);
        if (texture != null && animCache != texture)
        {
            animCache = texture != animCache ? texture : animCache;
            texture = TextureRedrawer.redraw(texture, this.size_, true, 0);
            this.itemBitmap.bitmapData = texture;
            this.itemBitmap.x = -texture.width / 2;
            this.itemBitmap.y = -texture.height / 2;
        }
    }

}
}