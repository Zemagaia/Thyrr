package com.company.assembleegameclient.util
{
import com.company.util.MoreColorUtil;

import flash.filters.BitmapFilterQuality;

import flash.filters.ColorMatrixFilter;

import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;

import thyrr.utils.Utils;

public class FilterUtil
{

    private static const WEAK_OUTLINE_FILTER:Array = [new GlowFilter(0,0.8,2,2,3,1)];

    private static const DMG_COUNTER_MULTI_FILTER:Array = [
        new DropShadowFilter(1, 90, 0, 1, 2, 2),
        new DropShadowFilter(0, 90, 0, 0.4, 4, 4, 1, BitmapFilterQuality.HIGH)];

    private static const STANDARD_OUTLINE_FILTER:Array = [new GlowFilter(0,1,2,2,10,1)];

    private static const NEWGRAY_COLOR_FILTER:Array = [new ColorMatrixFilter(MoreColorUtil.singleColorFilterMatrix(Utils.color(0xaea9a9, 1/(1.3*1.3))))];

    public function FilterUtil()
    {
        super();
    }

    public static function getDmgCounterMultiFilter():Array
    {
        return (DMG_COUNTER_MULTI_FILTER);
    }

    public static function getWeakOutlineFilter() : Array
    {
        return WEAK_OUTLINE_FILTER;
    }

    public static function getTextOutlineFilter() : Array
    {
        return STANDARD_OUTLINE_FILTER;
    }

    public static function getNewGrayColorFilter():Array
    {
        return NEWGRAY_COLOR_FILTER;
    }
}
}
