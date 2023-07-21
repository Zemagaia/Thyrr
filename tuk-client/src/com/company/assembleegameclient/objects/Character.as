package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.sound.SoundEffectLibrary;

public class Character extends GameObject {

    public var hurtSound_:String;
    public var deathSound_:String;

    public function Character(_arg1:XML) {
        super(_arg1);
        this.hurtSound_ = ((_arg1.hasOwnProperty("HitSound")) ? String(_arg1.HitSound) : "monster/default_hit");
        SoundEffectLibrary.load(this.hurtSound_);
        this.deathSound_ = ((_arg1.hasOwnProperty("DeathSound")) ? String(_arg1.DeathSound) : "monster/default_death");
        SoundEffectLibrary.load(this.deathSound_);
    }

    override public function damage(_arg2:int, _arg3:Vector.<uint>, _arg4:Boolean, _arg5:Projectile,
                                    _arg6:Boolean = false, _arg8:Boolean = false):void {
        super.damage(_arg2, _arg3, _arg4, _arg5, _arg6, _arg8);
        if (dead_) {
            SoundEffectLibrary.play(this.deathSound_);
        }
        else {
            if (((_arg5) || ((_arg2 > 0)))) {
                SoundEffectLibrary.play(this.hurtSound_);
            }
        }
    }

    public static function transitionGreenToRed(_arg1:int):int
    {
        if (_arg1 > 50)
        {
            return (0xFF00 + (0x50000 * int((100 - _arg1))));
        }
        return (0xFFFF00 - (0x0500 * int((50 - _arg1))));
    }

}
}
