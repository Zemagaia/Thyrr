package com.company.assembleegameclient.util {
import com.company.assembleegameclient.engine3d.Model3D;
import com.company.assembleegameclient.map.GroundLibrary;
import com.company.assembleegameclient.map.RegionLibrary;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.particles.ParticleLibrary;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.sound.SFX;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.company.assembleegameclient.ui.options.Options;
import com.company.util.AssetLibrary;

import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;

import thyrr.assets.EmbeddedAssets;
import thyrr.assets.realm.shore.pirateCave.EmbeddedAssets_pirateCaveChars16Embed_;
import thyrr.assets.realm.shore.pirateCave.EmbeddedAssets_pirateCaveChars16Embed_;
import thyrr.assets.utility.EmbeddedAssets_interfaceNewEmbed_;
import thyrr.assets.EmbeddedData;


public class AssetLoader {

    public static var currentXmlIsTesting:Boolean = false;


    public function load():void {
        this.addImages();
        this.addAnimatedCharacters();
        this.addSoundEffects();
        this.parse3DModels();
        this.parseParticleEffects();
        this.parseGroundFiles();
        this.parseObjectFiles();
        this.parseRegionFiles();
        Parameters.load();
        Options.refreshCursor();
        SFX.load();
    }

    private function addImages():void {
        AssetLibrary.addImageSet("stars", new EmbeddedAssets.starsEmbed_().bitmapData, 5, 5);
        AssetLibrary.addImageSet("textile4x4", new EmbeddedAssets.textile4x4Embed_().bitmapData, 4, 4);
        AssetLibrary.addImageSet("textile5x5", new EmbeddedAssets.textile5x5Embed_().bitmapData, 5, 5);
        AssetLibrary.addImageSet("textile9x9", new EmbeddedAssets.textile9x9Embed_().bitmapData, 9, 9);
        AssetLibrary.addImageSet("textile10x10", new EmbeddedAssets.textile10x10Embed_().bitmapData, 10, 10);
        AssetLibrary.addImageSet("inner_mask", new EmbeddedAssets.innerMaskEmbed_().bitmapData, 4, 4);
        AssetLibrary.addImageSet("sides_mask", new EmbeddedAssets.sidesMaskEmbed_().bitmapData, 4, 4);
        AssetLibrary.addImageSet("outer_mask", new EmbeddedAssets.outerMaskEmbed_().bitmapData, 4, 4);
        AssetLibrary.addImageSet("innerP1_mask", new EmbeddedAssets.innerP1MaskEmbed_().bitmapData, 4, 4);
        AssetLibrary.addImageSet("innerP2_mask", new EmbeddedAssets.innerP2MaskEmbed_().bitmapData, 4, 4);
        AssetLibrary.addImageSet("invisible", new BitmapDataSpy(8, 8, true, 0), 8, 8);
        AssetLibrary.addImageSet("cursorsEmbed", new EmbeddedAssets.cursorsEmbed_().bitmapData, 32, 32);
		
		AssetLibrary.addImageSet("particleEffectsEmbed", new EmbeddedAssets.particleEffectsEmbed_().bitmapData, 16, 16);

		AssetLibrary.addImageSet("equipmentCustom", new EmbeddedAssets.equipmentCustomEmbed_().bitmapData, 8, 8);
		AssetLibrary.addImageSet("equipmentTiered1", new EmbeddedAssets.equipmentTiered1Embed_().bitmapData, 8, 8);
		AssetLibrary.addImageSet("equipmentTiered2", new EmbeddedAssets.equipmentTiered2Embed_().bitmapData, 8, 8);
		
		AssetLibrary.addImageSet("projectileSmall", new EmbeddedAssets.projectilesSmallEmbed_().bitmapData, 8, 8);
		
		
		AssetLibrary.addImageSet("nexusEnvironment", new EmbeddedAssets.nexusEnvironmentEmbed_().bitmapData, 8, 8);
		AssetLibrary.addImageSet("realmEnvironment", new EmbeddedAssets.realmEnvironmentEmbed_().bitmapData, 8, 8);
		
		AssetLibrary.addImageSet("utility", new EmbeddedAssets.utilityEmbed_().bitmapData, 8, 8);
		AssetLibrary.addImageSet("utilityBig", new EmbeddedAssets.utilityBigEmbed_().bitmapData, 16, 16);
        AssetLibrary.addImageSet("utilityLarge", new EmbeddedAssets.utilityLargeEmbed_().bitmapData, 32, 32);

        AssetLibrary.addImageSet("interfaceNew", new EmbeddedAssets.interfaceNewEmbed_().bitmapData, 16, 16);
		AssetLibrary.addImageSet("interfaceSmall", new EmbeddedAssets.interfaceSmallEmbed_().bitmapData, 8, 8);
		AssetLibrary.addImageSet("interfaceBig", new EmbeddedAssets.interfaceBigEmbed_().bitmapData, 16, 16);
        AssetLibrary.addImageSet("interfaceNew2", new EmbeddedAssets.interfaceNewEmbed_().bitmapData, 8, 8);
        AssetLibrary.addImageSet("ui", new EmbeddedAssets.userInterface_().bitmapData, 8, 8);
    }

    private function addAnimatedCharacters():void {
        AnimatedChars.add("players", new EmbeddedAssets.playersEmbed_().bitmapData, new EmbeddedAssets.playersMaskEmbed_().bitmapData, 8, 8, 56, 24, AnimatedChar.RIGHT);
        AnimatedChars.add("playerskins", new EmbeddedAssets.playersSkinsEmbed_().bitmapData, new EmbeddedAssets.playersSkinsMaskEmbed_().bitmapData, 8, 8, 56, 24, AnimatedChar.RIGHT);
        AnimatedChars.add("playerskins16", new EmbeddedAssets.playersSkins16Embed_().bitmapData, new EmbeddedAssets.playersSkins16MaskEmbed_().bitmapData, 16, 16, 112, 48, AnimatedChar.RIGHT);
		AnimatedChars.add("realmChars16", new EmbeddedAssets.realmChars16x16Embed_().bitmapData, new EmbeddedAssets.realmChars16x16Embed_().bitmapData, 16, 16, 112, 16, AnimatedChar.RIGHT);
		AnimatedChars.add("realmChars", new EmbeddedAssets.realmChars8x8Embed_().bitmapData, new EmbeddedAssets.realmChars8x8Embed_().bitmapData, 8, 8, 56, 8, AnimatedChar.RIGHT);
        AnimatedChars.add("pirateCaveChars16", new EmbeddedAssets.pirateCaveChars16Embed_().bitmapData, new EmbeddedAssets.pirateCaveChars16Embed_().bitmapData, 16, 16, 112, 16, AnimatedChar.RIGHT);
        AnimatedChars.add("pirateCaveChars16L", new EmbeddedAssets.pirateCaveChars16Embed_().bitmapData, new EmbeddedAssets.pirateCaveChars16Embed_().bitmapData, 16, 16, 112, 16, AnimatedChar.LEFT);
    }

    private function addSoundEffects():void {
        SoundEffectLibrary.load("button_click");
        SoundEffectLibrary.load("death_screen");
        SoundEffectLibrary.load("enter_realm");
        SoundEffectLibrary.load("error");
        SoundEffectLibrary.load("inventory_move_item");
        SoundEffectLibrary.load("level_up");
        SoundEffectLibrary.load("loot_appears");
        SoundEffectLibrary.load("no_mana");
        SoundEffectLibrary.load("use_key");
        SoundEffectLibrary.load("use_potion");
    }

    private function parse3DModels():void {
        var _local1:String;
        var _local2:ByteArray;
        var _local3:String;
        for (_local1 in EmbeddedAssets.models_) {
            _local2 = EmbeddedAssets.models_[_local1];
            _local3 = _local2.readUTFBytes(_local2.length);
            Model3D.parse3DOBJ(_local1, _local2);
            Model3D.parseFromOBJ(_local1, _local3);
        }
    }

    private function parseParticleEffects():void {
        var _local1:XML = XML(new EmbeddedAssets.particlesEmbed());
        ParticleLibrary.parseFromXML(_local1);
    }

    private function parseGroundFiles():void {
        var _local1:*;
        for each (_local1 in EmbeddedData.groundFiles) {
            GroundLibrary.parseFromXML(XML(_local1));
        }
    }

    private function parseObjectFiles():void {
        var objectObj:* = undefined;
        for each(objectObj in EmbeddedData.objectFiles)
        {
            currentXmlIsTesting = this.checkIsTestingXML(objectObj);
            ObjectLibrary.parseFromXML(XML(objectObj), objectObj is EmbeddedData.equipmentCustomCXML);
        }
        for each(objectObj in EmbeddedData.objectFiles)
        {
            ObjectLibrary.parseDungeonXML(getQualifiedClassName(objectObj), XML(objectObj));
        }
        ObjectLibrary.addForgeRecipes();
        currentXmlIsTesting = false;
    }

    private function parseRegionFiles():void {
        var _local1:*;
        for each (_local1 in EmbeddedData.regionFiles) {
            RegionLibrary.parseFromXML(XML(_local1));
        }
    }

    private function checkIsTestingXML(_arg1:*):Boolean {
        return (!((getQualifiedClassName(_arg1).indexOf("null", 33) == -1)));
    }


}
}
