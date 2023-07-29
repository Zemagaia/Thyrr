package {

import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.game.events.KeyInfoResponseSignal;
import com.company.assembleegameclient.map.AbstractMap;
import com.company.assembleegameclient.mapeditor.MapEditor;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.screens.AccountLoadingScreen;
import com.company.assembleegameclient.screens.CharacterSelectionScreen;
import com.company.assembleegameclient.screens.LoadingScreen;
import com.company.assembleegameclient.ui.panels.PortalPanel;
import com.company.assembleegameclient.util.StageProxy;
import com.company.assembleegameclient.util.offer.Offer;

import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.net.Socket;

import kabam.lib.json.JsonParser;
import kabam.lib.json.SoftwareJsonParser;
import kabam.lib.net.impl.MessageCenter;
import kabam.lib.net.impl.SocketServer;
import kabam.lib.net.impl.SocketServerModel;
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.BuyCharacterSlot;
import kabam.rotmg.account.core.commands.PurchaseGold;
import kabam.rotmg.account.core.commands.VerifyAge;
import kabam.rotmg.account.core.model.JSInitializedModel;
import kabam.rotmg.account.core.model.MoneyConfig;
import kabam.rotmg.account.core.model.OfferModel;
import kabam.rotmg.account.web.WebAccount;
import kabam.rotmg.account.web.commands.Login;
import kabam.rotmg.account.web.commands.Logout;
import kabam.rotmg.account.web.commands.WebChangePassword;
import kabam.rotmg.account.web.commands.WebRegisterAccount;
import kabam.rotmg.account.web.commands.SendPasswordReminder;
import kabam.rotmg.account.web.model.AccountData;
import kabam.rotmg.account.web.model.ChangePasswordData;
import kabam.rotmg.account.web.view.WebAccountDetailDialog;
import kabam.rotmg.account.web.view.WebRegisterDialog;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.appengine.api.RetryLoader;
import kabam.rotmg.application.api.ApplicationSetup;
import kabam.rotmg.application.impl.FixedIPSetup;
import kabam.rotmg.application.impl.LocalhostSetup;
import kabam.rotmg.application.impl.NillysRealmSetup;
import kabam.rotmg.application.impl.NillysRealmTestSetup;
import kabam.rotmg.application.impl.PrivateSetup;
import kabam.rotmg.application.impl.ProductionSetup;
import kabam.rotmg.application.impl.Testing2Setup;
import kabam.rotmg.application.impl.TestingSetup;
import kabam.rotmg.application.model.DomainModel;
import kabam.rotmg.application.model.PlatformModel;
import kabam.rotmg.build.api.BuildData;
import kabam.rotmg.build.api.BuildEnvironment;
import kabam.rotmg.build.impl.BuildEnvironments;
import kabam.rotmg.characters.deletion.control.DeleteCharacter;
import kabam.rotmg.characters.model.CharacterModel;
import kabam.rotmg.characters.reskin.control.OpenReskinDialog;
import kabam.rotmg.characters.reskin.control.ReskinCharacter;
import kabam.rotmg.chat.control.AddTextLine;
import kabam.rotmg.chat.control.ParseChatMessage;
import kabam.rotmg.chat.control.SpamFilter;
import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.chat.model.ChatModel;
import kabam.rotmg.chat.model.ChatShortcutModel;
import kabam.rotmg.chat.model.TellModel;
import kabam.rotmg.chat.view.Chat;
import kabam.rotmg.chat.view.ChatInput;
import kabam.rotmg.chat.view.ChatListItemFactory;
import kabam.rotmg.classes.control.BuyCharacterSkin;
import kabam.rotmg.classes.control.ParseCharListData;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.classes.view.CharacterSkinListItemFactory;
import kabam.rotmg.core.commands.AppInitDataReceived;
import kabam.rotmg.core.commands.SetScreenWithValidData;
import kabam.rotmg.core.model.MapModel;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.core.model.ScreenModel;
import kabam.rotmg.core.signals.TaskErrorSignal;
import kabam.rotmg.core.view.Layers;
import kabam.rotmg.death.control.HandleDeath;
import kabam.rotmg.death.control.HandleNormalDeath;
import kabam.rotmg.death.model.DeathModel;
import kabam.rotmg.editor.model.SearchModel;
import kabam.rotmg.editor.model.TextureData;
import kabam.rotmg.editor.view.TextureView;
import kabam.rotmg.errors.LogError;
import kabam.rotmg.errors.ReportErrorToAppEngine;
import kabam.rotmg.external.command.RequestPlayerCredits;
import kabam.rotmg.external.service.ExternalServiceHelper;
import kabam.rotmg.fame.model.FameModel;
import kabam.rotmg.fame.model.FameVO;
import kabam.rotmg.fame.view.FameView;
import kabam.rotmg.game.commands.PlayGame;
import kabam.rotmg.game.commands.TransitionFromGameToMenu;
import kabam.rotmg.game.commands.UseBuyPotion;
import kabam.rotmg.game.model.AddSpeechBalloonVO;
import kabam.rotmg.game.model.ChatFilter;
import kabam.rotmg.game.model.GameInitData;
import kabam.rotmg.game.model.GameModel;
import kabam.rotmg.game.model.PotionInventoryModel;
import kabam.rotmg.game.model.TextPanelData;
import kabam.rotmg.game.model.UseBuyPotionVO;
import kabam.rotmg.game.view.NameChangerPanel;
import kabam.rotmg.game.view.components.Stats;
import kabam.rotmg.language.DebugTextAndMapProvider;
import kabam.rotmg.language.control.ReloadCurrentScreen;
import kabam.rotmg.language.control.SetLanguage;
import kabam.rotmg.language.model.CookieLanguageModel;
import kabam.rotmg.language.model.DebugStringMap;
import kabam.rotmg.language.model.LanguageModel;
import kabam.rotmg.language.model.StringMap;
import kabam.rotmg.language.model.StringMapConcrete;
import kabam.rotmg.legends.control.ExitLegends;
import kabam.rotmg.legends.control.RequestFameList;
import kabam.rotmg.legends.model.LegendFactory;
import kabam.rotmg.legends.model.LegendsModel;
import kabam.rotmg.legends.model.Timespan;
import kabam.rotmg.legends.view.LegendsView;
import kabam.rotmg.maploading.commands.CharacterAnimationFactory;
import kabam.rotmg.maploading.view.MapLoading;
import kabam.rotmg.messaging.impl.incoming.Death;
import kabam.rotmg.messaging.impl.incoming.MapInfo;
import kabam.rotmg.minimap.model.UpdateGroundTileVO;
import kabam.rotmg.queue.view.Queue;
import kabam.rotmg.servers.api.ServerModel;
import kabam.rotmg.servers.model.FixedIPServerModel;
import kabam.rotmg.servers.model.LiveServerModel;
import kabam.rotmg.servers.model.LocalhostServerModel;
import kabam.rotmg.stage3D.Render3D;
import kabam.rotmg.stage3D.Renderer;
import kabam.rotmg.stage3D.graphic3D.Graphic3D;
import kabam.rotmg.stage3D.graphic3D.TextureFactory;
import kabam.rotmg.stage3D.proxies.Context3DProxy;
import kabam.rotmg.stage3D.proxies.IndexBuffer3DProxy;
import kabam.rotmg.stage3D.proxies.VertexBuffer3DProxy;
import kabam.rotmg.startup.control.StartupSequence;
import kabam.rotmg.text.model.FontModel;
import kabam.rotmg.text.model.TextAndMapProvider;
import kabam.rotmg.text.view.BitmapTextFactory;
import kabam.rotmg.ui.commands.ChooseName;
import kabam.rotmg.ui.commands.EnterGame;
import kabam.rotmg.ui.model.HUDModel;
import kabam.rotmg.ui.model.TabStripModel;
import kabam.rotmg.ui.model.UpdateGameObjectTileVO;
import kabam.rotmg.ui.noservers.NoServersDialogFactory;
import kabam.rotmg.ui.noservers.ProductionNoServersDialogFactory;
import kabam.rotmg.ui.noservers.TestingNoServersDialogFactory;
import kabam.rotmg.ui.view.TitleView;

import thyrr.assets.CharacterFactory;
import thyrr.assets.IconFactory;

public class Global
{
    public static const StoredData:Object = {};

    public static var loaderInfo:LoaderInfo;
    public static var stageProxy:StageProxy;
    public static var account:Account;
    public static var buildData:BuildData;
    public static var platformModel:PlatformModel;
    public static var domainModel:DomainModel;
    public static var playerModel:PlayerModel;
    public static var gameModel:GameModel;
    public static var potionInventoryModel:PotionInventoryModel;
    public static var hudModel:HUDModel;
    public static var tellModel:TellModel;
    public static var chatModel:ChatModel;
    public static var fontModel:FontModel;
    public static var languageModel:LanguageModel;
    public static var chatShortcutModel:ChatShortcutModel;
    public static var classesModel:ClassesModel;
    public static var serverModel:ServerModel;
    public static var screenModel:ScreenModel;
    public static var iconFactory:IconFactory;
    public static var jsonParser:JsonParser;
    public static var buildEnvironments:BuildEnvironments;
    public static var applicationSetup:ApplicationSetup;
    public static var retryLoader:RetryLoader;
    public static var appEngine:AppEngineClient;
    public static var externalServiceHelper:ExternalServiceHelper;
    public static var spamFilter:SpamFilter;
    public static var stringMap:StringMap;
    public static var debugStringMap:DebugStringMap;
    public static var textAndMapProvider:TextAndMapProvider;
    public static var bitmapTextFactory:BitmapTextFactory;
    public static var chatListItemFactory:ChatListItemFactory;
    public static var taskErrorSignal:TaskErrorSignal;
    public static var loadingScreen:LoadingScreen;
    public static var taskMonitor:TaskMonitor;
    public static var startupSequence:StartupSequence;
    public static var deathModel:DeathModel;
    public static var fameModel:FameModel;
    public static var characterFactory:CharacterFactory;
    public static var socketServerModel:SocketServerModel;
    public static var jsInitializedModel:JSInitializedModel;
    public static var moneyConfig:MoneyConfig;
    public static var characterAnimationFactory:CharacterAnimationFactory;
    public static var tabStripModel:TabStripModel;
    public static var characterModel:CharacterModel;
    public static var offerModel:OfferModel;
    public static var characterSkinListItemFactory:CharacterSkinListItemFactory;
    public static var mapModel:MapModel;
    public static var searchModel:SearchModel;
    public static var legendFactory:LegendFactory;
    public static var legendsModel:LegendsModel;
    public static var socket:Socket;
    public static var messageCenter:MessageCenter;
    public static var socketServer:SocketServer;
    public static var chatFilter:ChatFilter;
    public static var noServersDialogFactory:NoServersDialogFactory;
    public static var textPanelData:TextPanelData;

    // not set on init function
    private static var appInitDataReceived:AppInitDataReceived;
    public static var accountData:AccountData;
    public static var changePasswordData:ChangePasswordData;
    private static var parseChatMessage_:ParseChatMessage;
    private static var addTextLine_:AddTextLine;
    private static var useBuyPotion_:UseBuyPotion;
    public static var layers:Layers;
    private static var reportErrorToAppengine:ReportErrorToAppEngine;
    private static var reportErrorRegular:LogError;
    private static var mapLoading:MapLoading;
    private static var queue:Queue;
    public static var portalPanel:PortalPanel;
    public static var context3DProxy:Context3DProxy;
    public static var indexBuffer3DProxy:IndexBuffer3DProxy;
    public static var vertexBuffer3DProxy:VertexBuffer3DProxy;
    public static var textureFactory:TextureFactory;
    public static var graphic3D:Graphic3D;
    public static var render3D:Render3D;
    public static var renderer:Renderer;
    public static var textureView:TextureView;
    public static var legendsView:LegendsView;
    public static var nameChangerPanel:NameChangerPanel;
    public static var characterSelectionScreen:CharacterSelectionScreen;
    public static var keyInfoResponse:KeyInfoResponseSignal;
    public static var mapEditor:MapEditor;
    private static var transitionFromGameToMenu:TransitionFromGameToMenu;
    public static var chatInput:ChatInput;
    public static var chat:Chat;

    public static function init(_loaderInfo:LoaderInfo, _stageProxy:StageProxy):void
    {
        loaderInfo = _loaderInfo;
        stageProxy = _stageProxy;
        account = new WebAccount();
        buildData = new BuildData();
        platformModel = new PlatformModel();
        domainModel = new DomainModel();
        playerModel = new PlayerModel();
        gameModel = new GameModel();
        potionInventoryModel = new PotionInventoryModel();
        hudModel = new HUDModel();
        tellModel = new TellModel();
        chatModel = new ChatModel();
        fontModel = new FontModel();
        languageModel = new CookieLanguageModel();
        chatShortcutModel = new ChatShortcutModel();
        classesModel = new ClassesModel();
        serverModel = makeServerModel();
        screenModel = new ScreenModel();
        iconFactory = new IconFactory();
        jsonParser = new SoftwareJsonParser();
        buildEnvironments = new BuildEnvironments();
        applicationSetup = makeApplicationSetup();
        retryLoader = new RetryLoader();
        appEngine = new AppEngineClient();
        externalServiceHelper = new ExternalServiceHelper();
        spamFilter = new SpamFilter();
        stringMap = new StringMapConcrete();
        debugStringMap = new DebugStringMap();
        textAndMapProvider = new DebugTextAndMapProvider();
        bitmapTextFactory = new BitmapTextFactory(fontModel, textAndMapProvider);
        chatListItemFactory = new ChatListItemFactory();
        taskErrorSignal = new TaskErrorSignal();
        loadingScreen = new LoadingScreen();
        taskMonitor = new TaskMonitor();
        startupSequence = new StartupSequence();
        deathModel = new DeathModel();
        fameModel = new FameModel();
        characterFactory = new CharacterFactory();
        socketServerModel = new SocketServerModel();
        jsInitializedModel = new JSInitializedModel();
        moneyConfig = new MoneyConfig();
        characterAnimationFactory = new CharacterAnimationFactory();
        tabStripModel = new TabStripModel();
        characterModel = new CharacterModel();
        offerModel = new OfferModel();
        characterSkinListItemFactory = new CharacterSkinListItemFactory();
        mapModel = new MapModel();
        searchModel = new SearchModel();
        legendFactory = new LegendFactory();
        legendsModel = new LegendsModel();
        socket = new Socket();
        messageCenter = new MessageCenter();
        socketServer = new SocketServer();
        chatFilter = new ChatFilter();
        noServersDialogFactory = makeNoServersDialogFactory();
        textPanelData = new TextPanelData();
        keyInfoResponse = new KeyInfoResponseSignal();
    }

    public static function setupLayers():void
    {
        layers = new Layers();
    }

    private static function makeNoServersDialogFactory():NoServersDialogFactory {
        if (applicationSetup.useProductionDialogs()) {
            return new ProductionNoServersDialogFactory();
        }
        else {
            return new TestingNoServersDialogFactory();
        }
    }

    private static function makeApplicationSetup():ApplicationSetup
    {
        var env:BuildEnvironment = buildData.getEnvironment();
        switch (env)
        {
            case BuildEnvironment.LOCALHOST:
                return new LocalhostSetup();
            case BuildEnvironment.FIXED_IP:
                return new FixedIPSetup().setAddress(buildData.getEnvironmentString());
            case BuildEnvironment.PRIVATE:
                return new PrivateSetup();
            case BuildEnvironment.TESTING:
                return new TestingSetup();
            case BuildEnvironment.TESTING2:
                return new Testing2Setup();
            case BuildEnvironment.NILLYSREALM:
                return new NillysRealmSetup();
            case BuildEnvironment.NILLYSREALMTEST:
                return new NillysRealmTestSetup();
            default:
                return new ProductionSetup();
        }
    }

    public static function makeServerModel():ServerModel
    {
        var environment:BuildEnvironment = buildData.getEnvironment();
        switch (environment)
        {
            case BuildEnvironment.FIXED_IP:
                 return makeFixedIPServerModel();
            case BuildEnvironment.LOCALHOST:
            case BuildEnvironment.PRIVATE:
                return new LocalhostServerModel();
            default:
                return new LiveServerModel();
        }
    }

    private static function makeFixedIPServerModel():FixedIPServerModel {
        return new FixedIPServerModel().setIP(buildData.getEnvironmentString());
    }

    public static function storeData(key:String, value:*):void
    {
        StoredData[key] = value;
    }

    public static function deleteStoredData(key:String):void
    {
        StoredData[key] = null;
    }

    public static function setupDomainSecurity():void
    {
        if (platformModel.isWeb())
            domainModel.applyDomainSecurity();
    }

    public static function mapExternalCallbacks():void
    {
        externalServiceHelper.mapExternalCallbacks();
    }

    public static function requestPlayerCredits():void
    {
        new RequestPlayerCredits();
    }

    public static function showLoadingUI():void
    {
        setScreen(new AccountLoadingScreen());
    }

    public static function showTitleUI():void
    {
        setScreen(new TitleView());
    }

    public static function setScreen(s:Sprite):void
    {
        layers.menu.setScreen(s);
    }

    public static function onAppInitDataReceived(data:XML):void
    {
        appInitDataReceived = new AppInitDataReceived(data);
    }

    public static function openMoneyWindow():void
    {
        appInitDataReceived.openMoneyWindow();
    }

    public static function setupChat():void
    {
        chatInput = new ChatInput();
        chat = new Chat();
    }

    public static function openDialog(s:Sprite):void
    {
        if (chat != null)
            chat.onOpenDialog(s);
        layers.dialogs.onOpenDialog(s);
    }

    public static function closeDialogs():void
    {
        if (chat != null)
            chat.onCloseDialog();
        layers.dialogs.onCloseDialog();
    }

    public static function openDialogNoModal(s:Sprite):void
    {
        layers.dialogs.onOpenDialogNoModal(s);
    }

    public static function register(data:AccountData):void
    {
        accountData = data;
        new WebRegisterAccount();
    }

    public static function changePassword(data:ChangePasswordData):void
    {
        changePasswordData = data;
        new WebChangePassword();
    }

    public static function chatScrollList(direction:int):void
    {
        chat.list.onScrollList(direction);
    }

    public static function onAddChat(msg:ChatMessage):void
    {
        chat.list.onAddChat(msg);
    }

    public static function onShowChatInput(focus:Boolean, ignored:String):void
    {
        chat.onShowChatInput(focus, ignored);
        chat.list.onShowChatInput(focus, ignored);
        chatInput.onShowChatInput(focus, ignored);
    }

    public static function parseChatMessage(msg:String):void
    {
        if (parseChatMessage_ == null)
            parseChatMessage_ = new ParseChatMessage();
        parseChatMessage_.execute(msg);
    }

    public static function addTextLine(msg:ChatMessage):void
    {
        if (addTextLine_ == null)
            addTextLine_ = new AddTextLine();
        addTextLine_.execute(msg);
    }

    public static function onCharListData(data:XML):void
    {
        new ParseCharListData(data);
    }

    public static function useBuyPotion(vo:UseBuyPotionVO):void
    {
        if (useBuyPotion_ == null)
            useBuyPotion_ = new UseBuyPotion();
        useBuyPotion_.execute(vo);
    }

    public static function gotoPreviousScreen():void
    {
        layers.menu.onGotoPrevious();
    }

    public static function showTooltip(toolTip:Sprite):void
    {
        layers.tooltips.showTooltip(toolTip);
    }

    public static function hideTooltip():void
    {
        layers.tooltips.hideTooltip();
    }

    public static function handleDeath(death:Death):void
    {
        new HandleDeath(death);
    }

    public static function handleNormalDeath(death:Death):void
    {
        new HandleNormalDeath(death);
    }

    public static function showFameView(vo:FameVO):void
    {
        fameModel.accountId = vo.getAccountId();
        fameModel.characterId = vo.getCharacterId();
        Global.setScreen(new FameView());
    }

    public static function playGame(data:GameInitData):void
    {
        new PlayGame(data);
    }

    public static function buyCharacterSkin(skin:CharacterSkin):void
    {
        new BuyCharacterSkin(skin);
    }

    public static function buyCharacterSlot(price:int):void
    {
        new BuyCharacterSlot(price);
    }

    public static function reloadCurrentScreen():void
    {
        new ReloadCurrentScreen();
    }

    public static function invalidateData():void
    {
        playerModel.isInvalidated = true;
        jsInitializedModel.isInitialized = false;
    }

    public static function setLanguage(lang:String):void
    {
        new SetLanguage(lang);
    }

    public static function logError(error:ErrorEvent):void
    {
        if (applicationSetup.areErrorsReported())
        {
            if (reportErrorToAppengine == null)
                    reportErrorToAppengine = new ReportErrorToAppEngine();
            reportErrorToAppengine.execute(error);
        }
        else
        {
            if (reportErrorRegular == null)
                reportErrorRegular = new LogError();
            reportErrorRegular.execute(error);
        }
    }

    public static function showQueue():void
    {
        queue = new Queue();
        layers.top.addChild(queue);
    }

    public static function updateQueue(pos:int, count:int):void
    {
        if (queue != null)
            queue.onUpdate(pos, count);
    }

    public static function hideMapLoading():void
    {
        if (queue != null)
            queue.onHide();
        mapLoading.onHide();
    }

    public static function showMapLoading():void
    {
        mapLoading = new MapLoading();
        layers.top.addChild(mapLoading);
    }

    public static function mapLoaded(info:MapInfo):void
    {
        mapLoading.onMapLoaded(info);
    }

    public static function setScreenWithValidData(view:Sprite):void
    {
        new SetScreenWithValidData(view);
    }

    public static function onTransitionFromGameToMenu():void
    {
        if (transitionFromGameToMenu == null)
            transitionFromGameToMenu = new TransitionFromGameToMenu();
        transitionFromGameToMenu.execute();
    }

    public static function exitGame():void
    {
        tellModel.clearRecipients();
    }

    public static function setPortalPanel(panel:PortalPanel):void
    {
        portalPanel = panel;
    }

    public static function setGameFocus(name:String):void
    {
        hudModel.gameSprite.setFocus(name);
        hudModel.gameSprite.miniMap.setFocus(name);
    }

    public static function setGameFocusDirect(go:GameObject):void
    {
        hudModel.gameSprite.setFocusDirect(go);
        hudModel.gameSprite.miniMap.setFocusDirect(go);
    }

    public static function miniMapZoom(zoom:String):void
    {
        hudModel.gameSprite.miniMap.onMiniMapZoom(zoom);
    }

    public static function updateGameObjectTile(vo:UpdateGameObjectTileVO):void
    {
        hudModel.gameSprite.miniMap.onUpdateGameObjectTile(vo);
    }

    public static function updateGroundTile(vo:UpdateGroundTileVO):void
    {
        if (hudModel.gameSprite.miniMap == null) return;
        hudModel.gameSprite.miniMap.onUpdateGroundTile(vo);
    }

    public static function updateBackpackTab(hasBackpack:Boolean):void
    {
        if (!hasBackpack || hudModel.gameSprite.hud.tabStrip == null) return;
        hudModel.gameSprite.hud.tabStrip.clearTabs();
        hudModel.gameSprite.hud.tabStrip.addTabs(hudModel.gameSprite.map.player_);
    }

    public static function switchTab():void
    {
        if (hudModel.gameSprite.hud.tabStrip == null) return;
        hudModel.gameSprite.hud.tabStrip.onTabHotkey();
    }

    public static function setContext3DProxy(c3d:Context3DProxy):void
    {
        context3DProxy = c3d;
        indexBuffer3DProxy = c3d.createIndexBuffer(6);
        vertexBuffer3DProxy = c3d.createVertexBuffer(4, 5);
        vertexBuffer3DProxy.uploadFromVector(Vector.<Number>([-0.5, 0.5, 0, 0, 0, 0.5, 0.5, 0, 1, 0, -0.5, -0.5, 0, 0, 1, 0.5, -0.5, 0, 1, 1]), 0, 4);
        textureFactory = new TextureFactory();
        graphic3D = new Graphic3D();
        render3D = new Render3D();
        renderer = new Renderer(render3D);
    }

    public static function purchaseGold(offer:Offer, paymentMethod:String):void
    {
        new PurchaseGold(offer, paymentMethod);
    }

    public static function verifyAge():void
    {
        new VerifyAge();
    }

    public static function openAccountInfo():void
    {
        if (account.isRegistered())
            openDialog(new WebAccountDetailDialog());
        else
            openDialog(new WebRegisterDialog());
    }

    public static function login(accountData:AccountData):void
    {
        new Login(accountData);
    }

    public static function sendPasswordReminder(email:String):void
    {
        new SendPasswordReminder(email);
    }

    public static function logout():void
    {
        new Logout();
    }

    public static function deleteCharacter(savedCharacter:SavedCharacter):void
    {
        new DeleteCharacter(savedCharacter);
    }

    public static function openReskinDialog():void
    {
        new OpenReskinDialog();
    }

    public static function setTextureView():void
    {
        textureView = new TextureView();
    }

    public static function setTexture(td:TextureData):void
    {
        if (textureView == null) return;
        textureView.onSetTexture(td);
    }

    public static function setLegendsView():void
    {
        legendsView = new LegendsView();
    }

    public static function fameListUpdate(span:Timespan = null):void
    {
        if (legendsView == null) return;
        legendsView.updateLegendList(span);
    }

    public static function exitLegends():void
    {
        new ExitLegends();
    }

    public static function requestFameList(span:Timespan):void
    {
        new RequestFameList(span);
    }

    public static function reskinCharacter(skin:CharacterSkin):void
    {
        new ReskinCharacter(skin);
    }

    public static function addSpeechBalloon(vo:AddSpeechBalloonVO):void
    {
        var map:AbstractMap = hudModel.gameSprite.map;
        if (map == null || map.mapOverlay_ == null) return;
        map.mapOverlay_.onAddSpeechBalloon(vo);
    }

    public static function initHud(gs:GameSprite):void
    {
        hudModel.gameSprite = gs;
        hudModel.gameSprite.hudModelInitialized();
    }

    public static function setNameChangerPanel(panel:NameChangerPanel):void
    {
        nameChangerPanel = panel;
    }

    public static function changeName(name:String):void
    {
        if (nameChangerPanel != null)
            nameChangerPanel.onNameChanged(name);
        if (characterSelectionScreen != null)
            characterSelectionScreen.setName(name);
    }

    public static function setCharacterSelectionScreen(screen:CharacterSelectionScreen):void
    {
        characterSelectionScreen = screen;
    }

    public static function chooseName():void
    {
        new ChooseName();
    }

    public static function enterGame():void
    {
        new EnterGame();
    }

    public static function textPanelUpdate(message:String):void
    {
        textPanelData.message = message;
    }

    public static function updateMail():void
    {
        storeData("mailCount", true);
    }

    public static function updateGift(hasGift:Boolean):void
    {
        storeData("hasGift", hasGift);
    }

    public static function setMapEditor(editor:MapEditor):void
    {
        mapEditor = editor;
    }

    public static function closeEditor():void
    {
        if (mapEditor == null) return;
        mapEditor.onMapTestDone(null);
    }

    public static function updateHUD(player:Player):void
    {
        if (hudModel.gameSprite.hud == null) return;
        hudModel.gameSprite.miniMap.initialize(player);
        hudModel.gameSprite.hud.onInitializeHUD(player);
        hudModel.gameSprite.hud.draw();
        hudModel.gameSprite.hud.cdTimer.update(player);
        hudModel.gameSprite.hud.potions.update(player);
        hudModel.gameSprite.miniMap.draw();
        if (hudModel.gameSprite.hud.tabStrip == null) return;
        if (hudModel.gameSprite.hud.tabStrip.stats != null)
            hudModel.gameSprite.hud.tabStrip.stats.draw(player);
        hudModel.gameSprite.hud.tabStrip.addTabs(player);
        hudModel.gameSprite.hud.tabStrip.InventoryTab.inv.draw();
        if (hudModel.gameSprite.hud.tabStrip.BackpackTab != null)
            hudModel.gameSprite.hud.tabStrip.BackpackTab.inv.draw();
    }
}
}