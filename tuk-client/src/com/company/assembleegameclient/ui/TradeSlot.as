package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.constants.InventoryOwnerTypes;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.GraphicsUtil;
import com.company.util.MoreColorUtil;
import com.company.util.SpriteUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.events.Event;
import flash.geom.Matrix;

import kabam.rotmg.constants.ItemConstants;

import kabam.rotmg.text.view.BitmapTextFactory;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.tooltips.HoverTooltipDelegate;

import thyrr.utils.ItemData;

public class TradeSlot extends Slot {

    private static const IDENTITY_MATRIX:Matrix = new Matrix();
    public static const EMPTY:int = -1;
    private static function matrixTranslate(x:int, y:int):Matrix {
        var matrix:Matrix = new Matrix();
        matrix.translate(x, y);
        return matrix;
    }

    public const hoverTooltipDelegate:HoverTooltipDelegate = new HoverTooltipDelegate();
    private var _includedIcon:Bitmap = new Bitmap();
    private var _levelReqIcon:Bitmap = new Bitmap();

    public var included_:Boolean;
    public var equipmentToolTipFactory:EquipmentToolTipFactory;
    private var id:uint;
    private var overlay_:Shape;
    private var overlayFill_:GraphicsSolidFill;
    private var lineStyle_:GraphicsStroke;
    private var overlayPath_:GraphicsPath;
    private var graphicsData_:Vector.<IGraphicsData>;
    private var bitmapFactory:BitmapTextFactory;
    private var player_:Player;
    private var item:ItemData;

    public function TradeSlot(itemData:ItemData, _arg2:Boolean, _arg3:Boolean, _arg4:int, _arg5:int, _arg6:Array, _arg7:uint, player:Player) {
        this.equipmentToolTipFactory = new EquipmentToolTipFactory();
        this.overlayFill_ = new GraphicsSolidFill(16711310, 0);
        this.lineStyle_ = new GraphicsStroke(2, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3, this.overlayFill_);
        this.overlayPath_ = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
        this.graphicsData_ = new <IGraphicsData>[this.lineStyle_, this.overlayPath_, GraphicsUtil.END_STROKE];
        super(_arg4, _arg5, _arg6);
        this.id = _arg7;
        this.player_ = player;
        this.item = itemData;
        this.included_ = _arg3;
        this.drawItemIfAvailable();
        if (!_arg2) {
            transform.colorTransform = MoreColorUtil.veryDarkCT;
        }
        this.overlay_ = this.getOverlay();
        addChild(this.overlay_);
        this.setIncluded(_arg3);
        this.hoverTooltipDelegate.setDisplayObject(this);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    public function initialize(e:Event):void {
        this.setBitmapFactory(Global.bitmapTextFactory);
    }

    private function drawItemIfAvailable():void {
        if (!this.isEmpty()) {
            this.drawItem();
        }
    }

    private function drawItem():void {
        var itemBitmap:Bitmap;
        var data:BitmapData;
        var tex:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.item.ObjectType, 80, true);
        var item:XML = ObjectLibrary.xmlLibrary_[this.item.ObjectType];
        var getIcon:BitmapData = AssetLibrary.getImageFromSet("interfaceNew", 0x00);
        if ((item.hasOwnProperty("Quantity") || this.item.Quantity) && this.bitmapFactory) {
            var quantity:String = item.hasOwnProperty("Quantity") || this.item.Quantity == 0 ? String(item.Quantity) : String(this.item.Quantity);
            tex = tex.clone();
            data = this.bitmapFactory.make(new StaticStringBuilder(quantity), 12, 0xFFFFFF, false, IDENTITY_MATRIX, false);
            tex.draw(data, matrixTranslate(10, 8));
        }
        var usable:Boolean = true;
        if (item && this.item.ObjectType != ItemConstants.NO_ITEM) {
            if (!(ObjectLibrary.isUsableByPlayer(this.item.ObjectType, this.player_)))
            {
                tex = tex.clone();
                data = TextureRedrawer.redraw(getIcon, 20, true, 0);
                tex.draw(data, matrixTranslate(20, 20));
                usable = false;
            }
        }

        itemBitmap = new Bitmap(tex);
        itemBitmap.x = (WIDTH / 2) - (itemBitmap.width / 2);
        itemBitmap.y = (HEIGHT / 2) - (itemBitmap.height / 2);
        SpriteUtil.safeAddChild(this, itemBitmap);

        var levelReq:int = item.LevelReq;
        if (item && this.item.ObjectType != ItemConstants.NO_ITEM
                && levelReq > this.player_.level_) {
            getIcon = AssetLibrary.getImageFromSet("interfaceNew", 0x02);
            data = TextureRedrawer.redraw(getIcon, 20, true, 0);
            _levelReqIcon.bitmapData = data;
            _levelReqIcon.x = itemBitmap.x + 20;
            _levelReqIcon.y = itemBitmap.y + (usable ? 20 : 8);
            addChild(_levelReqIcon);
            usable = false;
        }

        getIcon = AssetLibrary.getImageFromSet("interfaceNew", 0x01);
        data = TextureRedrawer.redraw(getIcon, 20, true, 0);
        _includedIcon.bitmapData = data;
        _includedIcon.x = itemBitmap.x + (usable ? 20 : 6);
        _includedIcon.y = itemBitmap.y + 20;
        addChild(_includedIcon);
        _includedIcon.visible = false;
    }

    public function setIncluded(_arg1:Boolean):void {
        this.included_ = _arg1;
        this.overlay_.visible = this.included_;
        _includedIcon.visible = this.included_;
        if (this.included_) {
            fill_.color = 16764247;
        }
        else {
            fill_.color = 0x545454;
        }
        drawBackground();
    }

    public function setBitmapFactory(_arg1:BitmapTextFactory):void {
        this.bitmapFactory = _arg1;
        this.drawItemIfAvailable();
    }

    private function getOverlay():Shape {
        var _local1:Shape = new Shape();
        GraphicsUtil.clearPath(this.overlayPath_);
        GraphicsUtil.drawCutEdgeRect(0, 0, WIDTH, HEIGHT, 4, cuts_, this.overlayPath_);
        _local1.graphics.drawGraphicsData(this.graphicsData_);
        return (_local1);
    }

    public function setPlayer(_arg1:Player):void {
        if (!this.isEmpty()) {
            this.hoverTooltipDelegate.tooltip = this.equipmentToolTipFactory.make(this.item, _arg1, -1, InventoryOwnerTypes.OTHER_PLAYER, this.id);
        }
    }

    public function isEmpty():Boolean {
        return ((item.ObjectType == EMPTY));
    }


}
}
