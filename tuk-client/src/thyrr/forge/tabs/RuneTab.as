package thyrr.forge.tabs {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;
import com.company.ui.BaseSimpleText;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import kabam.rotmg.constants.ItemConstants;

import thyrr.forge.Forge;
import thyrr.forge.model.ForgeItem;
import thyrr.utils.ItemData;
import thyrr.oldui.DefaultTab;

public class RuneTab extends DefaultTab {

    private static const CENTER_X:int = Main.DefaultWidth / 2;
    private static const CENTER_Y:int = Main.DefaultHeight / 2;
    private static const ITEM_CENTER_X:int = CENTER_X - 21; // 42 / 2
    private static const RESULT_CENTER_Y:int = CENTER_Y - 80;
    private static const BOTTOM_Y:int = CENTER_Y + 85;
    private static const RESULT_POINT_CENTER_Y:int = RESULT_CENTER_Y + 21;

    private var items_:Vector.<ForgeItem>;
    public var selectedItem_:ForgeItem;
    public var itemRunes_:Vector.<ForgeItem>;
    public var isSelected_:Boolean;
    public var runeSelected_:Boolean;
    private var selectAnItem_:BaseSimpleText;
    private var selectRune_:BaseSimpleText;
    public var objTypes_:Vector.<int> = new Vector.<int>(8);
    public var insertButton_:DeprecatedTextButton;
    private var runeSlot_:int;

    public function RuneTab(gameSprite:GameSprite) {
        super(gameSprite);
        drawTops();
        drawBots();
    }

    private function drawTops():void {
        this.selectedItem_ = new ForgeItem(new ItemData(null), null, -1, false);
        this.selectedItem_.x = ITEM_CENTER_X;
        this.selectedItem_.y = RESULT_CENTER_Y;
        addChild(this.selectedItem_);
        this.selectAnItem_ = new BaseSimpleText(14, 0xB3B3B3).setBold(true);
        this.selectAnItem_.text = "Select an equipment";
        this.selectAnItem_.updateMetrics();
        this.selectAnItem_.x = CENTER_X - this.selectAnItem_.width / 2;
        this.selectAnItem_.y = RESULT_CENTER_Y - 60;
        this.selectAnItem_.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.selectAnItem_);
    }

    private function positionSelected(i:int, objType:int):void {
        var x:int;
        var y:int;
        var x2:int;
        var y2:int;
        var pos:Vector.<int> = getPos(i);
        var pPos:Vector.<int> = getPos(i - 1);
        x = this.itemRunes_[i].x = pos[0];
        y = this.itemRunes_[i].y = pos[1];
        x2 = pPos[0] + 21;
        y2 = pPos[1] + 21;
        var traceColor:int = i - 1 < 0 ? 0x5B5B5B : (this.objTypes_[i - 1] > 0 && this.objTypes_[i] > 0 ? 0xD37337 : 0x5B5B5B);
        // line to center
        this.graphics.lineStyle(2, objType > 0 ? 0xD37337 : 0x5B5B5B, 1, true);
        this.graphics.moveTo(x + 21, y + 21);
        this.graphics.lineTo(CENTER_X, RESULT_POINT_CENTER_Y);
        // line to previous slot
        this.graphics.lineStyle(2, traceColor, 1, true);
        this.graphics.moveTo(x + 21, y + 21);
        this.graphics.lineTo(x2, y2);
        if (i == 7) {
            // line back to 0
            var tempPos:Vector.<int> = getPos(0);
            this.graphics.moveTo(x + 21, y + 21);
            this.graphics.lineTo(tempPos[0] + 21, tempPos[1] + 21);
        }
    }

    // gets manually coded position for the equipment 'square'
    private static function getPos(index:int):Vector.<int> {
        var pos:Vector.<int> = new Vector.<int>(2); // 0 = x, 1 = y
        switch (index) {
            default:
            case 0:
                pos[0] = ITEM_CENTER_X - 29;
                pos[1] = RESULT_CENTER_Y - 67;
                break;
            case 1:
                pos[0] = ITEM_CENTER_X + 29;
                pos[1] = RESULT_CENTER_Y - 67;
                break;
            case 2:
                pos[0] = ITEM_CENTER_X + 87;
                pos[1] = RESULT_CENTER_Y - 29;
                break;
            case 3:
                pos[0] = ITEM_CENTER_X + 87;
                pos[1] = RESULT_CENTER_Y + 29;
                break;
            case 4:
                pos[0] = ITEM_CENTER_X + 29;
                pos[1] = RESULT_CENTER_Y + 67;
                break;
            case 5:
                pos[0] = ITEM_CENTER_X - 29;
                pos[1] = RESULT_CENTER_Y + 67;
                break;
            case 6:
                pos[0] = ITEM_CENTER_X - 87;
                pos[1] = RESULT_CENTER_Y + 29;
                break;
            case 7:
                pos[0] = ITEM_CENTER_X - 87;
                pos[1] = RESULT_CENTER_Y - 29;
        }
        // index 0 is x, index 1 is y
        return pos;
    }

    // draw stuff below
    private function drawBots():void {
        var player:Player = this.gameSprite_.map.player_;
        this.items_ = new Vector.<ForgeItem>(player.equipment_.length - 4);
        // inventory
        var i:int = 0;
        while (i < this.items_.length) {
            this.items_[i] = new ForgeItem(player.equipment_[i + 4], player, i);
            var item:XML = ObjectLibrary.xmlLibrary_[player.equipment_[i + 4].ObjectType];
            this.items_[i].x = (CENTER_X + 48 * int(i % 4)) + (i < 8 ? -243 : 59);
            this.items_[i].y = BOTTOM_Y + 48 * int((i < 8 ? i : i - 8) / 4);
            addChild(this.items_[i]);
            if (item && item.hasOwnProperty("Consumable")) {
                this.items_[i].filters = ItemTileSprite.DIM_FILTER;
            }
            else if (item && item.hasOwnProperty("Rune"))
                this.items_[i].setBackground(16777103, 0x2B2B2B);
            i++;
        }
        this.selectRune_ = new BaseSimpleText(14, 0xB3B3B3).setBold(true);
        this.selectRune_.text = "Select a rune to add to your equipment";
        this.selectRune_.updateMetrics();
        this.selectRune_.x = CENTER_X - this.selectRune_.width / 2;
        this.selectRune_.y = BOTTOM_Y - 24;
        this.selectRune_.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.selectRune_);
        this.selectRune_.visible = false;
        this.insertButton_ = new DeprecatedTextButton(14, "Insert Rune");
        this.insertButton_.x = CENTER_X - 45;
        this.insertButton_.y = CENTER_Y + 36;
        addChild(this.insertButton_);
        this.insertButton_.addEventListener(MouseEvent.CLICK, this.onInsert);
        this.insertButton_.visible = false;
    }

    public function updateSelected(slot:int):void {
        var item:XML = ObjectLibrary.xmlLibrary_[this.items_[slot].objType_];
        var slotType:int;
        if (!item.hasOwnProperty("SlotType"))
            return;
        else slotType = item.SlotType;

        if ((slotType == ItemConstants.POTION_TYPE || slotType == ItemConstants.EGG_TYPE) && !this.isSelected_ ||
                this.runeSelected_ && slotType != ItemConstants.POTION_TYPE && slotType != ItemConstants.EGG_TYPE)
            return;
        else if ((slotType == ItemConstants.POTION_TYPE || slotType == ItemConstants.EGG_TYPE) && this.isSelected_) {
            if (!item.hasOwnProperty("Rune")) return;
            var availableSlot:int = -1;
            var i:int = 0;
            while (i < this.itemRunes_.length)
            {
                if (this.itemRunes_[i].objType_ <= 0)
                {
                    availableSlot = i;
                    break;
                }
                i++;
            }

            if (this.items_[slot].selected_) {
                if (!this.runeSelected_ && availableSlot != -1) {
                    this.itemRunes_[availableSlot].setItem(this.items_[slot].objType_, this.items_[slot].player_, this.items_[slot].itemData_);
                    this.itemRunes_[availableSlot].slot_ = this.runeSlot_ = this.items_[slot].slot_;
                    this.items_[slot].assignedSlot_ = availableSlot;
                    this.items_[slot].setBackground(0x10BB10, 0x007700); // green
                    this.runeSelected_ = true;
                    this.selectRune_.visible = false;
                    this.insertButton_.visible = true;
                    return;
                }
                this.items_[slot].selected_ = false;
            }
            else {
                if (this.runeSelected_ && this.items_[slot].assignedSlot_ != -1) {
                    this.itemRunes_[this.items_[slot].assignedSlot_].setItem(-1);
                    this.itemRunes_[this.items_[slot].assignedSlot_].slot_ = this.runeSlot_ = -1;
                    this.items_[slot].assignedSlot_ = -1;
                    this.items_[slot].setBackground(16777103, 0x2B2B2B); // default rune bg
                    this.runeSelected_ = false;
                    this.selectRune_.visible = true;
                    this.insertButton_.visible = false;
                }
            }
            return;
        }

        if (this.items_[slot].selected_) {
            if (!this.isSelected_) {
                this.selectedItem_.setItem(this.items_[slot].objType_, this.items_[slot].player_, this.items_[slot].itemData_);
                this.selectedItem_.slot_ = this.items_[slot].slot_;
                this.selectedItem_.setBackground(0xD37337, 0x3F1D10); // default selected background
                this.items_[slot].setBackground(0xD37337, 0x3F1D10);
                var itemData:ItemData = this.items_[slot].itemData_;
                this.itemRunes_ = new Vector.<ForgeItem>(itemData.Runes ? itemData.Runes.length : 1);
                i = 0;
                while (i < this.itemRunes_.length) {
                    var data:ItemData = new ItemData(null);
                    data.ObjectType = itemData.Runes ? itemData.Runes[i] : -1;
                    this.itemRunes_[i] = new ForgeItem(data, null, -1, false);
                    this.objTypes_[i] = data.ObjectType;
                    this.positionSelected(i, itemData.Runes[i]);
                    addChild(this.itemRunes_[i]);
                    i++;
                }
                this.isSelected_ = true;
                this.selectAnItem_.visible = false;
                this.selectRune_.visible = true;
                this.insertButton_.visible = false;
                return;
            }
            this.items_[slot].setBackground(0x7B7B7B, 0x2B2B2B);
        }
        else {
            if (this.items_[slot].objType_ != this.selectedItem_.objType_) return;
            this.selectedItem_.setItem(-1);
            this.selectedItem_.slot_ = -1;
            this.selectedItem_.setBackground(0x7B7B7B, 0x2B2B2B);
            this.items_[slot].setBackground(0x7B7B7B, 0x2B2B2B);
            i = 0;
            while (i < this.itemRunes_.length)
            {
                removeChild(this.itemRunes_[i]);
                i++;
            }
            this.graphics.clear();
            this.isSelected_ = false;
            this.selectAnItem_.visible = true;
            this.selectRune_.visible = false;
            this.insertButton_.visible = false;
        }
    }

    private function onInsert(event:MouseEvent):void {
        // rune will be attempted to be inserted on the item on this slot (this.selectedItem_.slot_)
        this.gameSprite_.gsc_.insertRune(this.selectedItem_.slot_ + 4, this.runeSlot_ + 4);
        (parent as Forge).close();
    }

    override public function dispose():void {
        super.dispose();
    }

}
}