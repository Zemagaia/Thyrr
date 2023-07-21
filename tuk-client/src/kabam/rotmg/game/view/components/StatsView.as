package kabam.rotmg.game.view.components
{

import com.company.assembleegameclient.objects.Player;

import flash.display.Sprite;

import kabam.rotmg.game.model.StatModel;

import thyrr.oldui.TabSwitchButtons;

public class StatsView extends Sprite
{

    private static const statsModel:Array = [
        new StatModel("STR", true),
        new StatModel("WIT", true),
        new StatModel("ARM", false),
        new StatModel("RES", false),
        new StatModel("DEX", true),
        new StatModel("AGL", true),
        new StatModel("STA", true),
        new StatModel("INT", true)
    ];

    private static const statsModel2:Array = [
        new StatModel("LCK", false),
        new StatModel("HST", false),
        new StatModel("TEN", false),
        new StatModel("CRT", false)
    ];

    private static const statsModel3:Array = [
        new StatModel("HPH", false),
        new StatModel("MPH", false),
        new StatModel("HPK", false),
        new StatModel("MPK", false),
        new StatModel("LTH", false),
        new StatModel("PRC", false)
    ];

    private const WIDTH:int = 176;
    private const HEIGHT:int = 45;

    private var background:Sprite;
    public var tabButtons:TabSwitchButtons;
    public var stats_:Vector.<StatView>;
    public var stats2_:Vector.<StatView>;
    public var stats3_:Vector.<StatView>;
    public var containerSprite:Sprite;
    public var containerSprite2:Sprite;
    public var containerSprite3:Sprite;

    public function StatsView()
    {
        this.background = this.createBackground();
        this.tabButtons = new TabSwitchButtons();
        this.tabButtons.setTabs(3);
        this.tabButtons.x = WIDTH / 2;
        this.tabButtons.y = 60;
        this.stats_ = new Vector.<StatView>();
        this.stats2_ = new Vector.<StatView>();
        this.stats3_ = new Vector.<StatView>();
        this.containerSprite = new Sprite();
        this.containerSprite2 = new Sprite();
        this.containerSprite3 = new Sprite();
        super();
        addChild(this.background);
        addChild(this.containerSprite);
        addChild(this.containerSprite2);
        addChild(this.containerSprite3);
        this.containerSprite.visible = true;
        this.containerSprite2.visible = false;
        this.containerSprite3.visible = false;
        this.createStats();
        this.createStats2();
        this.createStats3();
        addChild(tabButtons);
    }

    private function createStats():void
    {
        var statView:StatView;
        var _local1:int;
        var _local2:int;
        while (_local2 < statsModel.length)
        {
            statView = this.createStat(_local2, _local1);
            this.stats_.push(statView);
            this.containerSprite.addChild(statView);
            _local1 = (_local1 + (_local2 % 2));
            _local2++;
        }
    }

    private function createStat(_arg1:int, _arg2:int):StatView
    {
        var model:StatModel = statsModel[_arg1];
        var statView:StatView;
        statView = new StatView(model.name, model.redOnZero);
        statView.x = 4 + (((_arg1 % 2) * this.WIDTH) / 2);
        statView.y = -2 + (_arg2 * (this.HEIGHT / 3));
        return (statView);
    }

    private function createStats2():void
    {
        var statView:StatView;
        var _local1:int;
        var _local2:int;
        while (_local2 < statsModel2.length)
        {
            statView = this.createStat2(_local2, _local1);
            this.stats2_.push(statView);
            this.containerSprite2.addChild(statView);
            _local1 = (_local1 + (_local2 % 2));
            _local2++;
        }
    }

    private function createStat2(_arg1:int, _arg2:int):StatView
    {
        var model:StatModel = statsModel2[_arg1];
        var statView:StatView;
        statView = new StatView(model.name, model.redOnZero);
        statView.x = 2 + (((_arg1 % 2) * this.WIDTH) / 2);
        statView.y = -2 + (_arg2 * (this.HEIGHT / 3));
        return (statView);
    }

    private function createStats3():void
    {
        var statView:StatView;
        var _local1:int;
        var _local2:int;
        while (_local2 < statsModel3.length)
        {
            statView = this.createStat3(_local2, _local1);
            this.stats3_.push(statView);
            this.containerSprite3.addChild(statView);
            _local1 = (_local1 + (_local2 % 2));
            _local2++;
        }
    }

    private function createStat3(_arg1:int, _arg2:int):StatView
    {
        var model:StatModel = statsModel3[_arg1];
        var statView:StatView;
        statView = new StatView(model.name, model.redOnZero);
        statView.x = 2 + (((_arg1 % 2) * this.WIDTH) / 2);
        statView.y = -2 + (_arg2 * (this.HEIGHT / 3));
        return (statView);
    }

    public function draw(_arg1:Player):void
    {
        this.tabButtons.setLeftButton(-50);
        this.tabButtons.setRightButton(45);
        if (_arg1)
        {
            this.drawStats(_arg1);
            this.drawStats2(_arg1);
            this.drawStats3(_arg1);
        }
        this.containerSprite.x = ((this.WIDTH - this.containerSprite.width) / 2);
        this.containerSprite2.x = ((this.WIDTH - this.containerSprite2.width) / 2);
        this.containerSprite3.x = ((this.WIDTH - this.containerSprite3.width) / 2);
    }

    private function drawStats(_arg1:Player):void
    {
        this.stats_[0].draw(_arg1.strength_, _arg1.strengthBoost_, _arg1.strengthMax_, false, 384);
        this.stats_[1].draw(_arg1.wit_, _arg1.witBoost_, _arg1.witMax_, false, 384);
        this.stats_[2].draw(_arg1.armor_, _arg1.armorBoost_, _arg1.armorMax_, false, 384);
        this.stats_[3].draw(_arg1.resistance_, _arg1.resistanceBoost_, _arg1.resistanceMax_, false, 384);
        this.stats_[4].draw(_arg1.dexterity_, _arg1.dexterityBoost_, _arg1.dexterityMax_, false, 384);
        this.stats_[5].draw(_arg1.agility_, _arg1.agilityBoost_, _arg1.agilityMax_, false, 384);
        this.stats_[6].draw(_arg1.stamina_, _arg1.staminaBoost_, _arg1.staminaMax_, false, 384);
        this.stats_[7].draw(_arg1.intelligence_, _arg1.intelligenceBoost_, _arg1.intelligenceMax_, false, 384);
    }

    private function drawStats2(_arg1:Player):void
    {
        this.stats2_[0].draw(_arg1.luck_, _arg1.luckBonus_, 10);
        this.stats2_[1].draw(_arg1.haste_, _arg1.hasteBoost_, 10);
        this.stats2_[2].draw(_arg1.tenacity_, _arg1.tenacityBoost_, 10, true, 100);
        this.stats2_[3].draw(1 + _arg1.criticalStrike_, _arg1.criticalStrikeBoost_, 10, true, 50);
    }

    private function drawStats3(_arg1:Player):void
    {
        this.stats3_[0].draw(_arg1.lifeSteal_, _arg1.lifeStealBoost_, 10);
        this.stats3_[1].draw(_arg1.manaLeech_, _arg1.manaLeechBoost_, 10);
        this.stats3_[2].draw(_arg1.lifeStealKill_, _arg1.lifeStealKillBoost_, 10);
        this.stats3_[3].draw(_arg1.manaLeechKill_, _arg1.manaLeechKillBoost_, 10);
        this.stats3_[4].draw(_arg1.lethality_, _arg1.lethalityBoost_, 10);
        this.stats3_[5].draw(_arg1.piercing_, _arg1.piercingBoost_, 10);
    }

    private function createBackground():Sprite
    {
        this.background = new Sprite();
        this.background.graphics.clear();
        this.background.graphics.beginFill(0x2B2B2B);
        this.background.graphics.lineStyle(2, 0x545454);
        this.background.graphics.drawRect(5, -11, 176, 88);
        return (this.background);
    }

}
}