package com.company.assembleegameclient.ui.tooltip {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.tooltip.slotcomparisons.CloakComparison;
import com.company.assembleegameclient.ui.tooltip.slotcomparisons.HelmetComparison;
import com.company.assembleegameclient.ui.tooltip.slotcomparisons.VialComparison;
import com.company.assembleegameclient.ui.tooltip.slotcomparisons.SealComparison;
import com.company.assembleegameclient.ui.tooltip.slotcomparisons.SlotComparison;
import com.company.assembleegameclient.ui.tooltip.slotcomparisons.TomeComparison;

import kabam.rotmg.constants.ItemConstants;

public class SlotComparisonFactory
{
    private var hash:Object;

    public function SlotComparisonFactory() {
        this.hash = {};
        this.hash[ItemConstants.TOME_TYPE] = new TomeComparison();
        this.hash[ItemConstants.SEAL_TYPE] = new SealComparison();
        this.hash[ItemConstants.CLOAK_TYPE] = new CloakComparison();
        this.hash[ItemConstants.HELM_TYPE] = new HelmetComparison();
        this.hash[ItemConstants.VIAL_TYPE] = new VialComparison();
    }

    public function getComparisonResults(objectXML:XML, curItemXML:XML, player:Player):SlotComparisonResult {
        var slotType:int = int(objectXML.SlotType);
        var comparison:SlotComparison = this.hash[slotType];
        var result:SlotComparisonResult = new SlotComparisonResult();
        if (comparison != null) {
            comparison.compare(objectXML, curItemXML, player);
            result.lineBuilder = comparison.comparisonStringBuilder;
            result.processedTags = comparison.processedTags;
        }
        return (result);
    }
}
}
