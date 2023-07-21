package kabam.rotmg.ui.view {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.ExperienceBoostTimerPopup;
import com.company.assembleegameclient.ui.StatusBar;
import com.company.assembleegameclient.ui.TradePanel;
import com.company.assembleegameclient.ui.panels.InteractPanel;
import com.company.assembleegameclient.ui.panels.itemgrids.EquippedGrid;
import com.company.util.SpriteUtil;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Utils3D;

import kabam.rotmg.game.view.CooldownTimer;
import kabam.rotmg.game.view.components.TabStripView;
import kabam.rotmg.messaging.impl.incoming.TradeAccepted;
import kabam.rotmg.messaging.impl.incoming.TradeChanged;
import kabam.rotmg.messaging.impl.incoming.TradeStart;

import thyrr.ui.utils.HUDViewBackground;
import thyrr.utils.Utils;


public class HUDView extends Sprite implements UnFocusAble {

    private const BACKGROUND_POSITION:Point = new Point(0, 0);
    private const BAR_POSITION:Point = new Point(40, BACKGROUND_POSITION.y + 254);
    private const EQUIPMENT_POSITION:Point = new Point(146, BAR_POSITION.y + 90);
    private const INVENTORY_POSITION:Point = new Point(95, EQUIPMENT_POSITION.y + 43);
    private const INTERACT_PANEL_POSITION:Point = new Point(88, WebMain.DefaultHeight - 100);

    private var background:HUDViewBackground;
    private var xpBar:StatusBar;
    private var mpBar:StatusBar;
    private var hpBar:StatusBar;
    public var _equippedGrid:EquippedGrid;
    private var player:Player;
    private var cdTimer:CooldownTimer;
    public var tabStrip:TabStripView;
    public var interactPanel:InteractPanel;
    public var tradePanel:TradePanel;

    public function HUDView() {
        this.createAssets();
        this.addAssets();
        this.positionAssets();
    }

    private function createAssets():void {
        this.background = new HUDViewBackground();
        this.tabStrip = new TabStripView();
        this.cdTimer = new CooldownTimer();
        this.createStatusBars();
    }

    private function addAssets():void {
        addChild(this.background);
        addChild(this.tabStrip);
        this.addStatusBars();
    }

    private function positionAssets():void {
        this.background.x = this.BACKGROUND_POSITION.x;
        this.background.y = this.BACKGROUND_POSITION.y;
        this.tabStrip.x = this.INVENTORY_POSITION.x - 44 * 2;
        this.tabStrip.y = this.INVENTORY_POSITION.y;
    }

    public function setPlayerDependentAssets(_arg1:GameSprite):void {
        this.player = _arg1.map.player_;
        this.createEquippedGrid();
        this.createInteractPanel(_arg1);
        this.createCooldownTimer();
    }

    public function tick(player:Player):void
    {
        xpBar.setLabelText("{level}", {"level": player.level_});
        xpBar.draw(player.exp_, player.nextLevelExp_, 0);
        if (player.level_ != 301) {
            if (this.expTimer) {
                this.expTimer.update(player.xpTimer);
            }
            if (this.curXPBoost != player.xpBoost_) {
                this.curXPBoost = player.xpBoost_;
                if (this.curXPBoost) {
                    xpBar.showMultiplierText();
                } else {
                    xpBar.hideMultiplierText();
                }
            }
            if (player.xpTimer) {
                if (!this.areTempXpListenersAdded) {
                    xpBar.addEventListener("MULTIPLIER_OVER", this.onExpBarOver);
                    xpBar.addEventListener("MULTIPLIER_OUT", this.onExpBarOut);
                    this.areTempXpListenersAdded = true;
                }
            } else {
                if (this.areTempXpListenersAdded) {
                    xpBar.removeEventListener("MULTIPLIER_OVER", this.onExpBarOver);
                    xpBar.removeEventListener("MULTIPLIER_OUT", this.onExpBarOut);
                    this.areTempXpListenersAdded = false;
                }
                if (((this.expTimer) && (this.expTimer.parent))) {
                    removeChild(this.expTimer);
                    this.expTimer = null;
                }
            }
            //fameBar.draw(player.currFame_, player.nextClassQuestFame_, 0);
        }
        hpBar.draw(player.hp_, player.maxHP_, player.maxHPBoost_, player.maxHPMax_);
        mpBar.draw(player.mp_, player.maxMP_, player.maxMPBoost_, player.maxMPMax_);
    }

    private function createCooldownTimer():void {
        this.cdTimer.x = _equippedGrid.x + 44;
        this.cdTimer.y = _equippedGrid.y;
        addChild(cdTimer);
    }

    private function createInteractPanel(_arg1:GameSprite):void {
        this.interactPanel = new InteractPanel(_arg1, this.player, 200, 100);
        this.interactPanel.x = this.INTERACT_PANEL_POSITION.x;
        this.interactPanel.y = this.INTERACT_PANEL_POSITION.y;
        addChild(this.interactPanel);
    }

    private function createEquippedGrid():void {
        _equippedGrid = new EquippedGrid(this.player, this.player.slotTypes_, this.player);
        _equippedGrid.x = this.EQUIPMENT_POSITION.x - _equippedGrid.width / 2;
        _equippedGrid.y = this.EQUIPMENT_POSITION.y;
        this._equippedGrid.filters = [Utils.OutlineFilter];
        addChild(_equippedGrid);
    }

    private function createStatusBars():void
    {
        xpBar = new StatusBar(228, 18, 0x309C63, 0xAEA9A9, "{level}", 0x50);
        this.xpBar.filters = [Utils.OutlineFilter];
        xpBar.x = BAR_POSITION.x;
        xpBar.y = BAR_POSITION.y;
        hpBar = new StatusBar(228, 18, 0xC93038, 0xAEA9A9, null, 0x51);
        this.hpBar.filters = [Utils.OutlineFilter];
        hpBar.x = BAR_POSITION.x;
        hpBar.y = xpBar.y + 30;
        mpBar = new StatusBar(228, 18, 0x852D66, 0xAEA9A9, null, 0x52);
        this.mpBar.filters = [Utils.OutlineFilter];
        mpBar.x = BAR_POSITION.x;
        mpBar.y = hpBar.y + 30;
    }

    private function addStatusBars():void
    {
        addChild(xpBar);
        addChild(hpBar);
        addChild(mpBar);
    }

    private var areTempXpListenersAdded:Boolean;
    private var curXPBoost:int;
    private var expTimer:ExperienceBoostTimerPopup;

    private function onExpBarOver(_arg1:Event):void {
        addChild((this.expTimer = new ExperienceBoostTimerPopup()));
    }

    private function onExpBarOut(_arg1:Event):void {
        if (((this.expTimer) && (this.expTimer.parent))) {
            removeChild(this.expTimer);
            this.expTimer = null;
        }
    }

    public function draw():void {
        if (_equippedGrid) {
            _equippedGrid.draw();
        }
        if (this.interactPanel) {
            this.interactPanel.draw();
        }
    }

    public function startTrade(_arg1:GameSprite, _arg2:TradeStart):void {
        if (this.tradePanel == null) {
            this.tradePanel = new TradePanel(_arg1, _arg2);
            this.tradePanel.y = 200;
            this.tradePanel.addEventListener(Event.CANCEL, this.onTradeCancel);
            addChild(this.tradePanel);
            this.setNonTradePanelAssetsVisible(false);
        }
    }

    private function setNonTradePanelAssetsVisible(_arg1:Boolean):void {
        this.tabStrip.visible = _arg1;
        _equippedGrid.visible = _arg1;
        this.interactPanel.visible = _arg1;
    }

    public function tradeDone():void {
        this.removeTradePanel();
    }

    public function tradeChanged(_arg1:TradeChanged):void {
        if (this.tradePanel) {
            this.tradePanel.setYourOffer(_arg1.offer_);
        }
    }

    public function tradeAccepted(_arg1:TradeAccepted):void {
        if (this.tradePanel) {
            this.tradePanel.youAccepted(_arg1.myOffer_, _arg1.yourOffer_);
        }
    }

    private function onTradeCancel(_arg1:Event):void {
        this.removeTradePanel();
    }

    private function removeTradePanel():void {
        if (this.tradePanel) {
            SpriteUtil.safeRemoveChild(this, this.tradePanel);
            this.tradePanel.removeEventListener(Event.CANCEL, this.onTradeCancel);
            this.tradePanel = null;
            this.setNonTradePanelAssetsVisible(true);
        }
    }

}
}
