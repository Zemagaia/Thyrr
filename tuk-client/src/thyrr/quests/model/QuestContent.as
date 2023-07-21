package thyrr.quests.model {

import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.ui.DeprecatedTextButton;
import com.company.assembleegameclient.ui.LegacyScrollbar;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.ui.BaseSimpleText;
import com.company.util.AssetLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.CapsStyle;
import flash.display.DisplayObject;

import flash.display.JointStyle;
import flash.display.LineScaleMode;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;

import kabam.rotmg.constants.ItemConstants;

import kabam.rotmg.util.graphics.BevelRect;

import kabam.rotmg.util.graphics.GraphicsHelper;

import thyrr.quests.data.AcceptedQuestData;

import thyrr.quests.data.QuestData;
import thyrr.quests.model.QuestItem;
import thyrr.utils.ItemData;

public class QuestContent extends Sprite {

    private static const X_OFFSET:int = 516;
    private static const Y_OFFSET:int = 8;
    private static const WIDTH:int = 516;
    private static const INNER_HEIGHT:int = 526; // HEIGHT - 4
    public static const INNER_WIDTH:int = 512; // WIDTH - 4
    private static const HEIGHT:int = 530;

    private var shape_:Shape;
    private var mask_:Sprite;
    public var background_:Sprite;
    private var scrollbar_:LegacyScrollbar;
    private var questData_:QuestData;
    private var acceptedQuestData_:AcceptedQuestData;
    private var items_:Vector.<Object>;
    private var bgRect_:Sprite;

    private var icon_:Bitmap;
    private var title_:BaseSimpleText;
    private var description_:BaseSimpleText;
    private var timeText_:BaseSimpleText;
    private var rewards_:Vector.<BaseSimpleText>;
    private var rewardIcons_:Vector.<QuestItem>;
    private var slay_:Vector.<BaseSimpleText>;
    private var slayIcons_:Vector.<Bitmap>;
    private var dungeon_:Vector.<BaseSimpleText>;
    private var dungeonIcons_:Vector.<Bitmap>;
    private var experience_:BaseSimpleText;
    private var expIcon_:Bitmap;
    public var deliver_:Vector.<BaseSimpleText>;
    private var deliverIcons_:Vector.<QuestItem>;
    public var delivered_:Vector.<int>;
    public var scout_:BaseSimpleText;
    public var scoutIcon_:Bitmap;

    public var acceptButton_:DeprecatedTextButton = new DeprecatedTextButton(18, "Accept");
    public var dismissButton_:DeprecatedTextButton = new DeprecatedTextButton(18, "Dismiss");
    public var warpButton_:DeprecatedTextButton = new DeprecatedTextButton(12, "Warp");
    public var questId_:int;

    public function QuestContent(questData:QuestData, acceptedQuestData:AcceptedQuestData) {
        this.questData_ = questData;
        this.acceptedQuestData_ = acceptedQuestData;
        var data:Object = this.acceptedQuestData_ != null ? this.acceptedQuestData_ : this.questData_;
        this.questId_ = data.id_;
        this.shape_ = new Shape();
        this.bgRect_ = new Sprite();
        addChild(this.bgRect_);
        this.shape_.graphics.beginFill(0);
        this.shape_.graphics.drawRect(0, 0, WIDTH, INNER_HEIGHT);
        this.shape_.graphics.endFill();
        this.mask_ = new Sprite();
        this.mask_.addChild(this.shape_);
        this.mask_.mask = this.shape_;
        addChild(this.mask_);
        this.background_ = new Sprite();
        this.mask_.addChild(this.background_);
        this.items_ = new Vector.<Object>();
        this.mask_.y += 4;
        this.draw();
    }

    private function draw():void {
        if (this.scrollbar_ != null) {
            this.scrollbar_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            removeChild(this.scrollbar_);
            this.scrollbar_ = null;
        }

        this.clearPreviousResults();

        this.drawStuff(this.acceptedQuestData_ == null ? this.questData_ : this.acceptedQuestData_);

        var o:DisplayObject;
        for each (o in this.items_) {
            this.background_.addChild(o);
        }

        if (this.acceptedQuestData_ == null) {
            this.background_.addChild(this.acceptButton_);
            this.background_.addChild(this.dismissButton_);
        }
        else {
            this.dismissButton_ = new DeprecatedTextButton(18, "Delete");
            if (this.acceptedQuestData_.deliver_.length > 0) {
                this.acceptButton_ = new DeprecatedTextButton(18, "Deliver");
                var i:int = 0;
                while (i < this.delivered_.length) {
                    if (this.delivered_[i] == 0) {
                        this.background_.addChild(this.acceptButton_);
                        this.dismissButton_.x = 80;
                        break;
                    }
                    i++;
                }
            }
            this.background_.addChild(this.dismissButton_);
        }

        this.acceptButton_.textChanged.addOnce(this.positionAcceptButton);
        this.dismissButton_.textChanged.addOnce(this.positionDismissButton);

        this.drawBackground(this.background_.height);
        if (this.background_.height > 520) {
            this.scrollbar_ = new LegacyScrollbar(16, 520, 0.3);
            this.scrollbar_.x = X_OFFSET - 24;
            this.scrollbar_.y = Y_OFFSET;
            this.scrollbar_.setIndicatorSize(520, this.background_.height);
            this.scrollbar_.addEventListener(Event.CHANGE, this.onResultScrollChanged);
            addChild(this.scrollbar_);
        }
        if (this.scrollbar_ == null) {
            this.description_.width += 28;
            this.timeText_.x += 20;
        }
    }

    private function positionAcceptButton():void {
        this.acceptButton_.x = WIDTH - this.acceptButton_.width - 80;
        this.acceptButton_.y = this.background_.height - this.acceptButton_.height - 16;
    }

    private function positionDismissButton():void {
        this.dismissButton_.y = this.background_.height - this.dismissButton_.height - 16;
        if (this.background_.contains(this.acceptButton_)) {
            this.dismissButton_.x = 80;
            return;
        }
        this.dismissButton_.x = WIDTH / 2 - this.dismissButton_.width / 2;
    }

    private function drawStuff(data:Object):void {
        var getIcon:BitmapData = AssetLibrary.getImageFromSet("interfaceNew", 0x11 + data.icon_); // temp icon
        var bitmapData:BitmapData = TextureRedrawer.redraw(getIcon, 80, true, 0);
        this.icon_ = new Bitmap(bitmapData);
        this.icon_.x = 8;
        this.icon_.y = 8;
        this.items_.push(this.icon_);

        var unix:Number = (data.endTime_ * 1000);
        var later:Date = new Date(unix);
        var now:Date = new Date();
        var ms:Number = Math.floor((later.time - now.time));
        var minutes:Number = (ms / (3600000 / 60));
        var hours:Number = (ms / 3600000);
        var days:Number = (ms / (3600000 * 24));
        var value:Number;
        var abbrev:String;
        var color:uint;
        value = days > 1.0 ? days : hours > 1.0 ? hours : minutes;
        abbrev = days > 1.0 ? "d" : hours > 1.0 ? "h" : "m";
        color = hours > 12.0 ? 0xFFFFFF : hours > 2.0 ? 0xFF9900 : 0xFF0000;
        this.timeText_ = new BaseSimpleText(13, color);
        this.timeText_.setBold(true);
        this.timeText_.text = value.toFixed(1) + abbrev;
        this.timeText_.x = INNER_WIDTH - 30 - this.timeText_.width;
        this.timeText_.y = 22;
        this.timeText_.setAutoSize(TextFieldAutoSize.RIGHT);
        this.timeText_.updateMetrics();
        this.items_.push(this.timeText_);

        this.title_ = new BaseSimpleText(18, 0xB3B3B3, false).setBold(true);
        this.title_.text = data.title_;
        this.title_.updateMetrics();
        this.title_.x = this.icon_.width + this.icon_.x + ((375 - (this.title_.width > 375 ? 375 : this.title_.width)) / 2);
        this.title_.inputWidth_ = 375;
        this.title_.y = 20;
        this.title_.setAutoSize(TextFieldAutoSize.LEFT);
        this.title_.updateMetrics();
        this.items_.push(this.title_);

        this.description_ = new BaseSimpleText(16, 0xB3B3B3, false, INNER_WIDTH - 38);
        this.description_.setIndent(16);
        this.description_.multiline = true;
        this.description_.wordWrap = true;
        this.description_.text = data.description_;
        this.description_.x = 10;
        this.description_.y = this.icon_.height + 8;
        this.description_.updateMetrics();
        this.items_.push(this.description_);

        var yOffset:int = this.description_.y + (this.description_.text == "" ? 0 : (this.description_.numLines * 16) + 8);
        if (data.scout_) {
            getIcon = AssetLibrary.getImageFromSet("interfaceNew", 0x17);
            bitmapData = TextureRedrawer.redraw2(bitmapData, 60, true, 0);
            this.scoutIcon_ = new Bitmap(bitmapData);
            this.scoutIcon_.x = 4;
            this.scoutIcon_.y = yOffset;
            this.scout_ = new BaseSimpleText(14, 0xFFFFFF, false, 400).setBold(true);
            this.scout_.text = "Explore " + data.scout_;
            this.scout_.x = this.scoutIcon_.width + 2;
            this.scout_.y = yOffset + 16;
            this.scout_.updateMetrics();
            this.scout_.filters = [new DropShadowFilter(0, 0, 0)];
            yOffset += 30;
            this.items_.push(this.scout_);
            this.items_.push(this.scoutIcon_);
            if (data is AcceptedQuestData) {
                this.scout_.setColor(data.scouted_ ? 0x00CC00 : 0xFFFFFF);
                if (!data.scouted_) {
                    this.warpButton_ = new DeprecatedTextButton(12, "Warp");
                    this.warpButton_.x = this.scout_.getLineMetrics(0).width + 60;
                    this.warpButton_.y = yOffset - 16;
                    this.background_.addChild(this.warpButton_);
                }
            }
        }

        var i:int = 0;
        this.dungeonIcons_ = new Vector.<Bitmap>(data.dungeons_.length);
        this.dungeon_ = new Vector.<BaseSimpleText>(data.dungeons_.length);
        var dungCompleted:int;
        var extraText:String = "";
        var objType:int;
        while (i < data.dungeons_.length) {
            objType = ObjectLibrary.idToType_[data.dungeons_[i] + " Portal"];
            if (data.dungeons_[i] == "Sprite World")
                objType = ObjectLibrary.idToType_["Glowing Portal"];
            bitmapData = ObjectLibrary.getBitmapData(objType);
            bitmapData = TextureRedrawer.redraw2(bitmapData, 60, true, 0);
            this.dungeonIcons_[i] = new Bitmap(bitmapData);
            this.dungeonIcons_[i].x = 4;
            this.dungeonIcons_[i].y = yOffset;
            if (data is AcceptedQuestData) {
                var dungeonAmount:int = data.dungeonAmounts_[i];
                dungCompleted = data.dungsCompleted_[i];
                color = dungCompleted >= dungeonAmount ? 0x00cc00 :
                        dungCompleted > dungeonAmount * 0.6 ? 16777103 :
                                dungCompleted > dungeonAmount * 0.2 ? 0xFF9900 : 0xFF0000;
                extraText = dungCompleted >= 0 ? color == 0x00cc00 ? "" : EquipmentToolTip.wrapColor(dungCompleted.toString(), color) + "/" : "";
            }
            this.dungeon_[i] = new BaseSimpleText(14, color == 0x00cc00 ? color : 0xFFFFFF, false, 400).setBold(true);
            this.dungeon_[i].htmlText = "Complete " + extraText + data.dungeonAmounts_[i]
                    + " " + data.dungeons_[i] + (data.dungeonAmounts_[i] != 1 ? "s" : "");
            this.dungeon_[i].x = this.dungeonIcons_[i].width + 2;
            this.dungeon_[i].y = yOffset + 16;
            this.dungeon_[i].filters = [new DropShadowFilter(0, 0, 0)];
            this.items_.push(this.dungeonIcons_[i]);
            this.items_.push(this.dungeon_[i]);
            yOffset += 30;
            i++;
        }
        i = 0;
        this.slayIcons_ = new Vector.<Bitmap>(data.slay_.length);
        this.slay_ = new Vector.<BaseSimpleText>(data.slay_.length);
        var slainAmount:int;
        while (i < data.slay_.length) {
            var slay:String = ObjectLibrary.typeToDisplayId_[data.slay_[i]];
            bitmapData = ObjectLibrary.getBitmapData(data.slay_[i]);
            bitmapData = TextureRedrawer.redraw2(bitmapData, 60, true, 0);
            this.slayIcons_[i] = new Bitmap(bitmapData);
            this.slayIcons_[i].x = 4;
            this.slayIcons_[i].y = yOffset;
            if (data is AcceptedQuestData) {
                var slayAmount:int = data.slayAmounts_[i];
                slainAmount = data.slainAmounts_[i];
                color = slainAmount >= slayAmount ? 0x00cc00 :
                        slainAmount > slayAmount * 0.6 ? 16777103 :
                                slainAmount > slayAmount * 0.2 ? 0xFF9900 : 0xFF0000;
                extraText = slainAmount >= 0 ? color == 0x00cc00 ? "" : EquipmentToolTip.wrapColor(slainAmount.toString(), color) + "/" : "";
            }
            this.slay_[i] = new BaseSimpleText(14, color == 0x00cc00 ? color : 0xFFFFFF, false, 400).setBold(true);
            this.slay_[i].htmlText = "Slay " + extraText + data.slayAmounts_[i] + " " + slay;
            this.slay_[i].x = this.slayIcons_[i].width + 2;
            this.slay_[i].y = yOffset + 16;
            this.slay_[i].filters = [new DropShadowFilter(0, 0, 0)];
            this.items_.push(this.slayIcons_[i]);
            this.items_.push(this.slay_[i]);
            yOffset += 30;
            i++;
        }

        i = 0;
        this.deliverIcons_ = new Vector.<QuestItem>(data.deliver_.length);
        this.deliver_ = new Vector.<BaseSimpleText>(data.deliver_.length);
        if (data is AcceptedQuestData)
            this.delivered_ = new Vector.<int>(data.delivered_.length);
        while (i < data.deliver_.length) {
            var itemId:String = ObjectLibrary.typeToDisplayId_[data.deliver_[i]];
            this.deliverIcons_[i] = new QuestItem(data.deliver_[i], data.deliverDatas_[i]);
            this.deliverIcons_[i].x = 4;
            this.deliverIcons_[i].y = yOffset;
            color = 0xFFFFFF;
            if (data is AcceptedQuestData) {
                this.delivered_[i] = data.delivered_[i];
                if (data.delivered_[i] == 1)
                    color = 0x00CC00;
            }
            var quantity:String = "x1";
            if (data.deliverDatas_.length > 0) {
                var itemData:ItemData = data.deliverDatas_[i];
                if (data.deliverDatas_) {
                    quantity = "x" + itemData.MaxQuantity;
                }
            }
            this.deliver_[i] = new BaseSimpleText(14, color, false, 400).setBold(true);
            this.deliver_[i].text = "Deliver " + quantity + " " + itemId;
            this.deliver_[i].x = this.deliverIcons_[i].width + this.deliverIcons_[i].x - 4;
            this.deliver_[i].y = yOffset + 16;
            this.deliver_[i].filters = [new DropShadowFilter(0, 0, 0)];
            yOffset += 30;
            this.items_.push(this.deliverIcons_[i]);
            this.items_.push(this.deliver_[i]);
            i++;
        }

        if (data.experience_ > 0) {
            getIcon = AssetLibrary.getImageFromSet("interfaceNew", 0x10);
            bitmapData = TextureRedrawer.redraw2(getIcon, 60, true, 0);
            this.expIcon_ = new Bitmap(bitmapData);
            this.expIcon_.x = 4;
            this.expIcon_.y = yOffset;
            if (data is AcceptedQuestData) {
                color = data.expGained_ >= data.experience_ ? 0x00cc00 :
                        data.expGained_ > data.experience_ * 0.6 ? 0xFFFF4C :
                                data.expGained_ > data.experience_ * 0.2 ? 0xFF9900 : 0xFF0000;
                extraText = color == 0x00cc00 ? "" : EquipmentToolTip.wrapColor(data.expGained_.toString(), color) + "/";
            }
            this.experience_ = new BaseSimpleText(14, color == 0x00cc00 ? color : 0xFFFFFF, false, 400).setBold(true);
            this.experience_.htmlText = "Earn " + extraText + data.experience_ + " Experience";
            this.experience_.x = this.expIcon_.width + 2;
            this.experience_.y = yOffset + 16;
            this.experience_.filters = [new DropShadowFilter(0, 0, 0)];
            this.items_.push(this.expIcon_);
            this.items_.push(this.experience_);
            yOffset += 30;
        }

        if (data.rewards_.length > 0) {
            var title:BaseSimpleText = new BaseSimpleText(18, 0xB3B3B3, false, 400).setBold(true);
            title.text = "Reward" + (data.rewards_.length > 1 || data.rewards_.length == 1 && data.expReward_ > 0 ? "s" : "") + ":";
            title.x = 12;
            title.y = yOffset + 24;
            title.filters = [new DropShadowFilter(0, 0, 0)];
            this.items_.push(title);
            yOffset += 38;
            i = 0;
            this.rewardIcons_ = new Vector.<QuestItem>(data.rewards_.length);
            this.rewards_ = new Vector.<BaseSimpleText>(data.rewards_.length);
            while (i < data.rewards_.length) {
                var reward:String = ObjectLibrary.typeToDisplayId_[data.rewards_[i]];
                this.rewardIcons_[i] = new QuestItem(data.rewards_[i], ItemConstants.DEFAULT_ITEM);
                this.rewardIcons_[i].x = 16;
                this.rewardIcons_[i].y = yOffset;
                this.rewards_[i] = new BaseSimpleText(14, 0xB3B3B3, false, 400).setBold(true);
                this.rewards_[i].text = reward;
                this.rewards_[i].x = this.rewardIcons_[i].width + this.rewardIcons_[i].x - 4;
                this.rewards_[i].y = yOffset + 16;
                this.rewards_[i].filters = [new DropShadowFilter(0, 0, 0)];
                this.items_.push(this.rewardIcons_[i]);
                this.items_.push(this.rewards_[i]);
                yOffset += 30;
                i++;
            }
            if (data.expReward_ > 0) {
                getIcon = AssetLibrary.getImageFromSet("interfaceNew", 0x10);
                bitmapData = TextureRedrawer.redraw2(getIcon, 60, true, 0);
                this.expIcon_ = new Bitmap(bitmapData);
                this.expIcon_.x = 16;
                this.expIcon_.y = yOffset;
                this.experience_ = new BaseSimpleText(14, 0xB3B3B3, false, 400).setBold(true);
                this.experience_.htmlText = data.expReward_ + " Experience";
                this.experience_.x = this.expIcon_.width + this.expIcon_.x - 4;
                this.experience_.y = yOffset + 16;
                this.experience_.filters = [new DropShadowFilter(0, 0, 0)];
                this.items_.push(this.expIcon_);
                this.items_.push(this.experience_);
            }
        }

        this.timeText_.filters = this.title_.filters = this.description_.filters =
                [new DropShadowFilter(0, 0, 0)];
    }

    private function drawBackground(height:Number):void {
        this.bgRect_.graphics.clear();
        var rect:BevelRect = new BevelRect(INNER_WIDTH, height > HEIGHT ? HEIGHT : height, 4);
        var helper:GraphicsHelper = new GraphicsHelper();
        this.bgRect_.graphics.lineStyle(2, 0x676767, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3);
        this.bgRect_.graphics.beginFill(0x454545);
        helper.drawBevelRect(2, 2, rect, this.bgRect_.graphics);
        this.bgRect_.graphics.endFill();
    }

    private function clearPreviousResults():void {
        var displayObject:DisplayObject;
        for each (displayObject in this.background_) {
            this.background_.removeChild(displayObject);
            displayObject = null;
        }
    }

    private function onResultScrollChanged(event:Event):void {
        this.background_.y = -this.scrollbar_.pos() * (this.background_.height - 520);
    }

    public function dispose():void {
        this.shape_.parent.removeChild(this.shape_);
        this.shape_ = null;
        this.items_ = null;
        this.mask_.removeChild(this.background_);
        this.mask_ = null;
        this.background_.graphics.clear();
        this.background_ = null;
        if (this.scrollbar_ != null) {
            this.scrollbar_.removeEventListener(Event.CHANGE, this.onResultScrollChanged);
            this.scrollbar_ = null;
        }
        removeChild(this.bgRect_);
        this.bgRect_ = null
    }

}
}