package kabam.rotmg.classes.control {
import com.company.assembleegameclient.appengine.SavedCharactersList;
import com.company.assembleegameclient.sound.Music;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.web.WebAccount;
import kabam.rotmg.classes.model.CharacterClass;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.CharacterSkinState;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.servers.api.Server;
import kabam.rotmg.servers.api.ServerModel;

public class ParseCharListData
{

    public var data:XML;
    public var account:Account;
    public var servers:ServerModel = Global.serverModel;
    public var classesModel:ClassesModel = Global.classesModel;
    public var playerModel:PlayerModel = Global.playerModel;


    public function ParseCharListData(data:XML) {
        this.data = data;
        this.parseMaxLevelsAchieved();
        this.parseItemCosts();
        this.parseOwnership();
        this.parsePaymentData();
        this.parseServerData();
        this.updatePlayerModel();
    }

    public function parseServerData():void {
        this.servers.setServers(this.makeListOfServers());
    }

    private function makeListOfServers():Vector.<Server> {
        var server:XML;
        var servers:XMLList = this.data.child("Servers").child("Server");
        var arr:Vector.<Server> = new <Server>[];
        for each (server in servers) {
            arr.push(this.makeServer(server));
        }
        return (arr);
    }

    private function makeServer(_arg1:XML):Server {
        return (new Server().setName(_arg1.Name).setAddress(_arg1.DNS).setPort(_arg1.Port).setLatLong(Number(_arg1.Lat), Number(_arg1.Long)).setUsage(_arg1.Usage).setMaxPlayers(_arg1.MaxPlayers).setIsAdminOnly(_arg1.hasOwnProperty("AdminOnly")));
    }

    private function updatePlayerModel():void {
        this.playerModel.setCharacterList(new SavedCharactersList(this.data));
        this.playerModel.isInvalidated = false;
        Music.load(this.playerModel.getMenuMusic());
    }

    private function parsePaymentData():void
    {
        var _local2:XML;
        var _local1:WebAccount = (this.account as WebAccount);
        if (this.data.hasOwnProperty("KabamPaymentInfo")) {
            _local2 = XML(this.data.KabamPaymentInfo);
            _local1.signedRequest = _local2.signedRequest;
            _local1.kabamId = _local2.naid;
        }
    }

    private function parseMaxLevelsAchieved():void {
        var _local2:XML;
        var _local3:CharacterClass;
        var _local1:XMLList = this.data.MaxClassLevelList.MaxClassLevel;
        for each (_local2 in _local1) {
            _local3 = this.classesModel.getCharacterClass(_local2.@classType);
            _local3.setMaxLevelAchieved(_local2.@maxLevel);
        }
    }

    private function parseItemCosts():void {
        var _local2:XML;
        var _local3:CharacterSkin;
        var _local1:XMLList = this.data.ItemCosts.ItemCost;
        for each (_local2 in _local1) {
            _local3 = this.classesModel.getCharacterSkin(_local2.@type);
            if (_local3) {
                _local3.cost = int(_local2);
                _local3.limited = Boolean(int(_local2.@expires));
                if (!Boolean(int(_local2.@purchasable))) {
                    _local3.setState(CharacterSkinState.UNLISTED);
                }
            }
            else {
                trace("Cannot set Character Skin cost: type {0} not found", [_local2.@type]);
            }
        }
    }

    private function parseOwnership():void {
        var _local2:int;
        var _local3:CharacterSkin;
        var _local1:Array = ((this.data.OwnedSkins.length()) ? this.data.OwnedSkins.split(",") : []);
        for each (_local2 in _local1) {
            _local3 = this.classesModel.getCharacterSkin(_local2);
            if (_local3) {
                _local3.setState(CharacterSkinState.OWNED);
            }
            else {
                trace("Cannot set Character Skin ownership: type {0} not found", [_local2]);
            }
        }
    }


}
}
