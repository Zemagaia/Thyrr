package kabam.rotmg.text.view.stringBuilder {
import kabam.rotmg.language.model.StringMap;

public class AppendingLineBuilder implements StringBuilder {

    private var data:Vector.<LineData>;
    private var delimiter:String = "\n";
    private var provider:StringMap;

    private var ignoreColors_:Boolean = false;

    public function AppendingLineBuilder() {
        this.data = new Vector.<LineData>();
        super();
    }

    public function pushParams(key:String, keyReplacements:Object = null, color:int = 0xB3B3B3, bold:Boolean = false, replacementsColor:int = 0xB3B3B3):AppendingLineBuilder {
        this.data.push(new LineData().setKey(key).setTokens(keyReplacements)
                .setColor(color).setBold(bold).setReplacementsColor(replacementsColor)
                .setIgnoreColors(this.ignoreColors_));
        return this;
    }

    public function pushParams2(key:String, keyReplacements:Object = null):AppendingLineBuilder {
        this.ignoreColors_ = true;
        return pushParams(key, keyReplacements);
    }

    public function setDelimiter(delim:String):AppendingLineBuilder {
        this.delimiter = delim;
        return this;
    }

    public function setStringMap(provider:StringMap):void {
        this.provider = provider;
    }

    public function getString():String {
        var data:LineData;
        var text:Vector.<String> = new Vector.<String>();
        for each (data in this.data) {
            text.push(data.getString(this.provider));
        }
        return (text.join(this.delimiter));
    }

    public function hasLines():Boolean {
        return (!((this.data.length == 0)));
    }

    public function clear():void {
        this.data = new Vector.<LineData>();
    }


}
}

import kabam.rotmg.language.model.StringMap;

import kabam.rotmg.text.view.stringBuilder.StringBuilder;

class LineData {

    public var key:String;
    public var tokens:Object;
    public var bold:Boolean = false;
    public var color:uint = 0xB3B3B3;
    public var replacementsColor:uint = 0xB3B3B3;
    public var ignoreColors:Boolean = false;

    public function setKey(key:String):LineData {
        this.key = key;
        return (this);
    }

    public function setTokens(tokens:Object):LineData {
        this.tokens = tokens;
        return (this);
    }

    public function setBold(bold:Boolean):LineData {
        this.bold = bold;
        return (this);
    }

    public function setColor(color:uint):LineData {
        this.color = color;
        return (this);
    }

    public function setReplacementsColor(replacementsColor:uint):LineData {
        this.replacementsColor = replacementsColor;
        return (this);
    }

    public function setIgnoreColors(ignoreColors:Boolean):LineData {
        this.ignoreColors = ignoreColors;
        return (this);
    }

    public function getString(map:StringMap):String {
        var key:String;
        var token:String;
        var sb:StringBuilder;
        var repl:String;
        var text:String = this.bold ? "<b>" : "";
        key = map.getValue(this.key);
        if (key == null) {
            key = this.key;
        }
        text = color != 0xB3B3B3 && !ignoreColors ? text.concat('<font color="#' + color.toString(16) + '">' + key + "</font>") : text.concat(key);
        for (token in this.tokens) {
            if ((this.tokens[token] is StringBuilder)) {
                sb = StringBuilder(this.tokens[token]);
                sb.setStringMap(map);
                text = text.replace("{" + token + "}", sb.getString());
            }
            else {
                repl = this.tokens[token];
                if ((((((repl.length > 0)) && ((repl.charAt(0) == "{")))) && ((repl.charAt((repl.length - 1)) == "}")))) {
                    repl = map.getValue(repl.substr(1, (repl.length - 2)));
                }
                text = text.replace("{" + token + "}",
                        !ignoreColors ? '<font color="#' + (color != 0xB3B3B3 ? color : replacementsColor).toString(16) + '">' + repl + "</font>" : repl);
            }
        }
        text = text.replace(/\\n/g, "\n");
        return (text.concat(this.bold ? "</b>" : ""));
    }


}

