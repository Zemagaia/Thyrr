package kabam.rotmg.chat.view {
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.chat.model.ChatModel;
import kabam.rotmg.chat.model.ChatShortcutModel;
import kabam.rotmg.chat.model.TellModel;
import kabam.rotmg.ui.model.HUDModel;

public class Chat extends Sprite {

    private static const SCROLL_BUFFER_SIZE:int = 10;

    public var account:Account = Global.account;
    public var shortcuts:ChatShortcutModel = Global.chatShortcutModel;
    public var tellModel:TellModel = Global.tellModel;
    public var hudModel:HUDModel = Global.hudModel;
    public var list:ChatList;

    private var scrollDirection:int;
    private var scrollBuffer:int;
    private var listenersAdded:Boolean = false;
    private var input:ChatInput = Global.chatInput;
    private var model:ChatModel = Global.chatModel;
    private var stage_:Stage;

    public function Chat() {
        mouseEnabled = true;
        mouseChildren = true;
        this.list = new ChatList();
        addChild(this.list);
        addEventListener(Event.ADDED_TO_STAGE, initialize);
        addEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

    public function initialize(e:Event):void {
        this.x = this.model.bounds.left;
        this.y = this.model.bounds.top;
        this.setup(this.model);
        stage_ = this.stage;
        this.addListeners();
    }

    public function onOpenDialog(_arg1:Sprite):void {
        this.removeListeners();
    }

    public function onCloseDialog():void {
        this.addListeners();
    }

    public function onShowChatInput(focus:Boolean, ignored:String):void {
        if (focus) {
            this.stage_.focus = this;
            this.listenersAdded = false;
        }
        else {
            this.addListeners();
            this.stage_.focus = null;
        }
    }

    public function destroy(e:Event):void {
        this.removeListeners();
        this.stage_ = null;
    }

    private function addListeners():void {
        if (!this.listenersAdded && this.stage_ != null) {
            this.stage_.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
            this.stage_.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
            this.listenersAdded = true;
        }
    }

    private function removeListeners():void {
        if (this.listenersAdded && this.stage_ != null) {
            this.stage_.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
            this.stage_.removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
            this.stage_.removeEventListener(Event.ENTER_FRAME, this.iterate);
            this.listenersAdded = false;
        }
    }

    private function onKeyDown(_arg1:KeyboardEvent):void {
        if (_arg1.keyCode == this.shortcuts.getScrollUp()) {
            this.setupScroll(-1);
        }
        else {
            if (_arg1.keyCode == this.shortcuts.getScrollDown()) {
                this.setupScroll(1);
            }
        }
    }

    private function setupScroll(_arg1:int):void {
        this.scrollDirection = _arg1;
        Global.chatScrollList(_arg1);
        this.scrollBuffer = 0;
        this.addEventListener(Event.ENTER_FRAME, this.iterate);
    }

    private function iterate(_arg1:Event):void {
        if (this.scrollBuffer++ >= SCROLL_BUFFER_SIZE) {
            Global.chatScrollList(this.scrollDirection);
        }
    }

    private function onKeyUp(_arg1:KeyboardEvent):void {
        if (this.listenersAdded) {
            this.checkForInputTrigger(_arg1.keyCode);
        }
        if ((((_arg1.keyCode == this.shortcuts.getScrollUp())) || ((_arg1.keyCode == this.shortcuts.getScrollDown())))) {
            this.removeEventListener(Event.ENTER_FRAME, this.iterate);
        }
    }

    private function checkForInputTrigger(_arg1:uint):void {
        if ((((this.stage_.focus == null)) || ((_arg1 == this.shortcuts.getTellShortcut())))) {
            if (_arg1 == this.shortcuts.getCommandShortcut()) {
                this.triggerOrPromptRegistration("/");
            }
            else {
                if (_arg1 == this.shortcuts.getChatShortcut()) {
                    this.triggerOrPromptRegistration("");
                }
                else {
                    if (_arg1 == this.shortcuts.getGuildShortcut()) {
                        this.triggerOrPromptRegistration("/g ");
                    }
                    else {
                        if (_arg1 == this.shortcuts.getTellShortcut()) {
                            this.triggerOrPromptRegistration("/tell " + (this.tellModel.getNext() == "" ? "" : " "));
                        }
                    }
                }
            }
        }
    }

    private function triggerOrPromptRegistration(_arg1:String):void {
        Global.onShowChatInput(true, _arg1);
    }

    public function setup(_arg1:ChatModel):void {
        this.model = _arg1;
        this.y = (Main.DefaultHeight - _arg1.bounds.height);
        this.list.y = _arg1.bounds.height;
        this.addChatInput();
    }

    private function addChatInput():void {
        this.input = Global.chatInput;
        addChild(this.input);
    }


}
}
