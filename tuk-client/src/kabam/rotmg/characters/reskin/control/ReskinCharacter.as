package kabam.rotmg.characters.reskin.control {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.parameters.Parameters;

import kabam.lib.net.impl.MessageCenter;
import kabam.lib.net.impl.SocketServer;
import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.messaging.impl.outgoing.Reskin;

public class ReskinCharacter
{

    public var messages:MessageCenter = Global.messageCenter;
    public var server:SocketServer = Global.socketServer;

    public function ReskinCharacter(skin:CharacterSkin) {
        var pkt:Reskin = (this.messages.require(GameServerConnection.RESKIN) as Reskin);
        pkt.skinID = skin.id;
        var player:Player = Global.gameModel.player;
        if (player != null) {
            player.clearTextureCache();
            if (Parameters.skinTypes16.indexOf(pkt.skinID) != -1) {
                player.size_ = 70;
            }
            else {
                player.size_ = 100;
            }
        }
        this.server.queueMessage(pkt);
    }


}
}
