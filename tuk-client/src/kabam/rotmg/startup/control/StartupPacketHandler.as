package kabam.rotmg.startup.control
{
import kabam.lib.net.impl.MessageCenter;
import kabam.rotmg.characters.reskin.control.ReskinHandler;
import kabam.rotmg.chat.control.TextHandler;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.messaging.impl.incoming.Text;
import kabam.rotmg.messaging.impl.outgoing.Reskin;

public class StartupPacketHandler
{
    public var messageCenter:MessageCenter = Global.messageCenter;

    private static var textHandler:TextHandler;
    private static var reskinHandler:ReskinHandler;

    public function StartupPacketHandler()
    {
        messageCenter.map(GameServerConnection.RESKIN).toMessage(Reskin).toMethod(handleReskin);
        messageCenter.map(GameServerConnection.TEXT).toMessage(Text).toMethod(handleText);
    }

    public static function handleReskin(pkt:Reskin):void
    {
        if (reskinHandler == null)
            reskinHandler = new ReskinHandler();
        reskinHandler.execute(pkt);
    }

    public static function handleText(pkt:Text):void
    {
        if (textHandler == null)
            textHandler = new TextHandler();
        textHandler.execute(pkt);
    }
}
}
