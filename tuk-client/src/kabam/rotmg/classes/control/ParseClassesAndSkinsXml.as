package kabam.rotmg.classes.control {
import com.company.assembleegameclient.objects.ObjectLibrary;

import thyrr.assets.CharacterTemplate;
import kabam.rotmg.classes.model.CharacterClass;
import kabam.rotmg.classes.model.CharacterClassStat;
import kabam.rotmg.classes.model.CharacterClassUnlock;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.CharacterSkinState;
import kabam.rotmg.classes.model.ClassesModel;

import thyrr.assets.EmbeddedData;

public class ParseClassesAndSkinsXml
{

    public var data:XML;
    public var classes:ClassesModel = Global.classesModel;
    public var model:ClassesModel = Global.classesModel;

    public function ParseClassesAndSkinsXml(data:XML)
    {
        this.data = data;
        parseClasses();
        parseSkins();
    }

    private function parseClasses():void
    {
        var classXML:XML;
        var classXMLs:XMLList = this.data.Object;
        for each (classXML in classXMLs) {
            this.parseCharacterClass(classXML);
        }
    }

    private function parseSkins():void {
        var file:XML;
        var XMLs:XMLList;
        var xml:XML;
        file = EmbeddedData.skinsXML;
        XMLs = file.children();
        for each (xml in XMLs) {
            this.parseNode(xml);
        }
        file = EmbeddedData.equipmentSetsSkinsXML;
        XMLs = file.children();
        for each (xml in XMLs) {
            parseNodeEquipment(xml);
        }
    }

    private static function parseNodeEquipment(_arg1:XML):void {
        var _local2:XMLList;
        var _local3:XML;
        var _local4:int;
        var _local5:int;
        _local2 = _arg1.children();
        for each (_local3 in _local2) {
            if (_local3.attribute("skinType").length() != 0) {
                _local4 = int(_local3.@skinType);
                _local5 = 0xFFD700;
                if (_local3.attribute("color").length() != 0) {
                    _local5 = int(_local3.@color);
                }
                ObjectLibrary.skinSetXMLDataLibrary_[_local4] = _local3;
            }
        }
    }

    private function parseNode(tex:XML):void {
        var file:String = tex.AnimatedTexture.File;
        var index:int = tex.AnimatedTexture.Index;
        var skin:CharacterSkin = new CharacterSkin();
        skin.id = tex.@type;
        skin.name = (((tex.DisplayId == undefined)) ? tex.@id : tex.DisplayId);
        skin.unlockLevel = tex.UnlockLevel;
        if (tex.hasOwnProperty("NoSkinSelect")) {
            skin.skinSelectEnabled = false;
        }
        if (tex.hasOwnProperty("UnlockSpecial")) {
            skin.unlockSpecial = tex.UnlockSpecial;
        }
        skin.template = new CharacterTemplate(file, index);
        if (file.indexOf("16") >= 0) {
            skin.is16x16 = true;
        }
        var charClass:CharacterClass = this.model.getCharacterClass(tex.PlayerClassType);
        charClass.skins.addSkin(skin);
    }

    private function parseCharacterClass(classXML:XML):void {
        var objectType:int = classXML.@type;
        var charClass:CharacterClass = this.classes.getCharacterClass(objectType);
        this.populateCharacter(charClass, classXML);
    }

    private function populateCharacter(charClass:CharacterClass, classXML:XML):void {
        var unlockXML:XML;
        charClass.id = classXML.@type;
        charClass.name = (((classXML.DisplayId == undefined)) ? classXML.@id : classXML.DisplayId);
        charClass.description = classXML.Description;
        charClass.hitSound = classXML.HitSound;
        charClass.deathSound = classXML.DeathSound;
        charClass.bloodProb = classXML.BloodProb;
        charClass.slotTypes = this.parseIntList(classXML.SlotTypes);
        charClass.defaultEquipment = this.parseIntList(classXML.Equipment);
        charClass.hp = this.parseCharacterStat(classXML, "MaxHitPoints");
        charClass.mp = this.parseCharacterStat(classXML, "MaxMagicPoints");
        charClass.strength = this.parseCharacterStat(classXML, "Strength");
        charClass.wit = this.parseCharacterStat(classXML, "Wit");
        charClass.armor = this.parseCharacterStat(classXML, "Armor");
        charClass.agility = this.parseCharacterStat(classXML, "Agility");
        charClass.dexterity = this.parseCharacterStat(classXML, "Dexterity");
        charClass.stamina = this.parseCharacterStat(classXML, "Stamina");
        charClass.intelligence = this.parseCharacterStat(classXML, "Intelligence");
        charClass.resistance = this.parseCharacterStat(classXML, "Resistance");
        charClass.unlockCost = classXML.UnlockCost;
        for each (unlockXML in classXML.UnlockLevel) {
            charClass.unlocks.push(this.parseUnlock(unlockXML));
        }
        charClass.skins.addSkin(this.makeDefaultSkin(classXML), true);
    }

    private function makeDefaultSkin(tex:XML):CharacterSkin {
        var file:String = tex.AnimatedTexture.File;
        var index:int = tex.AnimatedTexture.Index;
        var skin:CharacterSkin = new CharacterSkin();
        skin.id = 0;
        skin.name = "Classic";
        skin.template = new CharacterTemplate(file, index);
        skin.setState(CharacterSkinState.OWNED);
        skin.setIsSelected(true);
        return (skin);
    }

    private function parseUnlock(classXML:XML):CharacterClassUnlock {
        var unlock:CharacterClassUnlock = new CharacterClassUnlock();
        unlock.level = classXML.@level;
        unlock.character = this.classes.getCharacterClass(classXML.@type);
        return (unlock);
    }

    private function parseCharacterStat(classXML:XML, tag:String):CharacterClassStat {
        var increase:XML;
        var increaseXML:XML;
        var stat:CharacterClassStat;
        var first:XML = classXML[tag][0];
        for each (increaseXML in classXML.LevelIncrease) {
            if (increaseXML.text() == tag) {
                increase = increaseXML;
            }
        }
        stat = new CharacterClassStat();
        stat.initial = int(first.toString());
        stat.max = first.@max;
        stat.rampMin = ((increase) ? increase.@min : 0);
        stat.rampMax = ((increase) ? increase.@max : 0);
        return (stat);
    }

    private function parseIntList(data:String):Vector.<int> {
        var arr:Array = data.split(",");
        var len:int = arr.length;
        var ret:Vector.<int> = new Vector.<int>(len, true);
        var i:int = 0;
        while (i < len) {
            ret[i] = int(arr[i]);
            i++;
        }
        return (ret);
    }


}
}
