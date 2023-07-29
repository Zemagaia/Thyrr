package kabam.rotmg.game.view {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Merchant;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.SellableObject;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.ConfirmBuyModal;
import com.company.assembleegameclient.ui.RankText;
import com.company.assembleegameclient.ui.panels.Panel;
import com.company.assembleegameclient.util.Currency;
import com.company.assembleegameclient.util.GuildUtil;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.view.RegisterPromptDialog;
import kabam.rotmg.game.model.GameModel;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.tooltips.HoverTooltipDelegate;
import kabam.rotmg.ui.view.NotEnoughGoldDialog;
import kabam.rotmg.util.components.LegacyBuyButton;

import org.osflash.signals.Signal;

public class SellableObjectPanel extends Panel {

    public static const TEXT:String = "In order to use {type} you must be a registered user.";
    private const BUTTON_OFFSET:int = 17;

    public var account:Account = Global.account;
    public var gameModel:GameModel = Global.gameModel;
    public var hoverTooltipDelegate:HoverTooltipDelegate;
    private var owner_:SellableObject;
    private var nameText_:TextFieldDisplayConcrete;
    private var buyButton_:LegacyBuyButton;
    private var rankReqText_:Sprite;
    private var guildRankReqText_:TextFieldDisplayConcrete;
    private var icon_:Sprite;
    private var bitmap_:Bitmap;
    private var confirmBuyModal:ConfirmBuyModal;
    private var availableInventoryNumber:int;

    public function SellableObjectPanel(gs:GameSprite, owner:SellableObject) {
        this.hoverTooltipDelegate = new HoverTooltipDelegate();
        super(gs);
        this.nameText_ = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setTextWidth(WIDTH - 8);
        this.nameText_.setBold(true);
        this.nameText_.setStringBuilder(new LineBuilder().setParams("Thing for Sale"));
        this.nameText_.setVerticalAlign(TextFieldDisplayConcrete.BOTTOM);
        this.nameText_.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.nameText_);
        this.icon_ = new Sprite();
        addChild(this.icon_);
        this.bitmap_ = new Bitmap(null);
        this.icon_.addChild(this.bitmap_);
        this.buyButton_ = new LegacyBuyButton("Buy for {cost}", 16, 0, Currency.INVALID);
        this.buyButton_.addEventListener(MouseEvent.CLICK, this.onBuyButtonClick);
        addChild(this.buyButton_);
        this.setOwner(owner);
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        this.hoverTooltipDelegate.setDisplayObject(this);
        this.hoverTooltipDelegate.tooltip = owner.getTooltip();
    }

    private static function createRankReqText(req:int):Sprite {
        var reqText:TextFieldDisplayConcrete;
        var rankText:Sprite;
        var container:Sprite = new Sprite();
        reqText = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setBold(true).setAutoSize(TextFieldAutoSize.CENTER);
        reqText.filters = [new DropShadowFilter(0, 0, 0)];
        container.addChild(reqText);
        rankText = new RankText(req, false, false);
        container.addChild(rankText);
        reqText.textChanged.addOnce(function ():void {
            rankText.x = ((reqText.width * 0.5) + 4);
            rankText.y = (-(rankText.height) / 2);
        });
        reqText.setStringBuilder(new LineBuilder().setParams("Rank Required:"));
        return (container);
    }

    private static function createGuildRankReqText(rankNum:int):TextFieldDisplayConcrete {
        var reqText:TextFieldDisplayConcrete;
        reqText = new TextFieldDisplayConcrete().setSize(16).setColor(0xFF0000).setBold(true).setAutoSize(TextFieldAutoSize.CENTER);
        var rankReq:String = GuildUtil.rankToString(rankNum);
        reqText.setStringBuilder(new LineBuilder().setParams("{amount} Rank Required", {"amount": rankReq}));
        reqText.filters = [new DropShadowFilter(0, 0, 0)];
        return (reqText);
    }

    public function onBuyItem(_arg1:SellableObject):void {
        if (this.account.isRegistered()) {
            if ((((_arg1.currency_ == Currency.GOLD)) && (_arg1.price_ > this.gameModel.player.credits_))) {
                Global.openDialog(new NotEnoughGoldDialog());
            }
            else {
                this.gs_.gsc_.buy(_arg1.objectId_);
            }
        }
        else {
            Global.openDialog(this.makeRegisterDialog(_arg1));
        }
    }

    private function makeRegisterDialog(_arg1:SellableObject):RegisterPromptDialog {
        return (new RegisterPromptDialog(TEXT, {"type": Currency.typeToName(_arg1.currency_)}));
    }

    public function setOwner(owner:SellableObject):void {
        if (owner == this.owner_) {
            return;
        }
        this.owner_ = owner;
        this.buyButton_.setPrice(this.owner_.price_, this.owner_.currency_);
        var itemName:String = this.owner_.soldObjectName();
        this.nameText_.setStringBuilder(new LineBuilder().setParams(itemName));
        this.bitmap_.bitmapData = this.owner_.getIcon();
    }

    public function setInventorySpaceAmount(availableInventoryNumber:int):void {
        this.availableInventoryNumber = availableInventoryNumber;
    }

    private function onAddedToStage(event:Event):void {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        this.icon_.x = WIDTH / 2 - this.icon_.width / 2;
        this.icon_.y = -12;
    }

    private function onRemovedFromStage(event:Event):void {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
        if (((((!((parent == null))) && (!((this.confirmBuyModal == null))))) && (this.confirmBuyModal.open))) {
            parent.removeChild(this.confirmBuyModal);
        }
    }

    private function onBuyButtonClick(event:MouseEvent):void {
        if (ConfirmBuyModal.free) {
            this.buyEvent();
        }
    }

    private function onKeyDown(event:KeyboardEvent):void {
        if ((((((event.keyCode == Parameters.data_.interact)) && ((stage.focus == null)))) && (ConfirmBuyModal.free))) {
            this.buyEvent();
        }
    }

    private function buyEvent():void {
        var account:Account = Global.account;
        if (((((!((parent == null))) && (account.isRegistered()))) && ((this.owner_ is Merchant)))) {
            this.confirmBuyModal = new ConfirmBuyModal(this.owner_, this.buyButton_.width);
            parent.addChild(this.confirmBuyModal);
        }
        else {
            this.onBuyItem(this.owner_);
        }
    }

    override public function draw():void {
        var player:Player = gs_.map.player_;
        this.nameText_.resize();
        this.nameText_.y = 52;
        this.nameText_.x = WIDTH / 2 - this.nameText_.width / 2;
        var rankReq:int = this.owner_.rankReq_;
        if (player.numStars_ < rankReq) {
            if (contains(this.buyButton_)) {
                removeChild(this.buyButton_);
            }
            if ((((this.rankReqText_ == null)) || (!(contains(this.rankReqText_))))) {
                this.rankReqText_ = createRankReqText(rankReq);
                this.rankReqText_.x = ((WIDTH / 2) - (this.rankReqText_.width / 2));
                this.rankReqText_.y = ((HEIGHT - (this.rankReqText_.height / 2)) - 20);
                addChild(this.rankReqText_);
            }
        }
        else {
            if (player.guildRank_ < this.owner_.guildRankReq_) {
                if (contains(this.buyButton_)) {
                    removeChild(this.buyButton_);
                }
                if ((((this.guildRankReqText_ == null)) || (!(contains(this.guildRankReqText_))))) {
                    this.guildRankReqText_ = createGuildRankReqText(this.owner_.guildRankReq_);
                    this.guildRankReqText_.x = ((WIDTH / 2) - (this.guildRankReqText_.width / 2));
                    this.guildRankReqText_.y = ((HEIGHT - (this.guildRankReqText_.height / 2)) - 20);
                    addChild(this.guildRankReqText_);
                }
            }
            else {
                this.buyButton_.setPrice(this.owner_.price_, this.owner_.currency_);
                this.buyButton_.setEnabled(!gs_.gsc_.outstandingBuy_);
                this.buyButton_.x = int(((WIDTH / 2) - (this.buyButton_.width / 2)));
                this.buyButton_.y = ((HEIGHT - (this.buyButton_.height / 2)) - this.BUTTON_OFFSET);
                if (!contains(this.buyButton_)) {
                    addChild(this.buyButton_);
                }
                if (((!((this.rankReqText_ == null))) && (contains(this.rankReqText_)))) {
                    removeChild(this.rankReqText_);
                }
            }
        }
    }


}
}
