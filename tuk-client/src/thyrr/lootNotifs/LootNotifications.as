package thyrr.lootNotifs {

import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.gskinner.motion.GTween;

import flash.display.DisplayObject;
import flash.display.Sprite;

import thyrr.lootNotifs.assets.LootNotifs_Divine;
import thyrr.lootNotifs.assets.LootNotifs_Legendary;
import thyrr.lootNotifs.assets.LootNotifs_Mythic;
import thyrr.lootNotifs.assets.LootNotifs_Unholy;

public class LootNotifications extends Sprite {

    private const legendary_:DisplayObject = new LootNotifs_Legendary();
    private const mythic_:DisplayObject = new LootNotifs_Mythic();
    private const divine_:DisplayObject = new LootNotifs_Divine();
    private const unholy_:DisplayObject = new LootNotifs_Unholy();

    public function LootNotifications() {
        mouseEnabled = false;
        mouseChildren = false;
    }

    public function show(notificationType:int):void {
        var notif:DisplayObject;
        var tween:GTween;
        // get symbol and notification image
        switch (notificationType) {
            case 1:
                notif = getNotification(this.mythic_);
                SoundEffectLibrary.play("test");
                break;
            case 2:
                notif = getNotification(this.divine_);
                SoundEffectLibrary.play("test");
                break;
            case 3:
                notif = getNotification(this.unholy_);
                SoundEffectLibrary.play("test");
                break;
            default:
                notif = getNotification(this.legendary_);
                SoundEffectLibrary.play("test2");
                break;
        }
        // add and fade in
        tween = new GTween(notif, 0.5, {
            "alpha": 1
        });
        tween.delay = 0.2;
        tween.init();
        // when done, fade out
        tween.onComplete = function ():void {
            tween = new GTween(notif, 1.5, {
                "alpha": 0
            });
            tween.delay = 1.5;
            tween.onComplete = function ():void {
                removeChild(notif);
            };
        };
    }

    private function getNotification(displayObject:DisplayObject):DisplayObject {
        var notif:DisplayObject = displayObject;
        notif.scaleX = 2;
        notif.scaleY = 2;
        notif.x = -notif.width / 2;
        notif.alpha = 0;
        addChild(notif);
        return notif;
    }

}
}