package kabam.rotmg.classes.model {
import org.osflash.signals.Signal;

public class CharacterClass {

    public const selected:Signal = new Signal(CharacterClass);
    public const unlocks:Vector.<CharacterClassUnlock> = new <CharacterClassUnlock>[];
    public const skins:CharacterSkins = new CharacterSkins();

    public var id:int;
    public var name:String;
    public var description:String;
    public var hitSound:String;
    public var deathSound:String;
    public var bloodProb:Number;
    public var slotTypes:Vector.<int>;
    public var defaultEquipment:Vector.<int>;
    public var hp:CharacterClassStat;
    public var mp:CharacterClassStat;
    public var strength:CharacterClassStat;
    public var wit:CharacterClassStat;
    public var armor:CharacterClassStat;
    public var agility:CharacterClassStat;
    public var dexterity:CharacterClassStat;
    public var stamina:CharacterClassStat;
    public var intelligence:CharacterClassStat;
    public var shield:CharacterClassStat;
    public var resistance:CharacterClassStat;
    public var unlockCost:int;
    private var maxLevelAchieved:int;
    private var isSelected:Boolean;


    public function getIsSelected():Boolean {
        return (this.isSelected);
    }

    public function setIsSelected(_arg1:Boolean):void {
        if (this.isSelected != _arg1) {
            this.isSelected = _arg1;
            ((this.isSelected) && (this.selected.dispatch(this)));
        }
    }

    public function getMaxLevelAchieved():int {
        return (this.maxLevelAchieved);
    }

    public function setMaxLevelAchieved(_arg1:int):void {
        this.maxLevelAchieved = _arg1;
        this.skins.updateSkins(this.maxLevelAchieved);
    }


}
}
