package com.company.assembleegameclient.ui.options {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.screens.TitleMenuOption;
import com.company.assembleegameclient.sound.Music;
import com.company.assembleegameclient.sound.SFX;
import com.company.assembleegameclient.ui.StatusBar;
import com.company.util.AssetLibrary;
import com.company.util.KeyCodes;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.text.TextFieldAutoSize;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.ui.MouseCursorData;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;
import kabam.rotmg.ui.UIUtils;

public class Options extends Sprite {

    private static const TABS:Vector.<String> = new <String>["Controls", "Hot Keys", "Chat", "Graphics", "Sound", "Misc"];
    public static const Y_POSITION:int = WebMain.DefaultHeight - 50;
    public static const CHAT_COMMAND:String = "chatCommand";
    public static const CHAT:String = "chat";
    public static const TELL:String = "tell";
    public static const GUILD_CHAT:String = "guildChat";
    public static const SCROLL_CHAT_UP:String = "scrollChatUp";
    public static const SCROLL_CHAT_DOWN:String = "scrollChatDown";

    private static var registeredCursors:Vector.<String> = new <String>[];

    private var gs_:GameSprite;
    private var continueButton_:TitleMenuOption;
    private var resetToDefaultsButton_:TitleMenuOption;
    private var homeButton_:TitleMenuOption;
    private var tabs_:Vector.<OptionsTabTitle>;
    private var selected_:OptionsTabTitle = null;
    private var options_:Vector.<Sprite>;

    public function Options(_arg1:GameSprite) {
        var _local2:TextFieldDisplayConcrete;
        var _local6:OptionsTabTitle;
        this.tabs_ = new Vector.<OptionsTabTitle>();
        this.options_ = new Vector.<Sprite>();
        super();
        this.gs_ = _arg1;
        graphics.clear();
        graphics.beginFill(0x2B2B2B, 0.8);
        graphics.drawRect(0, 0, WebMain.DefaultWidth, WebMain.DefaultHeight);
        graphics.endFill();
        graphics.lineStyle(1, 0x5E5E5E);
        graphics.moveTo(0, 100);
        graphics.lineTo(WebMain.DefaultWidth, 100);
        graphics.lineStyle();
        _local2 = new TextFieldDisplayConcrete().setSize(36).setColor(0xFFFFFF);
        _local2.setBold(true);
        _local2.setStringBuilder(new LineBuilder().setParams("Options"));
        _local2.setAutoSize(TextFieldAutoSize.CENTER);
        _local2.filters = [new DropShadowFilter(0, 0, 0)];
        _local2.x = ((WebMain.DefaultWidth / 2) - (_local2.width / 2));
        _local2.y = 8;
        addChild(_local2);
        this.continueButton_ = new TitleMenuOption("continue", 36, 24);
        this.continueButton_.addEventListener(MouseEvent.CLICK, this.onContinueClick);
        addChild(this.continueButton_);
        this.resetToDefaultsButton_ = new TitleMenuOption("reset to defaults", 22, 16);
        this.resetToDefaultsButton_.addEventListener(MouseEvent.CLICK, this.onResetToDefaultsClick);
        addChild(this.resetToDefaultsButton_);
        this.homeButton_ = new TitleMenuOption("back to home", 22, 16);
        this.homeButton_.addEventListener(MouseEvent.CLICK, this.onHomeClick);
        addChild(this.homeButton_);
        if (TABS.indexOf("Extra") == -1)
            TABS.push("Extra");
        var _local3:int = 14;
        var _local4:int = 0;
        while (_local4 < TABS.length) {
            _local6 = new OptionsTabTitle(TABS[_local4]);
            _local6.x = _local3;
            _local6.y = 70;
            addChild(_local6);
            _local6.addEventListener(MouseEvent.CLICK, this.onTabClick);
            this.tabs_.push(_local6);
            _local3 = (_local3 + 90);
            _local4++;
        }
        addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }

    private static function makeOnOffLabels():Vector.<StringBuilder> {
        return (new <StringBuilder>[makeLineBuilder("On"), makeLineBuilder("Off")]);
    }

    private static function makeHighLowLabels():Vector.<StringBuilder> {
        return (new <StringBuilder>[new StaticStringBuilder("High"), new StaticStringBuilder("Low")]);
    }

    private static function makeStarSelectLabels():Vector.<StringBuilder> {
        return (new <StringBuilder>[new StaticStringBuilder("Off"), new StaticStringBuilder("1"), new StaticStringBuilder("2"), new StaticStringBuilder("3"), new StaticStringBuilder("5"), new StaticStringBuilder("10")]);
    }

    private static function makeCursorSelectLabels():Vector.<StringBuilder> {
        return (new <StringBuilder>[new StaticStringBuilder("Off"), new StaticStringBuilder("Crosshair 1"), new StaticStringBuilder("Corner 1"), new StaticStringBuilder("Flower 1"), new StaticStringBuilder("Orbit 1"), new StaticStringBuilder("Crosshair 2"), new StaticStringBuilder("Corner 2"), new StaticStringBuilder("Flower 2"), new StaticStringBuilder("Orbit 2"), new StaticStringBuilder("Crosshair 3"), new StaticStringBuilder("Corner 3"), new StaticStringBuilder("Flower 3"), new StaticStringBuilder("Orbit 3"), new StaticStringBuilder("Crosshair 4"), new StaticStringBuilder("Corner 4"), new StaticStringBuilder("Flower 4"), new StaticStringBuilder("Orbit 4")]);
    }

    private static function makeLineBuilder(_arg1:String):LineBuilder {
        return (new LineBuilder().setParams(_arg1));
    }

    private static function onUIQualityToggle():void {
        UIUtils.toggleQuality(Parameters.data_.uiQuality);
    }

    public static function refreshCursor():void {
        var _local1:MouseCursorData;
        var _local2:Vector.<BitmapData>;
        if (((!((Parameters.data_.cursorSelect == MouseCursor.AUTO))) && ((registeredCursors.indexOf(Parameters.data_.cursorSelect) == -1)))) {
            _local1 = new MouseCursorData();
            _local1.hotSpot = new Point(15, 15);
            _local2 = new Vector.<BitmapData>(1, true);
            _local2[0] = AssetLibrary.getImageFromSet("cursorsEmbed", int(Parameters.data_.cursorSelect));
            _local1.data = _local2;
            Mouse.registerCursor(Parameters.data_.cursorSelect, _local1);
            registeredCursors.push(Parameters.data_.cursorSelect);
        }
        Mouse.cursor = Parameters.data_.cursorSelect;
    }

    private static function makeDegreeOptions():Vector.<StringBuilder> {
        return (new <StringBuilder>[new StaticStringBuilder("45°"), new StaticStringBuilder("0°")]);
    }

    private static function onDefaultCameraAngleChange():void {
        Parameters.data_.cameraAngle = Parameters.data_.defaultCameraAngle;
        Parameters.save();
    }


    private function onContinueClick(_arg1:MouseEvent):void {
        this.close();
    }

    private function onResetToDefaultsClick(_arg1:MouseEvent):void {
        var _local3:BaseOption;
        var _local2:int;
        while (_local2 < this.options_.length) {
            _local3 = (this.options_[_local2] as BaseOption);
            if (_local3 != null) {
                delete Parameters.data_[_local3.paramName_];
            }
            _local2++;
        }
        Parameters.setDefaults();
        Parameters.save();
        this.refresh();
    }

    private function onHomeClick(_arg1:MouseEvent):void {
        this.close();
        this.gs_.closed.dispatch();
    }

    private function onTabClick(_arg1:MouseEvent):void {
        var _local2:OptionsTabTitle = (_arg1.currentTarget as OptionsTabTitle);
        this.setSelected(_local2);
    }

    private function setSelected(_arg1:OptionsTabTitle):void {
        if (_arg1 == this.selected_) {
            return;
        }
        if (this.selected_ != null) {
            this.selected_.setSelected(false);
        }
        this.selected_ = _arg1;
        this.selected_.setSelected(true);
        this.removeOptions();
        switch (this.selected_.text_) {
            case "Controls":
                this.addControlsOptions();
                return;
            case "Hot Keys":
                this.addHotKeysOptions();
                return;
            case "Chat":
                this.addChatOptions();
                return;
            case "Graphics":
                this.addGraphicsOptions();
                return;
            case "Sound":
                this.addSoundOptions();
                return;
            case "Misc":
                this.addMiscOptions();
                return;
            case "Extra":
                this.addExtraOptions();
                return;
        }
    }

    private function onAddedToStage(_arg1:Event):void {
        this.continueButton_.x = (WebMain.DefaultWidth / 2);
        this.continueButton_.y = Y_POSITION;
        this.resetToDefaultsButton_.x = 20;
        this.resetToDefaultsButton_.y = Y_POSITION;
        this.homeButton_.x = (WebMain.DefaultWidth - 20);
        this.homeButton_.y = Y_POSITION;
        if (Capabilities.playerType == "Desktop") {
            Parameters.data_.fullscreenMode = (stage.displayState == "fullScreenInteractive");
            Parameters.save();
        }
        this.setSelected(this.tabs_[0]);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown, false, 1);
        stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp, false, 1);
    }

    private function onRemovedFromStage(_arg1:Event):void {
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown, false);
        stage.removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp, false);
    }

    private function onKeyDown(_arg1:KeyboardEvent):void {
        if ((((Capabilities.playerType == "Desktop")) && ((_arg1.keyCode == KeyCodes.ESCAPE)))) {
            Parameters.data_.fullscreenMode = false;
            Parameters.save();
            this.refresh();
        }
        if (_arg1.keyCode == Parameters.data_.options) {
            this.close();
        }
        _arg1.stopImmediatePropagation();
    }

    private function close():void {
        stage.focus = null;
        parent.removeChild(this);
    }

    private function onKeyUp(_arg1:KeyboardEvent):void {
        _arg1.stopImmediatePropagation();
    }

    private function removeOptions():void {
        var _local1:Sprite;
        for each (_local1 in this.options_) {
            removeChild(_local1);
        }
        this.options_.length = 0;
    }

    private function addControlsOptions():void {
        this.addOptionAndPosition(new KeyMapper("moveUp", "Move Up", "Key to move character up"));
        this.addOptionAndPosition(new KeyMapper("moveLeft", "Move Left", "Key to move character to the left"));
        this.addOptionAndPosition(new KeyMapper("moveDown", "Move Down", "Key to move character down"));
        this.addOptionAndPosition(new KeyMapper("moveRight", "Move Right", "Key to move character to the right"));
        this.addOptionAndPosition(this.makeAllowCameraRotation());
        this.addOptionAndPosition(this.makeAllowMiniMapRotation());
        this.addOptionAndPosition(new KeyMapper("rotateLeft", "Rotate Left", "Key to rotate the camera to the left", !(Parameters.data_.allowRotation)));
        this.addOptionAndPosition(new KeyMapper("rotateRight", "Rotate Right", "Key to rotate the camera to the right", !(Parameters.data_.allowRotation)));
        this.addOptionAndPosition(new KeyMapper("useSpecial", "Use Special Ability", "This key will activate your special ability"));
        this.addOptionAndPosition(new KeyMapper("autofireToggle", "Autofire Toggle", "This key will toggle autofire"));
        this.addOptionAndPosition(new KeyMapper("toggleHPBar", "Toggle Status Bars", "Toggle self HP and MP bars and enemy and other players' HP bars"));
        this.addOptionAndPosition(new KeyMapper("resetToDefaultCameraAngle", "Reset To Default Camera Angle", "This key will reset the camera angle to the default angle"));
        this.addOptionAndPosition(new KeyMapper("togglePerformanceStats", "Toggle Performance Stats", "This key will toggle a display of fps and memory usage"));
        this.addOptionAndPosition(new KeyMapper("toggleCentering", "Toggle Centering of Player", "This key will toggle the position between centered and offset"));
        this.addOptionAndPosition(new KeyMapper("interact", "Interact/Buy", "This key will allow you to enter a portal or buy an item"));
        this.addOptionAndPosition(new KeyMapper("secondAbility", "Use Secondary Ability", "This key will activate your secondary special ability if available"));
        this.addOptionAndPosition(new KeyMapper("skillTreeOffensive", "Use Offensive Ability", "This key will activate your skill tree's offensive ability if available"));
        this.addOptionAndPosition(new KeyMapper("skillTreeDefensive", "Use Defensive Ability", "This key will activate your skill tree's defensive ability if available"));
    }

    private function makeAllowCameraRotation():ChoiceOption {
        return (new ChoiceOption("allowRotation", makeOnOffLabels(), [true, false], "Allow Camera Rotation", "Toggles whether to allow for camera rotation", this.onAllowRotationChange));
    }

    private function makeAllowMiniMapRotation():ChoiceOption {
        return (new ChoiceOption("allowMiniMapRotation", makeOnOffLabels(), [true, false], "Allow mini map rotation", "Toggles whether to allow for mini map rotation", null));
    }

    private function onAllowRotationChange():void {
        var _local2:KeyMapper;
        var _local1:int;
        while (_local1 < this.options_.length) {
            _local2 = (this.options_[_local1] as KeyMapper);
            if (_local2 != null) {
                if ((((_local2.paramName_ == "rotateLeft")) || ((_local2.paramName_ == "rotateRight")))) {
                    _local2.setDisabled(!(Parameters.data_.allowRotation));
                }
            }
            _local1++;
        }
    }

    private function addHotKeysOptions():void {
        this.addOptionAndPosition(new KeyMapper("useHealthPotion", "Use Health Potion", "This key will use health potions if available"));
        this.addOptionAndPosition(new KeyMapper("useMagicPotion", "Use Magic Potion", "This key will use magic potions if available"));
        this.addInventoryOptions();
        this.addOptionAndPosition(new KeyMapper("miniMapZoomIn", "Mini-Map Zoom In", "This key will zoom in the minimap"));
        this.addOptionAndPosition(new KeyMapper("miniMapZoomOut", "Mini-Map Zoom Out", "This key will zoom out the minimap"));
        this.addOptionAndPosition(new KeyMapper("escapeToRealm", "Go to Realm", "This key will instantly bring you to the Realm or teleport you to a safe position if you are already there"));
        this.addOptionAndPosition(new KeyMapper("options", "Show Options", "This key will bring up the options screen"));
        this.addOptionAndPosition(new KeyMapper("switchTabs", "Switch Tabs", "This key will flip through your tabs."));
        this.addOptionAndPosition(new KeyMapper("GPURenderToggle", "Hardware Acc. Hotkey", "Quickly enable or disable hardware acceleration."));
        this.addOptionsChoiceOption();
        if (this.isAirApplication()) {
            this.addOptionAndPosition(new KeyMapper("toggleFullscreen", "Toggle Fullscreen Mode", "Toggle whether the game is run in a window or fullscreen"));
        }
    }

    public function isAirApplication():Boolean {
        return ((Capabilities.playerType == "Desktop"));
    }

    public function addOptionsChoiceOption():void {
        var _local1:String = (((Capabilities.os.split(" ")[0] == "Mac")) ? "Command" : "Ctrl");
        var _local2:ChoiceOption = new ChoiceOption("inventorySwap", makeOnOffLabels(), [true, false], "Switch item to/from backpack.", "", null);
        _local2.setTooltipText(new LineBuilder().setParams("Hold the {key} key and click on an item to swap it between your inventory and your backpack.", {"key": _local1}));
        this.addOptionAndPosition(_local2);
    }

    public function addInventoryOptions():void {
        var _local2:KeyMapper;
        var _local1:int = 1;
        while (_local1 <= 8) {
            _local2 = new KeyMapper(("useInvSlot" + _local1), "", "");
            _local2.setDescription(new LineBuilder().setParams("Use Inventory Slot {n}", {"n": _local1}));
            _local2.setTooltipText(new LineBuilder().setParams("Use item in inventory slot {n}", {"n": _local1}));
            this.addOptionAndPosition(_local2);
            _local1++;
        }
    }

    private function addChatOptions():void {
        this.addOptionAndPosition(new KeyMapper(CHAT, "Activate Chat", "This key will bring up the chat input box"));
        this.addOptionAndPosition(new KeyMapper(CHAT_COMMAND, "Start Chat Command", "This key will bring up the chat with a '/' prepended to allow for commands such as /who, /ignore, etc."));
        this.addOptionAndPosition(new KeyMapper(TELL, "Begin Tell", "This key will bring up a tell (private message) in the chat input box"));
        this.addOptionAndPosition(new KeyMapper(GUILD_CHAT, "Begin Guild Chat", "This key will bring up a guild chat in the chat input box"));
        this.addOptionAndPosition(new ChoiceOption("filterLanguage", makeOnOffLabels(), [true, false], "Filter Offensive Language", "This toggles whether offensive language filtering will be attempted", null));
        this.addOptionAndPosition(new KeyMapper(SCROLL_CHAT_UP, "Scroll Chat Up", "This key will scroll up to older messages in the chat buffer"));
        this.addOptionAndPosition(new KeyMapper(SCROLL_CHAT_DOWN, "Scroll Chat Down", "This key will scroll down to newer messages in the chat buffer"));
        this.addOptionAndPosition(new ChoiceOption("forceChatQuality", makeOnOffLabels(), [true, false], "Force High Quality Chat Text", "Even when Flash Player is set to low quality, force chat text to be in high quality.", null));
        this.addOptionAndPosition(new ChoiceOption("hidePlayerChat", makeOnOffLabels(), [true, false], "Hide Chat Window", "Hides the chat window when turned ON.", null));
        this.addOptionAndPosition(new ChoiceOption("chatStarRequirement", makeStarSelectLabels(), [0, 1, 2, 3, 5, 10], "Star requirement", "Only see chat from players who have earned at least this amount of stars. May help with chat spam.", null));
        this.addOptionAndPosition(new ChoiceOption("chatAll", makeOnOffLabels(), [true, false], "Player Chat", "Toggle Player chat ON / OFF. Does not hide System messages. NOTE: This also affects Whisper and Guild Chat options.", this.onAllChatEnabled));
        this.addOptionAndPosition(new ChoiceOption("chatWhisper", makeOnOffLabels(), [true, false], "Whisper Chat", "Toggle Whisper chat ON or OFF. Turn this ON, Player Chat OFF, and Guild Chat OFF to only display Whispers.  May help with chat spam.", this.onAllChatDisabled));
        this.addOptionAndPosition(new ChoiceOption("chatGuild", makeOnOffLabels(), [true, false], "Guild Chat", "Toggle Guild chat ON or OFF. Turn this ON, Player Chat OFF, and Whisper Chat OFF to only display chats from Guild members.", this.onAllChatDisabled));
        this.addOptionAndPosition(new ChoiceOption("chatTrade", makeOnOffLabels(), [true, false], "Trade Requests", "When turned OFF you will not see any incoming Trade requests. You can still initiate Trades with other players.", null));
    }

    private function onAllChatDisabled():void {
        var _local2:ChoiceOption;
        Parameters.data_.chatAll = false;
        var _local1:int;
        while (_local1 < this.options_.length) {
            _local2 = (this.options_[_local1] as ChoiceOption);
            if (_local2 != null) {
                switch (_local2.paramName_) {
                    case "chatAll":
                        _local2.refreshNoCallback();
                        break;
                }
            }
            _local1++;
        }
    }

    private function onAllChatEnabled():void {
        var _local2:ChoiceOption;
        Parameters.data_.hidePlayerChat = false;
        Parameters.data_.chatWhisper = true;
        Parameters.data_.chatGuild = true;
        var _local1:int;
        while (_local1 < this.options_.length) {
            _local2 = (this.options_[_local1] as ChoiceOption);
            if (_local2 != null) {
                switch (_local2.paramName_) {
                    case "hidePlayerChat":
                    case "chatWhisper":
                    case "chatGuild":
                        _local2.refreshNoCallback();
                        break;
                }
            }
            _local1++;
        }
    }

    private function addExtraOptions():void {
        this.addOptionAndPosition(new ChoiceOption("allyShots", makeOnOffLabels(), [true, false], "Disable ally shots", "Disables showing and rendering ally shots", null));
        this.addOptionAndPosition(new ChoiceOption("allyDamage", makeOnOffLabels(), [true, false], "Disable ally damage", "Disables damage dealt to and by allies", null));
        this.addOptionAndPosition(new ChoiceOption("allyNotifications", makeOnOffLabels(), [true, false], "Disable ally notifications", "Disables notifications targeted at other players", null));
        this.addOptionAndPosition(new ChoiceOption("disableAllyParticles", makeOnOffLabels(), [true, false], "Disable ally particles", "Disable particles produced by allies", null));
        this.addOptionAndPosition(new ChoiceOption("hpInfo", makeOnOffLabels(), [true, false], "HP info", "Toggles HP left on enemies and players damage text", null));
        this.addOptionAndPosition(new ChoiceOption("dynamicColor", makeOnOffLabels(), [true, false], "Dynamic damage color", "Toggle dynamic damage color text", null));
        this.addOptionAndPosition(new ChoiceOption("outlineProj", makeOnOffLabels(), [true, false], "Toggle projectile outline", "Toggle whether to outline projectiles", null));
        this.addOptionAndPosition(new ChoiceOption("outlineTooltips", makeOnOffLabels(), [true, false], "Toggle tooltip outline", "Toggle whether to outline equipment tooltips", null));
        this.addOptionAndPosition(new ChoiceOption("showDamageCounter", makeOnOffLabels(), [true, false], "Damage Counter", "Show percentage of damage dealt on bosses", null));
        this.addOptionAndPosition(new KeyMapper("reconVault", "Vault", "Connects you to Vault"));
        this.addOptionAndPosition(new KeyMapper("reconGuild", "Guild Hall", "Connects you to Guild Hall"));
    }

    private function addGraphicsOptions():void {
        var hwaDesc:String;
        var hwaColor:Number;
        this.addOptionAndPosition(new ChoiceOption("defaultCameraAngle", makeDegreeOptions(), [((7 * Math.PI) / 4), 0], "Default Camera Angle", "This toggles the default camera angle", onDefaultCameraAngleChange));
        this.addOptionAndPosition(new ChoiceOption("centerOnPlayer", makeOnOffLabels(), [true, false], "Center On Player", "This toggles whether the player is centered or offset", null));
        this.addOptionAndPosition(new ChoiceOption("showProtips", makeOnOffLabels(), [true, false], "Show Tips", "This toggles whether a tip is displayed when you join a new game", null));
        this.addOptionAndPosition(new ChoiceOption("drawShadows", makeOnOffLabels(), [true, false], "Draw Shadows", "This toggles whether to draw shadows", null));
        this.addOptionAndPosition(new ChoiceOption("textBubbles", makeOnOffLabels(), [true, false], "Draw Text Bubbles", "This toggles whether to draw text bubbles", null));
        this.addOptionAndPosition(new ChoiceOption("showTradePopup", makeOnOffLabels(), [true, false],"Show Trade Request Panel", "This toggles whether to show trade requests in the lower-right panel or just in chat.", null));
        this.addOptionAndPosition(new ChoiceOption("showGuildInvitePopup", makeOnOffLabels(), [true, false], "Show Guild Invite Panel", "This toggles whether to show guild invites in the lower-right panel or just in chat.", null));
        this.addOptionAndPosition(new ChoiceOption("cursorSelect", makeCursorSelectLabels(), [MouseCursor.AUTO, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"], "Custom Cursor", "Click here to change the mouse cursor. May help with aiming.", refreshCursor));
        this.addOptionAndPosition(new ChoiceOption("scaleChat", makeOnOffLabels(), [true, false], "Scale Chat", "Makes the chat box less intrusive.", null));
        if (!Parameters.GPURenderError) {
            hwaDesc = "Enables hardware acceleration. This reduces load on the CPU and may increase performance.";
            hwaColor = 0xFFFFFF;
        }
        else {
            hwaDesc = "Hardware Acceleration could not be enabled.  Please check flash player settings (right click on title screen).";
            hwaColor = 16724787;
        }
        this.addOptionAndPosition(new ChoiceOption("GPURender", makeOnOffLabels(), [true, false], "Hardware Acceleration", hwaDesc, null, hwaColor));
        if (Capabilities.playerType == "Desktop") {
            this.addOptionAndPosition(new ChoiceOption("fullscreenMode", makeOnOffLabels(), [true, false], "Fullscreen Mode", "This toggles whether the game is run in fullscreen mode.", this.onFullscreenChange));
        }
        this.addOptionAndPosition(new ChoiceOption("particleEffect", makeHighLowLabels(), [true, false], "Particle Effect", "Reduce particle to help performance", null));
        this.addOptionAndPosition(new ChoiceOption("uiQuality", makeHighLowLabels(), [true, false], "UI Quality", "Reduce UI quality to help performance", onUIQualityToggle));
        this.addOptionAndPosition(new ChoiceOption("HPBar", makeOnOffLabels(), [true, false], "Status Bars", "This key will toggle player HP and MP bars and enemy HP bars", null));
    }

    private function onFullscreenChange():void {
        stage.displayState = ((Parameters.data_.fullscreenMode) ? "fullScreenInteractive" : StageDisplayState.NORMAL);
    }

    private function addSoundOptions():void {
        this.addOptionAndPosition(new ChoiceOption("playMusic", makeOnOffLabels(), [true, false], "Play Music", "This toggles whether music is played", this.onPlayMusicChange));
        this.addOptionAndPosition(new SliderOption("musicVolume", this.onMusicVolumeChange), -115, 15);
        this.addOptionAndPosition(new ChoiceOption("playSFX", makeOnOffLabels(), [true, false], "Play Sound Effects", "This toggles whether sound effects are played", this.onPlaySoundEffectsChange));
        this.addOptionAndPosition(new SliderOption("SFXVolume", this.onSoundEffectsVolumeChange), -115, 34);
        this.addOptionAndPosition(new ChoiceOption("playPewPew", makeOnOffLabels(), [true, false], "Play Weapon Sounds", "This toggles whether weapon sounds are played", null));
    }

    private function addMiscOptions():void {
        this.addOptionAndPosition(new ChoiceOption("showProtips", new <StringBuilder>[makeLineBuilder("View"), makeLineBuilder("View")], [Parameters.data_.showProtips, Parameters.data_.showProtips], "Privacy Policy", "Privacy Policy for Realm of the Mad God", this.onLegalPrivacyClick));
        this.addOptionAndPosition(new NullOption());
        this.addOptionAndPosition(new ChoiceOption("showProtips", new <StringBuilder>[makeLineBuilder("View"), makeLineBuilder("View")], [Parameters.data_.showProtips, Parameters.data_.showProtips], "Terms of Service & EULA", "Terms of Service and End User License Agreement for Realm of the Mad God", this.onLegalTOSClick));
        this.addOptionAndPosition(new NullOption());
    }

    private function onPlayMusicChange():void {
        Music.setPlayMusic(Parameters.data_.playMusic);
        this.refresh();
    }

    private function onPlaySoundEffectsChange():void {
        SFX.setPlaySFX(Parameters.data_.playSFX);
        if (((Parameters.data_.playSFX) || (Parameters.data_.playPewPew))) {
            SFX.setSFXVolume(1);
        }
        else {
            SFX.setSFXVolume(0);
        }
        this.refresh();
    }

    private function onMusicVolumeChange(_arg1:Number):void {
        Music.setMusicVolume(_arg1);
    }

    private function onSoundEffectsVolumeChange(_arg1:Number):void {
        SFX.setSFXVolume(_arg1);
    }

    private function onLegalPrivacyClick():void {
        var _local1:URLRequest = new URLRequest();
        _local1.url = Parameters.PRIVACY_POLICY_URL;
        _local1.method = URLRequestMethod.GET;
        navigateToURL(_local1, "_blank");
    }

    private function onLegalTOSClick():void {
        var _local1:URLRequest = new URLRequest();
        _local1.url = Parameters.TERMS_OF_USE_URL;
        _local1.method = URLRequestMethod.GET;
        navigateToURL(_local1, "_blank");
    }

    private function addOptionAndPosition(option:Option, offsetX:Number = 0, offsetY:Number = 0):void {
        var positionOption:Function;
        positionOption = function ():void {
            option.x = (options_.length % 2 == 0 ? 20 : WebMain.DefaultWidth - 395) + offsetX;
            option.y = (((int((options_.length / 2)) * 44) + 122) + offsetY);
        };
        option.textChanged.addOnce(positionOption);
        this.addOption(option);
    }

    private function addOption(_arg1:Option):void {
        addChild(_arg1);
        _arg1.addEventListener(Event.CHANGE, this.onChange);
        this.options_.push(_arg1);
    }

    private function onChange(_arg1:Event):void {
        this.refresh();
    }

    private function refresh():void {
        var _local2:BaseOption;
        var _local1:int;
        while (_local1 < this.options_.length) {
            _local2 = (this.options_[_local1] as BaseOption);
            if (_local2 != null) {
                _local2.refresh();
            }
            _local1++;
        }
    }


}
}
