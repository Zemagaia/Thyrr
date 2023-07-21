package com.company.assembleegameclient.game {
import com.company.assembleegameclient.game.events.MoneyChangedEvent;
import com.company.assembleegameclient.map.AbstractMap;
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.IInteractiveObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.Projectile;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.DamageCounterFrame;
import com.company.assembleegameclient.ui.ExperienceBoostTimerPopup;
import com.company.assembleegameclient.ui.PlayerInfoPanel;
import com.company.assembleegameclient.ui.RankText;
import com.company.assembleegameclient.ui.StatusBar;
import com.company.assembleegameclient.ui.menu.PlayerMenu;
import com.company.assembleegameclient.ui.panels.PartyPanel;
import com.company.assembleegameclient.ui.tooltip.RankToolTip;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.CachingColorTransformer;
import com.company.util.MoreColorUtil;
import com.company.util.MoreObjectUtil;
import com.company.util.PointUtil;
import com.gskinner.motion.GTween;

import flash.display.Bitmap;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.filters.ColorMatrixFilter;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import kabam.lib.loopedprocs.LoopedCallback;
import kabam.lib.loopedprocs.LoopedProcess;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.chat.view.Chat;
import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.core.model.MapModel;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.core.view.Layers;
import kabam.rotmg.dialogs.control.AddPopupToStartupQueueSignal;
import kabam.rotmg.dialogs.control.FlushPopupStartupQueueSignal;
import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.dialogs.model.DialogsModel;
import kabam.rotmg.game.view.CreditDisplay;
import kabam.rotmg.game.view.GiftStatusDisplay;
import kabam.rotmg.game.view.MailDisplay;
import kabam.rotmg.maploading.signals.HideMapLoadingSignal;
import kabam.rotmg.maploading.signals.MapLoadedSignal;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.messaging.impl.incoming.MapInfo;
import kabam.rotmg.minimap.view.MiniMapImp;
import kabam.rotmg.servers.api.Server;
import kabam.rotmg.stage3D.Renderer;
import kabam.rotmg.ui.UIUtils;
import kabam.rotmg.ui.view.CharacterDetailsView;
import kabam.rotmg.ui.view.HUDView;

import org.osflash.signals.Signal;

import thyrr.mail.AccountMail;
import thyrr.lootNotifs.LootNotifications;
import thyrr.utils.Utils;

public class GameSprite extends Sprite {

    protected static const PAUSED_FILTER:ColorMatrixFilter = new ColorMatrixFilter(MoreColorUtil.greyscaleFilterMatrix);

    public const modelInitialized:Signal = new Signal();
    public const drawCharacterWindow:Signal = new Signal(Player);
    public static const DISPLAY_AREA_Y_SPACE:int = 32;

    private var miniMap:MiniMapImp;
    public var chatBox_:Chat;
    public var isNexus_:Boolean = false;
    public var idleWatcher_:IdleWatcher;
    public var rankText_:RankText;
    public var creditDisplay_:CreditDisplay;
    public var giftStatusDisplay:GiftStatusDisplay;
    public var mailDisplay_:MailDisplay;
    public var mapModel:MapModel;
    public var dialogsModel:DialogsModel;
    public var openDialog:OpenDialogSignal;
    public var addToQueueSignal:AddPopupToStartupQueueSignal;
    public var flushQueueSignal:FlushPopupStartupQueueSignal;
    private var focus:GameObject;
    private var isGameStarted:Boolean;
    private var displaysPosY:uint = 4;
    private var packageY:Number;
    public var chatPlayerMenu:PlayerMenu;
    public const closed:Signal = new Signal();
    public var isEditor:Boolean;
    public var mui_:MapUserInput;
    public var lastUpdate_:int;
    public var moveRecords_:MoveRecords;
    public var map:AbstractMap;
    public var model:PlayerModel;
    public var hudView:HUDView;
    public var camera_:Camera;
    public var gsc_:GameServerConnection;
    public var isSafeMap:Boolean;
    public var serverDisconnect:Boolean;
    public var damageCounter_:DamageCounterFrame;
    public var RankTooltip:Signal;
    public var mail_:AccountMail;
    public var lootNotifications_:LootNotifications;
    private var clockSprite_:Bitmap;
    private var gameTime:int;
    private var weather_:Sprite;

    public function GameSprite(_arg1:Server, _arg2:int, _arg3:Boolean, _arg4:int, _arg5:int, _arg6:ByteArray, _arg7:PlayerModel, _arg8:String) {
        RankTooltip = new Signal(Sprite);
        this.moveRecords_ = new MoveRecords();
        this.camera_ = new Camera();
        super();
        this.model = _arg7;
        map = new Map(this);
        addChild(map);
        initializeWeather();
        this.gsc_ = GameServerConnection.instance != null ? GameServerConnection.instance : new GameServerConnection(_arg1);
        this.gsc_.updateServer(_arg1);
        this.gsc_.update(this, _arg2, _arg3, _arg4, _arg5, _arg6, _arg8);
        mui_ = new MapUserInput(this);
        this.chatBox_ = new Chat();
        this.chatBox_.list.addEventListener(MouseEvent.MOUSE_DOWN, this.onChatDown);
        this.chatBox_.list.addEventListener(MouseEvent.MOUSE_UP, this.onChatUp);
        addChild(this.chatBox_);
        this.idleWatcher_ = new IdleWatcher();
        this.lootNotifications_ = new LootNotifications();
    }

    private function initializeWeather():void
    {
        this.weather_ = new Sprite();
        this.weather_.mouseEnabled = false;
        this.weather_.mouseChildren = false;
        addChild(this.weather_);
    }

    public static function dispatchMapLoaded(_arg1:MapInfo):void {
        var _local2:MapLoadedSignal = StaticInjectorContext.getInjector().getInstance(MapLoadedSignal);
        ((_local2) && (_local2.dispatch(_arg1)));
    }

    private static function hidePreloader():void {
        var _local1:HideMapLoadingSignal = StaticInjectorContext.getInjector().getInstance(HideMapLoadingSignal);
        ((_local1) && (_local1.dispatch()));
    }

    public function onChatDown(_arg1:MouseEvent):void {
        if (this.chatPlayerMenu != null) {
            this.removeChatPlayerMenu();
        }
        mui_.onMouseDown(_arg1);
    }

    public function onChatUp(_arg1:MouseEvent):void {
        mui_.onMouseUp(_arg1);
    }

    public function setFocus(_arg1:GameObject):void {
        _arg1 = ((_arg1) || (map.player_));
        this.focus = _arg1;
    }

    public function addChatPlayerMenu(_arg1:Player, _arg2:Number, _arg3:Number, _arg4:String = null, _arg5:Boolean = false, _arg6:Boolean = false):void {
        this.removeChatPlayerMenu();
        this.chatPlayerMenu = new PlayerMenu();
        if (_arg4 == null) {
            this.chatPlayerMenu.init(this, _arg1);
        }
        else {
            if (_arg6) {
                this.chatPlayerMenu.initDifferentServer(this, _arg4, _arg5, _arg6);
            }
            else {
                if ((((_arg4.length > 0)) && ((((((_arg4.charAt(0) == "#")) || ((_arg4.charAt(0) == "*")))) || ((_arg4.charAt(0) == "@")))))) {
                    return;
                }
                this.chatPlayerMenu.initDifferentServer(this, _arg4, _arg5);
            }
        }
        addChild(this.chatPlayerMenu);
        this.chatPlayerMenu.x = _arg2;
        this.chatPlayerMenu.y = (_arg3 - this.chatPlayerMenu.height);
    }

    public function removeChatPlayerMenu():void {
        if (((!((this.chatPlayerMenu == null))) && (!((this.chatPlayerMenu.parent == null))))) {
            removeChild(this.chatPlayerMenu);
            this.chatPlayerMenu = null;
        }
    }

    public function applyMapInfo(_arg1:MapInfo):void {
        map.setProps(_arg1.width_, _arg1.height_, _arg1.name_, _arg1.background_, _arg1.allowPlayerTeleport_, _arg1.showDisplays_);
        dispatchMapLoaded(_arg1);
    }

    public function hudModelInitialized():void {
        addChild(hudView = new HUDView());
    }

    public function initialize():void
    {
        var _local_1:Account;
        map.initialize();
        this.modelInitialized.dispatch();
        this.miniMap = new MiniMapImp(232, 232);
        this.miniMap.x = WebMain.DefaultWidth - this.miniMap._width - 14;
        this.miniMap.y = 14;
        addChild(this.miniMap);
        drawPlayerStats();
        if (this.evalIsNotInCombatMapArea())
        {
            this.showSafeAreaDisplays();
        }
        if (map.name_ == "Tutorial")
        {
            Parameters.data_.needsTutorial = false;
            Parameters.save();
        }
        _local_1 = StaticInjectorContext.getInjector().getInstance(Account);
        this.lootNotifications_.x = WebMain.DefaultWidth / 2;
        this.lootNotifications_.y = 30;
        addChild(this.lootNotifications_);

        this.creditDisplay_ = new CreditDisplay(true);
        this.creditDisplay_.x = 190;
        this.rankText_ = new RankText(-1, true, false);
        this.rankText_.mouseEnabled = true;
        this.rankText_.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverRank);
        this.rankText_.addEventListener(MouseEvent.ROLL_OUT, this.onRollOutRank);
        this.rankText_.x = WebMain.DefaultWidth - 400;
        this.rankText_.y = 18;
        this.giftStatusDisplay = new GiftStatusDisplay();
        this.mailDisplay_ = new MailDisplay();
        this.mailDisplay_.addEventListener(MouseEvent.CLICK, this.onMailClick);
        addChild(this.creditDisplay_);
        addChild(this.rankText_);
        addChild(this.giftStatusDisplay);
        addChild(this.mailDisplay_);

        var _local_4:Object = {
            "game_net_user_id": _local_1.gameNetworkUserId(),
            "game_net": _local_1.gameNetwork(),
            "play_platform": _local_1.playPlatform()
        };
        MoreObjectUtil.addToObject(_local_4, _local_1.getCredentials());
        isSafeMap = this.evalIsNotInCombatMapArea();
        hidePreloader();
        stage.dispatchEvent(new Event(Event.RESIZE));
        if (parent.parent is Layers)
            parent.parent.setChildIndex((parent.parent as Layers).top, 2);
        else if (parent.parent.parent is Layers)
            parent.parent.parent.setChildIndex((parent.parent.parent as Layers).top, 2);
    }

    public function setMiniMapFocus(object:GameObject) : void {
        this.miniMap.setFocus(object);
    }

    private var _characterDetails:CharacterDetailsView = new CharacterDetailsView();
    public var _partyPanel:PartyPanel;

    private function drawPlayerStats():void {
        _partyPanel = new PartyPanel(this);
        addChild(_partyPanel);
        addChild(_characterDetails);
        _partyPanel.x = WebMain.DefaultWidth - 400;
        _characterDetails.x = WebMain.DefaultWidth - 400;
    }

    private function onMailClick(event:MouseEvent):void {
        this.mail_ = new AccountMail(this);
        addChild(this.mail_);
    }

    private function showSafeAreaDisplays():void {
        this.setYAndPositionPackage();
    }

    private function setYAndPositionPackage():void {
        this.packageY = (this.displaysPosY + 2);
        this.displaysPosY = (this.displaysPosY + UIUtils.NOTIFICATION_SPACE);
    }

    protected function onMouseOverRank(_arg1:MouseEvent):void {
        this.RankTooltip.dispatch(new RankToolTip(map.player_.numStars_, true));
    }

    protected function onRollOutRank(_arg1:MouseEvent):void {
        this.RankTooltip.dispatch(null);
    }

    private function callTracking(_arg1:String):void {
        if (!ExternalInterface.available) {
            return;
        }
        try {
            ExternalInterface.call(_arg1);
        }
        catch (err:Error) {
        }
    }

    private function updateNearestInteractive():void {
        var _local4:Number;
        var _local7:GameObject;
        var _local8:IInteractiveObject;
        if (((map == null) || (map.player_ == null))) {
            return;
        }
        var _local1:Player = map.player_;
        var _local2:Number = GeneralConstants.MAXIMUM_INTERACTION_DISTANCE;
        var _local3:IInteractiveObject;
        var _local5:Number = _local1.x_;
        var _local6:Number = _local1.y_;
        for each (_local7 in map.goDict_) {
            _local8 = (_local7 as IInteractiveObject);
            if (_local8) {
                if ((((Math.abs((_local5 - _local7.x_)) < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE)) || ((Math.abs((_local6 - _local7.y_)) < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE)))) {
                    _local4 = PointUtil.distanceXY(_local7.x_, _local7.y_, _local5, _local6);
                    if ((((_local4 < GeneralConstants.MAXIMUM_INTERACTION_DISTANCE)) && ((_local4 < _local2)))) {
                        _local2 = _local4;
                        _local3 = _local8;
                    }
                }
            }
        }
        this.mapModel.currentInteractiveTarget = _local3;
    }

    public function connect():void {
        if (!this.isGameStarted) {
            this.serverDisconnect = false;
            this.isGameStarted = true;
            Renderer.inGame = true;
            if (!this.gsc_.connected || this.isEditor)
                this.gsc_.connect();
            else this.gsc_.sendHello();
            this.idleWatcher_.start(this);
            lastUpdate_ = getTimer();
            stage.addEventListener(MoneyChangedEvent.MONEY_CHANGED, this.onMoneyChanged);
            stage.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
            if (parent.parent is Layers)
                parent.parent.setChildIndex((parent.parent as Layers).top, 0);
            else if (parent.parent.parent is Layers)
                parent.parent.parent.setChildIndex((parent.parent.parent as Layers).top, 0);

            if (Parameters.data_["mscale"] == undefined) Parameters.data_["mscale"] = "1.0";
            if (Parameters.data_["stageScale"] == undefined) Parameters.data_["stageScale"] = StageScaleMode.NO_SCALE;

            Parameters.save();

            stage.scaleMode = Parameters.data_["stageScale"];
            stage.addEventListener(Event.RESIZE, this.onScreenResize);
            stage.dispatchEvent(new Event(Event.RESIZE));

            LoopedProcess.addProcess(new LoopedCallback(100, this.updateNearestInteractive));
        }
    }

    public function disconnect():void {
        if (this.isGameStarted) {
            this.isGameStarted = false;
            Renderer.inGame = false;
            this.idleWatcher_.stop();
            if (this.serverDisconnect)
                this.gsc_.disconnect();
            stage.removeEventListener(MoneyChangedEvent.MONEY_CHANGED, this.onMoneyChanged);
            stage.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
            stage.removeEventListener(Event.RESIZE, this.onScreenResize);
            stage.scaleMode = StageScaleMode.EXACT_FIT;
            stage.dispatchEvent(new Event(Event.RESIZE));
            LoopedProcess.destroyAll();
            ((contains(map)) && (removeChild(map)));
            map.dispose();
            CachingColorTransformer.clear();
            TextureRedrawer.clearCache();
            Projectile.dispose();
        }
    }

    private function onScreenResize(arg:Event):void
    {
        var widthScale:Number = WebMain.DefaultWidth / stage.stageWidth;
        var heightScale:Number = WebMain.DefaultHeight / stage.stageHeight;
        var factor:Number = widthScale / heightScale;

        if (this.map != null)
        {
            this.map.scaleX = widthScale * Parameters.data_["mscale"];
            this.map.scaleY = heightScale * Parameters.data_["mscale"];
        }

        if (_partyPanel != null && contains(_partyPanel))
        {
            _partyPanel.scaleX = factor;
            _partyPanel.scaleY = 1;

            _partyPanel.x = WebMain.DefaultWidth - 178 * _partyPanel.scaleX;
        }

        if (_characterDetails != null)
        {
            _characterDetails.scaleX = factor;
            _characterDetails.scaleY = 1;

            _characterDetails.x = WebMain.DefaultWidth - 400 * _characterDetails.scaleX;
        }

        if (this.rankText_ != null)
        {
            this.rankText_.scaleX = factor;
            this.rankText_.scaleY = 1;

            this.rankText_.x = (WebMain.DefaultWidth - 600 * this.rankText_.scaleX) + 20 * this.rankText_.scaleX;
            this.rankText_.y = 18 * this.rankText_.scaleY;
        }

        if (this.giftStatusDisplay != null)
        {
            this.giftStatusDisplay.scaleX = factor;
            this.giftStatusDisplay.scaleY = 1;

            this.giftStatusDisplay.x = (WebMain.DefaultWidth - 266 * this.giftStatusDisplay.scaleX) + 15 * this.giftStatusDisplay.scaleX;
            this.giftStatusDisplay.y = 25 * this.giftStatusDisplay.scaleY;
        }

        if (this.mailDisplay_ != null)
        {
            this.mailDisplay_.scaleX = factor;
            this.mailDisplay_.scaleY = 1;

            this.mailDisplay_.x = (175 * this.mailDisplay_.scaleX) + 15 * this.mailDisplay_.scaleX;
            this.mailDisplay_.y = 120 * this.mailDisplay_.scaleY;
        }

        if (this.hudView != null)
        {
            this.hudView.scaleX = factor;
            this.hudView.scaleY = 1;
            this.hudView.x = WebMain.DefaultWidth - 288 * this.hudView.scaleX;
            this.hudView.y = 0;
        }

        if (this.creditDisplay_ != null && this.miniMap != null)
        {
            this.creditDisplay_.x = 14;
            this.creditDisplay_.y = 14;

            this.miniMap.scaleX = factor;
            this.miniMap.scaleY = 1;
            this.miniMap.x = WebMain.DefaultWidth - 14 - this.miniMap._width * this.miniMap.scaleX;
            this.miniMap.y = 14;
        }

        if (this.chatBox_ != null)
        {
            if (Parameters.data_.scaleChat)
            {
                this.chatBox_.scaleX = widthScale;
                this.chatBox_.scaleY = heightScale;
            }
            else
            {
                this.chatBox_.scaleX = factor;
                this.chatBox_.scaleY = 1;
            }

            this.chatBox_.y = (WebMain.DefaultHeight - 300) + 300 * (1 - this.chatBox_.scaleY);
        }

        if (this.creditDisplay_ != null)
        {
            this.creditDisplay_.scaleX = factor;
            this.creditDisplay_.scaleY = 1;
        }
    }

    private function onMoneyChanged(_arg1:Event):void {
        gsc_.checkCredits();
    }

    public function evalIsNotInCombatMapArea():Boolean {
        return map.name_ == Map.NEXUS || map.name_ == Map.VAULT || map.name_ == Map.GUILD_HALL ||
                map.name_ == Map.CLOTH_BAZAAR || map.name_ == Map.NEXUS_EXPLANATION || map.name_ == Map.DAILY_QUEST_ROOM ||
                map.name_ == Map.MARKETPLACE;
    }

    private function onEnterFrame(_arg1:Event):void {
        var _local2:int = getTimer();
        var _local3:int = (_local2 - lastUpdate_);
        if (this.idleWatcher_.update(_local3)) {
            closed.dispatch();
            return;
        }
        LoopedProcess.runProcesses(_local2);
        map.update(_local2, _local3);
        camera_.update(_local3);
        var player:Player = map.player_;
        if (this.focus) {
            camera_.configureCamera(this.focus, ((player) ? player.isHallucinating() : false));
            map.draw(camera_, _local2);
        }
        if (player != null) {
            hudView.tick(player);
            this.creditDisplay_.draw(player.credits_, player.fame_, player.unholyEssence_, player.divineEssence_);
            this.drawCharacterWindow.dispatch(player);
            this.rankText_.draw(player.numStars_, player.rank_, player.admin_, true);
            if (player.isPaused()) {
                hudView.filters = [PAUSED_FILTER];
                map.mouseEnabled = false;
                map.mouseChildren = false;
                hudView.mouseEnabled = false;
                hudView.mouseChildren = false;
            }
            else {
                if (hudView.filters.length > 0) {
                    hudView.filters = [];
                    map.mouseEnabled = true;
                    map.mouseChildren = true;
                    hudView.mouseEnabled = true;
                    hudView.mouseChildren = true;
                }
            }
            moveRecords_.addRecord(_local2, player.x_, player.y_);
            _partyPanel.draw();
            _partyPanel.visible = this.hudView.tradePanel == null;
        }
        lastUpdate_ = _local2;
    }

    public function drawDamageCounter(go:GameObject):void {
        if (((this.damageCounter_) && (this.damageCounter_.parent))) {
            this.damageCounter_.update(go);
            return;
        }
        this.damageCounter_ = new DamageCounterFrame(go);
        this.repositionDamageCounter();
        addChild(this.damageCounter_);
    }

    public function repositionDamageCounter():void {
        this.damageCounter_.x = (((WebMain.DefaultWidth) / 2) - (this.damageCounter_.width / 2));
        this.damageCounter_.y = 10;
    }

    public function removeDamageCounter():void {
        if (((this.damageCounter_) && (this.damageCounter_.parent))) {
            this.damageCounter_.parent.removeChild(this.damageCounter_);
        }
        this.damageCounter_ = null;
    }

    public function showClock(hour:int):void
    {
        this.clockSprite_ = new Bitmap(Utils.getClock(hour));
        this.clockSprite_.alpha = 0;
        this.clockSprite_.x = WebMain.DefaultWidth / 2 - this.clockSprite_.width / 2;
        this.clockSprite_.y = 20;
        addChild(this.clockSprite_);
        new GTween(this.clockSprite_, 0.5, {
            "alpha": 1
        }).onComplete = function ():void
        {
            var tween:GTween = new GTween(clockSprite_, 0.5, {
                "alpha":0
            });
            tween.delay = 1;
            tween.onComplete = complete;
            tween.init();
        };
        var complete:Function = function ():void
        {
            removeChild(clockSprite_);
            clockSprite_ = null;
        }
    }

    public function set gameTime_(hour:int):void {
        this.gameTime = hour;
    }

    public function get gameTime_():int {
        return this.gameTime;
    }

    public function drawOverlay(hour:int):void
    {
        if (hour > 6 && hour < 18)
        {
            return;
        }
        this.weather_.graphics.clear();
        var color:uint = 0x000080; // dark blue
        this.weather_.graphics.beginFill(color, 0.25);
        this.weather_.graphics.drawRect(0, 0, WebMain.DefaultWidth, WebMain.DefaultHeight);
        this.weather_.graphics.endFill();
    }

}
}