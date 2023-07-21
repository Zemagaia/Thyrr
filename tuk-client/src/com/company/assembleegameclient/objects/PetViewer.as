package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.Panel;

import thyrr.pets.PetViewerPanel;

public class PetViewer extends GameObject implements IInteractiveObject {

   public function PetViewer(objectXML:XML) {
      super(objectXML);
      isInteractive_ = true;
   }

   public function getPanel(gs:GameSprite):Panel {
      return new PetViewerPanel(gs);
   }
}
}