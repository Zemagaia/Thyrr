package kabam.rotmg.classes.view {
import com.company.assembleegameclient.util.FameUtil;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.utils.Timer;

import kabam.rotmg.classes.model.CharacterClass;

import kabam.rotmg.classes.model.CharacterSkin;
import kabam.rotmg.classes.model.ClassesModel;
import kabam.rotmg.core.model.PlayerModel;

import thyrr.assets.Animation;
import thyrr.assets.CharacterFactory;
import thyrr.assets.IconFactory;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.ui.view.SignalWaiter;
import kabam.rotmg.util.components.StarsView;

public class ClassDetailView extends Sprite {

    private static const RIGHT_JUSTIFICATION_STATS:int = 205;
    private static const WIDTH:int = 344;
    private static const TEXT_WIDTH:int = 188;

    private const waiter:SignalWaiter = new SignalWaiter();
    private const skins:Object = new Object();
    private const nextSkinTimer:Timer = new Timer(250, 1);

    public var classesModel:ClassesModel = Global.classesModel;
    public var playerModel:PlayerModel = Global.playerModel;
    public var factory:CharacterFactory = Global.characterFactory;
    private var character:CharacterClass;
    private var nextSkin:CharacterSkin;
    private var classNameText:TextFieldDisplayConcrete;
    private var classDescriptionText:TextFieldDisplayConcrete;
    private var questCompletionText:TextFieldDisplayConcrete;
    private var levelTitleText:TextFieldDisplayConcrete;
    private var levelText:TextFieldDisplayConcrete;
    private var fameTitleText:TextFieldDisplayConcrete;
    private var fameText:TextFieldDisplayConcrete;
    private var fameIcon:Bitmap;
    private var nextGoalText:TextFieldDisplayConcrete;
    private var nextGoalDetailText:TextFieldDisplayConcrete;
    private var questCompletedStars:StarsView;
    private var showNextGoal:Boolean;
    private var animContainer:Sprite;
    private var animation:Animation;

    public function ClassDetailView() {
        var _local1:DropShadowFilter;
        super();
        this.waiter.complete.add(this.layout);
        _local1 = new DropShadowFilter(0, 0, 0, 1, 8, 8);
        this.animContainer = new Sprite();
        this.animContainer.x = ((WIDTH - 104) * 0.5);
        addChild(this.animContainer);
        this.classNameText = new TextFieldDisplayConcrete().setSize(20).setColor(0xFFFFFF).setBold(true).setTextWidth(TEXT_WIDTH);
        this.classNameText.filters = [_local1];
        this.waiter.push(this.classNameText.textChanged);
        addChild(this.classNameText);
        this.classDescriptionText = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF).setTextWidth(TEXT_WIDTH).setWordWrap(true);
        this.classDescriptionText.filters = [_local1];
        this.waiter.push(this.classDescriptionText.textChanged);
        addChild(this.classDescriptionText);
        this.questCompletionText = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF).setBold(true);
        this.questCompletionText.filters = [_local1];
        this.questCompletionText.setStringBuilder(new LineBuilder().setParams("Class Quests Completed"));
        this.waiter.push(this.questCompletionText.textChanged);
        addChild(this.questCompletionText);
        this.levelTitleText = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF).setBold(true);
        this.levelTitleText.filters = [_local1];
        this.levelTitleText.setStringBuilder(new LineBuilder().setParams("Highest Level Achieved"));
        this.waiter.push(this.levelTitleText.textChanged);
        addChild(this.levelTitleText);
        this.levelText = new TextFieldDisplayConcrete().setSize(16).setColor(0xFFFFFF).setBold(true);
        this.levelText.filters = [_local1];
        this.waiter.push(this.levelText.textChanged);
        addChild(this.levelText);
        this.fameTitleText = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF).setBold(true);
        this.fameTitleText.filters = [_local1];
        this.fameTitleText.setStringBuilder(new LineBuilder().setParams("Most Fame Achieved"));
        this.waiter.push(this.fameTitleText.textChanged);
        addChild(this.fameTitleText);
        this.fameText = new TextFieldDisplayConcrete().setSize(16).setColor(15387756).setBold(true);
        this.fameText.filters = [_local1];
        this.waiter.push(this.fameText.textChanged);
        addChild(this.fameText);
        this.fameIcon = new Bitmap(IconFactory.makeFame());
        this.fameIcon.filters = [_local1];
        addChild(this.fameIcon);
        this.nextGoalText = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF).setBold(true);
        this.nextGoalText.filters = [_local1];
        this.nextGoalText.setStringBuilder(new LineBuilder().setParams("Next Goal:"));
        this.nextGoalText.visible = false;
        addChild(this.nextGoalText);
        this.nextGoalDetailText = new TextFieldDisplayConcrete().setSize(14).setColor(0xFFFFFF);
        this.nextGoalDetailText.filters = [_local1];
        this.nextGoalDetailText.visible = false;
        addChild(this.nextGoalDetailText);
        this.questCompletedStars = new StarsView();
        addChild(this.questCompletedStars);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        this.character = this.classesModel.getSelected();
        this.nextSkinTimer.addEventListener(TimerEvent.TIMER, this.delayedFocusSet);
        this.setCharacterData();
        this.onFocusSet();
    }

    public function destroy(e:Event):void {
        this.nextSkinTimer.removeEventListener(TimerEvent.TIMER, this.delayedFocusSet);
        this.setWalkingAnimation(null);
        this.disposeAnimations();
    }

    private function setCharacterData():void {
        var _local1:int = this.playerModel.charList.bestFame(this.character.id);
        var _local2:int = FameUtil.numStars(_local1);
        this.setData(this.character.name, this.character.description, _local2, this.playerModel.charList.bestLevel(this.character.id), _local1);
        var _local3:int = FameUtil.nextStarFame(_local1, 0);
        this.setNextGoal(this.character.name, _local3);
    }

    public function onFocusSet(_arg1:CharacterSkin = null):void {
        _arg1 = ((_arg1) || (this.character.skins.getSelectedSkin()));
        this.nextSkin = _arg1;
        this.nextSkinTimer.start();
    }

    private function delayedFocusSet(_arg1:TimerEvent):void {
        var _local2:Animation = (this.skins[this.nextSkin.id] = ((this.skins[this.nextSkin.id]) || (this.factory.makeWalkingIcon(this.nextSkin.template, ((this.nextSkin.is16x16) ? 100 : 200)))));
        this.setWalkingAnimation(_local2);
    }

    private function disposeAnimations():void {
        var _local1:String;
        var _local2:Animation;
        for (_local1 in this.skins) {
            _local2 = this.skins[_local1];
            _local2.dispose();
            delete this.skins[_local1];
        }
    }

    public function setData(_arg1:String, _arg2:String, _arg3:int, _arg4:int, _arg5:int):void {
        this.classNameText.setStringBuilder(new LineBuilder().setParams(_arg1));
        this.classDescriptionText.setStringBuilder(new LineBuilder().setParams(_arg2));
        this.levelText.setStringBuilder(new StaticStringBuilder(String(_arg4)));
        this.fameText.setStringBuilder(new StaticStringBuilder(String(_arg5)));
    }

    public function setNextGoal(_arg1:String, _arg2:int):void {
        this.showNextGoal = !((_arg2 == -1));
        if (this.showNextGoal) {
            this.nextGoalDetailText.setStringBuilder(new LineBuilder().setParams("Earn {goal} Fame with {quest}", {
                "goal": String(_arg2),
                "quest": _arg1
            }));
            this.nextGoalDetailText.y = (this.nextGoalText.y + this.nextGoalText.height);
            this.nextGoalDetailText.x = ((WIDTH / 2) - (this.nextGoalDetailText.width / 2));
            this.waiter.push(this.nextGoalDetailText.textChanged);
            this.waiter.push(this.nextGoalText.textChanged);
        }
    }

    public function setWalkingAnimation(_arg1:Animation):void {
        ((this.animation) && (this.removeAnimation(this.animation)));
        this.animation = _arg1;
        ((this.animation) && (this.addAnimation(this.animation)));
        this.layout();
    }

    private function removeAnimation(_arg1:Animation):void {
        _arg1.stop();
        this.animContainer.removeChild(_arg1);
    }

    private function addAnimation(_arg1:Animation):void {
        this.animContainer.addChild(_arg1);
        _arg1.start();
    }

    private function layout():void {
        this.classNameText.x = ((WIDTH / 2) - (this.classNameText.width / 2));
        this.classNameText.y = 110;
        this.classDescriptionText.y = ((this.classNameText.y + this.classNameText.height) + 5);
        this.classDescriptionText.x = ((WIDTH / 2) - (this.classDescriptionText.width / 2));
        this.questCompletionText.y = ((this.classDescriptionText.y + this.classDescriptionText.height) + 20);
        this.questCompletionText.x = (RIGHT_JUSTIFICATION_STATS - this.questCompletionText.width);
        this.questCompletedStars.y = (this.questCompletionText.y - 2);
        this.questCompletedStars.x = (RIGHT_JUSTIFICATION_STATS + 18);
        this.levelTitleText.y = ((this.questCompletionText.y + this.questCompletionText.height) + 5);
        this.levelTitleText.x = (RIGHT_JUSTIFICATION_STATS - this.levelTitleText.width);
        this.levelText.y = this.levelTitleText.y;
        this.levelText.x = (RIGHT_JUSTIFICATION_STATS + 18);
        this.fameTitleText.y = ((this.levelTitleText.y + this.levelTitleText.height) + 5);
        this.fameTitleText.x = (RIGHT_JUSTIFICATION_STATS - this.fameTitleText.width);
        this.fameText.y = this.fameTitleText.y;
        this.fameText.x = (RIGHT_JUSTIFICATION_STATS + 18);
        this.fameIcon.y = (this.fameTitleText.y - 2);
        this.fameIcon.x = ((this.fameText.x + this.fameText.width) + 3);
        this.nextGoalText.y = ((this.fameTitleText.y + this.fameTitleText.height) + 17);
        this.nextGoalText.x = ((WIDTH / 2) - (this.nextGoalText.width / 2));
        this.nextGoalText.visible = this.showNextGoal;
        this.nextGoalDetailText.y = (this.nextGoalText.y + this.nextGoalText.height);
        this.nextGoalDetailText.x = ((WIDTH / 2) - (this.nextGoalDetailText.width / 2));
        this.nextGoalDetailText.visible = this.showNextGoal;
    }


}
}
