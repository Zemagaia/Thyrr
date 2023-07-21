package thyrr.ui.items
{

import thyrr.ui.utils.UIElement;
import thyrr.utils.Utils;

public class InventorySlot extends UIElement
{
    public function InventorySlot(i:int, slots:int = 12, rows:int = 2)
    {
        // draw base rectangle
        var origColor:uint = 0xAEA9A9;
        // outer outline (dark)
        graphics.clear();
        graphics.beginFill(Utils.color(origColor, 1 / 1.3));
        graphics.drawRect(0, 0, 44, 44);
        graphics.endFill();
        // background
        graphics.beginFill(Utils.color(origColor, 1 / (1.3 * 1.3)));
        graphics.drawRect(0, 0, 44, 2);
        graphics.drawRect(0, 2, 2, 42);
        graphics.drawRect(2, 42, 42, 2);
        graphics.drawRect(42, 2, 2, 40);
        graphics.endFill();
        // inner outline (light)
        graphics.beginFill(origColor);
        graphics.drawRect(2, 2, 40, 2);
        graphics.drawRect(2, 4, 2, 38);
        graphics.drawRect(4, 40, 38, 2);
        graphics.drawRect(40, 4, 2, 36);
        graphics.endFill();
		// link to the slot to the right
        if ((i + 1) % int(slots / rows) > 0)
        {
            graphics.beginFill(origColor);
            graphics.drawRect(40, 11, 4, 22);
            graphics.endFill();
            graphics.beginFill(Utils.color(origColor, 1 / 1.3));
            graphics.drawRect(40, 13, 4, 18);
            graphics.endFill();
        }
		
		// link with the slot to the left
        if (i % int(slots / rows) > 0)
        {
            graphics.beginFill(origColor);
            graphics.drawRect(0, 11, 4, 22);
            graphics.endFill();
            graphics.beginFill(Utils.color(origColor, 1 / 1.3));
            graphics.drawRect(0, 13, 4, 18);
            graphics.endFill();
        }
		
		// link with the slot below
        if (i + int(slots / rows) < slots)
        {
            graphics.beginFill(origColor);
            graphics.drawRect(11, 40, 22, 4);
            graphics.endFill();
            graphics.beginFill(Utils.color(origColor, 1 / 1.3));
            graphics.drawRect(13, 40, 18, 4);
            graphics.endFill();
        }
		
		// link with the slot above
        if (i - int(slots / rows) >= 0)
        {
            graphics.beginFill(origColor);
            graphics.drawRect(11, 0, 22, 4);
            graphics.endFill();
            graphics.beginFill(Utils.color(origColor, 1 / 1.3));
            graphics.drawRect(13, 0, 18, 4);
            graphics.endFill();
        }
    }
}
}
