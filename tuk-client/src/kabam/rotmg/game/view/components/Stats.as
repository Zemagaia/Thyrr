package kabam.rotmg.game.view.components
{

import com.company.assembleegameclient.objects.Player;

import flash.display.Sprite;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.game.model.StatModel;
import kabam.rotmg.game.view.components.Stat;
import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

import thyrr.oldui.TabSwitchButtons;
import thyrr.ui.buttons.HoldableButton;
import thyrr.ui.buttons.ToggleableButton;
import thyrr.ui.items.SimpleBox;
import thyrr.utils.Utils;

public class Stats extends Sprite
{

    private static const statsModel:Array = [ "STR", "WIT", "ARM", "RES", "AGL", "DEX" ];
    private static const statsModel2:Array = [ "STA", "INT", "LCK", "HST", "TEN", "CRT" ];
    private static const statsModel3:Array = ["HPH", "MPH", "HPK", "MPK", "LTH", "PRC" ];

    private var background:SimpleBox;
    private var backgroundBar:SimpleBox;
    private var closeButton:HoldableButton;
    private var extraButton:ToggleableButton;
    private var tabNum:TextFieldDisplayConcrete;
    private var tabButtons:TabSwitchButtons;
    private var stats_:Vector.<Stat>;
    private var stats2_:Vector.<Stat>;
    private var stats3_:Vector.<Stat>;
    private var containerSprite:Sprite;
    private var containerSprite2:Sprite;
    private var containerSprite3:Sprite;
    private var ignoreValues:Boolean;
    private var tabStrip:TabStrip;

    public function Stats(tabStrip:TabStrip)
    {
        this.tabStrip = tabStrip;
        this.background = new SimpleBox(264, 66, 0x5F5C5C).setOutline(0xaea9a9);
        this.backgroundBar = new SimpleBox(264 - 96, 24, 0x807D7D).setOutline(0xaea9a9);
        this.closeButton = new HoldableButton(24, 24, 0xaea9a9, 0x02, false);
        this.closeButton.clicked.addOnce(close);
        this.extraButton = new ToggleableButton(24, 24, 0xaea9a9, 0x0a, false);
        this.tabButtons = new TabSwitchButtons();
        this.tabButtons.setTabs(3);
        this.tabButtons.y = 88;
        this.closeButton.y = this.extraButton.y = this.tabButtons.y - 24;
        this.stats_ = new Vector.<Stat>();
        this.stats2_ = new Vector.<Stat>();
        this.stats3_ = new Vector.<Stat>();
        this.containerSprite = new Sprite();
        this.containerSprite2 = new Sprite();
        this.containerSprite3 = new Sprite();
        super();
        addChild(this.background);
        addChild(this.backgroundBar);
        addChild(this.closeButton);
        addChild(extraButton);
        extraButton.x = 240;
        extraButton.selected.add(onIgnoreValues);
        backgroundBar.x = 48;
        backgroundBar.y = this.tabButtons.y - 24;
        addChild(this.containerSprite);
        addChild(this.containerSprite2);
        addChild(this.containerSprite3);
        this.containerSprite.visible = true;
        this.containerSprite2.visible = false;
        this.containerSprite3.visible = false;
        this.createStats(containerSprite, stats_, statsModel);
        this.createStats(containerSprite2, stats2_, statsModel2);
        this.createStats(containerSprite3, stats3_, statsModel3);
        addChild(tabButtons);
        tabButtons.switchTab.add(onTabSwitched);
        this.tabButtons.setRightButton(264 - 24);
        this.tabButtons.setLeftButton(24);
        tabNum = new TextFieldDisplayConcrete().setSize(12).setColor(0xb3b3b3).setBold(true);
        tabNum.setStringBuilder(new StaticStringBuilder("1/3"));
        tabNum.setAutoSize(TextFieldAutoSize.CENTER);
        tabNum.filters = [Utils.OutlineFilter];
        tabNum.x = 130;
        tabNum.y = this.tabButtons.y - 19;
        addChild(tabNum);
    }

    private function onIgnoreValues(show:Boolean):void
    {
        ignoreValues = show;
    }

    private function onTabSwitched(tab:int):void
    {
        tabNum.setStringBuilder(new StaticStringBuilder((tab + 1) + "/3"));
        switch (tab)
        {
            case 0:
                this.containerSprite.visible = true;
                this.containerSprite2.visible = false;
                this.containerSprite3.visible = false;
                break;
            case 1:
                this.containerSprite.visible = false;
                this.containerSprite2.visible = true;
                this.containerSprite3.visible = false;
                break;
            case 2:
                this.containerSprite.visible = false;
                this.containerSprite2.visible = false;
                this.containerSprite3.visible = true;
                break;
        }
    }

    private function createStats(container:Sprite, sv:Vector.<Stat>, arr:Array):void
    {
        var statView:Stat;
        var i:int = 0;
        while (i < arr.length)
        {
            statView = this.createStat(i, arr);
            sv.push(statView);
            container.addChild(statView);
            i++;
        }
    }

    private function createStat(i:int, arr:Array):Stat
    {
        var statView:Stat;
        statView = new Stat(arr[i]);
        statView.x = 8 + 84 * int(i % 3);
        statView.y = 7 + 28 * int(i / 3);
        return statView;
    }

    public function draw(player:Player):void
    {
        if (player == null) return;
        this.drawStats(player);
        this.drawStats2(player);
        this.drawStats3(player);
    }

    private function drawStats(player:Player):void
    {
        this.stats_[0].draw(player.strength_, player.strengthBoost_, false, 384, ignoreValues);
        this.stats_[1].draw(player.wit_, player.witBoost_, false, 384, ignoreValues);
        this.stats_[2].draw(player.armor_, player.armorBoost_, false, 384, ignoreValues);
        this.stats_[3].draw(player.resistance_, player.resistanceBoost_, false, 384, ignoreValues);
        this.stats_[4].draw(player.agility_, player.agilityBoost_, false, 384, ignoreValues);
        this.stats_[5].draw(player.dexterity_, player.dexterityBoost_, false, 384, ignoreValues);
    }

    private function drawStats2(player:Player):void
    {
        this.stats2_[0].draw(player.stamina_, player.staminaBoost_, false, 384, ignoreValues);
        this.stats2_[1].draw(player.intelligence_, player.intelligenceBoost_, false, 384, ignoreValues);
        this.stats2_[2].draw(player.luck_, player.luckBonus_, false, 0, ignoreValues);
        this.stats2_[3].draw(player.haste_, player.hasteBoost_, false, 0, ignoreValues);
        this.stats2_[4].draw(player.tenacity_, player.tenacityBoost_, true, 100, ignoreValues);
        this.stats2_[5].draw(1 + player.criticalStrike_, player.criticalStrikeBoost_, true, 50, ignoreValues);
    }

    private function drawStats3(player:Player):void
    {
        this.stats3_[0].draw(player.lifeSteal_, player.lifeStealBoost_, false, 0, ignoreValues);
        this.stats3_[1].draw(player.manaLeech_, player.manaLeechBoost_, false, 0, ignoreValues);
        this.stats3_[2].draw(player.lifeStealKill_, player.lifeStealKillBoost_, false, 0, ignoreValues);
        this.stats3_[3].draw(player.manaLeechKill_, player.manaLeechKillBoost_, false, 0, ignoreValues);
        this.stats3_[4].draw(player.lethality_, player.lethalityBoost_, false, 0, ignoreValues);
        this.stats3_[5].draw(player.piercing_, player.piercingBoost_, false, 0, ignoreValues);
    }

    private function close():void
    {
        tabStrip.detachedTabs[0].setSelected(false);
        parent.removeChild(this);
    }

}
}