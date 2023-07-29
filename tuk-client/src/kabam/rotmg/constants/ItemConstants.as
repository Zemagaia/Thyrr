package kabam.rotmg.constants {
import com.company.util.AssetLibrary;

import flash.display.BitmapData;

import thyrr.utils.ItemData;

public class ItemConstants {

    public static const NO_ITEM:int = -1;
    public static const ALL_TYPE:int = 0;
    public static const SWORD_TYPE:int = 1;
    public static const DAGGER_TYPE:int = 2;
    public static const BOW_TYPE:int = 3;
    public static const TOME_TYPE:int = 4;
    public static const SHIELD_TYPE:int = 5;
    public static const LEATHER_TYPE:int = 6;
    public static const PLATE_TYPE:int = 7;
    public static const WAND_TYPE:int = 8;
    public static const RING_TYPE:int = 9;
    public static const POTION_TYPE:int = 10;
    public static const SPELL_TYPE:int = 11;
    public static const SEAL_TYPE:int = 12;
    public static const CLOAK_TYPE:int = 13;
    public static const ROBE_TYPE:int = 14;
    public static const QUIVER_TYPE:int = 15;
    public static const HELM_TYPE:int = 16;
    public static const STAFF_TYPE:int = 17;
    public static const VIAL_TYPE:int = 18;
    public static const SKULL_TYPE:int = 19;
    // 20 trap
    // 21 orb (old)
    // 22 prism
    public static const SCEPTER_TYPE:int = 23;
    public static const KATANA_TYPE:int = 24;
    public static const SHURIKEN_TYPE:int = 25;
    public static const EGG_TYPE:int = 26;
    public static const TOTEM_TYPE:int = 27;
    public static const CARD_TYPE:int = 28;
    public static const RUNE_TYPE:int = 29;
    public static const ORB_TYPE:int = 30;
    public static const ARTIFACT_TYPE:int = 31;
    public static const CHARM_TYPE:int = 32;


    public static function itemTypeToName(itemType:int):String {
        switch (itemType) {
            case ALL_TYPE:
                return ("Any");
            case SWORD_TYPE:
                return ("Sword");
            case DAGGER_TYPE:
                return ("Dagger");
            case BOW_TYPE:
                return ("Bow");
            case TOME_TYPE:
                return ("Tome");
            case SHIELD_TYPE:
                return ("Shield");
            case LEATHER_TYPE:
                return ("Leather Armor");
            case PLATE_TYPE:
                return ("Armor");
            case WAND_TYPE:
                return ("Wand");
            case RING_TYPE:
                return ("Accessory");
            case POTION_TYPE:
                return ("Potion");
            case SPELL_TYPE:
                return ("Spell");
            case SEAL_TYPE:
                return ("Holy Seal");
            case CLOAK_TYPE:
                return ("Cloak");
            case ROBE_TYPE:
                return ("Robe");
            case QUIVER_TYPE:
                return ("Quiver");
            case HELM_TYPE:
                return ("Helm");
            case STAFF_TYPE:
                return ("Staff");
            case VIAL_TYPE:
                return ("Vial");
            case SKULL_TYPE:
                return ("Skull");
            case SCEPTER_TYPE:
                return ("Scepter");
            case KATANA_TYPE:
                return ("Katana");
            case SHURIKEN_TYPE:
                return ("Shuriken");
            case EGG_TYPE:
                return ("Any");
            case TOTEM_TYPE:
                return ("Totem");
            case CARD_TYPE:
                return ("Card");
            case RUNE_TYPE:
                return ("Rune");
            case ORB_TYPE:
                return ("Orb");
            case ARTIFACT_TYPE:
                return "Artifact";
            case CHARM_TYPE:
                return "Charm";
        }
        return ("Invalid Type!");
    }

    public static function itemTypeToBaseSprite(itemType:int):BitmapData
    {
        var bitmap:BitmapData;
        switch (itemType)
        {
            case ALL_TYPE:
                break;
            case SWORD_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 48);
                break;
            case DAGGER_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 96);
                break;
            case BOW_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 80);
                break;
            case TOME_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 80);
                break;
            case SHIELD_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 112);
                break;
            case LEATHER_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 0);
                break;
            case PLATE_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 32);
                break;
            case WAND_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 64);
                break;
            case RING_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 144);
                break;
            case SPELL_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 64);
                break;
            case SEAL_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 160);
                break;
            case CLOAK_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 32);
                break;
            case ROBE_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 16);
                break;
            case QUIVER_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 48);
                break;
            case HELM_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 96);
                break;
            case STAFF_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 112);
                break;
            case VIAL_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 128);
                break;
            case SKULL_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 0);
                break;
            case SCEPTER_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 192);
                break;
            case KATANA_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered1", 128);
                break;
            case SHURIKEN_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 208);
                break;
            case TOTEM_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 0x100);
                break;
            case CARD_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 0xb0);
                break;
            case RUNE_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 0x110);
                break;
            case ORB_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 0x90);
                break;
            case ARTIFACT_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 0x160);
                break;
            case CHARM_TYPE:
                bitmap = AssetLibrary.getImageFromSet("equipmentTiered2", 0x1b0);
                break;
        }
        return (bitmap);
    }

}
}
