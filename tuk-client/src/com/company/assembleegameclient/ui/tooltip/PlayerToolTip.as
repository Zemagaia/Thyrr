package com.company.assembleegameclient.ui.tooltip {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.GameObjectListItem;
import com.company.assembleegameclient.ui.GuildText;
import com.company.assembleegameclient.ui.RankText;
import com.company.assembleegameclient.ui.StatusBar;
import com.company.assembleegameclient.ui.panels.itemgrids.EquippedGrid;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;

import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class PlayerToolTip extends ToolTip {

    public var player_:Player;
    private var playerPanel_:GameObjectListItem;
    private var rankText_:RankText;
    private var guildText_:GuildText;
    private var hpBar_:StatusBar;
    private var mpBar_:StatusBar;
    private var clickMessage_:TextFieldDisplayConcrete;
    private var eGrid:EquippedGrid;

    public function PlayerToolTip(_arg1:Player) {
        var _local2:int;
        super(0x2B2B2B, 0.5, 0x7B7B7B, 1);
        this.player_ = _arg1;
        this.playerPanel_ = new GameObjectListItem(0xB3B3B3, true, this.player_, false, true);
        var bitmapData:BitmapData = (((player_.props_.portrait_) != null) ? player_.props_.portrait_.getTexture() : player_.texture_);
        this.playerPanel_.portrait.bitmapData = TextureRedrawer.resize(bitmapData, player_.mask_, ((4 / bitmapData.width) * 100), true, player_.getTex1(), player_.getTex2());
        this.playerPanel_.portrait.bitmapData = GlowRedrawer.outline(this.playerPanel_.portrait.bitmapData, 0);
        addChild(this.playerPanel_);
        _local2 = 34;
        this.rankText_ = new RankText(this.player_.numStars_, false, true, this.player_.rank_, this.player_.admin_);
        this.rankText_.x = 6;
        this.rankText_.y = _local2;
        addChild(this.rankText_);
        _local2 = (_local2 + 30);
        if (((!((_arg1.guildName_ == null))) && (!((_arg1.guildName_ == ""))))) {
            this.guildText_ = new GuildText(this.player_.guildName_, this.player_.guildRank_, 136);
            this.guildText_.x = 6;
            this.guildText_.y = (_local2 - 2);
            addChild(this.guildText_);
            _local2 = (_local2 + 30);
        }
        this.hpBar_ = new StatusBar(152, 14, 0xC93038, 0xaea9a9);
        this.hpBar_.x = 21;
        this.hpBar_.y = _local2;
        addChild(this.hpBar_);
        _local2 = (_local2 + 24);
        this.mpBar_ = new StatusBar(152, 14, 0x852D66, 0xaea9a9);
        this.mpBar_.x = 21;
        this.mpBar_.y = _local2;
        addChild(this.mpBar_);
        _local2 = (_local2 + 24);
        this.eGrid = new EquippedGrid(null, this.player_.slotTypes_, this.player_);
        this.eGrid.x = 6;
        this.eGrid.y = _local2;
        addChild(this.eGrid);
        _local2 = (_local2 + 52);
        this.clickMessage_ = new TextFieldDisplayConcrete().setSize(12).setColor(0xB3B3B3);
        this.clickMessage_.setAutoSize(TextFieldAutoSize.CENTER);
        this.clickMessage_.setStringBuilder(new LineBuilder().setParams("(Click to open menu)"));
        this.clickMessage_.filters = [new DropShadowFilter(0, 0, 0)];
        this.clickMessage_.x = (width / 2);
        this.clickMessage_.y = _local2;
        waiter.push(this.clickMessage_.textChanged);
        addChild(this.clickMessage_);
    }

    override public function draw():void {
        this.hpBar_.draw(this.player_.hp_, this.player_.maxHP_, this.player_.maxHPBoost_, this.player_.maxHPMax_);
        this.mpBar_.draw(this.player_.mp_, this.player_.maxMP_, this.player_.maxMPBoost_, this.player_.maxMPMax_);
        this.eGrid.setItems(this.player_.equipment_);
        this.rankText_.draw(this.player_.numStars_, this.player_.rank_, this.player_.admin_, false);
        super.draw();
    }


}
}
