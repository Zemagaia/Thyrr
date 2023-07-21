package thyrr.mail
{

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.util.AssetLibrary;
import com.company.util.BitmapUtil;

import flash.display.BitmapData;

import thyrr.mail.content.MailContent;

import thyrr.oldui.DefaultFrame;

public class AccountMail extends DefaultFrame
{

    private var content_:MailContent;

    public function AccountMail(gameSprite:GameSprite)
    {
        var bitmapData:BitmapData = AssetLibrary.getImageFromSet("interfaceNew2", 0x29);
        bitmapData = TextureRedrawer.redraw(bitmapData, 40, true, 0, false);
        bitmapData = BitmapUtil.cropToBitmapData(bitmapData, 8, 8, (bitmapData.width - 16), (bitmapData.height - 16));
        super(gameSprite, new <String>["Mail"], new <BitmapData>[bitmapData]);
        this.content_ = new MailContent(gameSprite);
        addChild(this.content_);
    }

}
}