package kabam.rotmg.game.commands {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.parameters.Parameters;

import flash.utils.ByteArray;

import kabam.lib.net.impl.SocketServerModel;
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.core.services.GetCharListTask;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.core.signals.SetScreenSignal;
import kabam.rotmg.game.model.GameInitData;
import kabam.rotmg.servers.api.Server;
import kabam.rotmg.servers.api.ServerModel;

public class PlayGame
{

    public static const RECONNECT_DELAY:int = 1000;

    public var data:GameInitData;
    public var model:PlayerModel = Global.playerModel;
    public var servers:ServerModel = Global.serverModel;
    public var monitor:TaskMonitor = Global.taskMonitor;
    public var socketServerModel:SocketServerModel = Global.socketServerModel;


    public function PlayGame(data:GameInitData) {
        this.data = data;
        if (!this.data.isNewGame) {
            this.socketServerModel.connectDelayMS = PlayGame.RECONNECT_DELAY;
        }
        this.recordCharacterUseInSharedObject();
        this.makeGameView();
    }

    private function recordCharacterUseInSharedObject():void {
        Parameters.data_.charIdUseMap[this.data.charId] = new Date().getTime();
        Parameters.save();
    }

    private function makeGameView():void {
        var _local1:Server = ((this.servers.getServer()));
        var _local2:int = ((this.data.isNewGame) ? this.getInitialGameId() : this.data.gameId);
        var _local3:Boolean = this.data.createCharacter;
        var _local4:int = this.data.charId;
        var _local5:int = ((this.data.isNewGame) ? -1 : this.data.keyTime);
        var _local6:ByteArray = this.data.key;
        if (_local6)
            _local6.endian = "littleEndian";
        this.model.currentCharId = _local4;
        Global.setScreen(new GameSprite(_local1, _local2, _local3, _local4, _local5, _local6, this.model, null));
    }

    private function getInitialGameId():int {
        var _local1:int;
        if (Parameters.data_.needsTutorial) {
            _local1 = Parameters.TUTORIAL_GAMEID;
        }
        else {
            _local1 = Parameters.NEXUS_GAMEID;
        }
        return (_local1);
    }


}
}
