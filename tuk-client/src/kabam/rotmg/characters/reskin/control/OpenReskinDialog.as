package kabam.rotmg.characters.reskin.control {
import flash.display.DisplayObject;

import kabam.rotmg.characters.reskin.view.ReskinCharacterView;
import kabam.rotmg.classes.model.CharacterSkins;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.classes.view.CharacterSkinListItemFactory;
import kabam.rotmg.core.model.PlayerModel;

public class OpenReskinDialog
{
    public var player:PlayerModel = Global.playerModel;
    public var model:ClassesModel = Global.classesModel;
    public var factory:CharacterSkinListItemFactory = Global.characterSkinListItemFactory;

    public function OpenReskinDialog() {
        Global.openDialog(this.makeView());
    }

    private function makeView():ReskinCharacterView {
        var view:ReskinCharacterView = new ReskinCharacterView();
        view.setList(this.makeList());
        view.x = int(((Main.DefaultWidth - view.width) * 0.5));
        view.y = int(((Main.DefaultHeight - view.viewHeight) * 0.5));
        return (view);
    }

    private function makeList():Vector.<DisplayObject> {
        var skins:CharacterSkins = this.getCharacterSkins();
        return (this.factory.make(skins));
    }

    private function getCharacterSkins():CharacterSkins {
        return (this.model.getSelected().skins);
    }


}
}
