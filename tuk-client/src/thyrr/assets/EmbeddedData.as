package thyrr.assets
{

import thyrr.assetsData.*;

public class EmbeddedData
{

	public static const playersCXML:Class = EmbeddedData_playersCXML;


	private static const pirateCaveEntities:Class = EmbeddedData_pirateCaveEntitiesCXML;
	private static const realmObjectsCXML:Class = EmbeddedData_realmObjectsCXML;
	private static const realmGroundCXML:Class = EmbeddedData_realmGroundCXML;
	private static const realmEntitiesCXML:Class = EmbeddedData_realmEntitiesCXML;
	private static const nexusGroundCXML:Class = EmbeddedData_nexusGroundCXML;
	private static const nexusObjectsCXML:Class = EmbeddedData_nexusObjectsCXML;
	public static const equipmentCustomCXML:Class = EmbeddedData_equipmentCustomCXML;
	public static const equipmentSetsSkinsCXML:Class = EmbeddedData_equipmentSetsSkinsCXML;
	private static const equipmentSetsCXML:Class = EmbeddedData_equipmentSetsCXML;
	private static const equipmentTieredCXML:Class = EmbeddedData_equipmentTieredCXML;
	private static const utilityGroundCXML:Class = EmbeddedData_utilityGroundCXML;
	private static const utilityEntitiesCXML:Class = EmbeddedData_utilityEntitiesCXML;
	private static const petsCXML:Class = EmbeddedData_petsCXML;
	private static const petsEquip:Class = EmbeddedData_petsEquipCXML;
	private static const portalsCXML:Class = EmbeddedData_portalsCXML;
	private static const projectilesCXML:Class = EmbeddedData_projectilesCXML;
	private static const playersSkinsCXML:Class = EmbeddedData_playersSkinsCXML;
	private static const playersSkinsEquipCXML:Class = EmbeddedData_playersSkinsCXML;
	private static const textilesCXML:Class = EmbeddedData_textilesCXML;
	private static const dyesCXML:Class = EmbeddedData_dyesCXML;

	public static const skinsXML:XML = XML(new playersSkinsCXML());
	public static const equipmentSetsSkinsXML:XML = XML(new equipmentSetsSkinsCXML());
	public static const groundFiles:Array = [
		new realmGroundCXML(), new nexusGroundCXML(), new utilityGroundCXML()
	];
	public static const objectFiles:Array = [
		new realmEntitiesCXML(), new nexusObjectsCXML(), new equipmentCustomCXML(), new equipmentSetsCXML(), new equipmentTieredCXML(),
		new utilityEntitiesCXML(), new petsCXML(), new petsEquip(), new portalsCXML(), new projectilesCXML(), new dyesCXML(),
		new playersCXML(), new playersSkinsCXML(), new playersSkinsEquipCXML(), new textilesCXML(), new equipmentSetsSkinsCXML(),
		new realmObjectsCXML(), new pirateCaveEntities()
	];
	private static const regionsCXML:Class = EmbeddedData_regionsCXML;
	public static const regionFiles:Array = [
		new regionsCXML()
	];

	//   private static const TutorialScriptCXML:Class = EmbeddedData_TutorialScriptCXML;
	//   public static const tutorialXML:XML = XML(new TutorialScriptCXML());

}
}