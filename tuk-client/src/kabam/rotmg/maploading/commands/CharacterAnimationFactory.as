package kabam.rotmg.maploading.commands {
import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.parameters.Parameters;

import thyrr.assets.Animation;
import thyrr.assets.CharacterFactory;
import kabam.rotmg.classes.model.CharacterClass;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.core.model.PlayerModel;

public class CharacterAnimationFactory {

    public var playerModel:PlayerModel = Global.playerModel;
    public var factory:CharacterFactory = Global.characterFactory;
    public var classesModel:ClassesModel = Global.classesModel;
    private var currentChar:SavedCharacter;
    private var characterClass:CharacterClass;
    private var skin:CharacterSkin;
    private var tex2:int;
    private var tex1:int;


    public function make():Animation {
        this.currentChar = this.playerModel.getCharacterById(this.playerModel.currentCharId);
        this.characterClass = ((this.currentChar) ? this.getCurrentCharacterClass() : this.getDefaultCharacterClass());
        this.skin = this.characterClass.skins.getSelectedSkin();
        if (this.skin == null) return null;
        this.tex1 = ((this.currentChar) ? this.currentChar.tex1() : 0);
        this.tex2 = ((this.currentChar) ? this.currentChar.tex2() : 0);
        var _local1:int = (((Parameters.skinTypes16.indexOf(this.skin.id)) != -1) ? 70 : 100);
        return (this.factory.makeWalkingIcon(this.skin.template, _local1, this.tex1, this.tex2));
    }

    private function getDefaultCharacterClass():CharacterClass {
        return (this.classesModel.getSelected());
    }

    private function getCurrentCharacterClass():CharacterClass {
        return (this.classesModel.getCharacterClass(this.currentChar.objectType()));
    }


}
}
