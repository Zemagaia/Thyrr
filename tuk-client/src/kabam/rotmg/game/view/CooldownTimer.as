package kabam.rotmg.game.view {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.ui.BaseSimpleText;

import flash.display.Graphics;
import flash.filters.DropShadowFilter;
import flash.utils.getTimer;

import flash.display.Sprite;

public class CooldownTimer extends Sprite {
    private var cdText:BaseSimpleText;
	private var circleMask:Sprite;
	private var cd:int = 500;

    public function CooldownTimer() {
		mouseChildren = false;
		mouseEnabled = false;

		var circleToMask:Sprite = new Sprite();
		circleToMask.graphics.beginFill(0, 0.7);
		circleToMask.graphics.drawRect(0,0,40,40);
		circleToMask.graphics.endFill();
		addChild(circleToMask);
		
		circleMask = new Sprite();
		circleMask.x = 20;
		circleMask.y = 20;
		circleToMask.mask = circleMask;
		addChild(circleMask);

        this.cdText = new BaseSimpleText(14, 0xFFFFFF, false, 0, 0).setBold(true);
        this.cdText.updateMetrics();
        this.cdText.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.cdText);
    }

    public function update(player:Player):void {
		var percentage:Number = (getTimer() - player.lastAltAttack_) / cd;
		if (percentage < 1) {
			var cdText:Number = ((cd - cd * percentage) / 1000);
			var decimals:int = 1;
			if (cdText < 1.0)
				decimals = 2;

            this.cdText.text = cdText.toFixed(decimals) + "s";
            this.cdText.updateMetrics(); //so the first set isn't jumpy
			this.cdText.x = (40 - this.cdText.actualWidth_) / 2;
            this.cdText.y = (40 - this.cdText.actualHeight_) / 2;

			circleMask.graphics.clear();
			circleMask.graphics.beginFill(0);
			drawPieMask(circleMask.graphics, percentage, 20 * Math.sqrt(2) , 0, 0, -(Math.PI) / 2, 3);
			circleMask.graphics.endFill();
		}
		else {
			circleMask.graphics.clear();
            this.cdText.text = "";
            this.cdText.updateMetrics();
			cd = 500;
			var abilXML:XML = ObjectLibrary.xmlLibrary_[player.equipment_[2].ObjectType];
			if (abilXML != null && abilXML.hasOwnProperty("Cooldown")) {
				cd = EquipmentToolTip.getModdedCooldown(abilXML, player) * 1000;
				player.lastAltAttack_ = getTimer() - cd;
			}
		}
    }
	
	private function drawPieMask(graphics:Graphics, p:Number, radius:Number, x:Number = 0, y:Number = 0, rotation:Number = 0, sides:int = 6):void {
		p = 1 - p;
		graphics.moveTo(x, y);

		if (sides < 3) sides = 3;
		radius /= Math.cos(1/sides * Math.PI);

		var lineToRadians:Function = function(rads:Number) : void {
			rads = Math.PI - rads;
			graphics.lineTo(Math.cos(rads) * radius + x, Math.sin(rads) * radius + y);
		};

		var sidesToDraw:int = Math.floor(p * sides);
		var i:int = 0;
		while (i <= sidesToDraw)
		{
			lineToRadians((i / sides) * (Math.PI * 2) + rotation);
			i++;
		}
		if (p * sides != sidesToDraw) {
			lineToRadians(p * (Math.PI * 2) + rotation);
		}
	} 
}
}