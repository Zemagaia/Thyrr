package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.Panel;

import thyrr.forge.ForgePanel;

public class Forge extends GameObject implements IInteractiveObject {

   public function Forge(objectXML:XML) {
      super(objectXML);
      isInteractive_ = true;
   }

   public function getPanel(gs:GameSprite):Panel {
      return new ForgePanel(gs);
   }
}
}