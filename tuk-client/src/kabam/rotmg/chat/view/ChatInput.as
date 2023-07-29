package kabam.rotmg.chat.view {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.ui.Keyboard;

import kabam.rotmg.chat.model.ChatModel;
import kabam.rotmg.chat.model.ChatShortcutModel;
import kabam.rotmg.chat.model.TellModel;
import kabam.rotmg.text.model.FontModel;
import kabam.rotmg.text.model.TextAndMapProvider;

public class ChatInput extends Sprite {

    public var model:ChatModel = Global.chatModel;
    public var textAndMapProvider:TextAndMapProvider = Global.textAndMapProvider;
    public var fontModel:FontModel = Global.fontModel;
    public var tellModel:TellModel = Global.tellModel;
    public var chatShortcutModel:ChatShortcutModel = Global.chatShortcutModel;

    private var input:TextField;
    private var enteredText:Boolean;

    public function ChatInput() {
        visible = false;
        this.enteredText = false;
        addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    public function setup(_arg1:ChatModel, _arg2:TextField):void {
        addChild((this.input = _arg2));
        _arg2.width = (_arg1.bounds.width - 2);
        _arg2.height = _arg1.lineHeight;
        _arg2.y = (_arg1.bounds.height - _arg1.lineHeight);
    }

    public function activate(_arg1:String, _arg2:Boolean):void {
        this.enteredText = false;
        if (_arg1 != null) {
            this.input.text = _arg1;
        }
        var _local3:int = ((_arg1) ? _arg1.length : 0);
        this.input.setSelection(_local3, _local3);
        if (_arg2) {
            this.activateEnabled();
        }
        else {
            this.activateDisabled();
        }
        visible = true;
    }

    public function deactivate():void {
        this.enteredText = false;
        removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
        stage.removeEventListener(KeyboardEvent.KEY_UP, this.onTextChange);
        visible = false;
        ((stage) && ((stage.focus = null)));
    }

    public function hasEnteredText():Boolean {
        return (this.enteredText);
    }

    private function activateEnabled():void {
        this.input.type = TextFieldType.INPUT;
        this.input.border = true;
        this.input.selectable = true;
        this.input.maxChars = 128;
        this.input.borderColor = 0xFFFFFF;
        this.input.height = 18;
        this.input.filters = [new GlowFilter(0, 1, 3, 3, 2, 1)];
        addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
        stage.addEventListener(KeyboardEvent.KEY_UP, this.onTextChange);
        ((stage) && ((stage.focus = this.input)));
    }

    private function onTextChange(_arg1:Event):void {
        this.enteredText = true;
    }

    private function activateDisabled():void {
        this.input.type = TextFieldType.DYNAMIC;
        this.input.border = false;
        this.input.selectable = false;
        this.input.filters = [new GlowFilter(0, 1, 3, 3, 2, 1)];
        this.input.height = 18;
        removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
        stage.removeEventListener(KeyboardEvent.KEY_UP, this.onTextChange);
    }

    public function initialize(e:Event):void {
        this.setup(this.model, this.makeTextfield());
    }

    private function onDeactivate():void {
        Global.onShowChatInput(false, "");
        this.tellModel.resetRecipients();
    }

    private function onMessage(_arg1:String):void {
        Global.parseChatMessage(_arg1);
        Global.onShowChatInput(false, "");
    }

    public function onShowChatInput(_arg1:Boolean, _arg2:String):void {
        if (_arg1) {
            this.activate(_arg2, true);
        }
        else {
            this.deactivate();
        }
        if (!_arg1) {
            this.tellModel.resetRecipients();
        }
    }

    private function makeTextfield():TextField {
        var _local1:TextField = this.textAndMapProvider.getTextField();
        this.fontModel.apply(_local1, 14, 0xFFFFFF, true);
        return (_local1);
    }

    private function onKeyUp(_arg1:KeyboardEvent):void {
        if (_arg1.keyCode == Keyboard.ENTER) {
            if (this.input.text != "") {
                this.onMessage(this.input.text);
            }
            else {
                this.onDeactivate();
            }
            _arg1.stopImmediatePropagation();
            return;
        }
        if (((this.visible) && ((((_arg1.keyCode == this.chatShortcutModel.getTellShortcut())) || ((((this.stage.focus == null)) || (viewDoesntHaveFocus()))))))) {
            this.processKeyUp(_arg1);
        }
    }

    private function viewDoesntHaveFocus():Boolean {
        return (((!((this.stage.focus.parent == this))) && (!((this.stage.focus == this)))));
    }

    private function processKeyUp(_arg1:KeyboardEvent):void {
        _arg1.stopImmediatePropagation();
        var _local2:uint = _arg1.keyCode;
        if (_local2 == this.chatShortcutModel.getCommandShortcut()) {
            this.activate("/", true);
        }
        else {
            if (_local2 == this.chatShortcutModel.getChatShortcut()) {
                this.activate(null, true);
            }
            else {
                if (_local2 == this.chatShortcutModel.getGuildShortcut()) {
                    this.activate("/g ", true);
                }
                else {
                    if (_local2 == this.chatShortcutModel.getTellShortcut()) {
                        this.handleTell();
                    }
                }
            }
        }
    }

    private function handleTell():void {
        if (!this.hasEnteredText()) {
            this.activate((("/tell " + this.tellModel.getNext()) + " "), true);
        }
    }


}
}
