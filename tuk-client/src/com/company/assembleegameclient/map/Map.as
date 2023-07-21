package com.company.assembleegameclient.map {
import com.company.assembleegameclient.background.Background;
import com.company.assembleegameclient.map.mapoverlay.MapOverlay;
import com.company.assembleegameclient.map.partyoverlay.PartyOverlay;
import com.company.assembleegameclient.objects.BasicObject;
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.Party;
import com.company.assembleegameclient.objects.particles.ParticleEffect;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.util.ConditionEffect;
import com.company.assembleegameclient.game.GameSprite;

import flash.display.BitmapData;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.StageScaleMode;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.game.model.GameModel;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.stage3D.Object3D.Object3DStage3D;
import kabam.rotmg.stage3D.Render3D;
import kabam.rotmg.stage3D.Renderer;
import kabam.rotmg.stage3D.Stage3DConfig;
import kabam.rotmg.stage3D.graphic3D.Program3DFactory;
import kabam.rotmg.stage3D.graphic3D.TextureFactory;

public class Map extends AbstractMap {

    public static const CLOTH_BAZAAR:String = "Cloth Bazaar";
    public static const NEXUS:String = "Nexus";
    public static const DAILY_QUEST_ROOM:String = "Quest Room";
    public static const PET_YARD_1:String = "Pet Yard";
    public static const PET_YARD_2:String = "Pet Yard 2";
    public static const PET_YARD_3:String = "Pet Yard 3";
    public static const PET_YARD_4:String = "Pet Yard 4";
    public static const PET_YARD_5:String = "Pet Yard 5";
    public static const GUILD_HALL:String = "Guild Hall";
    public static const NEXUS_EXPLANATION:String = "Nexus_Explanation";
    public static const VAULT:String = "Vault";
    public static const MARKETPLACE:String = "Marketplace";
    private static const VISIBLE_SORT_FIELDS:Array = ["sortVal_", "objectId_"];
    private static const VISIBLE_SORT_PARAMS:Array = [Array.NUMERIC, Array.NUMERIC];
    protected static const BLIND_FILTER:ColorMatrixFilter = new ColorMatrixFilter([0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 0, 0, 0.05, 0.05, 0.05, 1, 0]);

    public static var forceSoftwareRender:Boolean = false;
    protected static var BREATH_CT:ColorTransform = new ColorTransform((0xFF / 0xFF), (55 / 0xFF), (0 / 0xFF), 0);
    public static var texture:BitmapData;

    public var ifDrawEffectFlag:Boolean = true;
    private var inUpdate_:Boolean = false;
    private var objsToAdd_:Vector.<BasicObject>;
    private var idsToRemove_:Vector.<int>;
    private var forceSoftwareMap:Dictionary;
    private var lastSoftwareClear:Boolean = false;
    private var graphicsData_:Vector.<IGraphicsData>;
    private var graphicsDataStageSoftware_:Vector.<IGraphicsData>;
    private var graphicsData3d_:Vector.<Object3DStage3D>;
    public var visible_:Array;
    public var visibleUnder_:Array;
    public var visibleSquares_:Vector.<Square>;
    public var topSquares_:Vector.<Square>;

    public function Map(_arg1:GameSprite) {
        this.objsToAdd_ = new Vector.<BasicObject>();
        this.idsToRemove_ = new Vector.<int>();
        this.forceSoftwareMap = new Dictionary();
        this.graphicsData_ = new Vector.<IGraphicsData>();
        this.graphicsDataStageSoftware_ = new Vector.<IGraphicsData>();
        this.graphicsData3d_ = new Vector.<Object3DStage3D>();
        this.visible_ = new Array();
        this.visibleUnder_ = new Array();
        this.visibleSquares_ = new Vector.<Square>();
        this.topSquares_ = new Vector.<Square>();
        super();
        gs_ = _arg1;
        hurtOverlay_ = new HurtOverlay();
        gradientOverlay_ = new GradientOverlay();
        mapOverlay_ = new MapOverlay();
        partyOverlay_ = new PartyOverlay(this);
        party_ = new Party(this);
        quest_ = new Quest(this);
        StaticInjectorContext.getInjector().getInstance(GameModel).gameObjects = goDict_;
        wasLastFrameGpu = Parameters.isGpuRender();
    }

    override public function setProps(_arg1:int, _arg2:int, _arg3:String, _arg4:int, _arg5:Boolean, _arg6:Boolean):void {
        width_ = _arg1;
        height_ = _arg2;
        name_ = _arg3;
        back_ = _arg4;
        allowPlayerTeleport_ = _arg5;
        showDisplays_ = _arg6;
        this.forceSoftwareRenderCheck(name_);
    }

    private function forceSoftwareRenderCheck(_arg1:String):void {
        forceSoftwareRender = this.forceSoftwareMap[_arg1] != null || WebMain.STAGE != null && WebMain.STAGE.stage3Ds[0].context3D == null;
    }

    override public function initialize():void {
        squares_.length = 0;
        squares_.length = (width_ * height_);
        background_ = Background.getBackground(back_);
        if (background_ != null) {
            addChild(background_);
        }
        addChild(map_);
        addChild(hurtOverlay_);
        addChild(gradientOverlay_);
        addChild(mapOverlay_);
        addChild(partyOverlay_);
        isPetYard = (name_.substr(0, 8) == "Pet Yard");
    }

    override public function dispose():void {
        var _local1:Square;
        var _local2:GameObject;
        var _local3:BasicObject;
        gs_ = null;
        background_ = null;
        map_ = null;
        hurtOverlay_ = null;
        gradientOverlay_ = null;
        mapOverlay_ = null;
        partyOverlay_ = null;
        for each (_local1 in squareList_) {
            _local1.dispose();
        }
        squareList_.length = 0;
        squareList_ = null;
        squares_.length = 0;
        squares_ = null;
        for each (_local2 in goDict_) {
            _local2.dispose();
        }
        goDict_ = null;
        for each (_local3 in boDict_) {
            _local3.dispose();
        }
        boDict_ = null;
        merchLookup_ = null;
        player_ = null;
        party_ = null;
        quest_ = null;
        this.objsToAdd_ = null;
        this.idsToRemove_ = null;
        TextureFactory.disposeTextures();
        GraphicsFillExtra.dispose();
        Program3DFactory.getInstance().dispose();
    }

    override public function update(_arg1:int, _arg2:int):void {
        var _local3:BasicObject;
        var _local4:int;
        this.inUpdate_ = true;
        for each (_local3 in goDict_) {
            if (!_local3.update(_arg1, _arg2)) {
                this.idsToRemove_.push(_local3.objectId_);
            }
        }
        for each (_local3 in boDict_) {
            if (!_local3.update(_arg1, _arg2)) {
                this.idsToRemove_.push(_local3.objectId_);
            }
        }
        this.inUpdate_ = false;
        for each (_local3 in this.objsToAdd_) {
            this.internalAddObj(_local3);
        }
        this.objsToAdd_.length = 0;
        for each (_local4 in this.idsToRemove_) {
            this.internalRemoveObj(_local4);
        }
        this.idsToRemove_.length = 0;
        party_.update(_arg1, _arg2);
    }

    override public function pSTopW(_arg1:Number, _arg2:Number):Point {
        var _local3:Square;
        for each (_local3 in this.visibleSquares_) {
            if (((!((_local3.faces_.length == 0))) && (_local3.faces_[0].face_.contains(_arg1, _arg2)))) {
                return (new Point(_local3.center_.x, _local3.center_.y));
            }
        }
        return (null);
    }

    override public function setGroundTile(_arg1:int, _arg2:int, _arg3:uint):void {
        var _local8:int;
        var _local9:int;
        var _local10:Square;
        var _local4:Square = this.getSquare(_arg1, _arg2);
        _local4.setTileType(_arg3);
        var _local5:int = (((_arg1 < (width_ - 1))) ? (_arg1 + 1) : _arg1);
        var _local6:int = (((_arg2 < (height_ - 1))) ? (_arg2 + 1) : _arg2);
        var _local7:int = (((_arg1 > 0)) ? (_arg1 - 1) : _arg1);
        while (_local7 <= _local5) {
            _local8 = (((_arg2 > 0)) ? (_arg2 - 1) : _arg2);
            while (_local8 <= _local6) {
                _local9 = (_local7 + (_local8 * width_));
                _local10 = squares_[_local9];
                if (((!((_local10 == null))) && (((_local10.props_.hasEdge_) || (!((_local10.tileType_ == _arg3))))))) {
                    _local10.faces_.length = 0;
                }
                _local8++;
            }
            _local7++;
        }
    }

    override public function addObj(_arg1:BasicObject, _arg2:Number, _arg3:Number):void {
        _arg1.x_ = _arg2;
        _arg1.y_ = _arg3;
        if ((_arg1 is ParticleEffect)) {
            (_arg1 as ParticleEffect).reducedDrawEnabled = !(Parameters.data_.particleEffect);
        }
        if (this.inUpdate_) {
            this.objsToAdd_.push(_arg1);
        } else {
            this.internalAddObj(_arg1);
        }
    }

    public function internalAddObj(_arg1:BasicObject):void {
        if (!_arg1.addTo(this, _arg1.x_, _arg1.y_)) {
            return;
        }
        var _local2:Dictionary = (((_arg1 is GameObject)) ? goDict_ : boDict_);
        if (_local2[_arg1.objectId_] != null) {
            if (!isPetYard) {
                return;
            }
        }
        _local2[_arg1.objectId_] = _arg1;
    }

    override public function removeObj(_arg1:int):void {
        if (this.inUpdate_) {
            this.idsToRemove_.push(_arg1);
        } else {
            this.internalRemoveObj(_arg1);
        }
    }

    public function internalRemoveObj(objId:int):void {
        var dict:Dictionary = goDict_;
        var bo:BasicObject = dict[objId];
        if (bo == null) {
            dict = boDict_;
            bo = dict[objId];
            if (bo == null) {
                return;
            }
        }
        bo.removeFromMap();
        delete dict[objId];
    }

    public function getSquare(_arg1:Number, _arg2:Number):Square {
        if ((((((((_arg1 < 0)) || ((_arg1 >= width_)))) || ((_arg2 < 0)))) || ((_arg2 >= height_)))) {
            return (null);
        }
        var _local3:int = (int(_arg1) + (int(_arg2) * width_));
        var _local4:Square = squares_[_local3];
        if (_local4 == null) {
            _local4 = new Square(this, int(_arg1), int(_arg2));
            squares_[_local3] = _local4;
            squareList_.push(_local4);
        }
        return (_local4);
    }

    public function lookupSquare(_arg1:int, _arg2:int):Square {
        if ((((((((_arg1 < 0)) || ((_arg1 >= width_)))) || ((_arg2 < 0)))) || ((_arg2 >= height_)))) {
            return (null);
        }
        return (squares_[(_arg1 + (_arg2 * width_))]);
    }

    public function correctMapView(_arg1:Camera):Point
    {
        var _local7:Number = Parameters.data_["mscale"];
        var _local2:Rectangle = _arg1.clipRect_;
        if (stage.scaleMode == StageScaleMode.EXACT_FIT)
        {
            x = -(_local2.x);
            y = -(_local2.y);
        }
        else
        {
            if (stage.scaleMode == StageScaleMode.NO_SCALE)
            {
                x = ((-(_local2.x) * WebMain.DefaultWidth) / (WebMain.sWidth / _local7));
                y = ((-(_local2.y) * WebMain.DefaultHeight) / (WebMain.sHeight / _local7));
            }
        }
        var _local3:Number = ((-(_local2.x) - (_local2.width / 2)) / 50);
        var _local5:Number = ((-(_local2.y) - (_local2.height / 2)) / 50);
        var _local6:Number = Math.sqrt(((_local3 * _local3) + (_local5 * _local5)));
        var _local4:Number = ((_arg1.angleRad_ - (Math.PI / 2)) - Math.atan2(_local3, _local5));
        return (new Point((_arg1.x_ + (_local6 * Math.cos(_local4))), (_arg1.y_ + (_local6 * Math.sin(_local4)))));
    }

    override public function draw(_arg1:Camera, _arg2:int):void
    {
        var _local7:GameObject;
        var _local8:BasicObject;
        var _local24:Array;
        var _local3:uint;
        var _local4:Render3D;
        var _local5:int;
        var _local6:Square;
        var _local9:int;
        var _local10:Number = NaN;
        var _local11:Number = NaN;
        var _local12:Number = NaN;
        var _local13:Number = NaN;
        var _local14:Number = NaN;
        var _local15:Number = NaN;
        var _local16:Rectangle = _arg1.clipRect_;
        var _local17:Point = this.correctMapView(_arg1);
        x = (((-(_local16.x) * WebMain.DefaultWidth) / WebMain.sWidth) * Parameters.data_.mscale);
        y = (((-(_local16.y) * WebMain.DefaultHeight) / WebMain.sHeight) * Parameters.data_.mscale);
        if (Parameters.isGpuRender())
        {
            WebMain.STAGE.stage3Ds[0].x = ((WebMain.DefaultWidth / 2) - (Stage3DConfig.HALF_WIDTH * Parameters.data_.mscale));
            WebMain.STAGE.stage3Ds[0].y = ((WebMain.DefaultHeight / 2) - (Stage3DConfig.HALF_HEIGHT * Parameters.data_.mscale));
        }
        if (this.wasLastFrameGpu != Parameters.isGpuRender())
        {
            if ((((this.wasLastFrameGpu) && (WebMain.STAGE.stage3Ds[0].context3D)) && (!((WebMain.STAGE.stage3Ds[0].context3D) && (!(WebMain.STAGE.stage3Ds[0].context3D.driverInfo.toLowerCase().indexOf("disposed") == -1))))))
            {
                WebMain.STAGE.stage3Ds[0].context3D.clear();
                WebMain.STAGE.stage3Ds[0].context3D.present();
            }
            else
            {
                this.map_.graphics.clear();
            }
            this.signalRenderSwitch.dispatch(this.wasLastFrameGpu);
            this.wasLastFrameGpu = Parameters.isGpuRender();
        }
        if (this.background_)
        {
            this.background_.draw(_arg1, _arg2);
        }
        this.visible_.length = 0;
        this.visibleUnder_.length = 0;
        this.visibleSquares_.length = 0;
        this.topSquares_.length = 0;
        this.graphicsData_.length = 0;
        this.graphicsDataStageSoftware_.length = 0;
        this.graphicsData3d_.length = 0;
        var _local18:int = _arg1.maxDist_;
        var _local19:int = Math.max(0, (_local17.x - _local18));
        var _local20:int = Math.min((this.width_ - 1), (_local17.x + _local18));
        var _local21:int = Math.max(0, (_local17.y - _local18));
        var _local22:int = Math.min((this.height_ - 1), (_local17.y + _local18));
        var _local23:int = _local19;
        while (_local23 <= _local20)
        {
            _local9 = _local21;
            while (_local9 <= _local22)
            {
                _local6 = this.squares_[(_local23 + (_local9 * this.width_))];
                if (_local6 != null)
                {
                    _local10 = (_local17.x - _local6.center_.x);
                    _local11 = (_local17.y - _local6.center_.y);
                    _local12 = ((_local10 * _local10) + (_local11 * _local11));
                    if (_local12 <= _arg1.maxDistSq_)
                    {
                        _local6.lastVisible_ = _arg2;
                        _local6.draw(this.graphicsData_, _arg1, _arg2);
                        this.visibleSquares_.push(_local6);
                        if (_local6.topFace_ != null)
                        {
                            this.topSquares_.push(_local6);
                        }
                    }
                }
                _local9++;
            }
            _local23++;
        }
        for each (_local7 in this.goDict_)
        {
            _local7.drawn_ = false;
            if (!_local7.dead_)
            {
                _local6 = _local7.square_;
                if (!((_local6 == null) || (!(_local6.lastVisible_ == _arg2))))
                {
                    _local7.drawn_ = true;
                    _local7.computeSortVal(_arg1);
                    if (_local7.props_.drawUnder_)
                    {
                        if (_local7.props_.drawOnGround_)
                        {
                            _local7.draw(this.graphicsData_, _arg1, _arg2);
                        }
                        else
                        {
                            this.visibleUnder_.push(_local7);
                        }
                    }
                    else
                    {
                        this.visible_.push(_local7);
                    }
                }
            }
        }
        for each (_local8 in this.boDict_)
        {
            _local8.drawn_ = false;
            _local6 = _local8.square_;
            if (!((_local6 == null) || (!(_local6.lastVisible_ == _arg2))))
            {
                _local8.drawn_ = true;
                _local8.computeSortVal(_arg1);
                this.visible_.push(_local8);
            }
        }
        if (this.visibleUnder_.length > 0)
        {
            this.visibleUnder_.sortOn(VISIBLE_SORT_FIELDS, VISIBLE_SORT_PARAMS);
            for each (_local8 in this.visibleUnder_)
            {
                _local8.draw(this.graphicsData_, _arg1, _arg2);
            }
        }
        this.visible_.sortOn(VISIBLE_SORT_FIELDS, VISIBLE_SORT_PARAMS);
        if (Parameters.data_.drawShadows)
        {
            for each (_local8 in this.visible_)
            {
                if (_local8.hasShadow_)
                {
                    _local8.drawShadow(this.graphicsData_, _arg1, _arg2);
                }
            }
        }
        for each (_local8 in this.visible_)
        {
            _local8.draw(this.graphicsData_, _arg1, _arg2);
        }
        if (this.topSquares_.length > 0)
        {
            for each (_local6 in this.topSquares_)
            {
                _local6.drawTop(this.graphicsData_, _arg1, _arg2);
            }
        }
        if ((((!(this.player_ == null)) && (this.player_.breath_ >= 0)) && (this.player_.breath_ < Parameters.BREATH_THRESH)))
        {
            _local13 = ((Parameters.BREATH_THRESH - this.player_.breath_) / Parameters.BREATH_THRESH);
            _local14 = (Math.abs(Math.sin((_arg2 / 300))) * 0.75);
            BREATH_CT.alphaMultiplier = (_local13 * _local14);
            this.hurtOverlay_.transform.colorTransform = BREATH_CT;
            this.hurtOverlay_.visible = true;
            this.hurtOverlay_.x = _local16.left;
            this.hurtOverlay_.y = _local16.top;
        }
        else
        {
            this.hurtOverlay_.visible = false;
        }
        if (((Parameters.isGpuRender()) && (Renderer.inGame)))
        {
            _local3 = this.getFilterIndex();
            _local4 = StaticInjectorContext.getInjector().getInstance(Render3D);
            _local4.dispatch(this.graphicsData_, this.graphicsData3d_, this.width_, this.height_, _arg1, _local3);
            _local5 = 0;
            while (_local5 < this.graphicsData_.length)
            {
                if (((this.graphicsData_[_local5] is GraphicsBitmapFill) && (GraphicsFillExtra.isSoftwareDraw(GraphicsBitmapFill(this.graphicsData_[_local5])))))
                {
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[_local5]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[(_local5 + 1)]);
                    this.graphicsDataStageSoftware_.push(this.graphicsData_[(_local5 + 2)]);
                }
                else
                {
                    if (((this.graphicsData_[_local5] is GraphicsSolidFill) && (GraphicsFillExtra.isSoftwareDrawSolid(GraphicsSolidFill(this.graphicsData_[_local5])))))
                    {
                        this.graphicsDataStageSoftware_.push(this.graphicsData_[_local5]);
                        this.graphicsDataStageSoftware_.push(this.graphicsData_[(_local5 + 1)]);
                        this.graphicsDataStageSoftware_.push(this.graphicsData_[(_local5 + 2)]);
                    }
                }
                _local5++;
            }
            if (this.graphicsDataStageSoftware_.length > 0)
            {
                this.map_.graphics.clear();
                this.map_.graphics.drawGraphicsData(this.graphicsDataStageSoftware_);
                if (this.lastSoftwareClear)
                {
                    this.lastSoftwareClear = false;
                }
            }
            else
            {
                if (!this.lastSoftwareClear)
                {
                    this.map_.graphics.clear();
                    this.lastSoftwareClear = true;
                }
            }
            if ((_arg2 % 149) == 0)
            {
                GraphicsFillExtra.manageSize();
            }
        }
        else
        {
            this.map_.graphics.clear();
            this.map_.graphics.drawGraphicsData(this.graphicsData_);
        }
        this.map_.filters.length = 0;
        if (((!(this.player_ == null)) && (!((this.player_.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.MAP_FILTER_BITMASK) == 0))))
        {
            _local24 = [];
            if (this.player_.isDrunk())
            {
                _local15 = (20 + (10 * Math.sin((_arg2 / 1000))));
                _local24.push(new BlurFilter(_local15, _local15));
            }
            if (this.player_.isUnsighted())
            {
                _local24.push(BLIND_FILTER);
            }
            this.map_.filters = _local24;
        }
        else
        {
            if (this.map_.filters.length > 0)
            {
                this.map_.filters = [];
            }
        }
        this.mapOverlay_.draw(_arg1, _arg2);
        this.partyOverlay_.draw(_arg1, _arg2);
    }

    private function getFilterIndex():uint {
        var _local1:uint;
        if (((!((player_ == null))) && (!(((player_.condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.MAP_FILTER_BITMASK) == 0))))) {
            if (player_.isPaused()) {
                _local1 = Renderer.STAGE3D_FILTER_PAUSE;
            }
            else {
                if (player_.isUnsighted()) {
                    _local1 = Renderer.STAGE3D_FILTER_BLIND;
                }
                else {
                    if (player_.isDrunk()) {
                        _local1 = Renderer.STAGE3D_FILTER_DRUNK;
                    }
                }
            }
        }
        return (_local1);
    }

}
}
