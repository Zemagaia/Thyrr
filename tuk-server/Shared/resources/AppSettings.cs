﻿using System.Collections.Generic;
using System.IO;
using System.Xml.Linq;
using System.Xml.XPath;
using NLog;

namespace Shared.resources
{
    public class AppSettings : InitSettings
    {
        static Logger log = LogUtil.GetLogger(typeof(AppSettings));

        public string MenuMusic { get; private set; }
        public string DeadMusic { get; private set; }
        public int MapMinRank { get; private set; }
        public int SpriteMinRank { get; private set; }
        public int CharacterSlotCost { get; private set; }
        public int CharacterSlotCurrency { get; private set; }
        public int VaultChestCost { get; private set; }
        public int InventorySize { get; private set; }
        public int MaxStackablePotions { get; private set; }
        public int PotionPurchaseCooldown { get; private set; }
        public int PotionPurchaseCostCooldown { get; private set; }
        public int[] PotionPurchaseCosts { get; private set; }
        public bool DisableRegistration { get; private set; }
        public int MaxPetCount { get; private set; }
        public NewAccounts Accounts { get; private set; }
        public NewCharacters Characters { get; private set; }

        public AppSettings(string path)
        {
            log.Info("Loading app settings...");

            elem = XElement.Parse(File.ReadAllText(path));

            MenuMusic = GetStringValue("MenuMusic");
            DeadMusic = GetStringValue("DeadMusic");
            MapMinRank = GetIntValue("MapMinRank");
            SpriteMinRank = GetIntValue("SpriteMinRank");
            CharacterSlotCost = GetIntValue("CharacterSlotCost");
            CharacterSlotCurrency = GetIntValue("CharacterSlotCurrency");
            VaultChestCost = GetIntValue("VaultChestCost");
            MaxStackablePotions = GetIntValue("MaxStackablePotions");
            PotionPurchaseCooldown = GetIntValue("PotionPurchaseCooldown");
            PotionPurchaseCostCooldown = GetIntValue("PotionPurchaseCostCooldown");
            DisableRegistration = GetBoolValue("DisableRegist");
            MaxPetCount = GetIntValue("MaxPetCount");
            Accounts = new NewAccounts(elem.Element("NewAccounts"));
            Characters = new NewCharacters(elem.Element("NewCharacters"));

            InventorySize = GetIntValue("InventorySize");
            if (InventorySize == 0) InventorySize = 20;

            if (Exists("PotionPurchaseCosts"))
            {
                var potCosts = elem.Element("PotionPurchaseCosts");
                var potCostList = new List<int>();
                foreach (var e in potCosts.XPathSelectElements("//cost"))
                {
                    int cost = 0;
                    int.TryParse(e.Value, out cost);
                    potCostList.Add(cost);
                }

                PotionPurchaseCosts = potCostList.ToArray();
            }
        }
    }

    public class NewAccounts : InitSettings
    {
        public int Gold { get; private set; }
        public int Fame { get; private set; }
        public bool ClassesUnlocked { get; private set; }
        public bool SkinsUnlocked { get; private set; }
        public int PetYardType { get; private set; }
        public int VaultCount { get; private set; }
        public int MaxCharSlot { get; private set; }
        public int UnholyEssence { get; internal set; }
        public int TotalUnholyEssence { get; private set; }
        public int DivineEssence { get; private set; }
        public int TotalDivineEssence { get; private set; }

        public NewAccounts(XElement e)
        {
            elem = e;

            Gold = GetIntValue("Gold");
            Fame = GetIntValue("Fame");
            UnholyEssence = GetIntValue("UnholyEssence");
            DivineEssence = GetIntValue("DivineEssence");
            ClassesUnlocked = GetBoolValue("ClassesUnlocked");
            SkinsUnlocked = GetBoolValue("SkinsUnlocked");
            PetYardType = GetIntValue("PetYardType");
            VaultCount = GetIntValue("VaultCount");
            MaxCharSlot = GetIntValue("MaxCharSlot");
        }
    }

    public class NewCharacters : InitSettings
    {
        public bool Maxed { get; private set; }
        public int Level { get; private set; }

        public NewCharacters(XElement e)
        {
            elem = e;

            Maxed = GetBoolValue("Maxed");
            Level = GetIntValue("Level");
        }
    }

    public class InitSettings
    {
        protected XElement elem;

        protected bool Exists(string element)
        {
            return elem.Element(element) != null;
        }

        protected int GetIntValue(string element)
        {
            return Exists(element) ? int.Parse(elem.Element(element).Value) : 0;
        }

        protected bool GetBoolValue(string element)
        {
            return Exists(element) ? (elem.Element(element).Value.Equals("1")) : false;
        }

        protected string GetStringValue(string element)
        {
            return Exists(element) ? elem.Element(element).Value : "";
        }
    }
}