package kabam.rotmg.messaging.impl {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.game.events.GuildResultEvent;
import com.company.assembleegameclient.game.events.KeyInfoResponseSignal;
import com.company.assembleegameclient.game.events.NameResultEvent;
import com.company.assembleegameclient.game.events.ReconnectEvent;
import com.company.assembleegameclient.map.AbstractMap;
import com.company.assembleegameclient.map.GroundLibrary;
import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
import com.company.assembleegameclient.objects.Container;
import com.company.assembleegameclient.objects.FlashDescription;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Merchant;
import com.company.assembleegameclient.objects.NameChanger;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.ObjectProperties;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.Portal;
import com.company.assembleegameclient.objects.Projectile;
import com.company.assembleegameclient.objects.ProjectileProperties;
import com.company.assembleegameclient.objects.SellableObject;
import com.company.assembleegameclient.objects.particles.AOEEffect;
import com.company.assembleegameclient.objects.particles.BurstEffect;
import com.company.assembleegameclient.objects.particles.CollapseEffect;
import com.company.assembleegameclient.objects.particles.ConeBlastEffect;
import com.company.assembleegameclient.objects.particles.FlowEffect;
import com.company.assembleegameclient.objects.particles.HealEffect;
import com.company.assembleegameclient.objects.particles.LightningEffect;
import com.company.assembleegameclient.objects.particles.LineEffect;
import com.company.assembleegameclient.objects.particles.NovaEffect;
import com.company.assembleegameclient.objects.particles.ParticleEffect;
import com.company.assembleegameclient.objects.particles.PoisonEffect;
import com.company.assembleegameclient.objects.particles.RingEffect;
import com.company.assembleegameclient.objects.particles.RisingFuryEffect;
import com.company.assembleegameclient.objects.particles.ShockeeEffect;
import com.company.assembleegameclient.objects.particles.ShockerEffect;
import com.company.assembleegameclient.objects.particles.StreamEffect;
import com.company.assembleegameclient.objects.particles.TeleportEffect;
import com.company.assembleegameclient.objects.particles.ThrowEffect;
import com.company.assembleegameclient.objects.thrown.ThrowProjectileEffect;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.sound.Music;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.company.assembleegameclient.ui.PicView;
import com.company.assembleegameclient.ui.dialogs.Dialog;
import com.company.assembleegameclient.ui.dialogs.NotEnoughFameDialog;
import com.company.assembleegameclient.ui.panels.GuildInvitePanel;
import com.company.assembleegameclient.ui.panels.TradeRequestPanel;
import com.company.assembleegameclient.util.ConditionEffect;
import com.company.assembleegameclient.util.Currency;
import com.company.assembleegameclient.util.FreeList;
import com.company.util.MoreStringUtil;
import com.company.util.Random;
import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.rsa.RSAKey;
import com.hurlant.crypto.symmetric.ICipher;
import com.hurlant.util.Base64;
import com.hurlant.util.der.PEM;

import flash.display.BitmapData;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.net.FileReference;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getTimer;

import kabam.lib.json.JsonParser;
import kabam.lib.net.impl.Message;
import kabam.lib.net.impl.MessageCenter;
import kabam.lib.net.impl.SocketServer;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.view.PurchaseConfirmationDialog;
import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.classes.model.CharacterClass;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.CharacterSkinState;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.game.model.GameModel;
import kabam.rotmg.game.model.PotionInventoryModel;
import kabam.rotmg.game.view.components.QueuedStatusText;
import kabam.rotmg.memMarket.signals.MemMarketAddSignal;
import kabam.rotmg.memMarket.signals.MemMarketBuySignal;
import kabam.rotmg.memMarket.signals.MemMarketMyOffersSignal;
import kabam.rotmg.memMarket.signals.MemMarketRemoveSignal;
import kabam.rotmg.memMarket.signals.MemMarketSearchSignal;
import kabam.rotmg.messaging.impl.data.GroundTileData;
import kabam.rotmg.messaging.impl.data.ObjectData;
import kabam.rotmg.messaging.impl.data.ObjectStatusData;
import kabam.rotmg.messaging.impl.data.StatData;
import kabam.rotmg.messaging.impl.incoming.AccountList;
import kabam.rotmg.messaging.impl.incoming.AllyShoot;
import kabam.rotmg.messaging.impl.incoming.Aoe;
import kabam.rotmg.messaging.impl.incoming.BuyResult;
import kabam.rotmg.messaging.impl.incoming.ClientStat;
import kabam.rotmg.messaging.impl.incoming.CreateSuccess;
import kabam.rotmg.messaging.impl.incoming.CurrentTime;
import kabam.rotmg.messaging.impl.incoming.Damage;
import kabam.rotmg.messaging.impl.incoming.Death;
import kabam.rotmg.messaging.impl.incoming.EnemyShoot;
import kabam.rotmg.messaging.impl.incoming.Failure;
import kabam.rotmg.messaging.impl.incoming.File;
import kabam.rotmg.messaging.impl.incoming.GlobalNotification;
import kabam.rotmg.messaging.impl.incoming.Goto;
import kabam.rotmg.messaging.impl.incoming.GuildResult;
import kabam.rotmg.messaging.impl.incoming.InvResult;
import kabam.rotmg.messaging.impl.incoming.InvitedToGuild;
import kabam.rotmg.messaging.impl.incoming.KeyInfoResponse;
import kabam.rotmg.messaging.impl.incoming.MapInfo;
import kabam.rotmg.messaging.impl.incoming.NameResult;
import kabam.rotmg.messaging.impl.incoming.NewTick;
import kabam.rotmg.messaging.impl.incoming.Notification;
import kabam.rotmg.messaging.impl.incoming.PasswordPrompt;
import kabam.rotmg.messaging.impl.incoming.Pic;
import kabam.rotmg.messaging.impl.incoming.Ping;
import kabam.rotmg.messaging.impl.incoming.PlaySound;
import kabam.rotmg.messaging.impl.incoming.QuestObjId;
import kabam.rotmg.messaging.impl.incoming.QueuePing;
import kabam.rotmg.messaging.impl.incoming.Reconnect;
import kabam.rotmg.messaging.impl.incoming.ReskinUnlock;
import kabam.rotmg.messaging.impl.incoming.ServerFull;
import kabam.rotmg.messaging.impl.incoming.ServerPlayerShoot;
import kabam.rotmg.messaging.impl.incoming.SetFocus;
import kabam.rotmg.messaging.impl.incoming.ShowEffect;
import kabam.rotmg.messaging.impl.incoming.SwitchMusic;
import kabam.rotmg.messaging.impl.incoming.TradeAccepted;
import kabam.rotmg.messaging.impl.incoming.TradeChanged;
import kabam.rotmg.messaging.impl.incoming.TradeDone;
import kabam.rotmg.messaging.impl.incoming.TradeRequested;
import kabam.rotmg.messaging.impl.incoming.TradeStart;
import kabam.rotmg.messaging.impl.incoming.Update;
import kabam.rotmg.messaging.impl.incoming.VerifyEmail;
import kabam.rotmg.messaging.impl.incoming.forge.CraftAnimation;
import kabam.rotmg.messaging.impl.incoming.mail.FetchMailResult;
import kabam.rotmg.messaging.impl.incoming.market.MarketAddResult;
import kabam.rotmg.messaging.impl.incoming.market.MarketBuyResult;
import kabam.rotmg.messaging.impl.incoming.market.MarketMyOffersResult;
import kabam.rotmg.messaging.impl.incoming.market.MarketRemoveResult;
import kabam.rotmg.messaging.impl.incoming.market.MarketSearchResult;
import kabam.rotmg.messaging.impl.incoming.pets.FetchPetsResult;
import kabam.rotmg.messaging.impl.incoming.quests.DeliverItemsResult;
import kabam.rotmg.messaging.impl.incoming.quests.FetchAccountQuestsResult;
import kabam.rotmg.messaging.impl.incoming.quests.FetchAvailableQuestsResult;
import kabam.rotmg.messaging.impl.incoming.quests.FetchCharacterQuestsResult;
import kabam.rotmg.messaging.impl.outgoing.AcceptTrade;
import kabam.rotmg.messaging.impl.outgoing.AoeAck;
import kabam.rotmg.messaging.impl.outgoing.Buy;
import kabam.rotmg.messaging.impl.outgoing.CancelTrade;
import kabam.rotmg.messaging.impl.outgoing.ChangeGuildRank;
import kabam.rotmg.messaging.impl.outgoing.ChangeTrade;
import kabam.rotmg.messaging.impl.outgoing.CheckCredits;
import kabam.rotmg.messaging.impl.outgoing.ChooseName;
import kabam.rotmg.messaging.impl.outgoing.Create;
import kabam.rotmg.messaging.impl.outgoing.CreateGuild;
import kabam.rotmg.messaging.impl.outgoing.EditAccountList;
import kabam.rotmg.messaging.impl.outgoing.EnemyHit;
import kabam.rotmg.messaging.impl.outgoing.Escape;
import kabam.rotmg.messaging.impl.outgoing.GoToQuestRoom;
import kabam.rotmg.messaging.impl.outgoing.GotoAck;
import kabam.rotmg.messaging.impl.outgoing.GuildInvite;
import kabam.rotmg.messaging.impl.outgoing.GuildRemove;
import kabam.rotmg.messaging.impl.outgoing.Hello;
import kabam.rotmg.messaging.impl.outgoing.InvDrop;
import kabam.rotmg.messaging.impl.outgoing.InvSwap;
import kabam.rotmg.messaging.impl.outgoing.JoinGuild;
import kabam.rotmg.messaging.impl.outgoing.KeyInfoRequest;
import kabam.rotmg.messaging.impl.outgoing.Load;
import kabam.rotmg.messaging.impl.outgoing.Move;
import kabam.rotmg.messaging.impl.outgoing.OtherHit;
import kabam.rotmg.messaging.impl.outgoing.PlayerHit;
import kabam.rotmg.messaging.impl.outgoing.PlayerShoot;
import kabam.rotmg.messaging.impl.outgoing.PlayerText;
import kabam.rotmg.messaging.impl.outgoing.Pong;
import kabam.rotmg.messaging.impl.outgoing.QueuePong;
import kabam.rotmg.messaging.impl.outgoing.RequestTrade;
import kabam.rotmg.messaging.impl.outgoing.Reskin;
import kabam.rotmg.messaging.impl.outgoing.SetCondition;
import kabam.rotmg.messaging.impl.outgoing.ShootAck;
import kabam.rotmg.messaging.impl.outgoing.SquareHit;
import kabam.rotmg.messaging.impl.outgoing.Teleport;
import kabam.rotmg.messaging.impl.outgoing.UseItem;
import kabam.rotmg.messaging.impl.outgoing.UsePortal;
import kabam.rotmg.messaging.impl.outgoing.forge.CraftItem;
import kabam.rotmg.messaging.impl.outgoing.mail.FetchMail;
import kabam.rotmg.messaging.impl.outgoing.market.MarketAdd;
import kabam.rotmg.messaging.impl.outgoing.market.MarketBuy;
import kabam.rotmg.messaging.impl.outgoing.market.MarketMyOffers;
import kabam.rotmg.messaging.impl.outgoing.market.MarketRemove;
import kabam.rotmg.messaging.impl.outgoing.market.MarketSearch;
import kabam.rotmg.messaging.impl.outgoing.pets.DeletePet;
import kabam.rotmg.messaging.impl.outgoing.pets.FetchPets;
import kabam.rotmg.messaging.impl.outgoing.pets.PetFollow;
import kabam.rotmg.messaging.impl.outgoing.quests.AcceptQuest;
import kabam.rotmg.messaging.impl.outgoing.quests.FetchAccountQuests;
import kabam.rotmg.messaging.impl.outgoing.quests.FetchAvailableQuests;
import kabam.rotmg.messaging.impl.outgoing.quests.FetchCharacterQuests;
import kabam.rotmg.messaging.impl.outgoing.skillTree.abilities.DefensiveAbility;
import kabam.rotmg.messaging.impl.outgoing.skillTree.abilities.OffensiveAbility;
import kabam.rotmg.minimap.model.UpdateGroundTileVO;
import kabam.rotmg.servers.api.Server;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.model.UpdateGameObjectTileVO;
import kabam.rotmg.ui.view.NotEnoughGoldDialog;
import kabam.rotmg.ui.view.TitleView;

import thyrr.forge.signals.CraftAnimationSignal;
import thyrr.mail.signals.FetchMailSignal;
import thyrr.pets.data.PetData;
import thyrr.pets.signals.FetchPetsSignal;
import thyrr.quests.signals.DeliverItemsSignal;
import thyrr.quests.signals.FetchAccountQuestsSignal;
import thyrr.quests.signals.FetchAvailableQuestsSignal;
import thyrr.quests.signals.FetchCharacterQuestsSignal;
import thyrr.utils.DamageTypes;
import thyrr.utils.ItemData;

public class GameServerConnection {

    private static const TO_MILLISECONDS:int = 1000;

    private var messages:MessageCenter;
    private var playerId_:int = -1;
    private var player:Player;
    private var retryConnection_:Boolean = true;
    private var rand_:Random = null;
    private var death:Death;
    private var retryTimer_:Timer;
    private var delayBeforeReconnect:int = 2;
    private var keyInfoResponse:KeyInfoResponseSignal;
    private var classesModel:ClassesModel;
    private var model:GameModel;

    public static const FAILURE:int = 0;
    public static const USEITEM:int = 1;
    public static const RESKIN_UNLOCK:int = 2;
    public static const ACCEPTTRADE:int = 3;
    public static const TRADECHANGED:int = 4;
    public static const USEPORTAL:int = 6;
    public static const HELLO:int = 9;
    public static const PLAYERHIT:int = 10;
    public static const CHANGEGUILDRANK:int = 11;
    public static const CREATE:int = 12;
    public static const SQUAREHIT:int = 13;
    public static const RECONNECT:int = 14;
    public static const RESKIN:int = 15;
    public static const MOVE:int = 16;
    public static const ARENA_DEATH:int = 17; // unused
    public static const INVDROP:int = 18;
    public static const ENEMYHIT:int = 19;
    public static const CHECKCREDITS:int = 20;
    public static const NAMERESULT:int = 22;
    public static const CHOOSENAME:int = 23;
    public static const GLOBAL_NOTIFICATION:int = 24;
    public static const INVSWAP:int = 25;
    public static const LOAD:int = 26;
    public static const JOINGUILD:int = 27;
    public static const QUESTOBJID:int = 28;
    public static const LOGIN_REWARD_MSG:int = 29; // unused
    public static const GOTO:int = 30;
    public static const TRADESTART:int = 31;
    public static const CLAIM_LOGIN_REWARD_MSG:int = 32; // unused
    public static const NOTIFICATION:int = 33;
    public static const REQUESTTRADE:int = 34;
    public static const SHOOTACK:int = 35;
    public static const ALLYSHOOT:int = 36;
    public static const SHOWEFFECT:int = 38;
    public static const CANCELTRADE:int = 39;
    public static const KEY_INFO_RESPONSE:int = 40;
    public static const GUILDINVITE:int = 41;
    public static const UPDATE:int = 42;
    public static const KEY_INFO_REQUEST:int = 43;
    public static const ACCOUNTLIST:int = 44;
    public static const TELEPORT:int = 45;
    public static const PIC:int = 46;
    public static const PLAYERTEXT:int = 47;
    public static const ENTER_ARENA:int = 48; // unused
    public static const GUILDREMOVE:int = 49;
    public static const BUYRESULT:int = 50;
    public static const ENEMYSHOOT:int = 52;
    public static const QUEST_ROOM_MSG:int = 54;
    public static const CHANGETRADE:int = 55;
    public static const FILE:int = 56;
    public static const OTHERHIT:int = 57;
    public static const INVITEDTOGUILD:int = 58;
    public static const PLAYSOUND:int = 59;
    public static const SETCONDITION:int = 60;
    public static const VERIFY_EMAIL:int = 61;
    public static const EDITACCOUNTLIST:int = 62;
    public static const INVRESULT:int = 63;
    public static const PONG:int = 64;
    public static const PLAYERSHOOT:int = 66;
    public static const NEWTICK:int = 68;
    public static const PASSWORD_PROMPT:int = 69;
    public static const PET_CHANGE_FORM_MSG:int = 70; // unused
    public static const SERVER_FULL:int = 71;
    public static const QUEUE_PING:int = 72;
    public static const QUEUE_PONG:int = 73;
    public static const MAPINFO:int = 74;
    public static const CLIENTSTAT:int = 75;
    public static const ACTIVEPETUPDATE:int = 76; // unused
    public static const AOEACK:int = 77;
    public static const TRADEACCEPTED:int = 78;
    public static const GOTOACK:int = 79;
    public static const TRADEREQUESTED:int = 80;
    public static const CREATE_SUCCESS:int = 81;
    public static const GUILDRESULT:int = 82;
    public static const DEATH:int = 83;
    public static const ACCEPT_ARENA_DEATH:int = 84; // unused
    public static const PING:int = 85;
    public static const HATCH_PET:int = 86; // unused
    public static const ESCAPE:int = 87;
    public static const AOE:int = 89;
    public static const ACTIVE_PET_UPDATE_REQUEST:int = 90; // unused
    public static const UPDATEACK:int = 91;
    public static const SERVERPLAYERSHOOT:int = 92;
    public static const BUY:int = 93;
    public static const TRADEDONE:int = 94;
    public static const CREATEGUILD:int = 95;
    public static const TEXT:int = 96;
    public static const DAMAGE:int = 97;
    public static const SET_FOCUS:int = 99;
    // 98 unused
    public static const SWITCH_MUSIC:int = 100;

    /* Market */
    public static const MARKET_SEARCH:int = 101;
    public static const MARKET_SEARCH_RESULT:int = 102;
    public static const MARKET_BUY:int = 103;
    public static const MARKET_BUY_RESULT:int = 104;
    public static const MARKET_ADD:int = 105;
    public static const MARKET_ADD_RESULT:int = 106;
    public static const MARKET_REMOVE:int = 107;
    public static const MARKET_REMOVE_RESULT:int = 108;
    public static const MARKET_MY_OFFERS:int = 109;
    public static const MARKET_MY_OFFERS_RESULT:int = 110;

    // Quests
    public static const FETCH_AVAILABLE_QUESTS:int = 111;
    public static const FETCH_AVAILABLE_QUESTS_RESULT:int = 112;
    public static const ACCEPT_QUEST:int = 113;
    public static const FETCH_CHARACTER_QUESTS:int = 114;
    public static const FETCH_CHARACTER_QUESTS_RESULT:int = 115;
    public static const DELIVER_ITEMS_RESULT:int = 116;

    // Mail
    public static const FETCH_MAIL:int = 117;
    public static const FETCH_MAIL_RESULT:int = 118;

    // Account Quests
    public static const FETCH_ACCOUNT_QUESTS:int = 119;
    public static const FETCH_ACCOUNT_QUESTS_RESULT:int = 37;

    //Forge
    public static const CRAFT_ITEM:int = 51;
    public static const CRAFT_ANIMATION:int = 7;

    // Skill Tree abilities
    public static const OFFENSIVE_ABILITY:int = 65;
    public static const DEFENSIVE_ABILITY:int = 88;

    // Pets
    public static const FETCH_PETS:int = 8;
    public static const FETCH_PETS_RESULT:int = 21;
    public static const DELETE_PET:int = 53;
    public static const PET_FOLLOW:int = 67;

    public static const CURRENT_TIME:int = 5;

    public static var instance:GameServerConnection;
    private var json_:JsonParser;

    public var gs_:GameSprite;
    public var server_:Server;
    public var gameId_:int;
    public var createCharacter_:Boolean;
    public var charId_:int;
    public var keyTime_:int;
    public var key_:ByteArray;
    public var mapJSON_:String;
    public var lastTickId_:int = -1;
    public var jitterWatcher_:JitterWatcher;
    public var serverConnection:SocketServer;
    public var outstandingBuy_:Boolean;
    public var connected:Boolean;

    public function GameServerConnection(_arg2:Server) {
        this.json_ = Global.jsonParser;
        this.keyInfoResponse = Global.keyInfoResponse;
        this.classesModel = Global.classesModel;
        serverConnection = Global.socketServer;
        this.messages = Global.messageCenter;
        this.model = Global.gameModel;
        this.server_ = _arg2;
        instance = this;
    }

    public function update(gs:GameSprite, gameId:int, createCharacter:Boolean, charId:int, keyTime:int, key:ByteArray, mapJSON:String):void {
        gs_ = gs;
        gameId_ = gameId;
        createCharacter_ = createCharacter;
        charId_ = charId;
        keyTime_ = keyTime;
        key_ = key;
        mapJSON_ = mapJSON;
    }

    public function updateServer(server:Server):void {
        server_ = server;
    }

    private static function isStatPotion(_arg1:int):Boolean {
        return ((((((((((((((((((((_arg1 == 2591)) || ((_arg1 == 5465)))) || ((_arg1 == 9064)))) || ((((((_arg1 == 2592)) || ((_arg1 == 5466)))) || ((_arg1 == 9065)))))) || ((((((_arg1 == 2593)) || ((_arg1 == 5467)))) || ((_arg1 == 9066)))))) || ((((((_arg1 == 2612)) || ((_arg1 == 5468)))) || ((_arg1 == 9067)))))) || ((((((_arg1 == 2613)) || ((_arg1 == 5469)))) || ((_arg1 == 9068)))))) || ((((((_arg1 == 2636)) || ((_arg1 == 5470)))) || ((_arg1 == 9069)))))) || ((((((_arg1 == 2793)) || ((_arg1 == 5471)))) || ((_arg1 == 9070)))))) || ((((((_arg1 == 2794)) || ((_arg1 == 5472)))) || ((_arg1 == 9071))))));
    }

    private function reset():void {
        this.connected = false;
        this.delayBeforeReconnect = 1;
        this.player != null && this.player.dispose();
        this.player = null;
        this.playerId_ = -1;
        this.lastTickId_ = -1;
        this.jitterWatcher_ = null;
    }

     public function disconnect():void {
        this.reset();
        this.removeServerConnectionListeners();
        this.unmapMessages();
        serverConnection.disconnect();
    }

    private function removeServerConnectionListeners():void {
        serverConnection.connected.remove(this.onConnected);
        serverConnection.closed.remove(this.onClosed);
        serverConnection.error.remove(this.onError);
    }

     public function connect():void {
        this.addServerConnectionListeners();
        this.mapMessages();
        var _local1:ChatMessage = new ChatMessage();
        _local1.name = Parameters.CLIENT_CHAT_NAME;
        _local1.text = "Connecting to {serverName}";
        var _local2:String = server_.name;
        _local2 = LineBuilder.getLocalizedStringFromKey(_local2);
        _local1.tokens = {"serverName": _local2};
        Global.addTextLine(_local1);
        serverConnection.connect(server_.address, server_.port);
    }

    public function addServerConnectionListeners():void {
        serverConnection.connected.add(this.onConnected);
        serverConnection.closed.add(this.onClosed);
        serverConnection.error.add(this.onError);
    }

    public function mapMessages():void {
        var messages:MessageCenter = Global.messageCenter;
        messages.map(CREATE).toMessage(Create);
        messages.map(PLAYERSHOOT).toMessage(PlayerShoot);
        messages.map(MOVE).toMessage(Move);
        messages.map(PLAYERTEXT).toMessage(PlayerText);
        messages.map(UPDATEACK).toMessage(Message);
        messages.map(INVSWAP).toMessage(InvSwap);
        messages.map(USEITEM).toMessage(UseItem);
        messages.map(HELLO).toMessage(Hello);
        messages.map(INVDROP).toMessage(InvDrop);
        messages.map(PONG).toMessage(Pong);
        messages.map(LOAD).toMessage(Load);
        messages.map(SETCONDITION).toMessage(SetCondition);
        messages.map(TELEPORT).toMessage(Teleport);
        messages.map(USEPORTAL).toMessage(UsePortal);
        messages.map(BUY).toMessage(Buy);
        messages.map(PLAYERHIT).toMessage(PlayerHit);
        messages.map(ENEMYHIT).toMessage(EnemyHit);
        messages.map(AOEACK).toMessage(AoeAck);
        messages.map(SHOOTACK).toMessage(ShootAck);
        messages.map(OTHERHIT).toMessage(OtherHit);
        messages.map(SQUAREHIT).toMessage(SquareHit);
        messages.map(GOTOACK).toMessage(GotoAck);
        messages.map(CHOOSENAME).toMessage(ChooseName);
        messages.map(CREATEGUILD).toMessage(CreateGuild);
        messages.map(GUILDREMOVE).toMessage(GuildRemove);
        messages.map(GUILDINVITE).toMessage(GuildInvite);
        messages.map(REQUESTTRADE).toMessage(RequestTrade);
        messages.map(CHANGETRADE).toMessage(ChangeTrade);
        messages.map(ACCEPTTRADE).toMessage(AcceptTrade);
        messages.map(CANCELTRADE).toMessage(CancelTrade);
        messages.map(CHECKCREDITS).toMessage(CheckCredits);
        messages.map(ESCAPE).toMessage(Escape);
        messages.map(QUEST_ROOM_MSG).toMessage(GoToQuestRoom);
        messages.map(JOINGUILD).toMessage(JoinGuild);
        messages.map(CHANGEGUILDRANK).toMessage(ChangeGuildRank);
        messages.map(EDITACCOUNTLIST).toMessage(EditAccountList);
        messages.map(KEY_INFO_REQUEST).toMessage(KeyInfoRequest);
        messages.map(FAILURE).toMessage(Failure).toMethod(this.onFailure);
        messages.map(CREATE_SUCCESS).toMessage(CreateSuccess).toMethod(this.onCreateSuccess);
        messages.map(SERVERPLAYERSHOOT).toMessage(ServerPlayerShoot).toMethod(this.onServerPlayerShoot);
        messages.map(DAMAGE).toMessage(Damage).toMethod(this.onDamage);
        messages.map(UPDATE).toMessage(Update).toMethod(this.onUpdate);
        messages.map(NOTIFICATION).toMessage(Notification).toMethod(this.onNotification);
        messages.map(GLOBAL_NOTIFICATION).toMessage(GlobalNotification).toMethod(this.onGlobalNotification);
        messages.map(NEWTICK).toMessage(NewTick).toMethod(this.onNewTick);
        messages.map(SHOWEFFECT).toMessage(ShowEffect).toMethod(this.onShowEffect);
        messages.map(GOTO).toMessage(Goto).toMethod(this.onGoto);
        messages.map(INVRESULT).toMessage(InvResult).toMethod(this.onInvResult);
        messages.map(RECONNECT).toMessage(Reconnect).toMethod(this.onReconnect);
        messages.map(PING).toMessage(Ping).toMethod(this.onPing);
        messages.map(MAPINFO).toMessage(MapInfo).toMethod(this.onMapInfo);
        messages.map(PIC).toMessage(Pic).toMethod(this.onPic);
        messages.map(DEATH).toMessage(Death).toMethod(this.onDeath);
        messages.map(BUYRESULT).toMessage(BuyResult).toMethod(this.onBuyResult);
        messages.map(AOE).toMessage(Aoe).toMethod(this.onAoe);
        messages.map(ACCOUNTLIST).toMessage(AccountList).toMethod(this.onAccountList);
        messages.map(QUESTOBJID).toMessage(QuestObjId).toMethod(this.onQuestObjId);
        messages.map(NAMERESULT).toMessage(NameResult).toMethod(this.onNameResult);
        messages.map(GUILDRESULT).toMessage(GuildResult).toMethod(this.onGuildResult);
        messages.map(ALLYSHOOT).toMessage(AllyShoot).toMethod(this.onAllyShoot);
        messages.map(ENEMYSHOOT).toMessage(EnemyShoot).toMethod(this.onEnemyShoot);
        messages.map(TRADEREQUESTED).toMessage(TradeRequested).toMethod(this.onTradeRequested);
        messages.map(TRADESTART).toMessage(TradeStart).toMethod(this.onTradeStart);
        messages.map(TRADECHANGED).toMessage(TradeChanged).toMethod(this.onTradeChanged);
        messages.map(TRADEDONE).toMessage(TradeDone).toMethod(this.onTradeDone);
        messages.map(TRADEACCEPTED).toMessage(TradeAccepted).toMethod(this.onTradeAccepted);
        messages.map(CLIENTSTAT).toMessage(ClientStat).toMethod(this.onClientStat);
        messages.map(FILE).toMessage(File).toMethod(this.onFile);
        messages.map(INVITEDTOGUILD).toMessage(InvitedToGuild).toMethod(this.onInvitedToGuild);
        messages.map(PLAYSOUND).toMessage(PlaySound).toMethod(this.onPlaySound);
        messages.map(VERIFY_EMAIL).toMessage(VerifyEmail).toMethod(this.onVerifyEmail);
        messages.map(RESKIN_UNLOCK).toMessage(ReskinUnlock).toMethod(this.onReskinUnlock);
        messages.map(PASSWORD_PROMPT).toMessage(PasswordPrompt).toMethod(this.onPasswordPrompt);
        messages.map(KEY_INFO_RESPONSE).toMessage(KeyInfoResponse).toMethod(this.onKeyInfoResponse);
        messages.map(SET_FOCUS).toMessage(SetFocus).toMethod(this.setFocus);
        messages.map(QUEUE_PONG).toMessage(QueuePong);
        messages.map(SERVER_FULL).toMessage(ServerFull).toMethod(this.HandleServerFull);
        messages.map(QUEUE_PING).toMessage(QueuePing).toMethod(this.HandleQueuePing);
        messages.map(SWITCH_MUSIC).toMessage(SwitchMusic).toMethod(this.onSwitchMusic);
        /* Market */
        messages.map(MARKET_SEARCH).toMessage(MarketSearch);
        messages.map(MARKET_SEARCH_RESULT).toMessage(MarketSearchResult).toMethod(this.onMarketSearchResult);
        messages.map(MARKET_BUY).toMessage(MarketBuy);
        messages.map(MARKET_BUY_RESULT).toMessage(MarketBuyResult).toMethod(this.onMarketBuyResult);
        messages.map(MARKET_ADD).toMessage(MarketAdd);
        messages.map(MARKET_ADD_RESULT).toMessage(MarketAddResult).toMethod(this.onMarketAddResult);
        messages.map(MARKET_REMOVE).toMessage(MarketRemove);
        messages.map(MARKET_REMOVE_RESULT).toMessage(MarketRemoveResult).toMethod(this.onMarketRemoveResult);
        messages.map(MARKET_MY_OFFERS).toMessage(MarketMyOffers);
        messages.map(MARKET_MY_OFFERS_RESULT).toMessage(MarketMyOffersResult).toMethod(this.onMarketMyOffersResult);

        // Quests
        messages.map(FETCH_AVAILABLE_QUESTS).toMessage(FetchAvailableQuests);
        messages.map(FETCH_AVAILABLE_QUESTS_RESULT).toMessage(FetchAvailableQuestsResult).toMethod(onFetchAvailableQuestsResult);
        messages.map(ACCEPT_QUEST).toMessage(AcceptQuest);
        messages.map(FETCH_CHARACTER_QUESTS).toMessage(FetchCharacterQuests);
        messages.map(FETCH_CHARACTER_QUESTS_RESULT).toMessage(FetchCharacterQuestsResult).toMethod(onFetchCharacterQuestsResult);
        messages.map(DELIVER_ITEMS_RESULT).toMessage(DeliverItemsResult).toMethod(onDeliverItemsResult);
        // Mail
        messages.map(FETCH_MAIL).toMessage(FetchMail);
        messages.map(FETCH_MAIL_RESULT).toMessage(FetchMailResult).toMethod(onFetchMailResult);
        // Account Quests
        messages.map(FETCH_ACCOUNT_QUESTS).toMessage(FetchAccountQuests);
        messages.map(FETCH_ACCOUNT_QUESTS_RESULT).toMessage(FetchAccountQuestsResult).toMethod(onFetchAccountQuestsResult);
        // Forge
        messages.map(CRAFT_ITEM).toMessage(CraftItem);
        messages.map(CRAFT_ANIMATION).toMessage(CraftAnimation).toMethod(onCraftAnimation);
        // Skill Tree abilities
        messages.map(OFFENSIVE_ABILITY).toMessage(OffensiveAbility);
        messages.map(DEFENSIVE_ABILITY).toMessage(DefensiveAbility);
        // Pets
        messages.map(FETCH_PETS).toMessage(FetchPets);
        messages.map(FETCH_PETS_RESULT).toMessage(FetchPetsResult).toMethod(onFetchPetsResult);
        messages.map(DELETE_PET).toMessage(DeletePet);
        messages.map(PET_FOLLOW).toMessage(PetFollow);

        messages.map(CURRENT_TIME).toMessage(CurrentTime).toMethod(onCurrentTime);
    }

    private function onSwitchMusic(sm:SwitchMusic):void {
        Music.load(sm.music);
    }

    private function HandleServerFull(_arg1:ServerFull):void
    {
        Global.showQueue();
        Global.updateQueue(_arg1.position_, _arg1.count_);
    }

    private function HandleQueuePing(_arg1:QueuePing):void
    {
        Global.updateQueue(_arg1.position_, _arg1.count_);
        var qp:QueuePong = (this.messages.require(QUEUE_PONG) as QueuePong);
        qp.serial_ = _arg1.serial_;
        qp.time_ = getTimer();
        serverConnection.queueMessage(qp);
    }

    private function unmapMessages():void {
        var messages:MessageCenter = Global.messageCenter;
        messages.unmap(CREATE);
        messages.unmap(PLAYERSHOOT);
        messages.unmap(MOVE);
        messages.unmap(PLAYERTEXT);
        messages.unmap(UPDATEACK);
        messages.unmap(INVSWAP);
        messages.unmap(USEITEM);
        messages.unmap(HELLO);
        messages.unmap(INVDROP);
        messages.unmap(PONG);
        messages.unmap(LOAD);
        messages.unmap(SETCONDITION);
        messages.unmap(TELEPORT);
        messages.unmap(USEPORTAL);
        messages.unmap(BUY);
        messages.unmap(PLAYERHIT);
        messages.unmap(ENEMYHIT);
        messages.unmap(AOEACK);
        messages.unmap(SHOOTACK);
        messages.unmap(OTHERHIT);
        messages.unmap(SQUAREHIT);
        messages.unmap(GOTOACK);
        messages.unmap(CHOOSENAME);
        messages.unmap(CREATEGUILD);
        messages.unmap(GUILDREMOVE);
        messages.unmap(GUILDINVITE);
        messages.unmap(REQUESTTRADE);
        messages.unmap(CHANGETRADE);
        messages.unmap(ACCEPTTRADE);
        messages.unmap(CANCELTRADE);
        messages.unmap(CHECKCREDITS);
        messages.unmap(ESCAPE);
        messages.unmap(QUEST_ROOM_MSG);
        messages.unmap(JOINGUILD);
        messages.unmap(CHANGEGUILDRANK);
        messages.unmap(EDITACCOUNTLIST);
        messages.unmap(FAILURE);
        messages.unmap(CREATE_SUCCESS);
        messages.unmap(SERVERPLAYERSHOOT);
        messages.unmap(DAMAGE);
        messages.unmap(UPDATE);
        messages.unmap(NOTIFICATION);
        messages.unmap(GLOBAL_NOTIFICATION);
        messages.unmap(NEWTICK);
        messages.unmap(SHOWEFFECT);
        messages.unmap(GOTO);
        messages.unmap(INVRESULT);
        messages.unmap(RECONNECT);
        messages.unmap(PING);
        messages.unmap(MAPINFO);
        messages.unmap(PIC);
        messages.unmap(DEATH);
        messages.unmap(BUYRESULT);
        messages.unmap(AOE);
        messages.unmap(ACCOUNTLIST);
        messages.unmap(QUESTOBJID);
        messages.unmap(NAMERESULT);
        messages.unmap(GUILDRESULT);
        messages.unmap(ALLYSHOOT);
        messages.unmap(ENEMYSHOOT);
        messages.unmap(TRADEREQUESTED);
        messages.unmap(TRADESTART);
        messages.unmap(TRADECHANGED);
        messages.unmap(TRADEDONE);
        messages.unmap(TRADEACCEPTED);
        messages.unmap(CLIENTSTAT);
        messages.unmap(FILE);
        messages.unmap(INVITEDTOGUILD);
        messages.unmap(PLAYSOUND);
        messages.unmap(SERVER_FULL);
        messages.unmap(QUEUE_PING);
        messages.unmap(QUEUE_PONG);
        messages.unmap(SET_FOCUS);
        messages.unmap(SWITCH_MUSIC);
        /* Market */
        messages.unmap(MARKET_SEARCH);
        messages.unmap(MARKET_SEARCH_RESULT);
        messages.unmap(MARKET_BUY);
        messages.unmap(MARKET_BUY_RESULT);
        messages.unmap(MARKET_ADD);
        messages.unmap(MARKET_ADD_RESULT);
        messages.unmap(MARKET_REMOVE);
        messages.unmap(MARKET_REMOVE_RESULT);
        messages.unmap(MARKET_MY_OFFERS);
        messages.unmap(MARKET_MY_OFFERS_RESULT);

        // Quests
        messages.unmap(FETCH_AVAILABLE_QUESTS);
        messages.unmap(FETCH_AVAILABLE_QUESTS_RESULT);
        messages.unmap(ACCEPT_QUEST);
        messages.unmap(FETCH_CHARACTER_QUESTS);
        messages.unmap(FETCH_CHARACTER_QUESTS_RESULT);
        messages.unmap(DELIVER_ITEMS_RESULT);
        // Mail
        messages.unmap(FETCH_MAIL);
        messages.unmap(FETCH_MAIL_RESULT);
        // Account Quests
        messages.unmap(FETCH_ACCOUNT_QUESTS);
        messages.unmap(FETCH_ACCOUNT_QUESTS_RESULT);
        // Forge
        messages.unmap(CRAFT_ITEM);
        messages.unmap(CRAFT_ANIMATION);
        // Skill Tree abilities
        messages.unmap(OFFENSIVE_ABILITY);
        messages.unmap(DEFENSIVE_ABILITY);
        // Pets
        messages.unmap(FETCH_PETS);
        messages.unmap(FETCH_PETS_RESULT);
        messages.unmap(DELETE_PET);
        messages.unmap(PET_FOLLOW);

        messages.unmap(CURRENT_TIME);
    }

    private function encryptConnection():void {
        var _local1:ICipher;
        var _local2:ICipher;
        if (Parameters.ENABLE_ENCRYPTION) {
            _local1 = Crypto.getCipher("rc4", MoreStringUtil.hexStringToByteArray(Parameters.RANDOM1));
            _local2 = Crypto.getCipher("rc4", MoreStringUtil.hexStringToByteArray(Parameters.RANDOM2));
            serverConnection.setOutgoingCipher(_local1);
            serverConnection.setIncomingCipher(_local2);
        }
    }

     public function getNextInt(_arg1:uint, _arg2:uint):uint {
        return (this.rand_.nextIntRange(_arg1, _arg2));
    }

     public function enableJitterWatcher():void {
        if (jitterWatcher_ == null) {
            jitterWatcher_ = new JitterWatcher();
        }
    }

     public function disableJitterWatcher():void {
        if (jitterWatcher_ != null) {
            jitterWatcher_ = null;
        }
    }


    /* Market */
    private function onMarketSearchResult(searchResult:MarketSearchResult) : void
    {
        MemMarketSearchSignal.instance.dispatch(searchResult);
    }

    /* Market */
    private function onMarketBuyResult(buyResult:MarketBuyResult) : void
    {
        MemMarketBuySignal.instance.dispatch(buyResult);
    }

    /* Market */
    private function onMarketAddResult(addResult:MarketAddResult) : void
    {
        MemMarketAddSignal.instance.dispatch(addResult);
    }

    /* Market */
    private function onMarketRemoveResult(removeResult:MarketRemoveResult) : void
    {
        MemMarketRemoveSignal.instance.dispatch(removeResult);
    }

    /* Market */
    private function onMarketMyOffersResult(myOffersResult:MarketMyOffersResult) : void
    {
        MemMarketMyOffersSignal.instance.dispatch(myOffersResult);
    }

    /* Market */
    public function marketSearch(itemType:int) : void
    {
        var search:MarketSearch = this.messages.require(MARKET_SEARCH) as MarketSearch;
        search.itemType_ = itemType;
        this.serverConnection.sendMessage(search);
    }

    /* Market */
    public function marketRemove(id:int) : void
    {
        var remove:MarketRemove = this.messages.require(MARKET_REMOVE) as MarketRemove;
        remove.id_ = id;
        this.serverConnection.sendMessage(remove);
    }

    /* Market */
    public function marketMyOffers() : void
    {
        var myOffers:MarketMyOffers = this.messages.require(MARKET_MY_OFFERS) as MarketMyOffers;
        this.serverConnection.sendMessage(myOffers);
    }

    /* Market */
    public function marketBuy(id:int) : void
    {
        var buy:MarketBuy = this.messages.require(MARKET_BUY) as MarketBuy;
        buy.id_ = id;
        this.serverConnection.sendMessage(buy);
    }

    /* Market */
    public function marketAdd(items:Vector.<int>, price:int, currency:int, hours:int) : void
    {
        var add:MarketAdd = this.messages.require(MARKET_ADD)  as MarketAdd;
        add.slots_ = items;
        add.price_ = price;
        add.currency_ = currency;
        add.hours_ = hours;
        this.serverConnection.sendMessage(add);
    }

    private function create():void {
        var _local1:CharacterClass = this.classesModel.getSelected();
        var _local2:Create = (this.messages.require(CREATE) as Create);
        _local2.classType = _local1.id;
        _local2.skinType = _local1.skins.getSelectedSkin().id;
        serverConnection.queueMessage(_local2);
    }

    private function load():void {
        var _local1:Load = (this.messages.require(LOAD) as Load);
        _local1.charId_ = charId_;
        serverConnection.queueMessage(_local1);
    }

     public function playerShoot(_arg1:int, _arg2:Projectile, _arg3:Number):void {
        var _local3:PlayerShoot = (this.messages.require(PLAYERSHOOT) as PlayerShoot);
        _local3.time_ = _arg1;
        _local3.bulletId_ = _arg2.bulletId_;
        _local3.containerType_ = _arg2.containerType_;
        _local3.startingPos_.x_ = _arg2.x_;
        _local3.startingPos_.y_ = _arg2.y_;
        _local3.angle_ = _arg3;
        serverConnection.queueMessage(_local3);
    }

     public function playerHit(_arg1:int, _arg2:int):void {
        var _local3:PlayerHit = (this.messages.require(PLAYERHIT) as PlayerHit);
        _local3.bulletId_ = _arg1;
        _local3.objectId_ = _arg2;
        serverConnection.queueMessage(_local3);
    }

     public function enemyHit(t:int, bulletId:int, targetId:int):void {
         var _local5:EnemyHit = (this.messages.require(ENEMYHIT) as EnemyHit);
         _local5.time_ = t;
         _local5.bulletId_ = bulletId;
         _local5.targetId_ = targetId;
         serverConnection.queueMessage(_local5);
     }

     public function otherHit(_arg1:int, _arg2:int, _arg3:int, _arg4:int):void {
        var _local5:OtherHit = (this.messages.require(OTHERHIT) as OtherHit);
        _local5.time_ = _arg1;
        _local5.bulletId_ = _arg2;
        _local5.objectId_ = _arg3;
        _local5.targetId_ = _arg4;
        serverConnection.queueMessage(_local5);
    }

     public function squareHit(_arg1:int, _arg2:int, _arg3:int):void {
        var _local4:SquareHit = (this.messages.require(SQUAREHIT) as SquareHit);
        _local4.time_ = _arg1;
        _local4.bulletId_ = _arg2;
        _local4.objectId_ = _arg3;
        serverConnection.queueMessage(_local4);
    }

    public function aoeAck(_arg1:int, _arg2:Number, _arg3:Number):void {
        var _local4:AoeAck = (this.messages.require(AOEACK) as AoeAck);
        _local4.time_ = _arg1;
        _local4.position_.x_ = _arg2;
        _local4.position_.y_ = _arg3;
        serverConnection.queueMessage(_local4);
    }

    public function shootAck(time:int):void {
        var _local2:ShootAck = (this.messages.require(SHOOTACK) as ShootAck);
        _local2.time_ = time;
        serverConnection.queueMessage(_local2);
    }

     public function playerText(_arg1:String):void {
        var _local2:PlayerText = (this.messages.require(PLAYERTEXT) as PlayerText);
        _local2.text_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function invSwap(
            plr:Player,
            go1:GameObject, go1Slot:int, go1Item:ItemData,
            go2:GameObject, go2Slot:int, go2Item:ItemData):Boolean {

         if (gs_ == null)
             return false;

         var swap:InvSwap = (this.messages.require(INVSWAP) as InvSwap);
         swap.time_ = gs_.lastUpdate_;
         swap.position_.x_ = plr.x_;
         swap.position_.y_ = plr.y_;
         swap.slotObject1_.objectId_ = go1.objectId_;
         swap.slotObject1_.slotId_ = go1Slot;
         swap.slotObject1_.objectType_ = go1Item.ObjectType;
         swap.slotObject2_.objectId_ = go2.objectId_;
         swap.slotObject2_.slotId_ = go2Slot;
         swap.slotObject2_.objectType_ = go2Item.ObjectType;
         serverConnection.queueMessage(swap);

         var temp:ItemData = go1.equipment_[go1Slot];
         go1.equipment_[go1Slot] = go2.equipment_[go2Slot];
         go2.equipment_[go2Slot] = temp;

         SoundEffectLibrary.play("inventory_move_item");
         return true;
     }

     public function invSwapPotion(_arg1:Player, _arg2:GameObject, _arg3:int, item1:ItemData, _arg5:GameObject, _arg6:int, item2:ItemData):Boolean {
        if (gs_ == null) {
            return (false);
        }
        var _local8:InvSwap = (this.messages.require(INVSWAP) as InvSwap);
        _local8.time_ = gs_.lastUpdate_;
        _local8.position_.x_ = _arg1.x_;
        _local8.position_.y_ = _arg1.y_;
        _local8.slotObject1_.objectId_ = _arg2.objectId_;
        _local8.slotObject1_.slotId_ = _arg3;
        _local8.slotObject1_.objectType_ = item1.ObjectType;
        _local8.slotObject2_.objectId_ = _arg5.objectId_;
        _local8.slotObject2_.slotId_ = _arg6;
        _local8.slotObject2_.objectType_ = item2.ObjectType;
        _arg2.equipment_[_arg3] = new ItemData(null);
        if (item1.ObjectType == PotionInventoryModel.HEALTH_POTION_ID) {
            _arg1.healthStackCount_++;
        }
        else {
            if (item1.ObjectType == PotionInventoryModel.MAGIC_POTION_ID) {
                _arg1.magicStackCount_++;
            }
        }
        serverConnection.queueMessage(_local8);
        SoundEffectLibrary.play("inventory_move_item");
        return (true);
    }

     public function invDrop(_arg1:GameObject, _arg2:int, _arg3:int):void {
        var _local4:InvDrop = (this.messages.require(INVDROP) as InvDrop);
        _local4.slotObject_.objectId_ = _arg1.objectId_;
        _local4.slotObject_.slotId_ = _arg2;
        _local4.slotObject_.objectType_ = _arg3;
        serverConnection.queueMessage(_local4);
        if (((!((_arg2 == PotionInventoryModel.HEALTH_POTION_SLOT))) && (!((_arg2 == PotionInventoryModel.MAGIC_POTION_SLOT))))) {
            _arg1.equipment_[_arg2] = new ItemData(null);
        }
    }

     public function useItem(time:int, objectId:int, slotId:int, objectType:int, x:Number, y:Number, activateId:int = 1):void {
        var useItem:UseItem = (this.messages.require(USEITEM) as UseItem);
         useItem.time_ = time;
         useItem.slotObject_.objectId_ = objectId;
         useItem.slotObject_.slotId_ = slotId;
         useItem.slotObject_.objectType_ = objectType;
         useItem.itemUsePos_.x_ = x;
         useItem.itemUsePos_.y_ = y;
         useItem.activateId_ = activateId;
        serverConnection.queueMessage(useItem);
    }

    public function useOffensiveAbility(time:int, x:Number, y:Number, angle:Number):void {
        var ability:OffensiveAbility = (this.messages.require(OFFENSIVE_ABILITY) as OffensiveAbility);
        ability.time_ = time;
        ability.usePos_.x_ = x;
        ability.usePos_.y_ = y;
        ability.angle_ = angle;
        serverConnection.queueMessage(ability);
    }

    public function useDefensiveAbility(time:int, x:Number, y:Number, angle:Number):void {
        var ability:DefensiveAbility = (this.messages.require(DEFENSIVE_ABILITY) as DefensiveAbility);
        ability.time_ = time;
        ability.usePos_.x_ = x;
        ability.usePos_.y_ = y;
        ability.angle_ = angle;
        serverConnection.queueMessage(ability);
    }

     public function useItem_new(go:GameObject, slot:int):Boolean {
         var item:XML;
         var objectType:int = go.equipment_[slot].ObjectType;
         if ((((objectType >= 0x9000)) && ((objectType < 0xF000)))) {
             item = ObjectLibrary.xmlLibrary_[36863];
         }
         else {
             item = ObjectLibrary.xmlLibrary_[objectType];
         }
         if (item && !go.isPaused() && (item.hasOwnProperty("Consumable") || item.hasOwnProperty("InvUse"))) {
             if (!this.validStatInc(objectType, go)) {
                 Global.addTextLine(ChatMessage.make("", (item.attribute("id") + " not consumed. Already at Max.")));
                 return false;
             }
             this.applyUseItem(go, slot, objectType, item, 1);
             SoundEffectLibrary.play("use_potion");
             return true;
         }
         SoundEffectLibrary.play("error");
         return false;
     }

    private function validStatInc(itemId:int, itemOwner:GameObject):Boolean {
        var p:Player;
        try {
            if ((itemOwner is Player)) {
                p = (itemOwner as Player);
            }
            else {
                p = this.player;
            }
            if ((((itemId == 0x033a || itemId == 0x0342) || itemId == 0x0552) && p.strengthMax_ == (p.strength_ - p.strengthBoost_))  ||
                    (((itemId == 0x033b || itemId == 0x0343) || itemId == 0x0553) && p.armorMax_ == (p.armor_ - p.armorBoost_)) ||
                    (((itemId == 0x033c || itemId == 0x0344) || itemId == 0x0554) && p.agilityMax_ == (p.agility_ - p.agilityBoost_)) ||
                    (((itemId == 0x033d || itemId == 0x0345) || itemId == 0x0555) && p.staminaMax_ == (p.stamina_ - p.staminaBoost_)) ||
                    (((itemId == 0x033e || itemId == 0x0346) || itemId == 0x0556) && p.intelligenceMax_ == (p.intelligence_ - p.intelligenceBoost_)) ||
                    (((itemId == 0x033f || itemId == 0x0347) || itemId == 0x0557) && p.dexterityMax_ == (p.dexterity_ - p.dexterityBoost_)) ||
                    (((itemId == 0x0340 || itemId == 0x0348) || itemId == 0x0558) && p.maxHPMax_ == (p.maxHP_ - p.maxHPBoost_)) ||
                    (((itemId == 0x0341 || itemId == 0x0349) || itemId == 0x0559) && p.maxMPMax_ == (p.maxMP_ - p.maxMPBoost_))) {
                return false;
            }
        }
        catch (err:Error) {
            trace(("PROBLEM IN STAT INC " + err.getStackTrace()));
        }
        return true;
    }

    private function applyUseItem(go:GameObject, slotId:int, objectType:int, item:XML, activateId:int = 1):void {
        var _local5:UseItem = (this.messages.require(USEITEM) as UseItem);
        _local5.time_ = getTimer();
        _local5.slotObject_.objectId_ = go.objectId_;
        _local5.slotObject_.slotId_ = slotId;
        _local5.slotObject_.objectType_ = objectType;
        _local5.itemUsePos_.x_ = 0;
        _local5.itemUsePos_.y_ = 0;
        _local5.activateId_ = activateId;
        serverConnection.queueMessage(_local5);
        if (item.hasOwnProperty("Consumable")) {
            go.equipment_[slotId] = new ItemData(null);
            if (((item.hasOwnProperty("Activate")) && ((item.Activate == "UnlockSkin")))) {
            }
        }
    }

     public function setCondition(_arg1:uint, _arg2:Number):void {
        var _local3:SetCondition = (this.messages.require(SETCONDITION) as SetCondition);
        _local3.conditionEffect_ = _arg1;
        _local3.conditionDuration_ = _arg2;
        serverConnection.queueMessage(_local3);
    }

    public function move(_arg1:int, _arg2:Player):void {
        if (this.player.map_ == null)
            return;

        var _local7:int;
        var _local8:int;
        var _local3:Number = -1;
        var _local4:Number = -1;
        var controlled:GameObject = _arg2 != null && _arg2.commune != null && !(_arg2.commune is Player) ? _arg2.commune : _arg2;
        if (controlled && !controlled.isPaused()) {
            _local3 = controlled.x_;
            _local4 = controlled.y_;
        }
        var _local5:Move = (this.messages.require(MOVE) as Move);
        _local5.objectId_ = controlled != null ? controlled.objectId_ : 0;
        _local5.tickId_ = _arg1;
        _local5.time_ = gs_.lastUpdate_;
        _local5.newPosition_.x_ = _local3;
        _local5.newPosition_.y_ = _local4;
        var _local6:int = gs_.moveRecords_.lastClearTime_;
        _local5.records_.length = 0;
        if ((((_local6 >= 0)) && (((_local5.time_ - _local6) > 125)))) {
            _local7 = Math.min(10, gs_.moveRecords_.records_.length);
            _local8 = 0;
            while (_local8 < _local7) {
                if (gs_.moveRecords_.records_[_local8].time_ >= (_local5.time_ - 25)) break;
                _local5.records_.push(gs_.moveRecords_.records_[_local8]);
                _local8++;
            }
        }
        gs_.moveRecords_.clear(_local5.time_);
        serverConnection.queueMessage(_local5);
        ((_arg2) && (_arg2.onMove()));
    }

     public function teleport(_arg1:int):void {
        var _local2:Teleport = (this.messages.require(TELEPORT) as Teleport);
        _local2.objectId_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function usePortal(_arg1:int):void {
        var _local2:UsePortal = (this.messages.require(USEPORTAL) as UsePortal);
        _local2.objectId_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function buy(sellableObjectId:int):void {
        var sObj:SellableObject;
        var converted:Boolean;
        if (outstandingBuy_) {
            return;
        }
        sObj = gs_.map.goDict_[sellableObjectId];
        if (sObj == null) {
            return;
        }
        converted = false;
        if (sObj.currency_ == Currency.GOLD) {
            converted = ((((gs_.model.getConverted()) || ((this.player.credits_ > 100)))) || ((sObj.price_ > this.player.credits_)));
        }
        if (sObj.soldObjectName() == "Vault Chest") {
            Global.openDialog(new PurchaseConfirmationDialog(function ():void {
                buyConfirmation(sObj, converted, sellableObjectId);
            }));
        }
        else {
            this.buyConfirmation(sObj, converted, sellableObjectId);
        }
    }

    private function buyConfirmation(_arg1:SellableObject, _arg2:Boolean, _arg3:int):void {
        outstandingBuy_ = true;
        var _local5:Buy = (this.messages.require(BUY) as Buy);
        _local5.objectId_ = _arg3;
        serverConnection.queueMessage(_local5);
    }

    public function gotoAck(_arg1:int):void {
        var _local2:GotoAck = (this.messages.require(GOTOACK) as GotoAck);
        _local2.time_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function editAccountList(_arg1:int, _arg2:Boolean, _arg3:int):void {
        var _local4:EditAccountList = (this.messages.require(EDITACCOUNTLIST) as EditAccountList);
        _local4.accountListId_ = _arg1;
        _local4.add_ = _arg2;
        _local4.objectId_ = _arg3;
        serverConnection.queueMessage(_local4);
    }

     public function chooseName(_arg1:String):void {
        var _local2:ChooseName = (this.messages.require(CHOOSENAME) as ChooseName);
        _local2.name_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function createGuild(_arg1:String):void {
        var _local2:CreateGuild = (this.messages.require(CREATEGUILD) as CreateGuild);
        _local2.name_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function guildRemove(_arg1:String):void {
        var _local2:GuildRemove = (this.messages.require(GUILDREMOVE) as GuildRemove);
        _local2.name_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function guildInvite(_arg1:String):void {
        var _local2:GuildInvite = (this.messages.require(GUILDINVITE) as GuildInvite);
        _local2.name_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function requestTrade(_arg1:String):void {
        var _local2:RequestTrade = (this.messages.require(REQUESTTRADE) as RequestTrade);
        _local2.name_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function changeTrade(_arg1:Vector.<Boolean>):void {
        var _local2:ChangeTrade = (this.messages.require(CHANGETRADE) as ChangeTrade);
        _local2.offer_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function acceptTrade(_arg1:Vector.<Boolean>, _arg2:Vector.<Boolean>):void {
        var _local3:AcceptTrade = (this.messages.require(ACCEPTTRADE) as AcceptTrade);
        _local3.myOffer_ = _arg1;
        _local3.yourOffer_ = _arg2;
        serverConnection.queueMessage(_local3);
    }

     public function cancelTrade():void {
        serverConnection.queueMessage(this.messages.require(CANCELTRADE));
    }

     public function checkCredits():void {
        serverConnection.queueMessage(this.messages.require(CHECKCREDITS));
    }

     public function escape():void
     {
         if (this.playerId_ == -1)
         {
             return;
         }

         serverConnection.sendMessage(this.messages.require(ESCAPE));
     }

     public function gotoQuestRoom():void {
        serverConnection.queueMessage(this.messages.require(QUEST_ROOM_MSG));
    }

     public function joinGuild(_arg1:String):void {
        var _local2:JoinGuild = (this.messages.require(JOINGUILD) as JoinGuild);
        _local2.guildName_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

     public function changeGuildRank(_arg1:String, _arg2:int):void {
        var _local3:ChangeGuildRank = (this.messages.require(CHANGEGUILDRANK) as ChangeGuildRank);
        _local3.name_ = _arg1;
        _local3.guildRank_ = _arg2;
        serverConnection.queueMessage(_local3);
    }

    public static function rsaEncrypt(_arg1:String):String {
        var _local2:RSAKey = PEM.readRSAPublicKey(Parameters.RSA_PUBLIC_KEY);
        var _local3:ByteArray = new ByteArray();
        _local3.endian = "littleEndian";
        _local3.writeUTFBytes(_arg1);
        var _local4:ByteArray = new ByteArray();
        _local4.endian = "littleEndian";
        _local2.encrypt(_local3, _local4, _local3.length);
        return (Base64.encodeByteArray(_local4));
    }

    private function onConnected():void {
        this.connected = true;
        Global.addTextLine(ChatMessage.make(Parameters.CLIENT_CHAT_NAME, "Connected!"));
        this.encryptConnection();
        this.sendHello();
    }

    public function sendHello() : void
    {
        var _local1:Account = Global.account;
        var _local2:Hello = (this.messages.require(HELLO) as Hello);
        _local2.buildVersion_ = Parameters.FULL_BUILD;
        _local2.gameId_ = gameId_;
        _local2.guid_ = rsaEncrypt(_local1.getUserId());
        _local2.password_ = _local1.getPassword();
        _local2.secret_ = rsaEncrypt(_local1.getSecret());
        _local2.keyTime_ = keyTime_;
        _local2.key_.length = 0;
        ((!((key_ == null))) && (_local2.key_.writeBytes(key_)));
        _local2.mapJSON_ = (((mapJSON_ == null)) ? "" : mapJSON_);
        serverConnection.sendMessage(_local2);
    }

    private function onCreateSuccess(_arg1:CreateSuccess):void {
        this.playerId_ = _arg1.objectId_;
        charId_ = _arg1.charId_;
        gs_.initialize();
        createCharacter_ = false;
    }

    private function onDamage(_arg1:Damage):void {
        if (Parameters.data_.allyDamage)
        {
            if (((!(_arg1.objectId_ == this.playerId_)) && (!(_arg1.targetId_ == this.playerId_))))
            {
                return;
            }
        }
        var _local5:int;
        var _local2:AbstractMap = gs_.map;
        var _local3:Projectile;
        if ((((_arg1.objectId_ >= 0)) && ((_arg1.bulletId_ > 0)))) {
            _local5 = Projectile.findObjId(_arg1.objectId_, _arg1.bulletId_);
            _local3 = (_local2.boDict_[_local5] as Projectile);
            if (((!((_local3 == null))) && (!(_local3.projProps_.multiHit_)))) {
                _local2.removeObj(_local5);
            }
        }
        var _local4:GameObject = _local2.goDict_[_arg1.targetId_];
        if (_local4 != null) {
            _local4.damage(_arg1.damageAmount_, _arg1.effects_, _arg1.kill_, _local3, false, _arg1.dTp_);
        }
    }

    private function onServerPlayerShoot(_arg1:ServerPlayerShoot):void {
        var _local2:Boolean = (_arg1.ownerId_ == this.playerId_);
        var _local3:GameObject = gs_.map.goDict_[_arg1.ownerId_];
        if ((((_local3 == null)) || (_local3.dead_))) {
            if (_local2) {
                this.shootAck(-1);
            }
            return;
        }
        if (((!((_local3.objectId_ == this.playerId_))) && (Parameters.data_.allyShots)))
            return;
        var _local5:Player = (_local3 as Player);
        var len:int = _arg1.bulletIds_.length;
        var i:int = 0;
        while (i < len)
        {
            var _local4:Projectile = (FreeList.newObject(Projectile) as Projectile);
            if (_local5 != null)
            {
                _local4.reset(_arg1.containerType_, 0, _arg1.ownerId_, _arg1.bulletIds_[i], i, i * (Math.PI * 2) / len, gs_.lastUpdate_, _local5.projectileIdSetOverrideNew, _local5.projectileIdSetOverrideOld);
            }
            else
            {
                _local4.reset(_arg1.containerType_, 0, _arg1.ownerId_, _arg1.bulletIds_[i], i, i * (Math.PI * 2) / len, gs_.lastUpdate_);
            }
            _local4.damageType_ = _arg1.damageTypes_[i];
            _local4.setDamage(_arg1.damages_[i]);
            gs_.map.addObj(_local4, _arg1.startingPos_.x_, _arg1.startingPos_.y_);
            i++;
        }
        if (_local2) {
            this.shootAck(gs_.lastUpdate_);
        }
    }

    private function onAllyShoot(_arg1:AllyShoot):void {
        var _local2:GameObject = gs_.map.goDict_[_arg1.ownerId_];
        if ((((((_local2 == null)) || (_local2.dead_))) || (Parameters.data_.allyShots)))
            return;
        var _local3:Projectile = (FreeList.newObject(Projectile) as Projectile);
        var _local4:Player = (_local2 as Player);
        if (_local4 != null) {
            _local3.reset(_arg1.containerType_, 0, _arg1.ownerId_, _arg1.bulletId_, _arg1.bulletId_, _arg1.angle_, gs_.lastUpdate_, _local4.projectileIdSetOverrideNew, _local4.projectileIdSetOverrideOld);
        }
        else {
            _local3.reset(_arg1.containerType_, 0, _arg1.ownerId_, _arg1.bulletId_, _arg1.bulletId_, _arg1.angle_, gs_.lastUpdate_);
        }
        gs_.map.addObj(_local3, _local2.x_, _local2.y_);
        _local2.setAttack(_arg1.containerType_, _arg1.angle_);
    }

    private function onReskinUnlock(_arg1:ReskinUnlock):void {
        var _local2:String;
        var _local3:CharacterSkin;
        for (_local2 in this.model.player.lockedSlot) {
            if (this.model.player.lockedSlot[_local2] == _arg1.skinID) {
                this.model.player.lockedSlot[_local2] = 0;
            }
        }
        _local3 = this.classesModel.getCharacterClass(this.model.player.objectType_).skins.getSkin(_arg1.skinID);
        _local3.setState(CharacterSkinState.OWNED);
    }

    // shoot ack wip
    private function onEnemyShoot(_arg1:EnemyShoot):void {
        var _local4:Projectile;
        var _local5:Number;
        var _local2:GameObject = gs_.map.goDict_[_arg1.ownerId_];
        if ((((_local2 == null)) || (_local2.dead_))) {
            //this.shootAck(-1);
            return;
        }
        var _local3:int = 0;
        while (_local3 < _arg1.numShots_) {
            _local4 = (FreeList.newObject(Projectile) as Projectile);
            _local5 = (_arg1.angle_ + (_arg1.angleInc_ * _local3));
            _local4.reset(_local2.objectType_, _arg1.bulletType_, _arg1.ownerId_, ((_arg1.bulletId_ + _local3) % 0x0100), _local3, _local5, gs_.lastUpdate_);
            _local4.damageType_ = _arg1.damageType_;
            _local4.setDamage(_arg1.damage_);
            gs_.map.addObj(_local4, _arg1.startingPos_.x_, _arg1.startingPos_.y_);
            _local3++;
        }
        //this.shootAck(gs_.lastUpdate_);
        _local2.setAttack(_local2.objectType_, (_arg1.angle_ + (_arg1.angleInc_ * ((_arg1.numShots_ - 1) / 2))));
    }

    private function onTradeRequested(_arg1:TradeRequested):void {
        if (!Parameters.data_.chatTrade) {
            return;
        }
        if (Parameters.data_.showTradePopup) {
            gs_.hud.interactPanel.setOverride(new TradeRequestPanel(gs_, _arg1.name_));
        }
        Global.addTextLine(ChatMessage.make("", ((((_arg1.name_ + " wants to ") + 'trade with you.  Type "/trade ') + _arg1.name_) + '" to trade.')));
    }

    private function onTradeStart(_arg1:TradeStart):void {
        gs_.hud.startTrade(gs_, _arg1);
    }

    private function onTradeChanged(_arg1:TradeChanged):void {
        gs_.hud.tradeChanged(_arg1);
    }

    private function onTradeDone(_arg1:TradeDone):void {
        var _local3:Object;
        var _local4:Object;
        gs_.hud.tradeDone();
        var _local2:String = "";
        try {
            _local4 = this.json_.parse(_arg1.description_);
            _local2 = _local4.key;
            _local3 = _local4.tokens;
        }
        catch (e:Error) {
            _local2 = _arg1.description_;
        }
        Global.addTextLine(ChatMessage.make(Parameters.SERVER_CHAT_NAME, _local2, -1, -1, "", false, _local3));
    }

    private function onTradeAccepted(_arg1:TradeAccepted):void {
        gs_.hud.tradeAccepted(_arg1);
    }

    private function addObject(_arg1:ObjectData):void {
        var _local2:AbstractMap = gs_.map;
        var _local3:GameObject = ObjectLibrary.getObjectFromType(_arg1.objectType_);
        if (_local3 == null) {
            return;
        }
        var _local4:ObjectStatusData = _arg1.status_;
        _local3.setObjectId(_local4.objectId_);
        _local2.addObj(_local3, _local4.pos_.x_, _local4.pos_.y_);
        if ((_local3 is Player)) {
            this.handleNewPlayer((_local3 as Player), _local2);
        }
        this.processObjectStatus(_local4, 0, -1);
        if (((((_local3.props_.static_) && (_local3.props_.occupySquare_))) && (!(_local3.props_.noMiniMap_)))) {
            Global.updateGameObjectTile(new UpdateGameObjectTileVO(_local3.x_, _local3.y_, _local3));
        }
    }

    private function handleNewPlayer(_arg1:Player, _arg2:AbstractMap):void {
        this.setPlayerSkinTemplate(_arg1, 0);
        if (_arg1.objectId_ == this.playerId_) {
            this.player = _arg1;
            this.model.player = _arg1;
            _arg2.player_ = _arg1;
            Global.setGameFocus(this.playerId_.toString());
        }
    }

    private function onUpdate(_arg1:Update):void {
        var _local3:int;
        var _local4:GroundTileData;
        var _local2:Message = this.messages.require(UPDATEACK);
        serverConnection.queueMessage(_local2);
        _local3 = 0;
        while (_local3 < _arg1.tiles_.length) {
            _local4 = _arg1.tiles_[_local3];
            gs_.map.setGroundTile(_local4.x_, _local4.y_, _local4.type_);
            Global.updateGroundTile(new UpdateGroundTileVO(_local4.x_, _local4.y_, _local4.type_));
            _local3++;
        }
        _local3 = 0;
        while (_local3 < _arg1.drops_.length) {
            gs_.map.removeObj(_arg1.drops_[_local3]);
            _local3++;
        }
        _local3 = 0;
        while (_local3 < _arg1.newObjs_.length) {
            this.addObject(_arg1.newObjs_[_local3]);
            _local3++;
        }
    }

    private function onNotification(packet:Notification):void
    {
        var lineBuilder:LineBuilder;
        var statusText:CharacterStatusText;
        var queuedStatusText:QueuedStatusText;
        var go:GameObject = gs_.map.goDict_[packet.objectId_];
        if (go == null)
        {
            return;
        }
        if (Parameters.data_.allyNotifications && go.props_.isPlayer_ && !(packet.objectId_ == this.playerId_))
        {
            return;
        }
        var message:String = packet.message;
        var status:Boolean = false;
        if (message.slice(0, 3) == "fn>")
        {
            message = message.slice(3);
            status = true;
        }
        lineBuilder = LineBuilder.fromJSON(message);
        if (lineBuilder.key == "server.plus_symbol" || status)
        {
            statusText = new CharacterStatusText(go, packet.color_, 1000);
            statusText.setStringBuilder(lineBuilder);
            gs_.map.mapOverlay_.addStatusText(statusText);
            return;
        }
        queuedStatusText = new QueuedStatusText(go, lineBuilder, packet.color_, 2000);
        gs_.map.mapOverlay_.addQueuedText(queuedStatusText);
        if ((((go == this.player)) && ((lineBuilder.key == "server.quest_complete"))))
        {
            gs_.map.quest_.Completed();
        }
    }

    private function onGlobalNotification(notif:GlobalNotification):void {
        if (notif.text.slice(0, 4) == "Mail") {
            Global.updateMail();
            return;
        }

        switch (notif.text)
        {
            case "giftChestOccupied":
                Global.updateGift(true);
                return;
            case "giftChestEmpty":
                Global.updateGift(false);
                return;
            case "beginnersPackage":
                return;
            case "legendaryLoot":
                this.gs_.lootNotifications_.show(0);
                return;
            case "mythicLoot":
                this.gs_.lootNotifications_.show(1);
                return;
            case "divineLoot":
                this.gs_.lootNotifications_.show(2);
                return;
            case "unholyLoot":
                this.gs_.lootNotifications_.show(3);
                return;
        }
    }

    private function onNewTick(_arg1:NewTick):void {
        var _local2:ObjectStatusData;
        if (jitterWatcher_ != null) {
            jitterWatcher_.record();
        }
        this.move(_arg1.tickId_, this.player);
        for each (_local2 in _arg1.statuses_) {
            this.processObjectStatus(_local2, _arg1.tickTime_, _arg1.tickId_);
        }
        lastTickId_ = _arg1.tickId_;
    }

    private function canShowEffect(_arg1:GameObject):Boolean {
        if (_arg1 != null) {
            return (true);
        }
        var _local2:Boolean = (_arg1.objectId_ == this.playerId_);
        if (((((!(_local2)) && (_arg1.props_.isPlayer_))) && (Parameters.data_.disableAllyParticles))) {
            return (false);
        }
        return (true);
    }

    private function onShowEffect(se:ShowEffect):void {
        var go:GameObject;
        var particleEffect:ParticleEffect;
        var toPos:Point;
        var time:uint;
        var map:AbstractMap = gs_.map;

        if (Parameters.data_.noParticlesMaster
                && (se.effectType_ == ShowEffect.HEAL_EFFECT_TYPE
                        || se.effectType_ == ShowEffect.TELEPORT_EFFECT_TYPE
                        || se.effectType_ == ShowEffect.STREAM_EFFECT_TYPE
                        || se.effectType_ == ShowEffect.POISON_EFFECT_TYPE
                        || se.effectType_ == ShowEffect.LINE_EFFECT_TYPE
                        || se.effectType_ == ShowEffect.FLOW_EFFECT_TYPE
                        || se.effectType_ == ShowEffect.COLLAPSE_EFFECT_TYPE
                        || se.effectType_ == ShowEffect.CONEBLAST_EFFECT_TYPE)) {
            return;
        }

        switch (se.effectType_) {
            case ShowEffect.HEAL_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                map.addObj(new HealEffect(go, se.color_), go.x_, go.y_);
                return;
            case ShowEffect.TELEPORT_EFFECT_TYPE:
                map.addObj(new TeleportEffect(), se.pos1_.x_, se.pos1_.y_);
                return;
            case ShowEffect.STREAM_EFFECT_TYPE:
                particleEffect = new StreamEffect(se.pos1_, se.pos2_, se.color_);
                map.addObj(particleEffect, se.pos1_.x_, se.pos1_.y_);
                return;
            case ShowEffect.THROW_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                toPos = (go != null ? new Point(go.x_, go.y_) : se.pos2_.toPoint());
                particleEffect = new ThrowEffect(toPos, se.pos1_.toPoint(), se.color_, se.duration_);
                map.addObj(particleEffect, toPos.x, toPos.y);
                return;
            case ShowEffect.NOVA_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new NovaEffect(go, se.pos1_.x_, se.color_);
                map.addObj(particleEffect, go.x_, go.y_);
                return;
            case ShowEffect.POISON_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new PoisonEffect(go, se.color_);
                map.addObj(particleEffect, go.x_, go.y_);
                return;
            case ShowEffect.LINE_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new LineEffect(go, se.pos1_, se.color_);
                map.addObj(particleEffect, se.pos1_.x_, se.pos1_.y_);
                return;
            case ShowEffect.BURST_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new BurstEffect(go, se.pos1_, se.pos2_, se.color_);
                map.addObj(particleEffect, se.pos1_.x_, se.pos1_.y_);
                return;
            case ShowEffect.FLOW_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new FlowEffect(se.pos1_, go, se.color_);
                map.addObj(particleEffect, se.pos1_.x_, se.pos1_.y_);
                return;
            case ShowEffect.RING_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new RingEffect(go, se.pos1_.x_, se.color_);
                map.addObj(particleEffect, go.x_, go.y_);
                return;
            case ShowEffect.LIGHTNING_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new LightningEffect(go, se.pos1_, se.color_, se.pos2_.x_);
                map.addObj(particleEffect, go.x_, go.y_);
                return;
            case ShowEffect.COLLAPSE_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new CollapseEffect(go, se.pos1_, se.pos2_, se.color_);
                map.addObj(particleEffect, se.pos1_.x_, se.pos1_.y_);
                return;
            case ShowEffect.CONEBLAST_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new ConeBlastEffect(go, se.pos1_, se.pos2_.x_, se.color_);
                map.addObj(particleEffect, go.x_, go.y_);
                return;
            case ShowEffect.JITTER_EFFECT_TYPE:
                gs_.camera_.startJitter();
                return;
            case ShowEffect.FLASH_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                go.flash_ = new FlashDescription(getTimer(), se.color_, se.pos1_.x_, se.pos1_.y_);
                return;
            case ShowEffect.THROW_PROJECTILE_EFFECT_TYPE:
                toPos = se.pos1_.toPoint();
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new ThrowProjectileEffect(se.color_, se.pos2_.toPoint(), se.pos1_.toPoint());
                map.addObj(particleEffect, toPos.x, toPos.y);
                return;
            case ShowEffect.SHOCKER_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;
                if (go && go.shockEffect) {
                    go.shockEffect.destroy();
                }

                particleEffect = new ShockerEffect(go);
                go.shockEffect = ShockerEffect(particleEffect);
                gs_.map.addObj(particleEffect, go.x_, go.y_);
                return;
            case ShowEffect.SHOCKEE_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                particleEffect = new ShockeeEffect(go);
                gs_.map.addObj(particleEffect, go.x_, go.y_);
                return;
            case ShowEffect.RISING_FURY_EFFECT_TYPE:
                go = map.goDict_[se.targetObjectId_];
                if (go == null || !this.canShowEffect(go)) break;

                time = (se.pos1_.x_ * 1000);
                particleEffect = new RisingFuryEffect(go, time);
                gs_.map.addObj(particleEffect, go.x_, go.y_);
                return;
        }
    }

    private function onGoto(_arg1:Goto):void {
        this.gotoAck(gs_.lastUpdate_);
        var _local2:GameObject = gs_.map.goDict_[_arg1.objectId_];
        if (_local2 == null) {
            return;
        }
        _local2.onGoto(_arg1.pos_.x_, _arg1.pos_.y_, gs_.lastUpdate_);
    }

    private function updateGameObject(go:GameObject, stats:Vector.<StatData>, isPlayer:Boolean):void {
        var stat:StatData;
        var statVal:int;
        var index:int;
        var player:Player = (go as Player);
        var merchant:Merchant = (go as Merchant);
        for each (stat in stats) {
            statVal = stat.statValue_;
            switch (stat.statType_) {
                case StatData.MAX_HP_STAT:
                    go.maxHP_ = statVal;
                    break;
                case StatData.HP_STAT:
                    go.hp_ = statVal;
                    break;
                case StatData.SIZE_STAT:
                    go.setSize(statVal);
                    break;
                case StatData.MAX_MP_STAT:
                    player.maxMP_ = statVal;
                    break;
                case StatData.MP_STAT:
                    player.mp_ = statVal;
                    break;
                case StatData.NEXT_LEVEL_EXP_STAT:
                    player.nextLevelExp_ = statVal;
                    break;
                case StatData.EXP_STAT:
                    player.exp_ = statVal;
                    break;
                case StatData.LEVEL_STAT:
                    go.level_ = statVal;
                    break;
                case StatData.STRENGTH_STAT:
                    player.strength_ = statVal;
                    break;
                case StatData.WIT_STAT:
                    player.wit_ = statVal;
                    break;
                case StatData.ARMOR_STAT:
                    go.armor_ = statVal;
                    break;
                case StatData.AGILITY_STAT:
                    player.agility_ = statVal;
                    break;
                case StatData.DEXTERITY_STAT:
                    player.dexterity_ = statVal;
                    break;
                case StatData.STAMINA_STAT:
                    player.stamina_ = statVal;
                    break;
                case StatData.INTELLIGENCE_STAT:
                    player.intelligence_ = statVal;
                    break;
                case StatData.CONDITION_STAT:
                    go.condition_[ConditionEffect.CE_FIRST_BATCH] = statVal;
                    break;
                case StatData.INVENTORY_STAT:
                    go.equipment_ = stat.itemsValue_;
                    break;
                case StatData.NUM_STARS_STAT:
                    player.numStars_ = statVal;
                    break;
                case StatData.NAME_STAT:
                    if (go.name_ != stat.strStatValue_) {
                        go.name_ = stat.strStatValue_;
                        go.nameBitmapData_ = null;
                    }
                    break;
                case StatData.TEX1_STAT:
                    (((statVal >= 0)) && (go.setTex1(statVal)));
                    break;
                case StatData.TEX2_STAT:
                    (((statVal >= 0)) && (go.setTex2(statVal)));
                    break;
                case StatData.MERCHANDISE_TYPE_STAT:
                    merchant.setMerchandiseType(statVal);
                    break;
                case StatData.CREDITS_STAT:
                    player.setCredits(statVal);
                    break;
                case StatData.MERCHANDISE_PRICE_STAT:
                    (go as SellableObject).setPrice(statVal);
                    break;
                case StatData.ACTIVE_STAT:
                    (go as Portal).active_ = statVal != 0;
                    break;
                case StatData.ACCOUNT_ID_STAT:
                    player.accountId_ = stat.strStatValue_;
                    break;
                case StatData.FAME_STAT:
                    player.fame_ = statVal;
                    break;
                case StatData.FORTUNE_TOKEN_STAT:
                    player.setTokens(statVal);
                    break;
                case StatData.MERCHANDISE_CURRENCY_STAT:
                    (go as SellableObject).setCurrency(statVal);
                    break;
                case StatData.CONNECT_STAT:
                    go.connectType_ = statVal;
                    break;
                case StatData.MERCHANDISE_COUNT_STAT:
                    merchant.count_ = statVal;
                    merchant.untilNextMessage_ = 0;
                    break;
                case StatData.MERCHANDISE_MINS_LEFT_STAT:
                    merchant.minsLeft_ = statVal;
                    merchant.untilNextMessage_ = 0;
                    break;
                case StatData.MERCHANDISE_DISCOUNT_STAT:
                    merchant.discount_ = statVal;
                    merchant.untilNextMessage_ = 0;
                    break;
                case StatData.MERCHANDISE_RANK_REQ_STAT:
                    (go as SellableObject).setRankReq(statVal);
                    break;
                case StatData.MAX_HP_BOOST_STAT:
                    player.maxHPBoost_ = statVal;
                    break;
                case StatData.MAX_MP_BOOST_STAT:
                    player.maxMPBoost_ = statVal;
                    break;
                case StatData.STRENGTH_BOOST_STAT:
                    player.strengthBoost_ = statVal;
                    break;
                case StatData.WIT_BOOST_STAT:
                    player.witBoost_ = statVal;
                    break;
                case StatData.ARMOR_BOOST_STAT:
                    player.armorBoost_ = statVal;
                    break;
                case StatData.AGILITY_BOOST_STAT:
                    player.agilityBoost_ = statVal;
                    break;
                case StatData.STAMINA_BOOST_STAT:
                    player.staminaBoost_ = statVal;
                    break;
                case StatData.INTELLIGENCE_BOOST_STAT:
                    player.intelligenceBoost_ = statVal;
                    break;
                case StatData.DEXTERITY_BOOST_STAT:
                    player.dexterityBoost_ = statVal;
                    break;
                case StatData.OWNER_ACCOUNT_ID_STAT:
                    (go as Container).setOwnerId(stat.strStatValue_);
                    break;
                case StatData.RANK_REQUIRED_STAT:
                    (go as NameChanger).setRankRequired(statVal);
                    break;
                case StatData.NAME_CHOSEN_STAT:
                    player.nameChosen_ = statVal != 0;
                    go.nameBitmapData_ = null;
                    break;
                case StatData.CURR_FAME_STAT:
                    player.currFame_ = statVal;
                    break;
                case StatData.NEXT_CLASS_QUEST_FAME_STAT:
                    player.nextClassQuestFame_ = statVal;
                    break;
                case StatData.GLOW_COLOR_STAT:
                    player.setGlow(statVal);
                    break;
                case StatData.SINK_LEVEL_STAT:
                    if (!isPlayer) {
                        player.sinkLevel_ = statVal;
                    }
                    break;
                case StatData.ALT_TEXTURE_STAT:
                    go.setAltTexture(statVal);
                    break;
                case StatData.GUILD_NAME_STAT:
                    player.setGuildName(stat.strStatValue_);
                    break;
                case StatData.GUILD_RANK_STAT:
                    player.guildRank_ = statVal;
                    break;
                case StatData.BREATH_STAT:
                    player.breath_ = statVal;
                    break;
                case StatData.XP_BOOSTED_STAT:
                    player.xpBoost_ = statVal;
                    break;
                case StatData.XP_TIMER_STAT:
                    player.xpTimer = (statVal * TO_MILLISECONDS);
                    break;
                case StatData.LD_TIMER_STAT:
                    player.dropBoost = (statVal * TO_MILLISECONDS);
                    break;
                case StatData.LT_TIMER_STAT:
                    player.tierBoost = (statVal * TO_MILLISECONDS);
                    break;
                case StatData.HEALTH_STACK_COUNT:
                    player.healthStackCount_ = statVal;
                    break;
                case StatData.MAGIC_STACK_COUNT:
                    player.magicStackCount_ = statVal;
                    break;
                case StatData.TEXTURE_STAT:
                    ((((!((player.skinId == statVal))) && ((statVal >= 0)))) && (this.setPlayerSkinTemplate(player, statVal)));
                    break;
                case StatData.HASBACKPACK_STAT:
                    player.hasBackpack_ = Boolean(statVal);
                    if (isPlayer) {
                        Global.updateBackpackTab(Boolean(statVal));
                    }
                    break;
                case StatData.NEW_CON_STAT:
                    go.condition_[ConditionEffect.CE_SECOND_BATCH] = statVal;
                    break;
                case StatData.RANK:
                    player.rank_ = statVal;
                    break;
                case StatData.ADMIN:
                    player.admin_ = statVal == 1;
                    break;
                case StatData.UNHOLY_ESSENCE_STAT:
                    player.setUnholyEssence(statVal);
                    break;
                case StatData.DIVINE_ESSENCE_STAT:
                    player.setDivineEssence(statVal);
                    break;
                case StatData.SHIELD_STAT:
                    player.shield_ = statVal;
                    break;
                case StatData.SHIELD_BOOST_STAT:
                    player.shieldBoost_ = statVal;
                    break;
                case StatData.SHIELDPOINTS:
                    player.shieldPoints_ = statVal;
                    break;
                case StatData.SHIELDMAX:
                    player.shieldPointsMax_ = statVal;
                    break;
                case StatData.LIGHTMAX:
                    player.lightMax_ = statVal;
                    break;
                case StatData.LIGHT:
                    player.light_ = statVal;
                    break;
                case StatData.HASTE:
                    player.haste_ = statVal;
                    break;
                case StatData.HASTE_BOOST:
                    player.hasteBoost_ = statVal;
                    break;
                case StatData.TENACITY:
                    player.tenacity_ = statVal;
                    break;
                case StatData.TENACITY_BOOST:
                    player.tenacityBoost_ = statVal;
                    break;
                case StatData.CRITICAL_STRIKE:
                    player.criticalStrike_ = statVal;
                    break;
                case StatData.CRITICAL_STRIKE_BOOST:
                    player.criticalStrikeBoost_ = statVal;
                    break;
                case StatData.LIFE_STEAL:
                    player.lifeSteal_ = statVal;
                    break;
                case StatData.LIFE_STEAL_BOOST:
                    player.lifeStealBoost_ = statVal;
                    break;
                case StatData.LUCK:
                    player.luck_ = statVal;
                    break;
                case StatData.LUCK_BONUS:
                    player.luckBonus_ = statVal;
                    break;
                case StatData.MANA_LEECH:
                    player.manaLeech_ = statVal;
                    break;
                case StatData.MANA_LEECH_BOOST:
                    player.manaLeechBoost_ = statVal;
                    break;
                case StatData.LIFE_STEAL_KILL:
                    player.lifeStealKill_ = statVal;
                    break;
                case StatData.LIFE_STEAL_KILL_BOOST:
                    player.lifeStealKillBoost_ = statVal;
                    break;
                case StatData.MANA_LEECH_KILL:
                    player.manaLeechKill_ = statVal;
                    break;
                case StatData.MANA_LEECH_KILL_BOOST:
                    player.manaLeechKillBoost_ = statVal;
                    break;
                case StatData.RESISTANCE_STAT:
                    go.resistance_ = statVal;
                    break;
                case StatData.RESISTANCE_BOOST_STAT:
                    player.resistanceBoost_ = statVal;
                    break;
                case StatData.OFFENSIVE_ABILITY_STAT:
                    player.offensiveAbility_ = statVal;
                    break;
                case StatData.DEFENSIVE_ABILITY_STAT:
                    player.defensiveAbility_ = statVal;
                    break;
                case StatData.PET_DATA_STAT:
                    go.petData_ = new PetData(stat.byteArrayValue_);
                    break;
                case StatData.LETHALITY:
                    player.lethality_ = statVal;
                    break;
                case StatData.LETHALITY_BOOST:
                    player.lethalityBoost_ = statVal;
                    break;
                case StatData.PIERCING:
                    player.piercing_ = statVal;
                    break;
                case StatData.PIERCING_BOOST:
                    player.piercingBoost_ = statVal;
                    break;
                case StatData.IMMUNITIES:
                    go.immunities_ = stat.statValues_;
                    break;
            }
        }
    }

    private function setPlayerSkinTemplate(_arg1:Player, _arg2:int):void {
        var _local3:Reskin = (this.messages.require(RESKIN) as Reskin);
        _local3.skinID = _arg2;
        _local3.player = _arg1;
        _local3.consume();
    }

    private function processObjectStatus(_arg1:ObjectStatusData, _arg2:int, _arg3:int):void {
        var _local8:int;
        var _local9:int;
        var _local10:int;
        var _local11:CharacterClass;
        var _local12:XML;
        var _local13:String;
        var _local14:String;
        var _local15:int;
        var _local16:ObjectProperties;
        var _local17:ProjectileProperties;
        var _local18:Array;
        var _local4:AbstractMap = gs_.map;
        var _local5:GameObject = _local4.goDict_[_arg1.objectId_];
        if (_local5 == null) {
            return;
        }
        var _local6:Boolean = (_arg1.objectId_ == this.playerId_);
        var _local19:Boolean = !(Parameters.data_.allyNotifications);
        var isControlled:Boolean = this.player != null && this.player.commune != null && !(this.player.commune is Player) && _arg1.objectId_ == this.player.commune.objectId_;
        if (_arg2 != 0 && !_local6 && !isControlled) {
            _local5.onTickPos(_arg1.pos_.x_, _arg1.pos_.y_, _arg2, _arg3);
        }
        if (_arg1.damageDealt > 0)
            _local5.damageDealt = _arg1.damageDealt;
        var _local7:Player = (_local5 as Player);
        if (_local7 != null) {
            _local8 = _local7.level_;
            _local9 = _local7.exp_;
            _local10 = _local7.skinId;
        }
        this.updateGameObject(_local5, _arg1.stats_, _local6);
        if (_local7) {
            if (_local6) {
                _local11 = this.classesModel.getCharacterClass(_local7.objectType_);
                if (_local11.getMaxLevelAchieved() < _local7.level_) {
                    _local11.setMaxLevelAchieved(_local7.level_);
                }
            }
            if (_local7.skinId != _local10) {
                if (ObjectLibrary.skinSetXMLDataLibrary_[_local7.skinId] != null) {
                    _local12 = (ObjectLibrary.skinSetXMLDataLibrary_[_local7.skinId] as XML);
                    _local13 = _local12.attribute("color");
                    _local14 = _local12.attribute("bulletType");
                    if (((!((_local8 == -1))) && ((_local13.length > 0)))) {
                        _local7.levelUpParticleEffect(uint(_local13));
                    }
                    if (_local14.length > 0) {
                        _local7.projectileIdSetOverrideNew = _local14;
                        _local15 = _local7.equipment_[1].ObjectType;
                        _local16 = ObjectLibrary.propsLibrary_[_local15];
                        _local17 = _local16.projectiles_[0];
                        _local7.projectileIdSetOverrideOld = _local17.objectId_;
                    }
                }
                else {
                    if (ObjectLibrary.skinSetXMLDataLibrary_[_local7.skinId] == null) {
                        _local7.projectileIdSetOverrideNew = "";
                        _local7.projectileIdSetOverrideOld = "";
                    }
                }
            }
            if (_local8 != -1 && _local7.level_ > _local8) {
                if (_local6) {
                    _local18 = gs_.model.getNewUnlocks(_local7.objectType_, _local7.level_);
                    _local7.handleLevelUp(!((_local18.length == 0)));
                }
                else {
                    if (_local19)
                    {
                        _local7.levelUpEffect("Level Up!");
                    }
                }
            }
            else {
                if (((!((_local8 == -1))) && ((_local7.exp_ > _local9)))) {
                    _local7.handleExpUp((_local7.exp_ - _local9));
                }
            }
        }
    }

    private function onInvResult(_arg1:InvResult):void {
        if (_arg1.result_ != 0) {
            this.handleInvFailure();
        }
    }

    private function handleInvFailure():void {
        SoundEffectLibrary.play("error");
        gs_.hud.interactPanel.redraw();
    }

    private function onReconnect(_arg1:Reconnect):void {
        var _local3:int = _arg1.gameId_;
        var _local4:Boolean = createCharacter_;
        var _local5:int = charId_;
        var _local6:int = _arg1.keyTime_;
        var _local7:ByteArray = _arg1.key_;
        var _local8:ReconnectEvent = new ReconnectEvent(_local3, _local4, _local5, _local6, _local7);
        gs_.onReconnect(_local8);
    }

    private function onPing(_arg1:Ping):void {
        var _local2:Pong = (this.messages.require(PONG) as Pong);
        _local2.serial_ = _arg1.serial_;
        _local2.time_ = getTimer();
        serverConnection.queueMessage(_local2);
    }

    private function parseXML(xmlString:String):void {
        var extraXML:XML = XML(xmlString);
        GroundLibrary.parseFromXML(extraXML);
        ObjectLibrary.parseFromXML(extraXML, false);
    }

    private function onMapInfo(_arg1:MapInfo):void {
        var _local2:String;
        var _local3:String;
        for each (_local2 in _arg1.clientXML_) {
            this.parseXML(_local2);
        }
        for each (_local3 in _arg1.extraXML_) {
            this.parseXML(_local3);
        }
        Global.closeDialogs();
        gs_.applyMapInfo(_arg1);
        this.rand_ = new Random(_arg1.fp_);
        Music.load(_arg1.music);
        if (createCharacter_) {
            this.create();
        }
        else {
            this.load();
        }
    }

    private function onPic(_arg1:Pic):void {
        gs_.addChild(new PicView(_arg1.bitmapData_));
    }

    private function onDeath(_arg1:Death):void {
        var gs:GameSprite = this.gs_ as GameSprite;
        gs.serverDisconnect = true;
        gs.disconnect();

        this.death = _arg1;
        var _local2:BitmapData = new BitmapDataSpy(gs_.stage.stageWidth, gs_.stage.stageHeight);
        _local2.draw(gs_);
        _arg1.background = _local2;
        if (!gs_.isEditor) {
            Global.handleDeath(_arg1);
        }
    }

    private function onBuyResult(_arg1:BuyResult):void {
        outstandingBuy_ = false;
        this.handleBuyResultType(_arg1);
    }

    private function handleBuyResultType(_arg1:BuyResult):void {
        var _local2:ChatMessage;
        switch (_arg1.result_) {
            case BuyResult.UNKNOWN_ERROR_BRID:
                _local2 = ChatMessage.make(Parameters.SERVER_CHAT_NAME, _arg1.resultString_);
                Global.addTextLine(_local2);
                return;
            case BuyResult.NOT_ENOUGH_GOLD_BRID:
                Global.openDialog(new NotEnoughGoldDialog());
                return;
            case BuyResult.NOT_ENOUGH_FAME_BRID:
                Global.openDialog(new NotEnoughFameDialog());
                return;
            default:
                this.handleDefaultResult(_arg1);
        }
    }

    private function handleDefaultResult(_arg1:BuyResult):void {
        var _local2:LineBuilder = LineBuilder.fromJSON(_arg1.resultString_);
        var _local3:Boolean = (((_arg1.result_ == BuyResult.SUCCESS_BRID)) || ((_arg1.result_ == BuyResult.PET_FEED_SUCCESS_BRID)));
        var _local4:ChatMessage = ChatMessage.make(_local3 ? Parameters.SERVER_CHAT_NAME : Parameters.ERROR_CHAT_NAME, _local2.key);
        _local4.tokens = _local2.tokens;
        Global.addTextLine(_local4);
    }

    private function onAccountList(_arg1:AccountList):void {
        if (_arg1.accountListId_ == 0) {
            if (_arg1.lockAction_ != -1) {
                if (_arg1.lockAction_ == 1) {
                    gs_.map.party_.setStars(_arg1);
                }
                else {
                    gs_.map.party_.removeStars(_arg1);
                }
            }
            else {
                gs_.map.party_.setStars(_arg1);
            }
        }
        else {
            if (_arg1.accountListId_ == 1) {
                gs_.map.party_.setIgnores(_arg1);
            }
        }
    }

    private function onQuestObjId(_arg1:QuestObjId):void {
        gs_.map.quest_.setObject(_arg1.objectId_);
    }

    private function onAoe(aoe:Aoe):void {
        var _local4:int;
        var _local5:Vector.<uint>;
        if (this.player == null) {
            this.aoeAck(gs_.lastUpdate_, 0, 0);
            return;
        }
        var _local2:AOEEffect = new AOEEffect(aoe.pos_.toPoint(), aoe.radius_, aoe.color_);
        gs_.map.addObj(_local2, aoe.pos_.x_, aoe.pos_.y_);
        if (((this.player.isInvincible()) || (this.player.isPaused()))) {
            this.aoeAck(gs_.lastUpdate_, this.player.x_, this.player.y_);
            return;
        }
        var _local3:Boolean = (this.player.distTo(aoe.pos_) < aoe.radius_);
        if (_local3) {
            _local4 = GameObject.damageWithArmor(aoe.damage_, this.player, this.player.condition_, DamageTypes.Magical);
            _local5 = null;
            if (aoe.effect_ != 0) {
                _local5 = new Vector.<uint>();
                _local5.push(aoe.effect_);
            }
            this.player.damage(_local4, _local5, false, null);
        }
        this.aoeAck(gs_.lastUpdate_, this.player.x_, this.player.y_);
    }

    private function onNameResult(_arg1:NameResult):void {
        gs_.dispatchEvent(new NameResultEvent(_arg1));
    }

    private function onGuildResult(_arg1:GuildResult):void {
        var _local2:LineBuilder;
        if (_arg1.lineBuilderJSON == "") {
            gs_.dispatchEvent(new GuildResultEvent(_arg1.success_, "", {}));
        }
        else {
            _local2 = LineBuilder.fromJSON(_arg1.lineBuilderJSON);
            Global.addTextLine(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _local2.key, -1, -1, "", false, _local2.tokens));
            gs_.dispatchEvent(new GuildResultEvent(_arg1.success_, _local2.key, _local2.tokens));
        }
    }

    private function onClientStat(_arg1:ClientStat):void {
        var _local2:Account = Global.account;
        _local2.reportIntStat(_arg1.name_, _arg1.value_);
    }

    private function onFile(_arg1:File):void {
        new FileReference().save(_arg1.file_, _arg1.filename_);
    }

    private function onInvitedToGuild(_arg1:InvitedToGuild):void {
        if (Parameters.data_.showGuildInvitePopup) {
            gs_.hud.interactPanel.setOverride(new GuildInvitePanel(gs_, _arg1.name_, _arg1.guildName_));
        }
        Global.addTextLine(ChatMessage.make("", (((((("You have been invited by " + _arg1.name_) + " to join the guild ") + _arg1.guildName_) + '.\n  If you wish to join type "/join ') + _arg1.guildName_) + '"')));
    }

    private function onPlaySound(_arg1:PlaySound):void {
        var _local2:GameObject = gs_.map.goDict_[_arg1.ownerId_];
        ((_local2) && (_local2.playSound(_arg1.soundId_)));
    }

    private function onVerifyEmail(_arg1:VerifyEmail):void {
        TitleView.queueEmailConfirmation = true;
        if (gs_ != null) {
            gs_.close();
        }
        Global.hideMapLoading();
    }

    private function onPasswordPrompt(_arg1:PasswordPrompt):void {
        if (_arg1.cleanPasswordStatus == 3) {
            TitleView.queuePasswordPromptFull = true;
        }
        else {
            if (_arg1.cleanPasswordStatus == 2) {
                TitleView.queuePasswordPrompt = true;
            }
            else {
                if (_arg1.cleanPasswordStatus == 4) {
                    TitleView.queueRegistrationPrompt = true;
                }
            }
        }
        if (gs_ != null) {
            gs_.close();
        }
        Global.hideMapLoading();
    }

     public function keyInfoRequest(_arg1:int):void {
        var _local2:KeyInfoRequest = (this.messages.require(KEY_INFO_REQUEST) as KeyInfoRequest);
        _local2.itemType_ = _arg1;
        serverConnection.queueMessage(_local2);
    }

    private function onKeyInfoResponse(_arg1:KeyInfoResponse):void {
        this.keyInfoResponse.dispatch(_arg1);
    }

    private function onClosed():void {
        if (this.playerId_ != -1) {
            gs_.close();
        }
        else {
            if (this.retryConnection_) {
                if (this.delayBeforeReconnect < 10) {
                    if (this.delayBeforeReconnect == 6) {
                        Global.hideMapLoading();
                    }
                    this.retry(this.delayBeforeReconnect++);
                    Global.addTextLine(ChatMessage.make(Parameters.ERROR_CHAT_NAME, "Connection failed!  Retrying..."));
                }
                else {
                    gs_.close();
                }
            }
        }
    }

    private function retry(_arg1:int):void {
        this.retryTimer_ = new Timer((_arg1 * 1000), 1);
        this.retryTimer_.addEventListener(TimerEvent.TIMER_COMPLETE, this.onRetryTimer);
        this.retryTimer_.start();
    }

    private function onRetryTimer(_arg1:TimerEvent):void {
        serverConnection.connect(server_.address, server_.port);
    }

    private function onError(_arg1:String):void {
        Global.addTextLine(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _arg1));
    }

    private function onFailure(_arg1:Failure):void {
        // remove loading screen
        Global.hideMapLoading();
        switch (_arg1.errorId_) {
            case Failure.INCORRECT_VERSION:
                this.handleIncorrectVersionFailure(_arg1);
                return;
            case Failure.BAD_KEY:
                this.handleBadKeyFailure(_arg1);
                return;
            case Failure.INVALID_TELEPORT_TARGET:
                this.handleInvalidTeleportTarget(_arg1);
                return;
            case Failure.EMAIL_VERIFICATION_NEEDED:
                this.handleEmailVerificationNeeded(_arg1);
                return;
            case Failure.JSON_DIALOG:
                this.handleJsonDialog(_arg1);
                return;
            case Failure.DEFAULT_FAILURE2:
                this.handleDefaultFailure2(_arg1);
                return;
            default:
                this.handleDefaultFailure(_arg1);
        }
    }

    private function handleJsonDialog(_arg1:Failure):void {
        var errorMsg:Object = this.json_.parse(_arg1.errorDescription_);
        var dlg:Dialog;

        // check for correct client version
        if (Parameters.FULL_BUILD != errorMsg.build) {
            handleIncorrectVersionFailureBasic(errorMsg.build);
            return;
        }

        // correct version, display custom json dialog
        dlg = new Dialog(errorMsg.title, errorMsg.description, "Ok", null, null);
        dlg.addEventListener(Dialog.LEFT_BUTTON, this.onDoClientUpdate);
        this.gs_.addChild(dlg);
        this.retryConnection_ = false;
    }

    private function handleEmailVerificationNeeded(_arg1:Failure):void {
        this.retryConnection_ = false;
        gs_.close();
    }

    private function handleInvalidTeleportTarget(_arg1:Failure):void {
        var _local2:String = LineBuilder.getLocalizedStringFromJSON(_arg1.errorDescription_);
        if (_local2 == "") {
            _local2 = _arg1.errorDescription_;
        }
        Global.addTextLine(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _local2));
        this.player.nextTeleportAt_ = 0;
    }

    private function handleBadKeyFailure(_arg1:Failure):void {
        var _local2:String = LineBuilder.getLocalizedStringFromJSON(_arg1.errorDescription_);
        if (_local2 == "") {
            _local2 = _arg1.errorDescription_;
        }
        Global.addTextLine(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _local2));
        this.retryConnection_ = false;
        gs_.close();
    }

    private function handleIncorrectVersionFailure(_arg1:Failure):void {
        handleIncorrectVersionFailureBasic(_arg1.errorDescription_);
    }

    private function handleIncorrectVersionFailureBasic(description:String):void {
        var _local2:Dialog = new Dialog("Client Update Needed", "", "Ok", null, "/clientUpdate");
        _local2.setTextParams("Client version: {client}\nServer version: {server}", {
            "client": Parameters.FULL_BUILD,
            "server": description
        });
        _local2.addEventListener(Dialog.LEFT_BUTTON, this.onDoClientUpdate);
        this.gs_.addChild(_local2);
        this.retryConnection_ = false;
    }

    private function handleDefaultFailure(_arg1:Failure):void {
        var _local2:String = LineBuilder.getLocalizedStringFromJSON(_arg1.errorDescription_);
        if (_local2 == "") {
            _local2 = _arg1.errorDescription_;
        }
        Global.addTextLine(ChatMessage.make(Parameters.ERROR_CHAT_NAME, _local2));
    }

    private function handleDefaultFailure2(_arg1:Failure):void {
        var _local2:String = LineBuilder.getLocalizedStringFromJSON(_arg1.errorDescription_);
        if (_local2 == "") {
            _local2 = _arg1.errorDescription_;
        }
        Global.addTextLine(ChatMessage.make("@", _local2));
    }

    private function onDoClientUpdate(_arg1:Event):void {
        var _local2:Dialog = (_arg1.currentTarget as Dialog);
        _local2.parent.removeChild(_local2);
        gs_.close();
    }

     public function isConnected():Boolean {
        return (serverConnection.isConnected());
    }

    private function setFocus(pkt:SetFocus):void {
        var goDict:Dictionary = this.gs_.map.goDict_;
        if (goDict) {
            var go:GameObject = goDict[pkt.objectId_];
            Global.setGameFocusDirect(go);
            player.commune = playerId_ == pkt.objectId_ ? null : go;
        }
    }

    // Quests- Fetching Available Quests
    private static function onFetchAvailableQuestsResult(result:FetchAvailableQuestsResult) : void {
        FetchAvailableQuestsSignal.instance.dispatch(result);
    }

    // Look for available quests
    public function fetchAvailableQuests() : void {
        var search:FetchAvailableQuests = this.messages.require(FETCH_AVAILABLE_QUESTS) as FetchAvailableQuests;
        this.serverConnection.sendMessage(search);
    }

    // Quests- Accept
    public function acceptQuest(questId:int, questType:int = 0) : void {
        var accept:AcceptQuest = this.messages.require(ACCEPT_QUEST) as AcceptQuest;
        accept.id_ = questId;
        accept.type_ = questType;
        this.serverConnection.sendMessage(accept);
    }

    // Quests- Fetching Character Quests
    private static function onFetchCharacterQuestsResult(result:FetchCharacterQuestsResult) : void {
        FetchCharacterQuestsSignal.instance.dispatch(result);
    }

    // Look for character quests
    public function fetchCharacterQuests() : void {
        var search:FetchCharacterQuests = this.messages.require(FETCH_CHARACTER_QUESTS) as FetchCharacterQuests;
        this.serverConnection.sendMessage(search);
    }

    // Quests- Delivering Items
    private static function onDeliverItemsResult(result:DeliverItemsResult) : void {
        DeliverItemsSignal.instance.dispatch(result);
    }

    // Receive mail data
    private static function onFetchMailResult(result:FetchMailResult) : void {
        FetchMailSignal.instance.dispatch(result);
    }

    // Look for mails
    public function fetchMail() : void {
        var search:FetchMail = this.messages.require(FETCH_MAIL) as FetchMail;
        this.serverConnection.sendMessage(search);
    }

    // Look for account quests
    public function fetchAccountQuests() : void {
        var search:FetchAccountQuests = this.messages.require(FETCH_ACCOUNT_QUESTS) as FetchAccountQuests;
        this.serverConnection.sendMessage(search);
    }

    // Receive account quests data
    private static function onFetchAccountQuestsResult(result:FetchAccountQuestsResult) : void {
        FetchAccountQuestsSignal.instance.dispatch(result);
    }

    // Crafting - Craft an Item
    public function craftItem(slots:Vector.<int>): void {
        var craft:CraftItem = this.messages.require(CRAFT_ITEM) as CraftItem;
        craft.slots_ = slots;
        craft.id_ = 0;
        this.serverConnection.sendMessage(craft);
    }

    // Crafting response (animation)
    private static function onCraftAnimation(result:CraftAnimation) : void {
        CraftAnimationSignal.instance.dispatch(result);
    }

    // Crafting - Inserting Rune on item
    public function insertRune(itemSlot:int, runeSlot:int): void {
        var craft:CraftItem = this.messages.require(CRAFT_ITEM) as CraftItem;
        // required to send packet but not on the server
        craft.slots_ = new Vector.<int>(0);
        craft.itemSlot_ = itemSlot;
        craft.runeSlot_ = runeSlot;
        craft.id_ = 1;
        this.serverConnection.sendMessage(craft);
    }

    // Look for pets
    public function fetchPets():void {
        var search:FetchPets = this.messages.require(FETCH_PETS) as FetchPets;
        this.serverConnection.sendMessage(search);
    }

    // Receive account's pet data
    private static function onFetchPetsResult(result:FetchPetsResult):void {
        FetchPetsSignal.instance.dispatch(result);
    }

    // Delete pet
    public function deletePet(petData:PetData):void {
        var deletePet:DeletePet = this.messages.require(DELETE_PET) as DeletePet;
        deletePet.petData_ = petData;
        this.serverConnection.sendMessage(deletePet);
    }

    // Pet follow/unfollow
    public function petFollow(petData:PetData):void {
        var petFollow:PetFollow = this.messages.require(PET_FOLLOW) as PetFollow;
        petFollow.petData_ = petData;
        this.serverConnection.sendMessage(petFollow);
    }

    // Get game time
    private static function onCurrentTime(result:CurrentTime):void {
        instance.gs_.gameTime = result.hour_;
        instance.gs_.showClock(instance.gs_.gameTime);
        instance.gs_.drawOverlay(instance.gs_.gameTime);
    }
}
}

