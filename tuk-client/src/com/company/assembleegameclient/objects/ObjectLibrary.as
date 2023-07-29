package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.objects.animation.AnimationsData;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.ConversionUtil;

import flash.display.BitmapData;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;

import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.messaging.impl.data.StatData;

import thyrr.utils.ItemData;
import thyrr.utils.Utils;

public class ObjectLibrary {

    public static const IMAGE_SET_NAME:String = "interfaceSmall";
    public static const IMAGE_ID:int = 0x43;
    public static const propsLibrary_:Dictionary = new Dictionary();
    public static const xmlLibrary_:Dictionary = new Dictionary();
    public static const idToType_:Dictionary = new Dictionary();
    public static const typeToDisplayId_:Dictionary = new Dictionary();
    public static const typeToObjId_:Dictionary = new Dictionary();
    public static const typeToTextureData_:Dictionary = new Dictionary();
    public static const typeToTopTextureData_:Dictionary = new Dictionary();
    public static const typeToAnimationsData_:Dictionary = new Dictionary();
    public static const typeToIdItems_:Dictionary = new Dictionary();
    public static const idToTypeItems_:Dictionary = new Dictionary();
    public static const preloadedCustom_:Dictionary = new Dictionary();
    public static const petXMLDataLibrary_:Dictionary = new Dictionary();
    public static const skinSetXMLDataLibrary_:Dictionary = new Dictionary();
    private static var recipesDict_:Dictionary = new Dictionary();
    public static var forgeRecipes_:Array = [];
    public static const dungeonsXMLLibrary_:Dictionary = new Dictionary(true);
    public static const ENEMY_FILTER_LIST:Vector.<String> = new <String>["None", "Hp", "Armor"];
    public static const TILE_FILTER_LIST:Vector.<String> = new <String>["ALL", "Walkable", "Unwalkable", "Slow", "Speed=1"];
    public static const defaultProps_:ObjectProperties = new ObjectProperties(null);
    public static const TYPE_MAP:Object = {
        "CaveWall": CaveWall,
        "Character": Character,
        "CharacterChanger": CharacterChanger,
        "ClosedGiftChest": ClosedGiftChest,
        "ClosedVaultChest": ClosedVaultChest,
        "ConnectedWall": ConnectedWall,
        "Container": Container,
        "DoubleWall": DoubleWall,
        "GameObject": GameObject,
        "GuildBoard": GuildBoard,
        "GuildChronicle": GuildChronicle,
        "GuildHallPortal": GuildHallPortal,
        "GuildMerchant": GuildMerchant,
        "GuildRegister": GuildRegister,
        "Merchant": Merchant,
        "MoneyChanger": MoneyChanger,
        "NameChanger": NameChanger,
        "ReskinVendor": ReskinVendor,
        "OneWayContainer": OneWayContainer,
        "Player": Player,
        "Portal": Portal,
        "Projectile": Projectile,
        "Sign": Sign,
        "SpiderWeb": SpiderWeb,
        "Stalagmite": Stalagmite,
        "Wall": Wall,
        "MarketObject": MarketObject,
        "QuestObject": QuestObject,
        "Forge": Forge,
        "PetViewer": PetViewer,
        "PetMerchant": PetMerchant
    };

    public static var textureDataFactory:TextureDataFactory = new TextureDataFactory();
    public static var playerChars_:Vector.<XML> = new Vector.<XML>();
    public static var hexTransforms_:Vector.<XML> = new Vector.<XML>();
    public static var playerClassAbbr_:Dictionary = new Dictionary();
    private static var currentDungeon:String = "";


    public static function parseDungeonXML(_arg1:String, _arg2:XML):void {
        var _local3:int = (_arg1.indexOf("_") + 1);
        var _local4:int = _arg1.indexOf("CXML");
        currentDungeon = _arg1.substr(_local3, (_local4 - _local3));
        dungeonsXMLLibrary_[currentDungeon] = new Dictionary(true);
        parseFromXML(_arg2, false, parseDungeonCallback);
    }

    private static function parseDungeonCallback(_arg1:int, _arg2:XML):void {
        if (((!((currentDungeon == ""))) && (!((dungeonsXMLLibrary_[currentDungeon] == null))))) {
            dungeonsXMLLibrary_[currentDungeon][_arg1] = _arg2;
            propsLibrary_[_arg1].belonedDungeon = currentDungeon;
        }
    }

    public static function parseFromXML(xml:XML, preload:Boolean, func:Function = null):void {
        var objectXML:XML;
        var id:String;
        var displayId:String;
        var objectType:int;
        var found:Boolean;
        var i:int;
        for each (objectXML in xml.Object) {
            id = String(objectXML.@id);
            displayId = id;
            if (objectXML.hasOwnProperty("DisplayId")) {
                displayId = objectXML.DisplayId;
            }
            if (objectXML.hasOwnProperty("Group")) {
                if (objectXML.Group == "Hexable") {
                    hexTransforms_.push(objectXML);
                }
            }
            objectType = int(objectXML.@type);
            if (((objectXML.hasOwnProperty("PetBehavior")) || (objectXML.hasOwnProperty("PetAbility")))) {
                petXMLDataLibrary_[objectType] = objectXML;
            }
            else {
                propsLibrary_[objectType] = new ObjectProperties(objectXML);
                xmlLibrary_[objectType] = objectXML;
                idToType_[id] = objectType;
                typeToDisplayId_[objectType] = displayId;
                typeToObjId_[objectType] = id;

                if (String(objectXML.Class) == "Equipment")
                {
                    typeToIdItems_[objectType] = id.toLowerCase(); /* Saves us the power to do this later */
                    idToTypeItems_[id.toLowerCase()] = objectType;
                }

                if (preload)
                {
                    preloadedCustom_[objectType] = id.toLowerCase();
                }

                if (func != null) {
                    (func(objectType, objectXML));
                }

                if (String(objectXML.Class) == "Player") {
                    playerClassAbbr_[objectType] = String(objectXML.@id).substr(0, 2);
                    found = false;
                    i = 0;
                    while (i < playerChars_.length) {
                        if (int(playerChars_[i].@type) == objectType) {
                            playerChars_[i] = objectXML;
                            found = true;
                        }
                        i++;
                    }
                    if (!found) {
                        playerChars_.push(objectXML);
                    }
                }
                typeToTextureData_[objectType] = textureDataFactory.create(objectXML);
                if (objectXML.hasOwnProperty("Top")) {
                    typeToTopTextureData_[objectType] = textureDataFactory.create(XML(objectXML.Top));
                }
                if (objectXML.hasOwnProperty("Animation")) {
                    typeToAnimationsData_[objectType] = new AnimationsData(objectXML);
                }
            }
        }
    }

    public static function getIdFromType(_arg1:int):String {
        var _local2:XML = xmlLibrary_[_arg1];
        if (_local2 == null) {
            return (null);
        }
        return (String(_local2.@id));
    }

    public static function getPropsFromId(_arg1:String):ObjectProperties {
        var _local2:int = idToType_[_arg1];
        return (propsLibrary_[_local2]);
    }

    public static function getXMLfromId(_arg1:String):XML {
        var _local2:int = idToType_[_arg1];
        return (xmlLibrary_[_local2]);
    }

    public static function getObjectFromType(objectType:int):GameObject {
        var objectXML:XML;
        var typeReference:String;
        try {
            objectXML = xmlLibrary_[objectType];
            typeReference = objectXML.Class;
        }
        catch (e:Error) {
            throw (new Error(("Type: 0x" + objectType.toString(16))));
        }
        var typeClass:Class = ((TYPE_MAP[typeReference]) || (makeClass(typeReference)));
        return (new (typeClass)(objectXML));
    }

    private static function makeClass(_arg1:String):Class {
        var _local2:String = ("com.company.assembleegameclient.objects." + _arg1);
        return ((getDefinitionByName(_local2) as Class));
    }

    public static function getTextureFromType(_arg1:int):BitmapData {
        var _local2:TextureData = typeToTextureData_[_arg1];
        if (_local2 == null) {
            return (null);
        }
        return (_local2.getTexture());
    }

    public static function getRedrawnTextureFromType(objType:int, size:int, padBottom:Boolean, useCache:Boolean = true, scale:Number = 5, itemData:ItemData = null):BitmapData {
        itemData = itemData != null ? itemData : new ItemData(null);
        var texture:BitmapData = getBitmapData(objType, itemData);
        if (Parameters.itemTypes16.indexOf(objType) != -1 || texture.height == 16) {
            size *= 0.5;
        }
        var textureData:TextureData = typeToTextureData_[objType];
        var mask:BitmapData = getMask(textureData, itemData);
        if (mask == null) {
            return TextureRedrawer.redraw(texture, size, padBottom, 0, useCache, scale);
        }
        var xml:XML = xmlLibrary_[objType];
        var tex1:int = getTex1(xml, itemData);
        var tex2:int = getTex2(xml, itemData);
        texture = TextureRedrawer.resize(texture, mask, size, padBottom, tex1, tex2, scale);
        texture = GlowRedrawer.outline(texture, 0);
        return (texture);
    }

    public static function getBitmapData(objType:int, itemData:ItemData = null):BitmapData {
        itemData = itemData != null ? itemData : new ItemData(null);
        var textureData:TextureData = typeToTextureData_[objType];
        var bitmapData:BitmapData = textureData ? textureData.getTexture() : null;
        if (bitmapData && (itemData == null || itemData.TexFile == null)) {
            return bitmapData;
        }
        try {
            return AssetLibrary.getImageFromSet(itemData.TexFile, itemData.TexIndex);
        } catch (e:Error) { }
        return AssetLibrary.getImageFromSet(IMAGE_SET_NAME, IMAGE_ID);
    }

    private static function getMask(textureData:TextureData, itemData:ItemData):BitmapData {
        if (itemData == null || itemData.MaskFile == null) {
            return textureData ? textureData.mask_ : null;
        }

        try {
            return AssetLibrary.getImageFromSet(itemData.MaskFile, itemData.MaskIndex);
        } catch (e:Error) { }
        return textureData ? textureData.mask_ : null;
    }

    private static function getTex1(xml:XML, itemData:ItemData):int {
        if (itemData == null || itemData.Tex1 < 0x01000000) {
            return xml.hasOwnProperty("Tex1") ? int(xml.Tex1) : 0;
        }

        return itemData.Tex1;
    }

    private static function getTex2(xml:XML, itemData:ItemData):int {
        if (itemData == null || itemData.Tex2 < 0x01000000) {
            return xml.hasOwnProperty("Tex2") ? int(xml.Tex2) : 0;
        }

        return itemData.Tex2;
    }

    public static function getSizeFromType(_arg1:int):int {
        var _local2:XML = xmlLibrary_[_arg1];
        if (!_local2.hasOwnProperty("Size")) {
            return (100);
        }
        return (int(_local2.Size));
    }

    public static function getSlotTypeFromType(_arg1:int):int {
        var _local2:XML = xmlLibrary_[_arg1];
        if (!_local2.hasOwnProperty("SlotType")) {
            return (-1);
        }
        return (int(_local2.SlotType));
    }

    public static function isEquippableByPlayer(_arg1:int, _arg2:Player):Boolean {
        if (_arg1 == ItemConstants.NO_ITEM) {
            return (false);
        }
        var _local3:XML = xmlLibrary_[_arg1];
        var _local4:int = int(_local3.SlotType.toString());
        var _local5:uint;
        while (_local5 < GeneralConstants.NUM_EQUIPMENT_SLOTS) {
            if (_arg2.slotTypes_[_local5] == _local4) {
                return (true);
            }
            _local5++;
        }
        return (false);
    }

    public static function getMatchingSlotIndex(objType:int, player:Player):int {
        var xml:XML;
        var slotType:int;
        var matches:uint;
        if (objType != ItemConstants.NO_ITEM) {
            xml = xmlLibrary_[objType];
            slotType = int(xml.SlotType);
            matches = 0;
            while (matches < GeneralConstants.NUM_EQUIPMENT_SLOTS) {
                if (player.slotTypes_[matches] == slotType) {
                    return matches;
                }
                matches++;
            }
        }
        return -1;
    }

    public static function isUsableByPlayer(objType:int, player:Player):Boolean {
        if ((((player == null)) || ((player.slotTypes_ == null)))) {
            return true;
        }
        var item:XML = xmlLibrary_[objType];
        if ((((item == null)) || (!(item.hasOwnProperty("SlotType"))))) {
            return false;
        }
        var slotType:int = item.SlotType;
        if ((((slotType == ItemConstants.POTION_TYPE)) || ((slotType == ItemConstants.EGG_TYPE)))) {
            return true;
        }
        var slot:int;
        while (slot < player.slotTypes_.length) {
            if (player.slotTypes_[slot] == slotType) {
                return true;
            }
            slot++;
        }
        return false;
    }

    public static function isSoulbound(itemData:ItemData):Boolean {
        var _local2:XML = xmlLibrary_[itemData.ObjectType];
        return !(_local2 == null) && (_local2.hasOwnProperty("Soulbound") || (itemData != null && itemData.Soulbound));
    }

    public static function usableBy(_arg1:int):Vector.<String> {
        var _local5:XML;
        var _local6:Vector.<int>;
        var _local7:int;
        var _local2:XML = xmlLibrary_[_arg1];
        if ((((_local2 == null)) || (!(_local2.hasOwnProperty("SlotType"))))) {
            return (null);
        }
        var _local3:int = _local2.SlotType;
        if ((((((_local3 == ItemConstants.POTION_TYPE)) || ((_local3 == ItemConstants.RING_TYPE)))) || ((_local3 == ItemConstants.EGG_TYPE)))) {
            return (null);
        }
        var _local4:Vector.<String> = new Vector.<String>();
        for each (_local5 in playerChars_) {
            _local6 = ConversionUtil.toIntVector(_local5.SlotTypes);
            _local7 = 0;
            while (_local7 < _local6.length) {
                if (_local6[_local7] == _local3) {
                    _local4.push(typeToDisplayId_[int(_local5.@type)]);
                    break;
                }
                _local7++;
            }
        }
        return (_local4);
    }

    public static function playerMeetsRequirements(_arg1:int, _arg2:Player):Boolean {
        var _local4:XML;
        if (_arg2 == null) {
            return (true);
        }
        var _local3:XML = xmlLibrary_[_arg1];
        for each (_local4 in _local3.EquipRequirement) {
            if (!playerMeetsRequirement(_local4, _arg2)) {
                return (false);
            }
        }
        return (true);
    }

    public static function playerMeetsRequirement(_arg1:XML, _arg2:Player):Boolean {
        var _local3:int;
        if (_arg1.toString() == "Stat") {
            _local3 = int(_arg1.@value);
            switch (int(_arg1.@stat)) {
                case StatData.MAX_HP_STAT:
                    return ((_arg2.maxHP_ >= _local3));
                case StatData.MAX_MP_STAT:
                    return ((_arg2.maxMP_ >= _local3));
                case StatData.LEVEL_STAT:
                    return ((_arg2.level_ >= _local3));
                case StatData.STRENGTH_STAT:
                    return ((_arg2.strength_ >= _local3));
                case StatData.ARMOR_STAT:
                    return ((_arg2.armor_ >= _local3));
                case StatData.AGILITY_STAT:
                    return ((_arg2.agility_ >= _local3));
                case StatData.STAMINA_STAT:
                    return ((_arg2.stamina_ >= _local3));
                case StatData.INTELLIGENCE_STAT:
                    return ((_arg2.intelligence_ >= _local3));
                case StatData.DEXTERITY_STAT:
                    return ((_arg2.dexterity_ >= _local3));
                case StatData.SHIELD_STAT:
                    return ((_arg2.shield_ >= _local3));
                case StatData.RESISTANCE_STAT:
                    return ((_arg2.resistance_ >= _local3));
                case StatData.WIT_STAT:
                    return ((_arg2.wit_ >= _local3));
                case StatData.LETHALITY:
                    return ((_arg2.lethality_ >= _local3));
                case StatData.PIERCING:
                    return ((_arg2.piercing_ >= _local3));
            }
        }
        return (false);
    }

    public static function getPetDataXMLByType(_arg1:int):XML {
        return (petXMLDataLibrary_[_arg1]);
    }

    public static function addForgeRecipes():void {
        recipesDict_[new <String>["Draconis Potion", "Cultist Potion", "Doom Bow"]] = "True Admin Wand";

        forgeRecipes_ = Utils.sortDictionaryByValue(recipesDict_);
    }

}
}
