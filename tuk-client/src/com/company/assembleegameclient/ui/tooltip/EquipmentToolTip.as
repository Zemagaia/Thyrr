package com.company.assembleegameclient.ui.tooltip {
import com.company.assembleegameclient.constants.InventoryOwnerTypes;
import com.company.assembleegameclient.game.events.KeyInfoResponseSignal;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.screens.CharacterBox;
import com.company.assembleegameclient.ui.LineBreakDesign;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;
import com.company.assembleegameclient.util.FilterUtil;
import com.company.assembleegameclient.util.MathUtil;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.rotmg.graphics.StarGraphic;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;
import com.company.util.ConversionUtil;
import com.company.util.GraphicsUtil;
import com.company.util.KeyCodes;
import com.company.assembleegameclient.util.MathUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GraphicsPath;
import flash.display.GraphicsPathWinding;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;
import flash.utils.Dictionary;

import kabam.rotmg.constants.ActivationType;
import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.messaging.impl.data.StatData;
import kabam.rotmg.messaging.impl.incoming.KeyInfoResponse;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;
import kabam.rotmg.ui.model.HUDModel;

import thyrr.utils.ItemData;

public class EquipmentToolTip extends ToolTip {

    private static const MAX_WIDTH:int = 275;

    public static var keyInfo:Dictionary = new Dictionary();

    private var icon:ItemTileSprite;
    private var titleText:TextFieldDisplayConcrete;
    private var descText:TextFieldDisplayConcrete;
    private var line1:LineBreakDesign;
    private var firstEffectsText:TextFieldDisplayConcrete;
    private var line2:LineBreakDesign;
    private var restrictionsText:TextFieldDisplayConcrete;
    private var player:Player;
    private var isEquippable:Boolean = false;
    private var objectType:int;
    private var titleOverride:String;
    private var descriptionOverride:String;
    private var curItemXML:XML = null;
    private var objectXML:XML = null;
    private var slotTypeToTextBuilder:SlotComparisonFactory;
    private var restrictions:Vector.<Restriction>;
    private var firstEffects:Vector.<Effect>;
    private var itemSlotTypeId:int;
    private var invType:int;
    private var inventorySlotID:uint;
    private var inventoryOwnerType:String;
    private var isInventoryFull:Boolean;
    private var playerCanUse:Boolean;
    private var comparisonResults:SlotComparisonResult;
    private var levelReqText:TextFieldDisplayConcrete;
    private var keyInfoResponse:KeyInfoResponseSignal;
    private var originalObjectType:int;
    private var specialityColor:uint;
    private var specialityText:TextFieldDisplayConcrete;
    private var bagIcon:Bitmap;
    private var AEs:Vector.<Effect>;
    private var AEsText:TextFieldDisplayConcrete;
    private var lastEffects:Vector.<Effect>;
    private var lastEffectsText:TextFieldDisplayConcrete;
    private var itemData_:ItemData;
    private var curItemData_:ItemData;
    private var qualityText_:TextFieldDisplayConcrete;
    private var qualityStars_:Sprite;
    private var runesText_:TextFieldDisplayConcrete;
    private var runeSprites_:Sprite;
    private var pushedOnEquip:Boolean = false;

    private var diamondFill_:GraphicsSolidFill = new GraphicsSolidFill(0x2B2B2B, 1);
    private var diamondPath_:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>(), GraphicsPathWinding.NON_ZERO);

    private const diamondGraphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[diamondFill_, diamondPath_, GraphicsUtil.END_FILL];

    public function EquipmentToolTip(item:ItemData, player:Player, invType:int, invOwnerType:String) {
        var hudModel:HUDModel;
        this.objectType = item.ObjectType;
        this.originalObjectType = this.objectType;
        this.player = player;
        this.invType = invType;
        this.inventoryOwnerType = invOwnerType;
        this.isInventoryFull = ((player) ? player.isInventoryFull() : false);
        if ((((this.objectType >= 0x9000)) && ((this.objectType <= 0xF000)))) {
            this.objectType = 36863;
        }
        this.playerCanUse = ((player) ? ObjectLibrary.isUsableByPlayer(this.objectType, player) : false);
        this.objectXML = ObjectLibrary.xmlLibrary_[this.objectType];
        this.itemData_ = item;
        var matchingSlotIdx:int = player ? ObjectLibrary.getMatchingSlotIndex(this.objectType, player) : -1;
        var bgColor:uint;
        bgColor = objectXML.hasOwnProperty("Legendary") ? 0x332117 : objectXML.hasOwnProperty("Mythic") ? 0x2D1B1F :
                objectXML.hasOwnProperty("Unholy") ? 0x381C38 : objectXML.hasOwnProperty("Divine") ? 0x1F353A : 0x2B2B2B;
        var outlineColor:uint;
        outlineColor = objectXML.hasOwnProperty("Legendary") ? 0xAD7948 : objectXML.hasOwnProperty("Mythic") ? 0x963F3D :
                objectXML.hasOwnProperty("Unholy") ? 0xA84D8A : objectXML.hasOwnProperty("Divine") ? 0x568C7B : 0x7B7B7B;
        super(bgColor, 1, outlineColor, 1, true);
        this.slotTypeToTextBuilder = new SlotComparisonFactory();
        this.isEquippable = matchingSlotIdx != -1;
        this.firstEffects = new Vector.<Effect>();
        this.AEs = new Vector.<Effect>();
        this.lastEffects = new Vector.<Effect>();
        this.itemSlotTypeId = int(this.objectXML.SlotType);
        this.specialityColor = TooltipHelper.getSpecialityColor(this.objectXML);
        if (this.player == null) {
            this.curItemXML = this.objectXML;
            this.curItemData_ = this.itemData_;
        }
        else {
            if (this.isEquippable) {
                if (this.player.equipment_[matchingSlotIdx].ObjectType != -1) {
                    this.curItemXML = ObjectLibrary.xmlLibrary_[this.player.equipment_[matchingSlotIdx].ObjectType];
                    this.curItemData_ = this.player.equipment_[matchingSlotIdx];
                }
            }
        }
        this.addIcon();
        if ((((this.originalObjectType >= 0x9000)) && ((this.originalObjectType <= 0xF000)))) {
            if (keyInfo[this.originalObjectType] == null) {
                this.addTitle();
                this.addDescriptionText();
                this.keyInfoResponse = Global.keyInfoResponse;
                this.keyInfoResponse.add(this.onKeyInfoResponse);
                hudModel = Global.hudModel;
                hudModel.gameSprite.gsc_.keyInfoRequest(this.originalObjectType);
            }
            else {
                this.titleOverride = (keyInfo[this.originalObjectType][0] + " Key");
                this.descriptionOverride = (((keyInfo[this.originalObjectType][1] + "\n") + "Created By: ") + keyInfo[this.originalObjectType][2]);
                this.addTitle();
                this.addDescriptionText();
            }
        }
        else {
            this.addTitle();
            this.addDescriptionText();
        }
        this.addSpecialityText();
        this.addBagIcon();
        this.handleWisMod();
        this.comparisonResults = this.slotTypeToTextBuilder.getComparisonResults(this.objectXML, this.curItemXML, this.player);
        this.makePassiveEffectText();
        this.makeExtraTooltipText();
        this.addNumProjectilesTagsToEffectsList();
        this.addProjectileTagsToEffectsList();
        this.addActivateTagsToEffectsList();
        if (this.objectXML.Activate2)
            this.addActivateTagsToEffectsList(2);
        this.addRuneBoostsTagsToEffectsList();
        this.addActivateOnEquipTagsToEffectsList();
        this.addActivateOnEquipPercTagsToEffectsList();
        this.addDoseTagsToEffectsList();
        this.addMpCostTagToEffectsList();
        this.addHpCostTagToEffectsList();
        this.addLightCostTagToEffectsList();
        this.addCooldownToEffectsList();
        this.addRoFToEffectsList();
        this.addXpBonusTagToEffectsList();
        this.makeLineOne();
        this.makeFirstEffectsList();
        this.makeAEsList();
        this.makeLastEffectsList();
        this.makeLineTwo();
        this.makeRestrictionList();
        this.makeRestrictionText();
        this.makeQualityText();
        this.makeRunes();
        this.makeLevelReqText(player);
    }

    // Returns text with gray color as description based on the item power.
    // If a power is not referenced here, it will show you clearly.
    private function getPowerDesc():Effect
    {
        var power:String = this.objectXML.Power;
        var activate:XML = this.objectXML.Activate[0];
        switch (power)
        {
            case "Vindictive Wraith":
                return new Effect("on ability use, 40% chance to summon {minion} to aid you in combat", {
                    "minion": "Vindictive Spirit"
                });
            case "Demonic Wrath":
                return new Effect("any projectile damage taken when below 40% health activates a 2500 damage blast within 6 sqrs. 60 second cooldown.", {});
            case "Unstable Mind":
                return new Effect("on shoot, 1% chance to get {effect} for 2 seconds.", {
                    "effect": "Unsteady"
                });
            case "Stheno's Kiss":
                return new Effect("inflicts 1000 damage on enemy over 5 seconds. 15 second cooldown.", {});
            case "Poison Coat":
                return new Effect("when equipped, this item grants immunity to {effect}.", {
                    "effect": "Bleeding"
                });
            case "Intervention":
                return new Effect("on ability use, 5% chance to heal players within 4 sqrs for 150. 5 second cooldown.", {});
            case "Lifeline":
                return new Effect("upon reaching 30% health, gain {shieldAmount} and {lifeSteal} for {duration}. 5 minute cooldown.", {
                    "shieldAmount": int(this.player.armor_ + this.player.maxHP_ / 2) + " Shield Points",
                    "lifeSteal": "15 Life Steal",
                    "duration": "15 seconds"
                });
            case "Thorns":
                return new Effect("reflect {damage} back to your enemy whenever you get hit below 60% health. 0.5 second cooldown.", {
                    "damage": int(50 + this.player.armor_) + " damage"
                });
            case "Rotting Touch":
                return new Effect("your critical strikes now deal extra {damage}.", {
                    "damage": int(this.player.strength_ / 2) + " damage"
                });
            case "Unholy Knowledge":
                return new Effect("on ability use, gain {manaLeech} for 5 seconds. Same cooldown as ability.", {
                    "manaLeech": "3 Mana Leech"
                });
            case "Arcane Refill":
                return new Effect("on ability use, your next attack restores {amount}% Mana. Same cooldown as ability.", {
                    "amount": Math.min(100, this.player.intelligence_ / 2)
                });
            case "Godly Vigor":
                return new Effect("after not taking damage for 10 seconds, heal yourself for {amount}.", {
                    "amount": int(this.player.maxHP_ / 4)
                });
            case "Pillar of Flame":
                return new Effect("transforms you into {transformation} for {duration}, " +
                        "using ability in under {seconds} after it wears off gives stronger boosts & is more expensive." +
                        "\nNext use:\n   {strength},\n   {dexterity},\n   {stamina}\n   {manaCost}", {
                    "transformation": activate.@transformSkin,
                    "duration": (Number(activate.@duration) + this.player.flamePillarState_) + colorWisBonus(this.player.flamePillarState_) + " seconds",
                    "seconds": getModdedCooldown(this.objectXML, this.player) + " seconds",
                    "strength": "+" + (10 + this.player.flamePillarState_ * 5) + colorWisBonus(this.player.flamePillarState_ * 5) + " Strength",
                    "dexterity": "+" + (5 + this.player.flamePillarState_ * 3) + colorWisBonus(this.player.flamePillarState_ * 3) + " Dexterity",
                    "stamina": (-15 + this.player.flamePillarState_ * -5) + colorWisBonus(this.player.flamePillarState_ * -5) + " Stamina",
                    "manaCost": wrapColor("MP Cost: ", TooltipHelper.MP_COST_COLOR) + (80 + this.player.flamePillarState_ * 20) + colorWisBonus(this.player.flamePillarState_ * 20)
                });
            case "Elemental Supremacy":
                return new Effect("Your damage is now converted equally between Elemental Damage Types.", {
                });
            case "Warden's Resolve":
                return new Effect("Upon being inflicted with a negative condition effect, gain 2 Tenacity for 4s. 20s cooldown.", {
                });
            case "Nightfall":
                return new Effect("When using an ability with an empty Mana bar, restore 15% of your Mana. 60s cooldown.", {
                });
            case "Shattering Touch":
                return new Effect("If an enemy's defences would reduce your damage to under 33% of its value, inflict the opposite type of damage for the next 5s. 90s cooldown.", {
                });
            case "Royal Madness":
                return new Effect("TBD (Forgotten King Effect)", {
                });
            case "Time Loop":
                return new Effect("Your last used active cooldown will be recast with a 3s delay. 90s cooldown.", {
                });
            case "Blasphemy":
                return new Effect("When trying to cast an active cooldown while under the required Mana, use health at three times the cost. 45s cooldown.", {
                });
            case "Astray":
                return new Effect("TBD (Mythic Ogmur Effect)", {
                });
            case "Astral Assault":
                return new Effect("Your projectiles burst in small novas of new projectiles, that then travel towards the nearest enemy.", {
                });
        }
        return new Effect("this literally can't happen", {});
    }

    public static function wrapColor(text:*, color:uint):String
    {
        return TooltipHelper.wrapInFontTag(String(text), "#" + color.toString(16));
    }

    private function makePassiveEffectText():void
    {
        if (this.objectXML.hasOwnProperty("Power"))
        {
            var power:Effect = getPowerDesc();
            this.firstEffects.push(new Effect(colorByTier(this.objectXML.Power + ": ", this.objectXML) + power.name_, power.valueReplacements_));
        }
    }

    private function makeLevelReqText(player:Player):void {
        var textColor:uint;
        if (this.objectXML.hasOwnProperty("LevelReq") && this.player != null)
        {
            textColor = player.level_ >= this.objectXML.LevelReq ? 0xffffff : 0xff0000;
            this.levelReqText = new TextFieldDisplayConcrete();
            this.levelReqText.setSize(12).setColor(0xffffff).setBold(true).setHTML(true);
            this.levelReqText.setStringBuilder(new LineBuilder().setParams("Level Required: {text}", {
                "text": wrapColor(this.objectXML.LevelReq, textColor)
            }));
            this.levelReqText.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
            addChild(this.levelReqText);
            this.waiter.push(this.levelReqText.textChanged);
        }
    }

    private function makeQualityText():void
    {
        if (this.itemData_.Quality <= 0) return;

        var i:int = 0;
        this.qualityStars_ = new Sprite();
        while (i < 5)
        {
            var star:StarGraphic = new StarGraphic();
            star.x = 18 * i;
            star.transform.colorTransform = i == 0 || MathUtil.round(this.itemData_.Quality, 2) >= (0.9 + 0.05 * (i > 3 ? i + 1 : i)) ? CharacterBox.fullCT : CharacterBox.emptyCT;
            this.qualityStars_.addChild(star);
            i++;
        }
        this.qualityText_ = new TextFieldDisplayConcrete();
        this.qualityText_.setSize(14).setColor(0xb3b3b3);
        this.qualityText_.setStringBuilder(new LineBuilder().setParams("Quality:"));
        this.qualityText_.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
        this.qualityStars_.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.qualityText_);
        addChild(this.qualityStars_);
        this.waiter.push(this.qualityText_.textChanged);
    }

    private function makeRunes():void {
        if (this.itemData_ == null || this.itemData_.Runes == null)
            return;

        this.runeSprites_ = new Sprite();
        this.runeSprites_.graphics.clear();
        var i:int = 0;
        while (i < this.itemData_.Runes.length) {
            var sprite:Sprite = new Sprite();
            if (this.itemData_.Runes[i] <= 0) {
                GraphicsUtil.clearPath(this.diamondPath_);
                GraphicsUtil.drawDiamond(0, 0, 8, this.diamondPath_);
                sprite.graphics.lineStyle(1, 0x7B7B7B);
                sprite.graphics.drawGraphicsData(this.diamondGraphicsData_);
                sprite.x = 24 * (i % 4);
                sprite.y = 24 * int(i / 4);
                sprite.filters = [new DropShadowFilter(0, 0, 0)];
                this.runeSprites_.addChild(sprite);
            }
            else {
                var data:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.itemData_.Runes[i], 40, true, true);
                data = BitmapUtil.cropToBitmapData(data, 4, 4, (data.width - 8), (data.height - 8));
                var bitmap:Bitmap = new Bitmap(data);
                bitmap.x = -16 + 24 * (i % 4);
                bitmap.y = -16 + 24 * int(i / 4);
                this.runeSprites_.addChild(bitmap);
            }
            i++;
        }
        this.runesText_ = new TextFieldDisplayConcrete();
        this.runesText_.setSize(14).setColor(0xb3b3b3);
        this.runesText_.setStringBuilder(new LineBuilder().setParams("Sockets:"));
        this.runesText_.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
        addChild(this.runesText_);
        addChild(this.runeSprites_);
        this.waiter.push(this.runesText_.textChanged);
    }

    private function onKeyInfoResponse(response:KeyInfoResponse):void {
        this.keyInfoResponse.remove(this.onKeyInfoResponse);
        this.removeTitle();
        this.removeDesc();
        this.titleOverride = response.name;
        this.descriptionOverride = response.description;
        keyInfo[this.originalObjectType] = [response.name, response.description, response.creator];
        this.addTitle();
        this.addDescriptionText();
    }

    private function makeExtraTooltipText():void {
        var effectInfos:XMLList;
        var effectInfo:XML;
        var name:String;
        var description:String;
        var delim:String;
        var alb:AppendingLineBuilder;
        if (this.objectXML.hasOwnProperty("ExtraTooltipData")) {
            effectInfos = this.objectXML.ExtraTooltipData.EffectInfo;
            for each (effectInfo in effectInfos) {
                name = effectInfo.attribute("name");
                description = effectInfo.attribute("description");
                delim = (name && description) ? ": " : "\n";
                alb = new AppendingLineBuilder();
                if (name) {
                    alb.pushParams(name);
                }
                if (description) {
                    alb.pushParams(description, {}, 16777103);
                }
                alb.setDelimiter(delim);
                this.firstEffects.push(new Effect("{data}", {"data": alb}));
            }
        }
    }

    private function isEmptyEquipSlot():Boolean {
        return (((this.isEquippable) && ((this.curItemXML == null))));
    }

    private function addIcon():void
    {
        this.icon = new ItemTileSprite(null);
        this.icon.setType(this.itemData_, 60);
        var data:BitmapData = this.icon.itemBitmap.bitmapData;
        this.icon.itemBitmap.bitmapData = BitmapUtil.cropToBitmapData(data, 8, 8, data.width - 16, data.height - 16);
        this.icon.x = 18;
        this.icon.y = 20;
        addChild(this.icon);
        var tick:Function = function (event:Event):void
        {
            icon.tickSprite();
        }
        this.icon.addEventListener(Event.ENTER_FRAME, tick);
    }

    private function addRoFToEffectsList():void {
        var otherRof:Number;
        var replacementColor:uint;
        var thisRof:Number;
        if (this.objectXML.hasOwnProperty("RateOfFire")) {
            otherRof = Number(this.objectXML.RateOfFire);
            replacementColor = TooltipHelper.NO_DIFF_COLOR;
            if (!(this.curItemXML == null) && this.curItemXML.hasOwnProperty("RateOfFire")) {
                thisRof = Number(this.curItemXML.RateOfFire);
                replacementColor = TooltipHelper.getTextColor((otherRof - thisRof));
            }
            this.firstEffects.push(new Effect("Rate of Fire: {rof}",
                    {"rof": (MathUtil.round(this.objectXML.RateOfFire * 100, 2) + "%")}).setReplacementsColor(replacementColor));
        }
    }

    private function addCooldownToEffectsList():void
    {
        var cd:Number = getCooldown(this.objectXML);
        var replacementColor:uint = TooltipHelper.NO_DIFF_COLOR;
        var thisCd:Number;
        var hasHaste:Boolean = this.player != null && this.player.haste_ > 0;
        var slotType:int = this.objectXML.SlotType;
        if ((this.objectXML.hasOwnProperty("Cooldown") || hasHaste)
                && this.objectXML.hasOwnProperty("Activate") && slotType != 10 && slotType != 26)
        {
            if (this.curItemXML != null && (this.curItemXML.hasOwnProperty("Cooldown") || hasHaste))
            {
                thisCd = getCooldown(this.curItemXML);
                replacementColor = TooltipHelper.getTextColor((thisCd - cd));
            }
            var hasteModCd:Number = getModdedCooldown(this.objectXML, this.player);
            if (hasteModCd < 1.0)
                hasteModCd = MathUtil.round(hasteModCd, 3);
            this.lastEffects.push(new Effect("Cooldown #1: {cd}",
                    {
                        "cd": TooltipHelper.getPlural(hasteModCd, "second") +
                                colorCdReductionBonus(MathUtil.round(cd - hasteModCd, 3))
                    }).setReplacementsColor(replacementColor));
        }

        cd = getCooldown2(this.objectXML);
        replacementColor = TooltipHelper.NO_DIFF_COLOR;
        hasHaste = this.player != null && this.player.haste_ > 0;
        slotType = this.objectXML.SlotType;
        if ((this.objectXML.hasOwnProperty("Cooldown2") || hasHaste)
                && this.objectXML.hasOwnProperty("Activate") && slotType != 10 && slotType != 26)
        {
            if (this.curItemXML != null && (this.curItemXML.hasOwnProperty("Cooldown2") || hasHaste))
            {
                thisCd = getCooldown2(this.curItemXML);
                replacementColor = TooltipHelper.getTextColor((thisCd - cd));
            }
            hasteModCd = getModdedCooldown2(this.objectXML, this.player);
            if (hasteModCd < 1.0)
                hasteModCd = MathUtil.round(hasteModCd, 3);
            this.lastEffects.push(new Effect("Cooldown #2: {cd}",
                    {
                        "cd": TooltipHelper.getPlural(hasteModCd, "second") +
                                colorCdReductionBonus(MathUtil.round(cd - hasteModCd, 3))
                    }).setReplacementsColor(replacementColor));
        }
    }

    private static function getCooldown(xml:XML):Number{
        return xml.hasOwnProperty("Cooldown") ? Number(xml.Cooldown) : 0.5;
    }

    private static function getCooldown2(xml:XML):Number{
        return xml.hasOwnProperty("Cooldown2") ? Number(xml.Cooldown2) : 0.5;
    }

    public static function getModdedCooldown(xml:XML, player:Player):Number
    {
        var haste:int = player != null ? player.haste_ : 0;
        var cd:Number = getCooldown(xml);
        return MathUtil.round(cd * (100 / (100 + haste)), 2);
    }

    public static function getModdedCooldown2(xml:XML, player:Player):Number
    {
        var haste:int = player != null ? player.haste_ : 0;
        var cd:Number = getCooldown2(xml);
        return MathUtil.round(cd * (100 / (100 + haste)), 2);
    }

    private function isPet():Boolean {
        var activateTags:XMLList;
        activateTags = this.objectXML.Activate.(text() == "PermaPet");
        return ((activateTags.length() >= 1));
    }

    private function removeTitle():void {
        removeChild(this.titleText);
    }

    private function removeDesc():void {
        removeChild(this.descText);
    }

    private function addTitle():void
    {
        var slotType:int = this.objectXML.SlotType;
        var isUntiered:Boolean = !this.objectXML.hasOwnProperty("Tier")
                && slotType != 0 && slotType != 10 && slotType != 26;
        var isTiered:Boolean = this.objectXML.hasOwnProperty("Tier")
                && slotType != 0 && slotType != 10 && slotType != 26;
        var color:int = isUntiered ? 0xB3B3B3 : (isTiered ? 0xFFFFFF : this.specialityColor);
        this.titleText = new TextFieldDisplayConcrete();
        this.titleText.setSize(17).setColor(color).setTextWidth(188);
        this.titleText.setStringBuilder(new LineBuilder().setParams(ObjectLibrary.typeToDisplayId_[this.objectType]));
        this.titleText.setAutoSize(TextFieldAutoSize.LEFT);
        this.titleText.setBold(true);
        this.titleText.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
        this.titleText.textChanged.addOnce(this.titleText.resize);
        this.waiter.push(this.titleText.textChanged);
        addChild(this.titleText);
    }

    private function addSpecialityText():void {
        var text:String = TooltipHelper.getSpecialityText(this.objectXML);
        this.specialityText = new TextFieldDisplayConcrete();
        this.specialityText.setSize(14).setColor(this.specialityColor);
        this.specialityText.setStringBuilder(new LineBuilder().setParams(text));
        this.specialityText.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
        addChild(this.specialityText);
    }

    private function addBagIcon():void {
        var tex:BitmapData = GetBagTexture(this.objectXML.BagType, 40);
        tex = BitmapUtil.cropToBitmapData(tex, 4, 4, tex.width - 8, tex.height - 8);
        this.bagIcon = new Bitmap(tex);
        this.bagIcon.x = (MAX_WIDTH - this.bagIcon.width) + 4;
        this.bagIcon.y = ((this.icon.height - this.bagIcon.height) / 2) - 2;
        addChild(this.bagIcon);
    }

    private static function GetBagTexture(bagType:int, size:int):BitmapData {
        switch (bagType) {
            case 0: // Brown
                return ObjectLibrary.getRedrawnTextureFromType(0x0407, size, true);
            case 1: // Black
                return ObjectLibrary.getRedrawnTextureFromType(0x0408, size, true);
            case 2: // Blue
                return ObjectLibrary.getRedrawnTextureFromType(0x0409, size, true);
            case 3: // Egg
                return ObjectLibrary.getRedrawnTextureFromType(0x040A, size, true);
            case 4: // Gray
                return ObjectLibrary.getRedrawnTextureFromType(0x040B, size, true);
            case 5: // Golden
                return ObjectLibrary.getRedrawnTextureFromType(0x040C, size, true);
            case 6: // Red
                return ObjectLibrary.getRedrawnTextureFromType(0x040D, size, true);
            case 7: // Pink
                return ObjectLibrary.getRedrawnTextureFromType(0x040E, size, true);
            case 8: // Cyan
                return ObjectLibrary.getRedrawnTextureFromType(0x040F, size, true);
        }
        return null;
    }

    private function makeLineOne():void {
        var alb:AppendingLineBuilder;
        this.line1 = new LineBreakDesign((MAX_WIDTH + 8), objectXML.hasOwnProperty("Legendary") ? 0xAD7948 : objectXML.hasOwnProperty("Mythic") ? 0x963F3D :
                objectXML.hasOwnProperty("Unholy") ? 0xA84D8A : objectXML.hasOwnProperty("Divine") ? 0x568C7B : 0x7B7B7B);
        var pushed:Boolean = false;
        alb = this.getFirstEffectsStringBuilder();
        if (alb.hasLines()) {
            addChild(this.line1);
            pushed = true;
        }
        alb = this.getAEsStringBuilder();
        if (alb.hasLines() && !pushed) {
            addChild(this.line1);
            pushed = true;
        }
        alb = this.getLastEffectsStringBuilder();
        if (alb.hasLines() && !pushed) {
            addChild(this.line1);
        }
    }

    private function makeFirstEffectsList():void {
        var alb:AppendingLineBuilder;
        if (this.firstEffects.length != 0 || this.comparisonResults.lineBuilder != null || this.objectXML.hasOwnProperty("ExtraTooltipData")) {
            this.firstEffectsText = new TextFieldDisplayConcrete().setSize(14).setColor(0xB3B3B3).setTextWidth(MAX_WIDTH - 8).setIndent(-10).setLeftMargin(10).setWordWrap(true).setHTML(true);
            alb = this.getFirstEffectsStringBuilder();
            this.firstEffectsText.setStringBuilder(alb);
            this.firstEffectsText.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
            if (alb.hasLines()) {
                addChild(this.firstEffectsText);
            }
        }
    }

    private function makeAEsList():void {
        var alb:AppendingLineBuilder;
        if (this.AEs.length != 0 || this.comparisonResults.lineBuilder != null) {
            this.AEsText = new TextFieldDisplayConcrete().setSize(14).setColor(0xB3B3B3).setTextWidth(MAX_WIDTH - 8).setIndent(-10).setLeftMargin(22).setWordWrap(true).setHTML(true);
            alb = this.getAEsStringBuilder();
            this.AEsText.setStringBuilder(alb);
            this.AEsText.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
            if (alb.hasLines()) {
                addChild(this.AEsText);
            }
        }
    }

    private function makeLastEffectsList():void {
        var alb:AppendingLineBuilder;
        if (this.lastEffects.length != 0 || this.comparisonResults.lineBuilder != null) {
            this.lastEffectsText = new TextFieldDisplayConcrete().setSize(14).setColor(0xB3B3B3).setTextWidth(MAX_WIDTH - 8).setWordWrap(true).setHTML(true);
            alb = this.getLastEffectsStringBuilder();
            this.lastEffectsText.setStringBuilder(alb);
            this.lastEffectsText.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
            if (alb.hasLines()) {
                addChild(this.lastEffectsText);
            }
        }
    }

    private function getFirstEffectsStringBuilder():AppendingLineBuilder {
        var alb:AppendingLineBuilder = new AppendingLineBuilder();
        this.appendEffects(this.firstEffects, alb);
        return (alb);
    }

    private function getAEsStringBuilder():AppendingLineBuilder {
        var alb:AppendingLineBuilder = new AppendingLineBuilder();
        if (this.comparisonResults.lineBuilder.hasLines()) {
            alb.pushParams("{data}", {"data": this.comparisonResults.lineBuilder});
        }
        this.appendEffects(this.AEs, alb);
        return (alb);
    }

    private function getLastEffectsStringBuilder():AppendingLineBuilder {
        var alb:AppendingLineBuilder = new AppendingLineBuilder();
        this.appendEffects(this.lastEffects, alb);
        return (alb);
    }

    private function appendEffects(effects:Vector.<Effect>, alb:AppendingLineBuilder):void {
        var effect:Effect;
        for each (effect in effects) {
            alb.pushParams(effect.name_, effect.getValueReplacementsWithColor(), effect.color_);
        }
    }

    private function addNumProjectilesTagsToEffectsList():void {
        if (this.objectXML.hasOwnProperty("NumProjectiles"))
            this.firstEffects.push(new Effect("Shots: {numShots}", {"numShots": this.objectXML.NumProjectiles}));
    }

    private function addXpBonusTagToEffectsList():void {
        var xpBonus:int;
        var usable:uint;
        var curXpBonus:int;
        if (this.objectXML.hasOwnProperty("XpBonus")) {
            xpBonus = int(this.objectXML.XpBonus);
            usable = ((this.playerCanUse) ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR);
            if (((!((this.curItemXML == null))) && (this.curItemXML.hasOwnProperty("XpBonus")))) {
                curXpBonus = int(this.curItemXML.XpBonus.text());
                usable = TooltipHelper.getTextColor((xpBonus - curXpBonus));
            }
            this.lastEffects.push(new Effect("XP Bonus: {percent}", {"percent": (this.objectXML.XpBonus + "%")}).setReplacementsColor(usable));
        }
    }

    private function addMpCostTagToEffectsList():void {
        if (this.objectXML.Power == "Pillar of Flame")
        {
            return;
        }

        var otherMpCost:int;
        var replacementsColor:uint;
        var thisMpCost:int;
        if (this.objectXML.hasOwnProperty("MpEndCost")) {
            otherMpCost = int(this.objectXML.MpEndCost);
            replacementsColor = this.playerCanUse ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR;
            if (this.curItemXML != null && this.curItemXML.hasOwnProperty("MpEndCost")) {
                thisMpCost = int(this.curItemXML.MpEndCost.text());
                replacementsColor = TooltipHelper.getTextColor((thisMpCost - otherMpCost));
            }
            this.lastEffects.push(new Effect("MP Cost: {cost}", {"cost": this.objectXML.MpEndCost}).setColor(TooltipHelper.MP_COST_COLOR).setReplacementsColor(replacementsColor));
            return;
        }
        if (this.objectXML.hasOwnProperty("MpCost") && !this.comparisonResults.processedTags[this.objectXML.MpCost[0].toXMLString()]) {
            otherMpCost = int(this.objectXML.MpCost);
            replacementsColor = this.playerCanUse ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR;
            if (this.curItemXML != null && this.curItemXML.hasOwnProperty("MpCost")) {
                thisMpCost = int(this.curItemXML.MpCost.text());
                replacementsColor = TooltipHelper.getTextColor((thisMpCost - otherMpCost));
            }
            this.lastEffects.push(new Effect("MP Cost: {cost}", {"cost": this.objectXML.MpCost}).setColor(TooltipHelper.MP_COST_COLOR).setReplacementsColor(replacementsColor));
        }
    }

    private function addHpCostTagToEffectsList():void {
        var otherHpCost:int;
        var replacementsColor:uint;
        var thisHpCost:int;
        if (this.objectXML.hasOwnProperty("HpEndCost")) {
            otherHpCost = int(this.objectXML.HpEndCost);
            replacementsColor = this.playerCanUse ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR;
            if (this.curItemXML != null && this.curItemXML.hasOwnProperty("HpEndCost")) {
                thisHpCost = int(this.curItemXML.HpEndCost.text());
                replacementsColor = TooltipHelper.getTextColor((thisHpCost - otherHpCost));
            }
            this.lastEffects.push(new Effect("HP Cost: {cost}", {"cost": this.objectXML.HpEndCost}).setColor(TooltipHelper.HP_COST_COLOR).setReplacementsColor(replacementsColor));
            return;
        }
        if (this.objectXML.hasOwnProperty("HpCost") && !this.comparisonResults.processedTags[this.objectXML.HpCost[0].toXMLString()]) {
            otherHpCost = int(this.objectXML.HpCost);
            replacementsColor = this.playerCanUse ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR;
            if (this.curItemXML != null && this.curItemXML.hasOwnProperty("HpCost")) {
                thisHpCost = int(this.curItemXML.HpCost.text());
                replacementsColor = TooltipHelper.getTextColor((thisHpCost - otherHpCost));
            }
            this.lastEffects.push(new Effect("HP Cost: {cost}", {"cost": this.objectXML.HpCost}).setColor(TooltipHelper.HP_COST_COLOR).setReplacementsColor(replacementsColor));
        }
    }

    private function addLightCostTagToEffectsList():void {
        var otherLightCost:int;
        var replacementsColor:uint;
        var thisLightCost:int;
        if (this.objectXML.hasOwnProperty("LightEndCost")) {
            otherLightCost = int(this.objectXML.LightEndCost);
            replacementsColor = this.playerCanUse ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR;
            if (this.curItemXML != null && this.curItemXML.hasOwnProperty("LightEndCost")) {
                thisLightCost = int(this.curItemXML.LightEndCost.text());
                replacementsColor = TooltipHelper.getTextColor((thisLightCost - otherLightCost));
            }
            this.lastEffects.push(new Effect("Light Cost: {cost}", {"cost": this.objectXML.LightEndCost}).setColor(0xFFFFD9).setReplacementsColor(replacementsColor));
            return;
        }
        if (this.objectXML.hasOwnProperty("LightCost") && !this.comparisonResults.processedTags[this.objectXML.LightCost[0].toXMLString()]) {
            otherLightCost = int(this.objectXML.LightCost);
            replacementsColor = this.playerCanUse ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR;
            if (this.curItemXML != null && this.curItemXML.hasOwnProperty("LightCost")) {
                thisLightCost = int(this.curItemXML.LightCost.text());
                replacementsColor = TooltipHelper.getTextColor((thisLightCost - otherLightCost));
            }
            this.lastEffects.push(new Effect("Light Cost: {cost}", {"cost": this.objectXML.LightCost}).setColor(0xFFFFD9).setReplacementsColor(replacementsColor));
        }
    }

    private function addDoseTagsToEffectsList():void {
        var quantity:String = String(this.objectXML.Quantity);
        if (this.objectXML.hasOwnProperty("Quantity") || this.itemData_.Quantity) {
            if (this.itemData_.Quantity) {
                quantity = String(this.itemData_.Quantity);
            }
            this.lastEffects.push(new Effect("Quantity: {quantity}", {"quantity": quantity}));
        }
        quantity = String(this.objectXML.MaxQuantity);
        if (this.objectXML.hasOwnProperty("MaxQuantity") || this.itemData_.MaxQuantity) {
            if (this.itemData_.MaxQuantity) {
                quantity = String(this.itemData_.MaxQuantity);
            }
            this.lastEffects.push(new Effect("Max Quantity: {quantity}", {"quantity": quantity}));
        }
    }

    private function addProjectileTagsToEffectsList():void
    {
        var curProj:XML;
        if (this.objectXML.hasOwnProperty("Projectile"))
        {
            curProj = this.curItemXML == null ? null : this.curItemXML.Projectile[0];
            this.addProjectile(this.objectXML.Projectile[0], curProj);
        }
    }

    private function addProjectile(proj:XML, thisProj:XML=null):void {
        var effect:XML;
        var minDmg:ComPairTag = new ComPairTag(proj, thisProj, "MinDamage");
        var maxDmg:ComPairTag = new ComPairTag(proj, thisProj, "MaxDamage");
        var speed:ComPairTag = new ComPairTag(proj, thisProj, "Speed");
        var lifetime:ComPairTag = new ComPairTag(proj, thisProj, "LifetimeMS");
        var boomerang:ComPairTagBool = new ComPairTagBool(proj, thisProj, "Boomerang");
        var parametric:ComPairTagBool = new ComPairTagBool(proj, thisProj, "Parametric");
        var magnitude:ComPairTag = new ComPairTag(proj, thisProj, "Magnitude", 3);
        var acceleration:ComPairTag = new ComPairTag(proj, thisProj, "Acceleration", 0);
        var msPerAccel:ComPairTag = new ComPairTag(proj, thisProj, "MSPerAcceleration", 50);
        var speedCap:ComPairTag = new ComPairTag(proj, thisProj, "SpeedCap", -1);
        if (speedCap.a == -1)
            speedCap.a = speed.a + acceleration.a * 10;
        if (speedCap.b == -1)
            speedCap.b = speed.b + acceleration.b * 10;
        if (acceleration.a)
        {
            speed.a = speed.a + acceleration.a * (lifetime.a / msPerAccel.a);
            if (acceleration.a < 0 && speed.a < speedCap.a || acceleration.a > 0 && speed.a > speedCap.a)
                speed.a = speedCap.a;
        }

        if (acceleration.b)
        {
            speed.b = speed.b + acceleration.b * (lifetime.b / msPerAccel.b);
            if (acceleration.b < 0 && speed.b < speedCap.b || acceleration.b > 0 && speed.b > speedCap.b)
                speed.b = speedCap.b;
        }

        var range:Number = parametric.a ? magnitude.a : MathUtil.round((speed.a * lifetime.a) / (int(boomerang.a) + 1) / 10000, 2);
        var thisRange:Number = parametric.b ? magnitude.b : MathUtil.round((speed.b * lifetime.b) / (int(boomerang.b) + 1) / 10000, 2);
        var quality:Number = this.itemData_.Quality > 0 ? this.itemData_.Quality : 1;
        var thisQuality:Number = this.curItemData_ && this.curItemData_.Quality ? this.curItemData_.Quality : quality;

        var maxA:int = quality > 0 ? int(maxDmg.a * quality) : maxDmg.a;
        var minA:int = quality > 0 ? int(minDmg.a * quality) : minDmg.a;
        var maxB:int = int(maxDmg.b * thisQuality);
        var minB:int = int(minDmg.b * thisQuality);
        var aAvg:Number = ((maxA + minA) / 2);
        var bAvg:Number = ((maxB + minB) / 2);
        var text:String = String((minA == maxA) ? minA : ((minA + " - ") + maxA));
        var damageType:String = !proj.hasOwnProperty("DamageType") ? "Physical" : proj.DamageType;
        var boosts:Vector.<int> = this.itemData_.DamageBoosts;
        var additional:String = this.itemData_.DamageBoosts ?
                (boosts[0] != 0 ? " (" + wrapColor(prefix(boosts[0]), TooltipHelper.getTextColor2(boosts[0])) + " PS)" : "") +
                (boosts[1] != 0 ? " (" + wrapColor(prefix(boosts[1]), TooltipHelper.getTextColor2(boosts[1])) + " M)" : "") +
                (boosts[2] != 0 ? " (" + wrapColor(prefix(boosts[2]), TooltipHelper.getTextColor2(boosts[2])) + " E)" : "") +
                (boosts[3] != 0 ? " (" + wrapColor(prefix(boosts[3]), TooltipHelper.getTextColor2(boosts[3])) + " A)" : "") +
                (boosts[4] != 0 ? " (" + wrapColor(prefix(boosts[4]), TooltipHelper.getTextColor2(boosts[4])) + " PF)" : "") +
                (boosts[5] != 0 ? " (" + wrapColor(prefix(boosts[5]), TooltipHelper.getTextColor2(boosts[5])) + " F)" : "") +
                (boosts[6] != 0 ? " (" + wrapColor(prefix(boosts[6]), TooltipHelper.getTextColor2(boosts[6])) + " W)" : "") +
                (boosts[7] != 0 ? " (" + wrapColor(prefix(boosts[7]), TooltipHelper.getTextColor2(boosts[7])) + " H)" : "")
                : "";
        var damageText:String = damageType + " " + "Damage: {damage}" + additional;
        var replacements:Object = {"damage": wrapColor(text, TooltipHelper.getTextColor(aAvg - bAvg))};
        this.firstEffects.push(new Effect(damageText, replacements));
        this.firstEffects.push(new Effect("Range: {range}", {
            "range": wrapColor(range, TooltipHelper.getTextColor(range - thisRange))
        }));
        if (proj.hasOwnProperty("ConditionEffect")) {
            var shotEffectNum:int = proj.ConditionEffect.length;
            var shotEffects:String = shotEffectNum > 1 ? "Shot Effects:" : "Shot Effect:";
            this.firstEffects.push(new Effect(shotEffects, {}));
            for each (effect in proj.ConditionEffect) {
                this.firstEffects.push(new Effect("    {effect} for {duration}", {
                    "effect": effect,
                    "duration": TooltipHelper.getPlural(effect.@duration, "sec")
                }));
            }
        }
        if (proj.hasOwnProperty("MultiHit")) {
            this.firstEffects.push(new Effect("Shots hit multiple targets", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
        }
        if (proj.hasOwnProperty("PassesCover")) {
            this.firstEffects.push(new Effect("Shots pass through obstacles", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
        }
        if (parametric.a) {
            this.firstEffects.push(new Effect("Shots are parametric", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
        }
        else {
            if (boomerang.a) {
                this.firstEffects.push(new Effect("Shots boomerang", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
            }
        }
    }

    private var pushedMpCost2:Boolean = false;
    private var pushed:Boolean = false;
    private function addActivateTagsToEffectsList(activateType:int = 1):void
    {
        var s:Object; // stat

        var activate:XML;
        var thisActivate:XML;
        var activateX:XMLList = this.objectXML.Activate;
        var activationType:String;

        if (activateType == 2)
            activateX = this.objectXML.Activate2;

        // Ignores activate tooltip for all activate effects.
        if (this.objectXML.hasOwnProperty("IgnoreTooltip"))
        {
            return;
        }

        // special case
        if (this.objectXML.Power == "Pillar of Flame")
        {
            return;
        }

        for each (activate in activateX)
        {
            activationType = activate.toString();
            if (!pushed && activationType != ActivationType.CREATE && activationType != ActivationType.SHOOT
                    && activationType != ActivationType.SHURIKEN_ABILITY && activationType != ActivationType.UNLOCK_PORTAL
                    && activationType != ActivationType.CLEAR_COND_EFFECT_SELF && activationType != ActivationType.CLEAR_COND_EFFECT_AURA
                    && activationType != ActivationType.DAZE_BLAST && activationType != ActivationType.PET && activationType != ActivationType.PERMA_PET
                    && activationType != "CreatePet" && activationType != ActivationType.SMALL_DIG && activationType != ActivationType.FILL
                    && activationType != "UnlockSkin" && activationType != ActivationType.DYE){
                this.firstEffects.push(new Effect("On Use:",{}));
                pushed = true;
            }
            if (this.comparisonResults.processedTags[activate.toXMLString()] == null)
            {
                thisActivate = ((this.curItemXML == null) ? null : this.curItemXML.Activate.(text() == activationType)[0]);
                if (activateType == 2)
                    thisActivate = ((this.curItemXML == null) ? null : this.curItemXML.Activate2.(text() == activationType)[0]);

                if (activateType == 2 && activationType != "" && !this.pushedMpCost2)
                {
                    var manaEndCost:int = this.objectXML.MpEndCost2;
                    var manaCost:int = this.objectXML.MpCost2;
                    var costText:String = "";
                    var color:uint = TooltipHelper.NO_DIFF_COLOR;

                    if (manaEndCost != 0)
                    {
                        if (this.curItemXML != null && int(this.curItemXML.MpEndCost2) != 0)
                            color = TooltipHelper.getTextColor((int(this.curItemXML.MpEndCost2) - int(this.objectXML.MpEndCost2)))
                        else if (this.curItemXML != null && int(this.curItemXML.MpEndCost2) == 0)
                            color = TooltipHelper.BETTER_COLOR;

                        costText = " (" + wrapColor(manaEndCost.toString(), color) + " " +
                                wrapColor("MP", 0xB368FF) + ")";
                    }
                    else if (manaCost != 0)
                    {
                        if (this.curItemXML != null && int(this.curItemXML.MpCost2) != 0)
                            color = TooltipHelper.getTextColor((int(this.curItemXML.MpCost2) - int(this.objectXML.MpCost2)))
                        else if (this.curItemXML != null && int(this.curItemXML.MpCost2) == 0)
                            color = TooltipHelper.BETTER_COLOR;

                        costText = " (" + wrapColor(manaCost.toString(), color) + " " +
                                wrapColor("MP", 0xB368FF) + ")";
                    }

                    this.AEs.push(new Effect("Alternative Cast" + costText + ":",{}).setColor(0xffffff));
                    this.pushedMpCost2 = true;
                }

                switch (activationType)
                {
                    case ActivationType.COND_EFFECT_AURA:
                        this.AEs.push(new Effect("-On Party: {effect} for {duration} within {range}", {
                            "range": TooltipHelper.getPlural(activate.@range, "sqr"),
                            "effect": activate.@effect,
                            "duration": TooltipHelper.getPlural(activate.@duration, "sec")
                        }));
                        break;
                    case ActivationType.COND_EFFECT_SELF:
                        this.AEs.push(new Effect("-On Self: {effect} for {duration}", {
                            "effect": activate.@effect,
                            "duration": TooltipHelper.getPlural(activate.@duration, "sec")
                        }));
                        break;
                    case ActivationType.STAT_BOOST_SELF:
                        s = String(activate.@stat);
                        switch (s){
                            case "MaximumHP": s = "Maximum HP"; break;
                            case "MaximumMP": s = "Maximum MP"; break;
                            case "ShieldPoints": s = "Shield Points"; break;
                            case "CriticalStrike": s = "Critical Strike"; break;
                            case "LifeSteal": s = "Health on Hit"; break;
                            case "LifeStealKill": s = "Health on Kill"; break;
                            case "ManaLeech": s = "Mana on Hit"; break;
                            case "ManaLeechKill": s = "Mana on Kill"; break;
                        }
                        if (s == "")
                            s = new LineBuilder().setParams(StatData.statToName(int(activate.@statId)));
                        this.AEs.push(new Effect("-On Self: {amount} {stat} for {duration}",
                                {
                                    "amount": prefix(activate.@amount),
                                    "stat": s,
                                    "duration": TooltipHelper.getPlural(activate.@duration, "sec")
                                }));
                        break;
                    case ActivationType.STAT_BOOST_AURA:
                        s = String(activate.@stat);
                        switch (s){
                            case "MaximumHP": s = "Maximum HP"; break;
                            case "MaximumMP": s = "Maximum MP"; break;
                            case "ShieldPoints": s = "Shield Points"; break;
                            case "CriticalStrike": s = "Critical Strike"; break;
                            case "LifeSteal": s = "Health on Hit"; break;
                            case "LifeStealKill": s = "Health on Kill"; break;
                            case "ManaLeech": s = "Mana on Hit"; break;
                            case "ManaLeechKill": s = "Mana on Kill"; break;
                        }
                        if (s == "")
                            s = new LineBuilder().setParams(StatData.statToName(int(activate.@statId)));
                        this.AEs.push(new Effect(
                                "-On Party: {amount} {stat} for {duration} within {range}", {
                                    "range": TooltipHelper.getPlural(activate.@range, "sqr"),
                                    "stat": s,
                                    "amount": prefix(activate.@amount),
                                    "duration": TooltipHelper.getPlural(activate.@duration, "sec")
                                }));
                        break;
                    case ActivationType.HEAL:
                        this.AEs.push(new Effect("{statAmount}{statName}", {
                            "statAmount":(("+" + activate.@amount) + " "),
                            "statName":new LineBuilder().setParams("HP")
                        }));
                        break;
                    case ActivationType.HEAL_NOVA:
                        this.AEs.push(new Effect("-Party Heal: {amount} within {range}", {
                            "amount":activate.@amount + " " + "HP",
                            "range":activate.@range + " " + "sqrs"}));
                        break;
                    case ActivationType.MAGIC:
                        this.AEs.push(new Effect("{statAmount}{statName}", {
                            "statAmount":(("+" + activate.@amount) + " "),
                            "statName":new LineBuilder().setParams("MP")
                        }));
                        break;
                    case ActivationType.MAGIC_NOVA:
                        this.AEs.push(new Effect("-Party Magic: {amount} within {range}", {
                            "amount":activate.@amount + " " + "MP",
                            "range":activate.@range + " " + "sqrs"}));
                        break;
                    case ActivationType.TELEPORT:
                        this.AEs.push(new Effect("-Teleport to Target", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                    case ActivationType.SPAWN_UNDEAD:
                        this.getSkull(activate, thisActivate);
                        break;
                    case ActivationType.BULLET_NOVA:
                        this.getSpell(activate, thisActivate);
                        break;
                    case ActivationType.TOTEM:
                        this.getTotem(activate, thisActivate);
                        break;
                    case ActivationType.CARD:
                        this.getCard(activate, thisActivate);
                        break;
                    case ActivationType.TRAP:
                        this.AEs.push(new Effect("-Trap: {data}", {
                            "data": new AppendingLineBuilder().pushParams("{amount} within {range}", {
                                "amount": activate.@totalDamage + " damage",
                                "range": TooltipHelper.getPlural(activate.@radius, "sqr")
                            }, TooltipHelper.NO_DIFF_COLOR).pushParams("{effect} for {duration} seconds", {
                                "effect": (activate.hasOwnProperty("@condEffect") ? activate.@condEffect : new LineBuilder().setParams("Slow")),
                                "duration": (activate.hasOwnProperty("@condDuration") ? activate.@condDuration : "5")
                            }, TooltipHelper.NO_DIFF_COLOR)
                        }));
                        break;
                    case ActivationType.STASIS_BLAST:
                        this.AEs.push(new Effect("-Stasis on group: {stasis}", {
                            "stasis": new AppendingLineBuilder().pushParams("{duration}", {
                                "duration":TooltipHelper.getPlural(activate.@duration, "sec")}, TooltipHelper.NO_DIFF_COLOR)
                        }));
                        break;
                    case ActivationType.DECOY:
                        this.AEs.push(new Effect("-Decoy: {data}", {
                            "data": new AppendingLineBuilder().pushParams("{duration}", {
                                "duration": TooltipHelper.getPlural(activate.@duration, "sec")}, TooltipHelper.NO_DIFF_COLOR)
                        }));
                    break;
                    case ActivationType.LIGHTNING:
                        this.getScepter(activate, thisActivate);
                        break;
                    case ActivationType.VIAL:
                        this.getVial(activate, thisActivate);
                        break;
                    case ActivationType.POISON_TIP:
                        this.getPoisonTip(activate, thisActivate);
                        break;
                    case ActivationType.ORB:
                        this.getOrb(activate, thisActivate);
                        break;
                    case ActivationType.REMOVE_NEG_COND:
                        this.AEs.push(new Effect("-Removes negative conditions within {range}",{
                            "range": TooltipHelper.getPlural(activate.@range, "sqr")}).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                    case ActivationType.REMOVE_NEG_COND_SELF:
                        this.AEs.push(new Effect("-Removes negative conditions", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                    case ActivationType.GENERIC_ACTIVATE:
                        if (activate.hasOwnProperty("@ignoreOnTooltip")) break;
                        var GA_prefix:String = "-On Party: ";
                        if (activate.@target == "enemy")
                            GA_prefix = "-On Enemies: ";
                        this.AEs.push(new Effect(GA_prefix + "{effect} for {duration} within {range}",
                                {
                                    "range": TooltipHelper.getPlural(activate.@range, "sqr"),
                                    "effect": activate.@effect,
                                    "duration": TooltipHelper.getPlural(activate.@duration, "sec")
                                }));
                        break;
                    case ActivationType.INCREMENT_STAT:
                        s = String(activate.@stat);
                        switch (s) {
                            case "MaximumHP": s = "Maximum HP"; break;
                            case "MaximumMP": s = "Maximum MP"; break;
                            case "ShieldPoints": s = "Shield Points"; break;
                            case "CriticalStrike": s = "Critical Strike"; break;
                            case "LifeSteal": s = "Health on Hit"; break;
                            case "LifeStealKill": s = "Health on Kill"; break;
                            case "ManaLeech": s = "Mana on Hit"; break;
                            case "ManaLeechKill": s = "Mana on Kill"; break;
                        }
                        if (String(activate.@stat) == "")
                            s = new LineBuilder().setParams(StatData.statToName(int(activate.@statId)));
                        this.AEs.push(new Effect("-Permanently increases {stat} by {amount}", {
                                    "stat":s,
                                    "amount":activate.@amount
                                }));
                        break;
                    case ActivationType.TOME:
                        this.getTome(activate, thisActivate);
                        break;
                    case ActivationType.MISC_BOOSTS:
                        var mBoosts_id:String = activate.@id;
                        var mBoosts_duration:int = activate.@duration;
                        var mBoosts_prefix:String;
                        switch (mBoosts_id) {
                            case "XP":
                                mBoosts_prefix = "-Boosts all XP gained by 1.3x";
                                break;
                            case "Drop":
                                mBoosts_prefix = "-Boosts loot drop chance by 1.5x";
                                break;
                            case "Tier":
                                mBoosts_prefix = "-Boosts loot tier";
                                break;
                        }
                        this.AEs.push(new Effect(mBoosts_prefix + " for {duration}", {"duration":(mBoosts_duration / 60) + " minutes"}).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                    case ActivationType.BACKPACK:
                        this.AEs.push(new Effect("-Gain a backpack, doubling inventory space", {}).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                    case ActivationType.FAME:
                        this.AEs.push(new Effect("{amount} Fame", {
                            "amount": prefix(activate.@amount)
                        }).setColor(TooltipHelper.NO_DIFF_COLOR));
                        break;
                }
            }
        }
    }

    private function addActivateOnEquipTagsToEffectsList():void {
        var onEquip:XML;
        var stats:Vector.<String> = new Vector.<String>();
        var s:Object;
        for each (onEquip in this.objectXML.ActivateOnEquip) {
            if (!this.pushedOnEquip) {
                this.lastEffects.push(new Effect("On Equip:", ""));
                this.pushedOnEquip = true;
            }
            if (onEquip.toString() == "IncrementStat") {
                s = String(onEquip.@stat);
                switch (s) {
                    case "MaximumHP": s = "Maximum HP"; break;
                    case "MaximumMP": s = "Maximum MP"; break;
                    case "ShieldPoints": s = "Shield Points"; break;
                    case "CriticalStrike": s = "Critical Strike"; break;
                    case "LifeSteal": s = "Health on Hit"; break;
                    case "LifeStealKill": s = "Health on Kill"; break;
                    case "ManaLeech": s = "Mana on Hit"; break;
                    case "ManaLeechKill": s = "Mana on Kill"; break;
                }
                if (s == "")
                    s = int(onEquip.@statId);
                var color:uint = this.getComparedStatColor(onEquip, this.itemData_);
                var percentStat:Boolean = false;
                if (s == StatData.CRITICAL_STRIKE || s == StatData.TENACITY || s == "Critical Strike" || s == "Tenacity")
                    percentStat = true;
                var incrementStat:Effect = new Effect(
                        "   {statAmount}{statName}", getComparedStatText(onEquip, this.itemData_, percentStat)).setReplacementsColor(color);
                this.lastEffects.push(incrementStat);
                if (s is int) {
                    stats.push(StatData.statToName(int(s)));
                }
                else {
                    stats.push(s);
                }
            }
        }
        for each (var boosts:Object in this.itemData_.StatBoosts) {
            if (int(boosts.Value) == 0) {
                continue;
            }
            if (!this.pushedOnEquip) {
                this.lastEffects.push(new Effect("On Equip:", ""));
                this.pushedOnEquip = true;
            }
            s = StatData.statToName(int(boosts.Key));
            var contains:Boolean = false;
            for each (var stat:String in stats) {
                if (stat == s) {
                    contains = true;
                    break;
                }
            }
            if (!contains) {
                color = TooltipHelper.getRuneColor(int(boosts.Value));
                var increment:Effect = new Effect("   {statAmount}{statName}",
                        getItemDataStatBoosts(boosts, s == StatData.CRITICAL_STRIKE || s == StatData.TENACITY || s == "Critical Strike" || s == "Tenacity"))
                        .setReplacementsColor(color);
                this.lastEffects.push(increment);
            }
        }
    }
    private function addActivateOnEquipPercTagsToEffectsList():void
    {
        var onEquip:XML;
        var s:Object;
        for each (onEquip in this.objectXML.ActivateOnEquipPerc)
        {
            if (!this.pushedOnEquip)
            {
                this.lastEffects.push(new Effect("On Equip:", ""));
                this.pushedOnEquip = true;
            }
            if (onEquip.toString() == "IncrementStat")
            {
                s = String(onEquip.@stat);
                switch (s)
                {
                    case "MaximumHP":s = "Maximum HP";break;
                    case "MaximumMP":s = "Maximum MP";break;
                    case "ShieldPoints":s = "Shield Points";break;
                    case "CriticalStrike":s = "Critical Strike";break;
                    case "LifeSteal":s = "Health on Hit";break;
                    case "LifeStealKill":s = "Health on Kill";break;
                    case "ManaLeech":s = "Mana on Hit";break;
                    case "ManaLeechKill":s = "Mana on Kill";break;
                }
                if (s == "")
                    s = int(onEquip.@statId);
                var color:uint = this.getComparedStatColor(onEquip, this.itemData_);
                var incrementStat:Effect = new Effect(
                        "   {statAmount}{statName}", getComparedStatText(onEquip, this.itemData_, true)).setReplacementsColor(color);
                this.lastEffects.push(incrementStat);
            }
        }
    }

    private function addRuneBoostsTagsToEffectsList():void {
        var onEquip:XML;
        var pushed:Boolean = false;
        var runeBoosts:Object = this.objectXML.RuneBoosts;
        if (!this.objectXML.hasOwnProperty("RuneBoosts")) return;

        var effects:Vector.<Effect> = new Vector.<Effect>();
        effects.push(new Effect("Rune Boosts:", ""));
        if (int(runeBoosts.PhysicalDmg) != 0) {
            effects.push(new Effect("    " + prefix(int(runeBoosts.PhysicalDmg)) + " Physical Damage on projectiles", "")
                    .setColor(TooltipHelper.getTextColor2(int(runeBoosts.PhysicalDmg))));
        }
        if (int(runeBoosts.MagicalDmg) != 0) {
            effects.push(new Effect("    " + prefix(int(runeBoosts.MagicalDmg)) + " Magical Damage on projectiles", "")
                    .setColor(TooltipHelper.getTextColor2(int(runeBoosts.MagicalDmg))));
        }
        if (int(runeBoosts.EarthDmg) != 0) {
            effects.push(new Effect("    " + prefix(int(runeBoosts.EarthDmg)) + " Earth Damage on projectiles", "")
                    .setColor(TooltipHelper.getTextColor2(int(runeBoosts.EarthDmg))));
        }
        if (int(runeBoosts.AirDmg) != 0) {
            effects.push(new Effect("    " + prefix(int(runeBoosts.AirDmg)) + " Air Damage on projectiles", "")
                    .setColor(TooltipHelper.getTextColor2(int(runeBoosts.AirDmg))));
        }
        if (int(runeBoosts.ProfaneDmg) != 0) {
            effects.push(new Effect("    " + prefix(int(runeBoosts.ProfaneDmg)) + " Profane Damage on projectiles", "")
                    .setColor(TooltipHelper.getTextColor2(int(runeBoosts.ProfaneDmg))));
        }
        if (int(runeBoosts.FireDmg) != 0) {
            effects.push(new Effect("    " + prefix(int(runeBoosts.FireDmg)) + " Fire Damage on projectiles", "")
                    .setColor(TooltipHelper.getTextColor2(int(runeBoosts.FireDmg))));
        }
        if (int(runeBoosts.WaterDmg) != 0) {
            effects.push(new Effect("    " + prefix(int(runeBoosts.WaterDmg)) + " Water Damage on projectiles", "")
                    .setColor(TooltipHelper.getTextColor2(int(runeBoosts.WaterDmg))));
        }
        if (int(runeBoosts.HolyDmg) != 0) {
            effects.push(new Effect("    " + prefix(int(runeBoosts.HolyDmg)) + " Holy Damage on projectiles", "")
                    .setColor(TooltipHelper.getTextColor2(int(runeBoosts.HolyDmg))));
        }

        for each (onEquip in runeBoosts.StatOnEquip) {
            if (!pushed) {
                effects.push(new Effect("    On Equip:", ""));
                pushed = true;
            }
            var s:Object = String(onEquip.@stat);
            switch (s) {
                case "MaximumHP":s = "Maximum HP";break;
                case "MaximumMP":s = "Maximum MP";break;
                case "ShieldPoints":s = "Shield Points";break;
                case "CriticalStrike":s = "Critical Strike";break;
                case "LifeSteal":s = "Health on Hit";break;
                case "LifeStealKill":s = "Health on Kill";break;
                case "ManaLeech":s = "Mana on Hit";break;
                case "ManaLeechKill":s = "Mana on Kill";break;
            }
            if (s == "") {
                s = int(onEquip.@statId);
            }
            var color:uint = TooltipHelper.getRuneColor(int(onEquip.@amount));
            var percentStat:Boolean = false;
            if (s == StatData.CRITICAL_STRIKE || s == StatData.TENACITY || s == "Critical Strike" || s == "Tenacity")
                percentStat = true;
            var incrementStat:Effect = new Effect("        {statAmount}{statName}", getComparedStatText(onEquip, this.itemData_, percentStat)).setReplacementsColor(color);
            effects.push(incrementStat);
        }

        var i:int = 0;
        while (i < effects.length) {
            this.lastEffects.push(effects[i]);
            i++;
        }
    }

    private static function getItemDataStatBoosts(boost:Object, percentStat:Boolean):Object
    {
        var s:Object = StatData.statToName(int(boost.Key));
        var amount:int = int(boost.Value);
        return ({
            "statAmount":(prefix(amount) + (percentStat ? "%" : "") + " "),
            "statName":s
        });
    }

    private static function statNameToId(stat:String):int
    {
        switch (stat)
        {
            case "MaximumHP": return 0;
            case "MaximumMP": return 3;
            case "Strength": return 20;
            case "Armor": return 21;
            case "Agility": return 22;
            case "Dexterity": return 28;
            case "Stamina": return 26;
            case "Intelligence": return 27;
            case "Luck": return 102;
            case "Haste": return 108;
            case "ShieldPoints": return 110;
            case "Tenacity": return 117;
            case "CriticalStrike": return 119;
            case "LifeSteal": return 121;
            case "LifeStealKill": return 125;
            case "ManaLeech": return 123;
            case "ManaLeechKill": return 127;
            case "Resistance": return 156;
            case "Wit": return 82;
            case "Lethality": return 84;
            case "Piercing": return 86;
            default: return 0;
        }
    }

    private static function getComparedStatText(item:XML, itemData:ItemData, percentStat:Boolean):Object
    {
        var s:String = String(item.@stat);
        switch (s){
            case "MaximumHP": s = "Maximum HP"; break;
            case "MaximumMP": s = "Maximum MP"; break;
            case "ShieldPoints": s = "Shield Points"; break;
            case "CriticalStrike": s = "Critical Strike"; break;
            case "LifeSteal": s = "Health on Hit"; break;
            case "LifeStealKill": s = "Health on Kill"; break;
            case "ManaLeech": s = "Mana on Hit"; break;
            case "ManaLeechKill": s = "Mana on Kill"; break;
        }
        if (s == "")
            s = String(StatData.statToName(int(item.@statId)));
        var additional:int;
        for each (var boosts:Object in itemData.StatBoosts) {
            var k:String = StatData.statToName(int(boosts.Key));
            if (k == s) {
                additional = int(boosts.Value);
            }
        }
        var amount:int = int(item.@amount);
        if (!isNaN(itemData.Quality) && itemData.Quality.toFixed(2) != "0.00") {
            if (amount < 0)
                amount = int(Math.floor(amount / itemData.Quality));
            else
                amount = int(Math.floor(amount * itemData.Quality));
        }
        amount += additional;
        return ({
            "statAmount":(prefix(amount) + (percentStat ? "%" : "") + " "),
            "statName":s
        });
    }

    public static function prefix(value:int):String
    {
        var prefix:String = ((value > -1) ? "+" : "");
        return (prefix + value);
    }

    private function getComparedStatColor(activateXML:XML, itemData:ItemData):uint {
        var match:XML;
        var curAmount:int;
        var s:Object = activateXML.@stat;
        if (activateXML.hasOwnProperty("@stat"))
            s = statNameToId(String(s));
        else
            s = int(activateXML.@statId);
        var amount:int = int(activateXML.@amount);
        var obj:Object;
        if (!isNaN(itemData.Quality) && itemData.Quality.toFixed(2) != "0.00") {
            if (amount < 0)
                amount = int(Math.floor(amount / itemData.Quality));
            else
                amount = int(Math.floor(amount * itemData.Quality));
        }
        for each (obj in itemData.StatBoosts) {
            if (obj.Key == s) {
                amount += obj.Value;
                break;
            }
        }
        var textColor:uint = ((this.playerCanUse) ? TooltipHelper.BETTER_COLOR : TooltipHelper.NO_DIFF_COLOR);
        var curActivateXML:XMLList;
        if (this.curItemXML != null) {
            curActivateXML = this.curItemXML.ActivateOnEquip;
            if (curActivateXML.hasOwnProperty("@stat"))
            {
                for each (var xml:XML in curActivateXML)
                    if (statNameToId(xml.@stat) == s)
                    {
                        match = xml;
                        break;
                    }
            }
            else
                for each (var sId:XML in curActivateXML)
                    if (int(sId.statId) == s)
                    {
                        match = sId;
                        break;
                    }
        }
        if (match != null) {
            curAmount = int(match.@amount);
            if (!isNaN(this.curItemData_.Quality) && this.curItemData_.Quality.toFixed(2) != "0.00") {
                if (curAmount < 0)
                    curAmount = int(Math.floor(curAmount / this.curItemData_.Quality));
                else
                    curAmount = int(Math.floor(curAmount * this.curItemData_.Quality));
            }
            for each (obj in this.curItemData_.StatBoosts) {
                if (obj.Key == s) {
                    curAmount += obj.Value;
                    break;
                }
            }
            textColor = TooltipHelper.getTextColor((amount - curAmount));
        }
        if (amount < 0)
            textColor = 0xFF0000;
        return (textColor);
    }

    private function addEquipmentItemRestrictions():void {
        if (!this.objectXML.hasOwnProperty("Treasure")) {
            this.restrictions.push(new Restriction("Must be equipped to use", 0xB3B3B3, false));
            if (((this.isInventoryFull) || ((this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)))) {
                this.restrictions.push(new Restriction("Double-Click to equip", 0xB3B3B3, false));
            }
            else {
                this.restrictions.push(new Restriction("Double-Click to take", 0xB3B3B3, false));
            }
        }
    }

    private function addAbilityItemRestrictions():void {
        this.restrictions.push(new Restriction("Press [{keyCode}] in world to use", 0xFFFFFF, false));
        if (this.objectXML.hasOwnProperty("Activate2"))
            this.restrictions.push(new Restriction("Press [{secondAbilityKeyCode}] to use secondary ability", 0xFFFFFF, false));
    }

    private function addConsumableItemRestrictions():void {
        this.restrictions.push(new Restriction("Consumed with use", 0xB3B3B3, false));
        if (this.player == null) return;
        if (((this.isInventoryFull) || ((this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)))) {
            this.restrictions.push(new Restriction("Double-Click or Shift-Click on item to use", 0xFFFFFF, false));
        }
        else {
            this.restrictions.push(new Restriction("Double-Click to take & Shift-Click to use", 0xFFFFFF, false));
        }
    }

    private function addReusableItemRestrictions():void {
        this.restrictions.push(new Restriction("Can be used multiple times", 0xB3B3B3, false));
        this.restrictions.push(new Restriction("Double-Click or Shift-Click on item to use", 0xFFFFFF, false));
    }

    private function makeRestrictionList():void {
        this.restrictions = new Vector.<Restriction>();
        if (((((this.objectXML.hasOwnProperty("VaultItem")) && (!((this.invType == -1))))) && (!((this.invType == ObjectLibrary.idToType_["Vault Chest"]))))) {
            this.restrictions.push(new Restriction("Store this item in your Vault to avoid losing it!", 16549442, true));
        }
        // Add this text if inventory owner isn't NPC (so it doesn't show up on rune ui)
        if (this.objectXML.hasOwnProperty("Rune") && this.inventoryOwnerType != InventoryOwnerTypes.NPC) {
            this.restrictions.push(new Restriction("This item is a rune that can be inserted on your equipment for unique boosts", 16549442, true));
        }
        if (this.objectXML.hasOwnProperty("Soulbound") || this.itemData_ && this.itemData_.Soulbound) {
            this.restrictions.push(new Restriction("Soulbound", 0xB3B3B3, false));
        }
        if (this.objectXML.hasOwnProperty("Legendary")) {
            this.titleText.setColor(TooltipHelper.LEGENDARY_COLOR);
        }
        if (this.objectXML.hasOwnProperty("Mythic")) {
            this.titleText.setColor(TooltipHelper.MYTHIC_COLOR);
        }
        if (this.objectXML.hasOwnProperty("Unholy")) {
            this.titleText.setColor(TooltipHelper.UNHOLY_COLOR);
        }
        if (this.objectXML.hasOwnProperty("Divine")) {
            this.titleText.setColor(TooltipHelper.DIVINE_COLOR);
        }
        if (this.playerCanUse) {
            if (this.objectXML.hasOwnProperty("Usable")
                    && !this.objectXML.hasOwnProperty("Consumable")) {
                this.addAbilityItemRestrictions();
                this.addEquipmentItemRestrictions();
            }
            else {
                if (this.objectXML.hasOwnProperty("InvUse")) {
                    this.addReusableItemRestrictions();
                }
                else if (!this.objectXML.hasOwnProperty("Consumable")) {
                    this.addEquipmentItemRestrictions();
                }
            }
        }
        else {
            if (this.player != null) {
                this.restrictions.push(new Restriction("Not usable by {unUsableClass}", 16549442, true));
            }
        }
        if (this.objectXML.hasOwnProperty("Consumable")) {
            this.addConsumableItemRestrictions();
        }
        if (this.objectXML.hasOwnProperty("Treasure")) {
            this.restrictions.push(new Restriction("Treasure", 0xB3B3B3, false));
        }
        if (ObjectLibrary.usableBy(this.objectType) != null) {
            this.restrictions.push(new Restriction("Usable by: {usableClasses}", 0xB3B3B3, false));
        }
        var item:XML = ObjectLibrary.xmlLibrary_[this.objectType];
        if (int(item.SlotType) == ItemConstants.RING_TYPE) {
            this.restrictions.push(new Restriction("Usable by all classes", 0xB3B3B3, false));
        }
        var equipReq:XML;
        var meetsReq:Boolean;
        var reqStat:int;
        var reqValue:int;
        for each (equipReq in this.objectXML.EquipRequirement) {
            meetsReq = ObjectLibrary.playerMeetsRequirement(equipReq, this.player);
            if (equipReq.toString() == "Stat") {
                reqStat = int(equipReq.@stat);
                reqValue = int(equipReq.@value);
                this.restrictions.push(new Restriction(((("Requires " + StatData.statToName(reqStat)) + " of ") + reqValue), (0xB3B3B3), (!meetsReq)));
            }
        }
    }

    private function makeLineTwo():void {
        this.line2 = new LineBreakDesign((this.line1.width), objectXML.hasOwnProperty("Legendary") ? 0xAD7948 : objectXML.hasOwnProperty("Mythic") ? 0x963F3D :
                objectXML.hasOwnProperty("Unholy") ? 0xA84D8A : objectXML.hasOwnProperty("Divine") ? 0x568C7B : 0x7B7B7B);
        addChild(this.line2);
    }

    private function makeRestrictionText():void {
        if (this.restrictions.length != 0) {
            this.restrictionsText = new TextFieldDisplayConcrete().setSize(14).setColor(0xB3B3B3).setTextWidth((MAX_WIDTH - 8)).setIndent(-10).setLeftMargin(10).setWordWrap(true).setHTML(true);
            this.restrictionsText.setStringBuilder(this.buildRestrictionsLineBuilder());
            this.restrictionsText.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
            waiter.push(this.restrictionsText.textChanged);
            addChild(this.restrictionsText);
        }
    }

    private function buildRestrictionsLineBuilder():StringBuilder {
        var restriction:Restriction;
        var unusableClass:String;
        var alb:AppendingLineBuilder = new AppendingLineBuilder();
        for each (restriction in this.restrictions) {
            unusableClass = ((this.player) ? ObjectLibrary.typeToDisplayId_[this.player.objectType_] : "");
            alb.pushParams(restriction.text_, {
                "unUsableClass": unusableClass,
                "usableClasses": this.getUsableClasses(),
                "keyCode": KeyCodes.CharCodeStrings[Parameters.data_.useSpecial],
                "secondAbilityKeyCode": KeyCodes.CharCodeStrings[Parameters.data_.secondAbility]
            }, restriction.color_, restriction.bold_,
                    restriction.replacementColor_ != 1 ? restriction.replacementColor_ : 0xB3B3B3);
        }
        return (alb);
    }

    private function getUsableClasses():StringBuilder {
        var usableClass:String;
        var usableBy:Vector.<String> = ObjectLibrary.usableBy(this.objectType);
        var alb:AppendingLineBuilder = new AppendingLineBuilder();
        alb.setDelimiter(", ");
        for each (usableClass in usableBy) {
            alb.pushParams(usableClass);
        }
        return (alb);
    }

    private var _hasDescription:Boolean = true;
    private function addDescriptionText():void
    {
        var hasTier:Boolean = this.objectXML.hasOwnProperty("Tier");
        var isConsumable:Boolean = this.objectXML.hasOwnProperty("Consumable");
        var noDescription:Boolean = this.objectXML.hasOwnProperty("NoDescription");
        this.descText = new TextFieldDisplayConcrete().setSize(14).setColor(0xB3B3B3).setTextWidth(MAX_WIDTH - 8).setWordWrap(true);
        if (this.descriptionOverride)
        {
            this.descText.setStringBuilder(new StaticStringBuilder(this.descriptionOverride));
        }
        else if ((hasTier && !isConsumable) || noDescription)
        {
            this.descText.setStringBuilder(new LineBuilder().setParams(""));
            _hasDescription = false;
        }
        else
        {
            this.descText.setStringBuilder(new LineBuilder().setParams(String(this.objectXML.Description)));
        }
        this.descText.filters = Parameters.data_.outlineTooltips ? FilterUtil.getTextOutlineFilter() : FilterUtil.getWeakOutlineFilter();
        waiter.push(this.descText.textChanged);
        addChild(this.descText);
    }

    override protected function alignUI():void {
        this.titleText.x = this.icon.width - 8;
        this.titleText.y = (((this.icon.height - this.titleText.height) / 4) - 3);
        this.specialityText.x = this.titleText.x;
        this.specialityText.y = this.titleText.y + this.titleText.height - 2;
        this.bagIcon.x = (MAX_WIDTH - this.bagIcon.width) + 4;
        this.bagIcon.y = ((this.icon.height - this.bagIcon.height) / 2) - 2;
        this.line1.x = -5;
        this.descText.x = 4;
        this.descText.y = this.icon.height - 6;
        if (contains(this.line1)) {
            if (!_hasDescription)
                this.line1.y = (this.descText.y + this.descText.height);
            else
                this.line1.y = ((this.descText.y + this.descText.height) + 8);
            this.firstEffectsText.x = 4;
            this.firstEffectsText.y = (this.line1.y + 8);
        } else {
            this.line1.y = (this.descText.y + this.descText.height);
            this.firstEffectsText.y = this.line1.y;
        }
        this.AEsText.x = 4;
        this.AEsText.y = (this.line1.y + 8);
        this.lastEffectsText.x = 4;
        this.lastEffectsText.y = (this.line1.y + 8);
        this.line2.x = -5;
        if (!_hasDescription)
            this.line2.y = (this.descText.y + this.descText.height);
        else
            this.line2.y = ((this.descText.y + this.descText.height) + 8);
        if (contains(this.firstEffectsText)){
            this.AEsText.y = (this.firstEffectsText.y + this.firstEffectsText.height) - 4;
            this.lastEffectsText.y = (this.firstEffectsText.y + this.firstEffectsText.height) - 4;
            this.line2.y = ((this.firstEffectsText.y + this.firstEffectsText.height) + 8);
        }
        if (contains(this.AEsText)) {
            this.lastEffectsText.y = (this.AEsText.y + this.AEsText.height) - 4;
            this.line2.y = ((this.AEsText.y + this.AEsText.height) + 8);
        }
        if (contains(this.lastEffectsText)){
            this.line2.y = ((this.lastEffectsText.y + this.lastEffectsText.height) + 8);
        }
        var yOffset:uint = (this.line2.y + 8);
        if (this.restrictionsText) {
            this.restrictionsText.x = 4;
            this.restrictionsText.y = yOffset;
            yOffset = (yOffset + this.restrictionsText.height);
        }
        if (this.qualityText_) {
            this.qualityText_.x = 4;
            this.qualityText_.y = yOffset - 2;
            this.qualityStars_.x = this.qualityText_.width + 8;
            this.qualityStars_.y = yOffset;
            yOffset = (yOffset + this.qualityText_.height);
        }
        if (this.runesText_) {
            this.runesText_.x = 4;
            this.runesText_.y = yOffset;
            this.runeSprites_.x = this.runesText_.width + 16;
            this.runeSprites_.y = yOffset + 10;
            yOffset = yOffset + (this.runeSprites_.height < 40 ? 23 : 46);
        }
        if (this.levelReqText) {
            this.levelReqText.x = 4;
            this.levelReqText.y = yOffset;
        }
    }

    private function handleWisMod():void {
        var activate:XML;
        var xml:XML;
        var activateType:String;
        var useWisMod:String;
        if (this.player == null) {
            return;
        }
        var intelligence:Number = (this.player.intelligence_ + this.player.intelligenceBoost_);
        if (intelligence < 30) {
            return;
        }
        var xmls:Vector.<XML> = new Vector.<XML>();
        if (this.curItemXML != null) {
            this.curItemXML = this.curItemXML.copy();
            xmls.push(this.curItemXML);
        }
        if (this.objectXML != null) {
            this.objectXML = this.objectXML.copy();
            xmls.push(this.objectXML);
        }
        for each (xml in xmls) {
            for each (activate in xml.Activate) {
                activateType = activate.toString();
                if (activate.@effect != "Stasis") {
                    useWisMod = activate.@useWisMod;
                    if (useWisMod != "" && useWisMod != "false" && useWisMod != "0" && activate.@effect != "Stasis") {
                        switch (activateType) {
                            case ActivationType.HEAL_NOVA:
                                activate.@amount = this.modifyWisModStat(activate.@amount, 0);
                                activate.@range = this.modifyWisModStat(activate.@range);
                                break;
                            case ActivationType.COND_EFFECT_AURA:
                                activate.@duration = this.modifyWisModStat(activate.@duration);
                                activate.@range = this.modifyWisModStat(activate.@range);
                                break;
                            case ActivationType.COND_EFFECT_SELF:
                                activate.@duration = this.modifyWisModStat(activate.@duration);
                                break;
                            case ActivationType.STAT_BOOST_AURA:
                                activate.@amount = this.modifyWisModStat(activate.@amount, 0);
                                activate.@duration = this.modifyWisModStat(activate.@duration);
                                activate.@range = this.modifyWisModStat(activate.@range);
                                break;
                            case ActivationType.GENERIC_ACTIVATE:
                                activate.@duration = this.modifyWisModStat(activate.@duration);
                                activate.@range = this.modifyWisModStat(activate.@range);
                                break;
                        }
                    }
                }
            }
        }
    }

    private function modifyWisModStat(tagAmount:String, digits:Number = 1):String {
        var amount:Number;
        var negativeMult:int;
        var value:Number;
        var fAmount:String;
        var intelligence:Number = (this.player.intelligence_ + this.player.intelligenceBoost_);
        if (intelligence < 30) {
            fAmount = tagAmount;
        }
        else {
            amount = Number(tagAmount);
            negativeMult = (((amount) < 0) ? -1 : 1);
            value = (((amount * intelligence) / 150) + (amount * negativeMult));
            value = (Math.floor((value * Math.pow(10, digits))) / Math.pow(10, digits));
            if ((value - (int(value) * negativeMult)) >= ((1 / Math.pow(10, digits)) * negativeMult)) {
                fAmount = value.toFixed(1);
            }
            else {
                fAmount = value.toFixed(0);
            }
        }
        return (fAmount);
    }

    private function getTome(activate:XML, thisActivate:XML=null):void
    {
        var wis:int = ((this.player != null) ? this.player.intelligence_ : 10);
        var wisRes:Number = Math.max(0, (wis - 50));

        var wismodMult:Number = this.GetFloatArgument(activate, "wismodMult", 1.0);

        var modAmount:int = MathUtil.round(30 * int(wisRes / 10) * wismodMult, 0);
        var modRange:Number = MathUtil.round(0.1 * wisRes * wismodMult,1);

        var range:ComPair = new ComPair(activate, thisActivate, "range");
        var amount:ComPair = new ComPair(activate, thisActivate, "amount");
        range.add(modRange);
        amount.add(modAmount);

        var effectiveLoss:ComPair = new ComPair(activate, thisActivate, "effectiveLoss", 0.025);

        var tomeText:String = colorByTier("-Tome: ", this.objectXML);
        tomeText += "{amount} within {range}";
        if (effectiveLoss.a)
        {
            tomeText += ", losing {effectiveLoss} ({amountMin}) per ally healed";
        }

        this.AEs.push(new Effect(tomeText, {
            "amount":
                    wrapColor(amount.a + colorWisBonus(modAmount) + " HP",
                            TooltipHelper.getTextColor(amount.a - amount.b)),
            "range":
                    wrapColor(range.a + colorWisBonus(modRange) + " sqrs",
                            TooltipHelper.getTextColor(range.a - range.b)),
            "effectiveLoss":
                    wrapColor((effectiveLoss.a * 100) + "% effectiveness",
                            TooltipHelper.getTextColor(effectiveLoss.a - effectiveLoss.b)),
            "amountMin":
                    wrapColor(int(amount.a * 0.3) + " minimum",
                            TooltipHelper.getTextColor(amount.a - amount.b))
        }));
    }

    private function getScepter(activate:XML, thisActivate:XML=null):void
    {
        var wis:int = ((this.player != null) ? this.player.intelligence_ : 10);
        var wisRes:Number = Math.max(0, (wis - 50));

        var wismodMult:Number = this.GetFloatArgument(activate, "wismodMult", 1.0);
        var condDuration:Number = this.GetFloatArgument(activate, "condDuration");

        var decreaseDmg:ComPair = new ComPair(activate, thisActivate, "decreaseDmg");
        // dmg comparison wismod shit
        var wisDmgBase:ComPair = new ComPair(activate, thisActivate, "wisDmgBase");
        var modTotalDmg:int = MathUtil.round(wisDmgBase.a * wisRes * wismodMult, 0);
        var thisModTotalDmg:int = MathUtil.round(wisDmgBase.b * wisRes * wismodMult, 0);
        // target comparison wismod shit
        var wisPerTarget:ComPair = new ComPair(activate, thisActivate, "wisPerTarget", 10);
        var modMaxTargets:Number = MathUtil.round(1 * int(wisRes / wisPerTarget.a) * wismodMult,0);
        var thisModMaxTargets:Number = MathUtil.round(1 * int(wisRes / wisPerTarget.b) * wismodMult,0);

        var totalDmg:ComPair = new ComPair(activate, thisActivate, "totalDamage");
        totalDmg.add(modTotalDmg, thisModTotalDmg);
        var maxTargets:ComPair = new ComPair(activate, thisActivate, "maxTargets");
        maxTargets.add(modMaxTargets, thisModMaxTargets);

        var scepterText:String = colorByTier("-Lightning: ", this.objectXML);
        scepterText += "{totalDamage} to {targets}";
        if (decreaseDmg.a)
        {
            scepterText += ", reduced by {decreaseDmg} for each subsequent target";
        }

        this.AEs.push(new Effect(scepterText, {
            "targets":
                    wrapColor(maxTargets.a + colorWisBonus(modMaxTargets) + " targets",
                            TooltipHelper.getTextColor(maxTargets.a - maxTargets.b)),
            "totalDamage":
                    wrapColor(totalDmg.a + colorWisBonus(modTotalDmg) + " damage",
                            TooltipHelper.getTextColor(totalDmg.a - totalDmg.b)),
            "decreaseDmg":
                    wrapColor(decreaseDmg.a, TooltipHelper.getTextColor(decreaseDmg.b - decreaseDmg.a))
        }));
        this.AddConditionToEffects(activate, thisActivate, "Nothing", condDuration);
    }

    private function getTotem(activate:XML, thisActivate:XML=null):void
    {
        var boostAmounts:Vector.<int> = ConversionUtil.toIntVector(activate.@boostAmounts);
        var boostStats:Array = ConversionUtil.toStringArray(activate.@boostStats);

        var tfSkin:String = this.GetStringArgument(activate, "transformSkin", "");

        var duration:ComPair = new ComPair(activate, thisActivate, "duration");

        var totemText:String = colorByTier("-Totem: ", this.objectXML);

        totemText += "Transforms you into a {transformationSkin}" +
                " for {duration}" + ", increasing ";


        var i:int = 0;
        while (i < boostAmounts.length)
        {
            switch (boostStats[i])
            {
                case "MaximumHP": boostStats[i] = "Maximum HP"; break;
                case "MaximumMP": boostStats[i] = "Maximum MP"; break;
                case "ShieldPoints": boostStats[i] = "Shield Points"; break;
                case "CriticalStrike": boostStats[i] = "Critical Strike"; break;
                default: break;
            }

            var boostAmt:String = wrapColor(boostAmounts[i].toString(), TooltipHelper.NO_DIFF_COLOR);
            var boostStat:String = wrapColor(boostStats[i], TooltipHelper.NO_DIFF_COLOR);
            totemText += boostAmt + " " + boostStat + (i == boostAmounts.length - 1 ? "" : ", ");
            i++;
        }

        this.AEs.push(new Effect(totemText,
            {
            "transformationSkin":tfSkin,
            "duration": wrapColor(TooltipHelper.getPlural(duration.a, "sec"),
                    TooltipHelper.getTextColor(duration.a - duration.b))
        }));
    }

    private function getCard(activate:XML, thisActivate:XML=null):void
    {
        var chances:Vector.<int> = ConversionUtil.toIntVector(activate.@chances);
        var condEffs:Array = ConversionUtil.toStringArray(activate.@condEffs);

        var maxRoll:int = this.GetIntArgument(activate, "maxRoll", 52);

        var duration:ComPair = new ComPair(activate, thisActivate, "duration");

        var cardText:String = colorByTier("-Card: ", this.objectXML);
        cardText += "picks a random number from {maxRoll}, with ";

        var i:int = 0;
        while (i < chances.length)
        {
            switch (condEffs[i])
            {
                case "NinjaSpeedy": condEffs[i] = "Ninja Speedy"; break;
                case "PetDisable": condEffs[i] = "Pet Disable"; break;
                case "HPBoost": condEffs[i] = "HP Boost"; break;
                case "MPBoost": condEffs[i] = "MP Boost"; break;
                case "StrBoost": condEffs[i] = "Strength Boost"; break;
                case "ArmBoost": condEffs[i] = "Armor Boost"; break;
                case "AglBoost": condEffs[i] = "Agility Boost"; break;
                case "DexBoost": condEffs[i] = "Dexterity Boost"; break;
                case "StaBoost": condEffs[i] = "Stamina Boost"; break;
                case "IntBoost": condEffs[i] = "Intelligence Boost"; break;
                case "ShieldBoost": condEffs[i] = "Shield Boost"; break;
                case "ResBoost": condEffs[i] = "Resistance Boost"; break;
                default: break;
            }
            var noDiffColor:uint = TooltipHelper.NO_DIFF_COLOR;
            var chance:String = wrapColor(chances[i], noDiffColor);
            var chanceLast:String = wrapColor((chances[i - 1 < 0 ? 0 : i - 1] + 1).toString() + "-" + chance, noDiffColor);
            var chanceFirst:String = wrapColor("0-" + chances[i].toString(), noDiffColor);
            var condEff:String = wrapColor(condEffs[i].toString(), noDiffColor);
            cardText += (i == chances.length - 1 ? "and " : "") +
                    (i == 0 ? chanceFirst : chanceLast) +
                    " granting " + condEff + (i >= chances.length - 2 ? " " : ", ");
            i++;
        }

        cardText += "for {duration}";

        this.AEs.push(new Effect(cardText,
                {
                    "maxRoll": "0-" + maxRoll,
                    "duration": wrapColor(TooltipHelper.getPlural(duration.a, "sec"),
                            TooltipHelper.getTextColor(duration.a - duration.b))
                }));
    }

    private function getSkull(activate:XML, thisActivate:XML = null): void
    {
        var wis:int = ((this.player != null) ? this.player.intelligence_ : 10);
        var wisRes:int = Math.max(0, (wis - 50));

        var maxAmount:ComPair = new ComPair(activate, thisActivate, "maxAmount", 5);
        var objType:String = this.GetStringArgument(activate, "objType", "");
        var wismodMult:Number = this.GetFloatArgument(activate, "wismodMult", 1.0);

        var modDuration:Number = MathUtil.round(int(wisRes / 5) * wismodMult, 1);
        var duration:ComPair = new ComPair(activate, thisActivate, "duration");
        duration.add(modDuration);

        var skullText:String = colorByTier("-Summons: ", this.objectXML);
        skullText = (skullText + "{objType} to aid you in combat.");
        if (duration.a)
        {
            skullText += " Lasts for {duration},";
        }

        if (maxAmount.a)
        {
            skullText += " with a maximum of {maxAmount}";
        }

        this.AEs.push(new Effect(skullText, {
            "objType": objType,
            "duration":
                    wrapColor(TooltipHelper.getPlural(duration.a, "sec") + colorWisBonus(modDuration),
                            TooltipHelper.getTextColor(duration.a - duration.b)),
            "maxAmount":
                    wrapColor(TooltipHelper.getPlural(maxAmount.a, objType),
                            TooltipHelper.getTextColor(maxAmount.a - maxAmount.b))
        }));
    }

    private function getSpell(activate:XML, thisActivate:XML = null): void
    {
        var numShots:ComPair = new ComPair(activate, thisActivate, "numShots", 20);

        var spellText:String = colorByTier("-Spell: ", this.objectXML);
        spellText += "{numShots} Shots";
        this.AEs.push(new Effect(spellText, {
            "numShots": wrapColor(numShots.a, TooltipHelper.getTextColor(numShots.a - numShots.b))
        }));
    }

    private function getOrb(activate:XML, thisActivate:XML = null): void
    {
        var shoots:String = this.GetStringArgument(activate, "shoots", "true");

        var manaDrain:ComPair = new ComPair(activate, thisActivate, "manaDrain", 10);
        var lightGain:ComPair = new ComPair(activate, thisActivate, "lightGain", 5);

        var orbText:String = colorByTier("-Orb: ", this.objectXML);
        orbText += "hold to drain {manaDrain} and gain {lightGain}";
        if (shoots == "true")
            orbText += ", press to shoot";

        this.AEs.push(new Effect(orbText, {
            "manaDrain":
                    wrapColor(manaDrain.a + " MP/sec", TooltipHelper.getTextColor(manaDrain.b - manaDrain.b)),
            "lightGain":
                    wrapColor(lightGain.a + " Light/sec", TooltipHelper.getTextColor(lightGain.a - lightGain.b))
        }));
    }

    private function getVial(activate:XML, thisActivate:XML = null): void
    {
        // comparison stuff is unused now...
        var wis:int = ((this.player != null) ? this.player.intelligence_ : 10);
        var wisRes:Number = Math.max(0, (wis - 50));
        var wismodMult:Number = this.GetFloatArgument(activate, "wismodMult", 1.0);

        var totalDmg:ComPair = new ComPair(activate, thisActivate, "totalDamage");
        var impactDmg:ComPair = new ComPair(activate, thisActivate, "impactDamage");
        var modTotalDmg:int = MathUtil.round((totalDmg.a / 10 * (wisRes / 3)) * wismodMult, 1);
        var modImpDmg:int = MathUtil.round((impactDmg.a / 10 * (wisRes / 3)) * wismodMult, 1);
        totalDmg.add(modTotalDmg);
        impactDmg.add(modImpDmg);

        var throwTime:ComPair = new ComPair(activate, thisActivate, "throwTime", 0.8);
        var duration:ComPair = new ComPair(activate, thisActivate, "duration");
        var radius:ComPair = new ComPair(activate, thisActivate, "radius");

        var vialText:String = colorByTier("-Vial: ", this.objectXML);
        vialText += "{totalDamage}" +
                (impactDmg.a ? " ({impactDamage}" + colorWisBonus(modImpDmg) + " immediately)" : "") + " within {radius} after {throwTime} over {duration}";

        this.AEs.push(new Effect(vialText, {
            "radius":
                    wrapColor(TooltipHelper.getPlural(radius.a, "sqr"),
                            TooltipHelper.getTextColor(radius.a - radius.b)),
            "duration":
                    wrapColor(TooltipHelper.getPlural(duration.a, "sec"),
                            TooltipHelper.getTextColor(duration.b - duration.a)),
            "impactDamage":
                    wrapColor(impactDmg.a, TooltipHelper.getTextColor(impactDmg.a - impactDmg.b)),
            "totalDamage":
                    wrapColor(totalDmg.a + colorWisBonus(modTotalDmg) + "damage",
                            TooltipHelper.getTextColor(totalDmg.a - totalDmg.b)),
            "throwTime":
                    wrapColor(TooltipHelper.getPlural(throwTime.a, "sec"),
                            TooltipHelper.getTextColor(throwTime.b - throwTime.a))
        }));
    }

    private function getPoisonTip(activate:XML, thisActivate:XML = null): void
    {
        var wis:int = ((this.player != null) ? this.player.intelligence_ : 10);
        var wisRes:Number = Math.max(0, (wis - 50));
        var wismodMult:Number = this.GetFloatArgument(activate, "wismodMult", 1.0);

        var totalDmg:ComPair = new ComPair(activate, thisActivate, "totalDamage");
        var modTotalDmg:int = MathUtil.round((totalDmg.a / 10 * (wisRes / 3)) * wismodMult, 1);
        totalDmg.add(modTotalDmg);

        var duration:ComPair = new ComPair(activate, thisActivate, "duration");

        var vialText:String = colorByTier("-Poison Tip: ", this.objectXML);
        vialText += "tips your next {count} to deal {totalDamage} over {duration}";

        this.AEs.push(new Effect(vialText, {
            "count": TooltipHelper.getPlural(1, "projectile"),
            "duration":
                    wrapColor(TooltipHelper.getPlural(duration.a, "sec"),
                            TooltipHelper.getTextColor(duration.b - duration.a)),
            "totalDamage":
                    wrapColor(totalDmg.a + colorWisBonus(modTotalDmg) + "damage",
                            TooltipHelper.getTextColor(totalDmg.a - totalDmg.b))
        }));
    }

    private function AddConditionToEffects(activate:XML, thisActivate:XML, effect:String = "Nothing", defaultDuration:Number = 5): void
    {
        var duration:ComPair;
        var thisCondition:String;
        var condition:String = ((activate.hasOwnProperty("@condEffect")) ? activate.@condEffect : effect);
        if (condition != "Nothing")
        {
            duration = new ComPair(activate, thisActivate, "condDuration", defaultDuration);
            if (thisActivate)
            {
                thisCondition = ((thisActivate.hasOwnProperty("@condEffect")) ? thisActivate.@condEffect : effect);
                if (thisCondition == "Nothing")
                {
                    duration.b = 0;
                }
            }
            this.AEs.push(new Effect("Inflicts {condition} for {duration}", {
                "condition": condition,
                "duration":
                        wrapColor(TooltipHelper.getPlural(duration.a, "sec"),
                                TooltipHelper.getTextColor(duration.a - duration.b))
            }));
        }
    }
    
    private function GetIntArgument(activate:XML, argument:String, def:int=0):int
    {
        return ((activate.hasOwnProperty(("@" + argument))) ? int(activate.@[argument]) : def);
    }

    private function GetFloatArgument(activate:XML, argument:String, def:Number=0):Number
    {
        return ((activate.hasOwnProperty(("@" + argument))) ? Number(activate.@[argument]) : def);
    }

    private function GetStringArgument(activate:XML, argument:String, def:String=""):String
    {
        return ((activate.hasOwnProperty(("@" + argument))) ? activate.@[argument] : def);
    }

    public static function colorWisBonus(value:Number):String
    {
        if (value)
        {
            return TooltipHelper.wrapInFontTag(" (" + (value > -1 ? "+" : "") + value + ")", "#" + TooltipHelper.WIS_BONUS_COLOR.toString(16));
        }
        return ("");
    }

    public static function colorCdReductionBonus(value:Number):String
    {
        if (value)
        {
            return TooltipHelper.wrapInFontTag(" (" + (value > -1 ? "-" : "") + value + ")", "#" + TooltipHelper.HASTE_STAT_COLOR.toString(16));
        }
        return ("");
    }

    public static function colorByTier(text:String, item:XML):String
    {
        var isTiered:Boolean = item.hasOwnProperty("Tier");
        var isLegendary:Boolean = item.hasOwnProperty("Legendary");
        var isMythic:Boolean = item.hasOwnProperty("Mythic");
        var isUnholy:Boolean = item.hasOwnProperty("Unholy");
        var isDivine:Boolean = item.hasOwnProperty("Divine");
        if (isDivine)
        {
            return wrapColor(text, TooltipHelper.DIVINE_COLOR);
        }
        if (isUnholy)
        {
            return wrapColor(text, TooltipHelper.UNHOLY_COLOR);
        }
        if (isMythic)
        {
            return wrapColor(text, TooltipHelper.MYTHIC_COLOR);
        }
        if (isLegendary)
        {
            return wrapColor(text, TooltipHelper.LEGENDARY_COLOR);
        }
        if (!isTiered)
        {
            return wrapColor(text, TooltipHelper.UNTIERED_COLOR);
        }
        return (text);
    }

}
}

class ComPair
{

    public var a:Number;
    public var b:Number;

    public function ComPair(itemA:XML, itemB:XML, argument:String, def:Number=0)
    {
        this.a = (this.b = ((itemA.hasOwnProperty(("@" + argument))) ? Number(itemA.@[argument]) : def));
        if (itemB)
        {
            this.b = ((itemB.hasOwnProperty(("@" + argument))) ? Number(itemB.@[argument]) : def);
        }
    }

    public function add(valueA:Number, valueB:Number = 0):void
    {
        this.a += valueA;
        this.b += valueB > 0 ? valueB : valueA;
    }


}

class ComPairTag
{

    public var a:Number;
    public var b:Number;

    public function ComPairTag(itemA:XML, itemB:XML, argument:String, def:Number=0)
    {
        this.a = (this.b = ((itemA.hasOwnProperty(argument)) ? itemA[argument] : def));
        if (itemB)
        {
            this.b = ((itemB.hasOwnProperty(argument)) ? itemB[argument] : def);
        }
    }

    public function add(value:Number):void
    {
        this.a = (this.a + value);
        this.b = (this.b + value);
    }


}

class ComPairTagBool
{

    public var a:Boolean;
    public var b:Boolean;

    public function ComPairTagBool(itemA:XML, itemB:XML, argument:String, def:Boolean=false)
    {
        this.a = (this.b = ((itemA.hasOwnProperty(argument)) ? true : def));
        if (itemB)
        {
            this.b = ((itemB.hasOwnProperty(argument)) ? true : def);
        }
    }

}

import kabam.rotmg.text.view.stringBuilder.AppendingLineBuilder;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;

class Effect {

    public var name_:String;
    public var valueReplacements_:Object;
    public var replacementColor_:uint = 16777103;
    public var color_:uint = 0xB3B3B3;

    public function Effect(name:String, valueReplacements:Object) {
        this.name_ = name;
        this.valueReplacements_ = valueReplacements;
    }

    public function setColor(color:uint):Effect {
        this.color_ = color;
        return (this);
    }

    public function setReplacementsColor(replacementColor:uint):Effect {
        this.replacementColor_ = replacementColor;
        return (this);
    }

    public function getValueReplacementsWithColor():Object {
        var value:String;
        var lineBuilder:LineBuilder;
        var key:Object = {};
        var replacementColorTag:String = "";
        var colorTag:String = "";
        if (this.replacementColor_) {
            replacementColorTag = (('</font><font color="#' + this.replacementColor_.toString(16)) + '">');
            colorTag = (('</font><font color="#' + this.color_.toString(16)) + '">');
        }
        for (value in this.valueReplacements_) {
            if ((this.valueReplacements_[value] is AppendingLineBuilder)) {
                key[value] = this.valueReplacements_[value];
            }
            else {
                if ((this.valueReplacements_[value] is LineBuilder)) {
                    lineBuilder = (this.valueReplacements_[value] as LineBuilder);
                    lineBuilder.setPrefix(replacementColorTag).setPostfix(colorTag);
                    key[value] = lineBuilder;
                }
                else {
                    key[value] = ((replacementColorTag + this.valueReplacements_[value]) + colorTag);
                }
            }
        }
        return (key);
    }


}

class Restriction {

    public var text_:String;
    public var color_:uint;
    public var bold_:Boolean;
    public var replacementColor_:uint;

    public function Restriction(text:String, color:uint, bold:Boolean, replColor:uint = 1) {
        this.text_ = text;
        this.color_ = color;
        this.bold_ = bold;
        this.replacementColor_ = replColor;
    }

}