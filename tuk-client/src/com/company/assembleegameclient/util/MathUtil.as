// Decompiled by AS3 Sorcerer 6.00
// www.as3sorcerer.com

//com.company.assembleegameclient.util.MathUtil

package com.company.assembleegameclient.util
{
    public class MathUtil 
    {

        public static const TO_DEG:Number = (180 / Math.PI);//57.2957795130823
        public static const TO_RAD:Number = (Math.PI / 180);//0.0174532925199433


        public static function round(val:Number, decimals:int=0):Number
        {
            var m:int = Math.pow(10, decimals);
            return (Math.round((val * m)) / m);
        }


    }
}//package com.company.assembleegameclient.util

