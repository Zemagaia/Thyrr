package kabam.rotmg.minimap.view {
import com.company.assembleegameclient.map.AbstractMap;
import com.company.assembleegameclient.map.GroundLibrary;
import com.company.assembleegameclient.objects.Character;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.GuildHallPortal;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.Portal;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.menu.PlayerGroupMenu;
import com.company.assembleegameclient.ui.options.Options;
import com.company.assembleegameclient.ui.tooltip.PlayerGroupToolTip;
import com.company.assembleegameclient.ui.tooltip.TextToolTip;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;
import com.company.util.KeyCodes;
import com.company.util.PointUtil;
import com.company.util.RectangleUtil;

import flash.display.Bitmap;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import kabam.rotmg.core.view.Layers;
import kabam.rotmg.minimap.model.UpdateGroundTileVO;
import kabam.rotmg.tooltips.HoverTooltipDelegate;
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.model.UpdateGameObjectTileVO;

import thyrr.mail.AccountMail;
import thyrr.quests.QuestGiver;
import thyrr.ui.buttons.HoldableButton;
import thyrr.ui.items.FlexibleBox;
import thyrr.utils.Utils;

public class MiniMap extends Sprite {

    public static const MOUSE_DIST_SQ:int = (5 * 5);//25

    private static var objectTypeColorDict_:Dictionary = new Dictionary();

    public var model:HUDModel = Global.hudModel;
    public var layers:Layers = Global.layers;
    public var map:AbstractMap;
    public var menuLayer:DisplayObjectContainer;
    public var _width:int;
    public var _height:int;
    public var zoomIndex:int = 0;
    public var windowRect_:Rectangle;
    public var active:Boolean = true;
    public var maxWH_:Point;
    public var miniMapData_:BitmapData;
    public var zoomLevels:Vector.<Number>;
    public var blueArrow_:BitmapData;
    public var groundLayer_:Shape;
    public var characterLayer_:Shape;
    private var focus:GameObject;
    private var zoomButtons:MiniMapZoomButtons;
    private var isMouseOver:Boolean = false;
    private var tooltip:PlayerGroupToolTip = null;
    private var menu:PlayerGroupMenu = null;
    private var mapMatrix_:Matrix;
    private var arrowMatrix_:Matrix;
    private var players_:Vector.<Player>;
    private var tempPoint:Point;
    private var _rotateEnableFlag:Boolean;
    private var optionsBtn:HoldableButton;
    private var infoBtn:HoldableButton;
    private var questBtn:HoldableButton;
    private var giftBtn:HoldableButton;
    private var mailBtn:HoldableButton;
    private var friendsBtn:HoldableButton;
    private var portraitBox:FlexibleBox;
    private var starBox:FlexibleBox;
    private var bgBox:FlexibleBox = new FlexibleBox(232, 232, 0xAEA9A9, 0, false, null, 2);
    private var initialized:Boolean = false;

    public function MiniMap(w:int, h:int) {
        this.zoomLevels = new Vector.<Number>();
        this.mapMatrix_ = new Matrix();
        this.arrowMatrix_ = new Matrix();
        this.players_ = new Vector.<Player>();
        this.tempPoint = new Point();
        super();
        this._width = w;
        this._height = h;
        this._rotateEnableFlag = Parameters.data_.allowMiniMapRotation;
        this.makeVisualLayers();
        this.addMouseListeners();
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }

    public function onAdded(e:Event):void {
        this.setMap(this.model.gameSprite.map);
        this.menuLayer = this.layers.top;
    }

    private function getFocusById(_arg1:String):GameObject {
        var _local3:GameObject;
        if (_arg1 == "") {
            return (this.map.player_);
        }
        var _local2:Dictionary = this.map.goDict_;
        for each (_local3 in _local2) {
            if (_local3.name_ == _arg1) {
                return (_local3);
            }
        }
        return (this.map.player_);
    }

    public function onUpdateGroundTile(_arg1:UpdateGroundTileVO):void {
        this.setGroundTile(_arg1.tileX, _arg1.tileY, _arg1.tileType);
    }

    public function onUpdateGameObjectTile(_arg1:UpdateGameObjectTileVO):void {
        this.setGameObjectTile(_arg1.tileX, _arg1.tileY, _arg1.gameObject);
    }

    public function onMiniMapZoom(_arg1:String):void {
        if (_arg1 == "IN") {
            this.zoomIn();
        }
        else {
            if (_arg1 == "OUT") {
                this.zoomOut();
            }
        }
    }

    public static function gameObjectToColor(_arg1:GameObject):uint {
        var _local2:* = _arg1.objectType_;
        if (!objectTypeColorDict_.hasOwnProperty(_local2)) {
            objectTypeColorDict_[_local2] = _arg1.getColor();
        }
        return (objectTypeColorDict_[_local2]);
    }

    public function setMap(_arg1:AbstractMap):void {
        this.map = _arg1;
        this.makeViewModel();
    }

    public function setFocus(_arg1:String):void {
        this.focus = getFocusById(_arg1);
    }

    public function setFocusDirect(go:GameObject):void {
        this.focus = go;
    }

    private function makeViewModel():void {
        this.windowRect_ = new Rectangle((-(this._width) / 2) + 2, (-(this._height) / 2) + 2, this._width - 4, this._height - 4);
        this.maxWH_ = new Point(map.width_, map.height_);
        this.miniMapData_ = new BitmapDataSpy(this.maxWH_.x, this.maxWH_.y, false, 0);
        var _local1:Number = Math.max((this._width / this.maxWH_.x), (this._height / this.maxWH_.y));
        var _local2:Number = 4;
        while (_local2 > _local1) {
            this.zoomLevels.push(_local2);
            _local2 = (_local2 / 2);
        }
        this.zoomLevels.push(_local1);
        ((this.zoomButtons) && (this.zoomButtons.setZoomLevels(this.zoomLevels.length)));
    }

    private function makeVisualLayers():void {
        this.blueArrow_ = AssetLibrary.getImageFromSet("interfaceSmall", 0x0E).clone();
        this.blueArrow_.colorTransform(this.blueArrow_.rect, new ColorTransform(0, 0, 1));
        addChild(bgBox);
        this.groundLayer_ = new Shape();
        this.groundLayer_.x = (this._width / 2);
        this.groundLayer_.y = (this._height / 2);
        addChild(this.groundLayer_);
        this.characterLayer_ = new Shape();
        this.characterLayer_.x = (this._width / 2);
        this.characterLayer_.y = (this._height / 2);
        addChild(this.characterLayer_);
        this.zoomButtons = new MiniMapZoomButtons();
        this.zoomButtons.x = this._width - 20;
        this.zoomButtons.y -= 4;
        this.zoomButtons.zoom.add(this.onZoomChanged);
        this.zoomButtons.setZoomLevels(this.zoomLevels.length);
        addChild(this.zoomButtons);
        this.createOptionsBtn();
        this.createInfoBtn();
        this.createQuestBtn();
        this.createGiftBtn();
        this.createMailBtn();
        this.createFriendsBtn();
        this.createPortraitBox();
        this.createStarBox();
        bgBox.filters = [Utils.OutlineFilter];
    }

    public function initialize(player:Player):void
    {
        if (initialized) return;
        initialized = true;
        var icon:Bitmap = new Bitmap();
        var data:BitmapData = ObjectLibrary.getRedrawnTextureFromType(player.objectType_, 40, true);
        data = BitmapUtil.cropToBitmapData(data, 8, 8, (data.width - 16), (data.height - 16));
        data = BitmapUtil.flipBitmapData(data);
        icon.bitmapData = data;
        icon.x = this.portraitBox.x + portraitBox.width / 2 - icon.width / 2;
        icon.y = this.portraitBox.y + portraitBox.height / 2 - icon.height / 2;
        addChild(icon);
    }

    private function setTooltip(object:DisplayObject, tooltip:TextToolTip):HoverTooltipDelegate
    {
        var delegate:HoverTooltipDelegate = new HoverTooltipDelegate();
        delegate.setDisplayObject(object);
        delegate.tooltip = tooltip;
        return delegate;
    }

    private function createOptionsBtn():void {
        optionsBtn = new HoldableButton(24, 24, 0xAEA9A9, 0x09, false);
        this.optionsBtn.x = bgBox.x - optionsBtn.width - 4;
        this.optionsBtn.y = bgBox.y + 6;
        addChild(this.optionsBtn);
        this.optionsBtn.clicked.add(onOptionsClick);
        this.filters = [Utils.OutlineFilter];
        var tooltip:TextToolTip = new TextToolTip(0x666363, 0xaea9a9, "Options",
                "Open the options screen.{font}\n\nHotkey: {key}{_font}", 128, {
            "key": KeyCodes.CharCodeStrings[Parameters.data_.options],
            "font": "<font color='#FFFFFF'>",
            "_font": "</font>"
        });
        setTooltip(optionsBtn, tooltip);
    }

    private function onOptionsClick():void {
        this.layers.overlay.addChild(new Options(model.gameSprite));
        model.gameSprite.mui_.clearInput();
    }

    private function createInfoBtn():void {
        infoBtn = new HoldableButton(24, 24, 0xAEA9A9, 0x0A, false);
        this.infoBtn.x = bgBox.x - infoBtn.width - 4;
        this.infoBtn.y = optionsBtn.y + 28;
        addChild(this.infoBtn);
        this.filters = [Utils.OutlineFilter];
    }

    private function createQuestBtn():void {
        questBtn = new HoldableButton(24, 24, 0xAEA9A9, 0x0B, false);
        questBtn.changeColorOnToggle = false;
        this.questBtn.x = bgBox.x - questBtn.width - 4;
        this.questBtn.y = infoBtn.y + 28;
        addChild(this.questBtn);
        this.questBtn.clicked.add(onQuestsClick);
        this.filters = [Utils.OutlineFilter];
        var tooltip:TextToolTip = new TextToolTip(0x666363, 0xaea9a9, "Quest Log",
                "Open the active quests log.{font}\n\nHotkey: {key}{_font}", 128, {
                    "key": "null",
                    "font": "<font color='#FFFFFF'>",
                    "_font": "</font>"
                });
        setTooltip(questBtn, tooltip);
    }

    private function onQuestsClick():void {
        this.layers.overlay.addChild(new QuestGiver(model.gameSprite));
        model.gameSprite.mui_.clearInput();
    }

    private function createGiftBtn():void {
        giftBtn = new HoldableButton(24, 24, 0xAEA9A9, 0x0D, false);
        giftBtn.changeColorOnToggle = false;
        this.giftBtn.x = bgBox.x - giftBtn.width - 4;
        this.giftBtn.y = questBtn.y + 28;
        addChild(this.giftBtn);
        this.filters = [Utils.OutlineFilter];
        updateGift(Global.StoredData["hasGift"]);
        Global.deleteStoredData("hasGift");
    }

    private function createMailBtn():void {
        mailBtn = new HoldableButton(24, 24, 0xAEA9A9, 0x0C, false);
        mailBtn.changeColorOnToggle = false;
        this.mailBtn.x = bgBox.x - mailBtn.width - 4;
        this.mailBtn.y = giftBtn.y + 28;
        addChild(this.mailBtn);
        mailBtn.clicked.add(onMailClick);
        this.filters = [Utils.OutlineFilter];
        updateMail();
        Global.deleteStoredData("mailCount");
    }

    private function onMailClick():void
    {
        this.layers.overlay.addChild(new AccountMail(model.gameSprite));
        model.gameSprite.mui_.clearInput();
    }

    private function createFriendsBtn():void {
        friendsBtn = new HoldableButton(24, 24, 0xAEA9A9, 0x0e, false);
        this.friendsBtn.x = bgBox.x - mailBtn.width - 4;
        this.friendsBtn.y = mailBtn.y + 28;
        addChild(this.friendsBtn);
        this.filters = [Utils.OutlineFilter];
    }

    private function createPortraitBox():void {
        portraitBox = new FlexibleBox(24, 24, 0xAEA9A9, 0, false, null, 2);
        this.portraitBox.x = bgBox.x - friendsBtn.width - 4;
        this.portraitBox.y = friendsBtn.y + 28;
        addChild(this.portraitBox);
        this.filters = [Utils.OutlineFilter];
    }

    private function createStarBox(): void {
        starBox = new FlexibleBox(24, 24, 0xAEA9A9, 0, false, null, 2);
        this.starBox.x = bgBox.x - portraitBox.width - 4;
        this.starBox.y = portraitBox.y + 28;
        addChild(this.starBox);
        this.filters = [Utils.OutlineFilter];
    }

    private function updateGift(hasGift:Boolean):void
    {
        if (hasGift)
            giftBtn.toggle(Utils.color(0xaea9a9, 1.3));
        var text:String = hasGift ? "There are gifts in your Vault!" : "You currently have no gifts.";
        var tooltip:TextToolTip = new TextToolTip(0x666363, 0xaea9a9, "Gifts", text, 128);
        setTooltip(giftBtn, tooltip);
    }

    private function updateMail():void
    {
        if (Global.StoredData["mailCount"] != null)
            mailBtn.toggle(Utils.color(0xaea9a9, 1.3));
        var tooltip:TextToolTip = new TextToolTip(0x666363, 0xaea9a9, "Mails", "Open the mail menu.{font}\n\nHotkey: {key}{_font}", 128, {
            "key": "null",
            "font": "<font color='#FFFFFF'>",
            "_font": "</font>"
        });
        setTooltip(mailBtn, tooltip);
    }

    private function addMouseListeners():void {
        addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
        addEventListener(MouseEvent.RIGHT_CLICK, this.onMapRightClick);
        addEventListener(MouseEvent.CLICK, this.onMapClick);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        this.active = false;
        this.removeDecorations();
    }

    public function dispose():void {
        this.miniMapData_.dispose();
        this.miniMapData_ = null;
        this.removeDecorations();
    }

    private function onZoomChanged(_arg1:int):void {
        this.zoomIndex = _arg1;
    }

    private function onMouseOver(_arg1:MouseEvent):void {
        this.isMouseOver = true;
    }

    private function onMouseOut(_arg1:MouseEvent):void {
        this.isMouseOver = false;
    }

    private function onMapRightClick(_arg1:MouseEvent):void {
        this._rotateEnableFlag = ((!(this._rotateEnableFlag)) && (Parameters.data_.allowMiniMapRotation));
    }

    private function onMapClick(_arg1:MouseEvent):void {
        if ((((((((this.tooltip == null)) || ((this.tooltip.parent == null)))) || ((this.tooltip.players_ == null)))) || ((this.tooltip.players_.length == 0)))) {
            return;
        }
        this.removeMenu();
        this.addMenu();
        this.removeTooltip();
    }

    private function addMenu():void {
        this.menu = new PlayerGroupMenu(map, this.tooltip.players_);
        this.menu.x = (this.tooltip.x + 12);
        this.menu.y = this.tooltip.y;
        menuLayer.addChild(this.menu);
    }

    public function setGroundTile(_arg1:int, _arg2:int, _arg3:uint):void {
        var _local4:uint = GroundLibrary.getColor(_arg3);
        this.miniMapData_.setPixel(_arg1, _arg2, _local4);
    }

    public function setGameObjectTile(_arg1:int, _arg2:int, _arg3:GameObject):void {
        var _local4:uint = gameObjectToColor(_arg3);
        this.miniMapData_.setPixel(_arg1, _arg2, _local4);
    }

    private function removeDecorations():void {
        this.removeTooltip();
        this.removeMenu();
    }

    private function removeTooltip():void {
        if (this.tooltip != null) {
            if (this.tooltip.parent != null) {
                this.tooltip.parent.removeChild(this.tooltip);
            }
            this.tooltip = null;
        }
    }

    private function removeMenu():void {
        if (this.menu != null) {
            if (this.menu.parent != null) {
                this.menu.parent.removeChild(this.menu);
            }
            this.menu = null;
        }
    }

    public function draw():void {
        var g:Graphics;
        var go:GameObject;
        var fillColor:uint;
        var player:Player;
        var mmx:Number;
        var mmy:Number;
        var dx:Number;
        var dy:Number;
        var distSq:Number;
        this._rotateEnableFlag = ((this._rotateEnableFlag) && (Parameters.data_.allowMiniMapRotation));
        this.groundLayer_.graphics.clear();
        this.characterLayer_.graphics.clear();
        if (!this.focus) {
            return;
        }
        if (!this.active) {
            return;
        }
        var zoom:Number = this.zoomLevels[this.zoomIndex];
        this.mapMatrix_.identity();
        this.mapMatrix_.translate(-(this.focus.x_), -(this.focus.y_));
        this.mapMatrix_.scale(zoom, zoom);
        var topLeft:Point = this.mapMatrix_.transformPoint(PointUtil.ORIGIN);
        var bottomRight:Point = this.mapMatrix_.transformPoint(this.maxWH_);
        var tx:Number = 0;
        if (topLeft.x > this.windowRect_.left) {
            tx = (this.windowRect_.left - topLeft.x);
        }
        else {
            if (bottomRight.x < this.windowRect_.right) {
                tx = (this.windowRect_.right - bottomRight.x);
            }
        }
        var ty:Number = 0;
        if (topLeft.y > this.windowRect_.top) {
            ty = (this.windowRect_.top - topLeft.y);
        }
        else {
            if (bottomRight.y < this.windowRect_.bottom) {
                ty = (this.windowRect_.bottom - bottomRight.y);
            }
        }
        this.mapMatrix_.translate(tx, ty);
        topLeft = this.mapMatrix_.transformPoint(PointUtil.ORIGIN);
        if ((((zoom >= 1)) && (this._rotateEnableFlag))) {
            this.mapMatrix_.rotate(-(Parameters.data_.cameraAngle));
        }
        var drawRect:Rectangle = new Rectangle();
        drawRect.x = Math.max(this.windowRect_.x, topLeft.x);
        drawRect.y = Math.max(this.windowRect_.y, topLeft.y);
        drawRect.right = Math.min(this.windowRect_.right, (topLeft.x + (this.maxWH_.x * zoom)));
        drawRect.bottom = Math.min(this.windowRect_.bottom, (topLeft.y + (this.maxWH_.y * zoom)));
        g = this.groundLayer_.graphics;
        g.beginBitmapFill(this.miniMapData_, this.mapMatrix_, false);
        g.drawRect(drawRect.x, drawRect.y, drawRect.width, drawRect.height);
        g.endFill();
        g = this.characterLayer_.graphics;
        var mX:Number = (mouseX - (this._width / 2));
        var mY:Number = (mouseY - (this._height / 2));
        this.players_.length = 0;
        for each (go in map.goDict_) {
            if (!((go.props_.noMiniMap_) || ((go == this.focus)))) {
                player = (go as Player);
                if (player != null) {
                    if (player.isPaused()) {
                        fillColor = 0x7F7F7F;
                    }
                    else {
                        if (player.isFellowGuild_) {
                            fillColor = 0xFF00;
                        }
                        else {
                            fillColor = 0xFFFF00;
                        }
                    }
                }
                else {
                    if ((go is Character)) {
                        if (go.props_.isEnemy_) {
                            if (go.props_.color_ != -1) {
                                fillColor = go.props_.color_;
                            } else {
                                fillColor = 0xFF0000;
                            }
                        }
                        else {
                            fillColor = gameObjectToColor(go);
                        }
                    }
                    else {
                        if ((((go is Portal)) || ((go is GuildHallPortal)))) {
                            fillColor = 0xFF;
                        }
                        else {
                            continue;
                        }
                    }
                }
                mmx = (((this.mapMatrix_.a * go.x_) + (this.mapMatrix_.c * go.y_)) + this.mapMatrix_.tx);
                mmy = (((this.mapMatrix_.b * go.x_) + (this.mapMatrix_.d * go.y_)) + this.mapMatrix_.ty);
                if (mmx <= -(this._width) / 2 || mmx >= this._width / 2 || mmy <= -(this._height) / 2 || mmy >= this._height / 2) {
                    RectangleUtil.lineSegmentIntersectXY(this.windowRect_, 0, 0, mmx, mmy, this.tempPoint);
                    mmx = this.tempPoint.x;
                    mmy = this.tempPoint.y;
                }
                if (((((!((player == null))) && (this.isMouseOver))) && ((((this.menu == null)) || ((this.menu.parent == null)))))) {
                    dx = (mX - mmx);
                    dy = (mY - mmy);
                    distSq = ((dx * dx) + (dy * dy));
                    if (distSq < MOUSE_DIST_SQ) {
                        this.players_.push(player);
                    }
                }
                g.beginFill(fillColor);
                g.drawRect(mmx - 2, mmy - 2, 4, 4);
                g.endFill();
            }
        }
        if (this.players_.length != 0) {
            if (this.tooltip == null) {
                this.tooltip = new PlayerGroupToolTip(this.players_);
                menuLayer.addChild(this.tooltip);
            }
            else {
                if (!this.areSamePlayers(this.tooltip.players_, this.players_)) {
                    this.tooltip.setPlayers(this.players_);
                }
            }
        }
        else {
            if (this.tooltip != null) {
                if (this.tooltip.parent != null) {
                    this.tooltip.parent.removeChild(this.tooltip);
                }
                this.tooltip = null;
            }
        }
        var px:Number = this.focus.x_;
        var py:Number = this.focus.y_;
        var ppx:Number = (((this.mapMatrix_.a * px) + (this.mapMatrix_.c * py)) + this.mapMatrix_.tx);
        var ppy:Number = (((this.mapMatrix_.b * px) + (this.mapMatrix_.d * py)) + this.mapMatrix_.ty);
        this.arrowMatrix_.identity();
        this.arrowMatrix_.translate(-4, -5);
        this.arrowMatrix_.scale((8 / this.blueArrow_.width), (32 / this.blueArrow_.height));
        if (!(((zoom >= 1)) && (this._rotateEnableFlag))) {
            this.arrowMatrix_.rotate(Parameters.data_.cameraAngle);
        }
        this.arrowMatrix_.translate(ppx, ppy);
        g.beginBitmapFill(this.blueArrow_, this.arrowMatrix_, false);
        g.drawRect((ppx - 16), (ppy - 16), 32, 32);
        g.endFill();
    }

    private function areSamePlayers(_arg1:Vector.<Player>, _arg2:Vector.<Player>):Boolean {
        var bottomRight:int = _arg1.length;
        if (bottomRight != _arg2.length) {
            return (false);
        }
        var _local4:int;
        while (_local4 < bottomRight) {
            if (_arg1[_local4] != _arg2[_local4]) {
                return (false);
            }
            _local4++;
        }
        return true;
    }

    public function zoomIn():void {
        this.zoomIndex = this.zoomButtons.setZoomLevel((this.zoomIndex - 1));
    }

    public function zoomOut():void {
        this.zoomIndex = this.zoomButtons.setZoomLevel((this.zoomIndex + 1));
    }

    public function deactivate():void {
    }

}
}
