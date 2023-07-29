package kabam.rotmg.characters.deletion.service {
import com.company.assembleegameclient.appengine.SavedCharacter;

import kabam.lib.tasks.BaseTask;
import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.characters.model.CharacterModel;

public class DeleteCharacterTask extends BaseTask {

    public var character:SavedCharacter;
    public var client:AppEngineClient = Global.appEngine;
    public var account:Account = Global.account;
    public var model:CharacterModel = Global.characterModel;

    public function DeleteCharacterTask(savedCharacter:SavedCharacter)
    {
        character = savedCharacter;
    }

    override protected function startTask():void {
        this.client.setMaxRetries(2);
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest("/char/delete", this.getRequestPacket());
    }

    private function getRequestPacket():Object {
        var credentials:Object = this.account.getCredentials();
        credentials.charId = this.character.charId();
        credentials.reason = 1;
        return credentials;
    }

    private function onComplete(isOk:Boolean, data:*):void {
        if (isOk) updateUserData();
        completeTask(isOk, data);
    }

    private function updateUserData():void {
        this.model.deleteCharacter(this.character.charId());
    }


}
}
