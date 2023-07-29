package kabam.rotmg.account.web.commands
{
import com.company.assembleegameclient.screens.CharacterSelectionScreen;

import flash.display.Sprite;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.classes.model.CharacterClass;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.CharacterSkinState;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.core.model.ScreenModel;
import kabam.rotmg.fame.view.FameView;

public class Logout
{
    public var account:Account = Global.account;
    public var screenModel:ScreenModel = Global.screenModel;
    public var classes:ClassesModel = Global.classesModel;

    public function Logout()
    {
        this.account.clear();
        Global.invalidateData();
        this.makeScreen();
        this.resetClassData();
    }

    private function resetClassData():void
    {
        var classCount:int = this.classes.getCount();
        var i:int = 0;
        while (i < classCount)
        {
            this.resetClass(this.classes.getClassAtIndex(i));
            i++;
        }
    }

    private function resetClass(characterClass:CharacterClass):void
    {
        characterClass.setIsSelected((characterClass.id == ClassesModel.WIZARD_ID));
        this.resetClassSkins(characterClass);
    }

    private function resetClassSkins(characterClass:CharacterClass):void
    {
        var skin:CharacterSkin;
        var defaultSkin:CharacterSkin = characterClass.skins.getDefaultSkin();
        var skinCount:int = characterClass.skins.getCount();
        var i:int = 0;
        while (i < skinCount)
        {
            skin = characterClass.skins.getSkinAt(i);
            if (skin != defaultSkin)
                this.resetSkin(characterClass.skins.getSkinAt(i));
            i++;
        }
    }

    private function resetSkin(characterSkin:CharacterSkin):void
    {
        characterSkin.setState(CharacterSkinState.LOCKED);
    }

    private function makeScreen():Sprite
    {
        if (this.screenModel.getCurrentScreenType() == FameView)
        {
            Global.setCharacterSelectionScreen(new CharacterSelectionScreen());
            return Global.characterSelectionScreen;
        }
        return (new (((this.screenModel.getCurrentScreenType()) || (CharacterSelectionScreen)))());
    }
}
}