package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.Panel;

import thyrr.quests.QuestGiverPanel;

public class QuestObject extends GameObject implements IInteractiveObject {

   public function QuestObject(objectXML:XML) {
      super(objectXML);
      isInteractive_ = true;
   }

   public function getPanel(gs:GameSprite):Panel {
      return new QuestGiverPanel(gs);
   }
}
}