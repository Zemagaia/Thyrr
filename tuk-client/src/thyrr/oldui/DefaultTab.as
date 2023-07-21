package thyrr.oldui
{
import flash.display.Sprite;

import com.company.assembleegameclient.game.GameSprite;

public class DefaultTab extends Sprite
{

    public var gameSprite_:GameSprite;

    public function DefaultTab(gameSprite:GameSprite)
    {
        this.gameSprite_ = gameSprite;
    }

    public function dispose():void
    {
        this.gameSprite_ = null;
        var i:int = 0;
        while (i < numChildren)
        {
            removeChildAt(i);
            i++;
        }
    }
}
}