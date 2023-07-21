package thyrr.forge.tabs {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.util.FilterUtil;
import com.company.ui.BaseSimpleText;
import com.gskinner.motion.GTween;

import flash.events.MouseEvent;
import flash.geom.Point;

import kabam.rotmg.constants.ItemConstants;

import kabam.rotmg.constants.ItemConstants;

import kabam.rotmg.messaging.impl.incoming.forge.CraftAnimation;

import thyrr.forge.Forge;

import thyrr.forge.model.ForgeItem;
import thyrr.forge.animations.ForgeAnimation;
import thyrr.forge.signals.CraftAnimationSignal;

import thyrr.oldui.DefaultTab;

public class ForgeTab extends DefaultTab {

    private static const CENTER_X:int = WebMain.DefaultWidth / 2;
    private static const CENTER_Y:int = WebMain.DefaultHeight / 2;
    private static const ITEM_CENTER_X:int = CENTER_X - 21; // 42 / 2
    private static const RESULT_CENTER_Y:int = CENTER_Y - 80;
    private static const BOTTOM_Y:int = CENTER_Y + 85;
    private static const RESULT_POINT_CENTER_Y:int = RESULT_CENTER_Y + 21;

    private var items_:Vector.<ForgeItem>;
    public var selectedItems_:Vector.<ForgeItem>;
    public var availableSlots_:Vector.<int>;
    public var craftButton_:DeprecatedTextButton;
    public const craftAnimationSignal_:CraftAnimationSignal = new CraftAnimationSignal();

    private var errorText_:BaseSimpleText;
    private var animationRunning_:Boolean = false;

    public function ForgeTab(gameSprite:GameSprite) {
        super(gameSprite);

        this.craftAnimationSignal_.add(this.onAnimation);
        drawTops();
        drawBots();
        setupErrorText();
    }

    private function drawTops():void {
        var result:ForgeItem = new ForgeItem(ItemConstants.DEFAULT_ITEM);
        result.setResult();
        result.x = ITEM_CENTER_X;
        result.y = RESULT_CENTER_Y;
        addChild(result);
        this.availableSlots_ = new Vector.<int>(8);
        this.selectedItems_ = new Vector.<ForgeItem>(8);
        var i:int = 0;
        while (i < this.selectedItems_.length) {
            this.selectedItems_[i] = new ForgeItem(ItemConstants.DEFAULT_ITEM, null, -1, false);
            this.availableSlots_[i] = i;
            this.positionSelected(i);
            addChild(this.selectedItems_[i]);
            i++;
        }
        this.craftButton_ = new DeprecatedTextButton(18, "Craft");
        this.craftButton_.x = CENTER_X - 30;
        this.craftButton_.y = CENTER_Y + 45;
        addChild(this.craftButton_);
        this.craftButton_.addEventListener(MouseEvent.CLICK, this.onCraft);
    }

    private function positionSelected(i:int):void {
        var pos:Point = getPosition(i);
        this.graphics.lineStyle(3, 0x5B5B5B, 1, true);
        this.selectedItems_[i].x = pos.x;
        this.selectedItems_[i].y = pos.y;
        this.graphics.moveTo(pos[0] + 21, pos[1] + 21);
        this.graphics.lineTo(CENTER_X, RESULT_POINT_CENTER_Y);
    }

    public static function getPosition(index:int):Point {
        var x:int;
        var y:int;
        switch (index) {
            case 0:
                x = ITEM_CENTER_X - 29;
                y = RESULT_CENTER_Y - 67;
                break;
            case 1:
                x = ITEM_CENTER_X + 29;
                y = RESULT_CENTER_Y - 67;
                break;
            case 2:
                x = ITEM_CENTER_X + 87;
                y = RESULT_CENTER_Y - 29;
                break;
            case 3:
                x = ITEM_CENTER_X + 87;
                y = RESULT_CENTER_Y + 29;
                break;
            case 4:
                x = ITEM_CENTER_X + 29;
                y = RESULT_CENTER_Y + 67;
                break;
            case 5:
                x = ITEM_CENTER_X - 29;
                y = RESULT_CENTER_Y + 67;
                break;
            case 6:
                x = ITEM_CENTER_X - 87;
                y = RESULT_CENTER_Y + 29;
                break;
            case 7:
                x = ITEM_CENTER_X - 87;
                y = RESULT_CENTER_Y - 29;
                break;
        }
        return new Point(x, y);
    }

    private function drawBots():void {
        var player:Player = this.gameSprite_.map.player_;
        this.items_ = new Vector.<ForgeItem>(player.equipment_.length - 4);
        var i:int = 0;
        // inventory
        while (i < this.items_.length) {
            this.items_[i] = new ForgeItem(player.equipment_[i + 4], player, i);
            this.items_[i].x = (CENTER_X + 48 * int(i % 4)) + (i < 8 ? -243 : 59);
            this.items_[i].y = BOTTOM_Y + 48 * int((i < 8 ? i : i - 8) / 4);
            addChild(this.items_[i]);
            i++;
        }
    }

    public function updateSelected(slot:int):void {
        if (this.items_[slot].selected_) {
            var i:int = 0;
            while (i < this.availableSlots_.length) {
                if (this.availableSlots_[i] != -1) {
                    this.selectedItems_[this.availableSlots_[i]].setItem(this.items_[slot].objType_, this.items_[slot].player_, this.items_[slot].itemData_);
                    this.selectedItems_[this.availableSlots_[i]].slot_ = this.items_[slot].slot_;
                    this.items_[slot].setBackground(0xD37337, 0x3F1D10);
                    this.items_[slot].assignedSlot_ = this.availableSlots_[i];
                    this.availableSlots_[i] = -1;
                    return;
                }
                i++;
            }
            this.items_[slot].setBackground(0x7B7B7B, 0x2B2B2B);
        }
        else {
            var assignedSlot:int = this.items_[slot].assignedSlot_;
            if (assignedSlot != -1) {
                this.availableSlots_[assignedSlot] = assignedSlot;
                this.selectedItems_[assignedSlot].setItem(-1);
                this.selectedItems_[assignedSlot].slot_ = -1;
                this.items_[slot].assignedSlot_ = -1;
                this.items_[slot].setBackground(0x7B7B7B, 0x2B2B2B);
            }
        }
    }

    private function onCraft(event:MouseEvent):void {
        var slots:Vector.<int> = new Vector.<int>();
        var i:int = 0;
        while (i < this.selectedItems_.length) {
            if (this.selectedItems_[i].slot_ != -1) {
                slots.push(this.selectedItems_[i].slot_ + 4);
            }
            i++;
        }

        this.gameSprite_.gsc_.craftItem(slots);
    }

    private function setupErrorText():void {
        this.errorText_ = new BaseSimpleText(16, 0xFF0000);
        this.errorText_.setBold(true);
        this.errorText_.text = "Recipe not found!";
        this.errorText_.updateMetrics();
        this.errorText_.x = CENTER_X - this.errorText_.width / 2;
        this.errorText_.y = CENTER_Y + 20;
        addChild(this.errorText_);
        this.errorText_.alpha = 0;
        this.errorText_.filters = FilterUtil.getDmgCounterMultiFilter();
    }

    private function hideErrorText(tween:GTween):void {
        this.errorText_.alpha = 0;
        this.animationRunning_ = false;
    }

    private function onAnimation(packet:CraftAnimation):void {
        if (this.animationRunning_) {
            return;
        }
        if (packet.objectType_ == -1) {
            this.animationRunning_ = true;
            this.errorText_.alpha = 1;
            this.errorText_.y = CENTER_Y + 20;
            var tween:GTween = new GTween(this.errorText_, 1, {
                "y": RESULT_CENTER_Y,
                "alpha": 0.3
            });
            tween.init();
            tween.onComplete = hideErrorText;
            return;
        }

        (parent as Forge).addAnimation(new ForgeAnimation(this.gameSprite_, packet));
    }

    override public function dispose():void {
        this.craftAnimationSignal_.remove(this.onAnimation);
        super.dispose();
    }

}
}