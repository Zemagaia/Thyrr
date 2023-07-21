package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.objects.SellableObject;
import com.company.assembleegameclient.util.Currency;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;

import kabam.rotmg.util.ItemWithTooltip;
import thyrr.oldui.PetsViewAssetFactory;

import kabam.rotmg.text.view.TextFieldConcreteBuilder;
import kabam.rotmg.util.components.LegacyBuyButton;

import org.osflash.signals.Signal;

import thyrr.oldui.PopupWindowBackground;
import thyrr.oldui.closeButton.DialogCloseButton;

public class ConfirmBuyModal extends Sprite {

    public static const WIDTH:int = 280;
    public static const TEXT_MARGIN:int = 20;

    public static var free:Boolean = true;

    private const closeButton:DialogCloseButton = PetsViewAssetFactory.returnCloseButton(ConfirmBuyModal.WIDTH);
    private const buyButton:LegacyBuyButton = new LegacyBuyButton("Buy for {cost}", 16, 0, Currency.INVALID);

    private var owner_:SellableObject;
    public var buyItem:Signal;
    public var open:Boolean;
    public var buttonWidth:int;
    private var item_:ItemWithTooltip;
    private var nameText_:TextFieldDisplayConcrete;
    private var background_:PopupWindowBackground = new PopupWindowBackground();

    public function ConfirmBuyModal(buyItem:Signal, owner:SellableObject, width:Number):void {
        var textField:TextFieldConcreteBuilder;
        super();
        ConfirmBuyModal.free = false;
        this.buyItem = buyItem;
        this.owner_ = owner;
        this.buttonWidth = width;
        this.events();
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
        this.addChildren();
        this.buyButton.setPrice(this.owner_.price_, this.owner_.currency_);
        var itemName:String = this.owner_.soldObjectName();
        textField = new TextFieldConcreteBuilder();
        textField.containerMargin = TEXT_MARGIN;
        textField.containerWidth = WIDTH;
        this.nameText_ = textField.getLocalizedTextObject(itemName, TEXT_MARGIN, 0);
        this.nameText_.filters = [new DropShadowFilter(0, 0, 0)];
        this.nameText_.textChanged.addOnce(positionAndStuff);
        addChild(textField.getLocalizedTextObject("Confirm Purchase", TEXT_MARGIN, 5));
        addChild(textField.getLocalizedTextObject("Are you sure that you want to buy this item?", TEXT_MARGIN, 40));
        addChild(this.nameText_);
        if (this.owner_.getSellableType() != -1) {
            this.item_ = new ItemWithTooltip(this.owner_.getSellableType(), 64);
        }
        this.item_.x = (((WIDTH * 1) / 2) - (this.item_.width / 2));
        addChild(this.item_);
        this.open = true;
    }

    private function makeModalBackground(width:int, height:int):void {
        this.background_.draw(width, height);
        this.background_.divide(PopupWindowBackground.HORIZONTAL_DIVISION, 30);
    }

    private function positionAndStuff():void {
        this.item_.y = 90 - this.item_.height / 3;
        this.nameText_.y = this.item_.y + this.item_.height;
        this.buyButton.x = WIDTH / 2 - this.buttonWidth / 2;
        this.buyButton.y = this.nameText_.y + this.nameText_.height + 12;
        var height:int = this.buyButton.y + this.buyButton.height + 12;
        makeModalBackground(ConfirmBuyModal.WIDTH, height);
        this.x = -WebMain.DefaultWidth / 2 + WIDTH / 4 - 10;
        this.y = -WebMain.DefaultHeight / 2 + ((200 - height) / 2);
    }

    private function events():void {
        this.closeButton.clicked.add(this.onCloseClick);
        this.buyButton.addEventListener(MouseEvent.CLICK, onBuyClick);
    }

    private function addChildren():void {
        addChild(this.background_);
        addChild(this.closeButton);
        addChild(this.buyButton);
    }

    public function onCloseClick():void {
        this.close();
    }

    public function onBuyClick(event:MouseEvent):void {
        this.buyItem.dispatch(this.owner_);
        this.close();
    }

    private function close():void {
        parent.removeChild(this);
        ConfirmBuyModal.free = true;
        this.open = false;
    }

    private function onRemovedFromStage(event:Event):void {
        ConfirmBuyModal.free = true;
        this.open = false;
    }
}
}
