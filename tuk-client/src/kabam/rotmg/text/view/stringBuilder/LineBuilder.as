package kabam.rotmg.text.view.stringBuilder {
import kabam.lib.json.JsonParser;
import kabam.rotmg.language.model.StringMap;

public class LineBuilder implements StringBuilder {

    public var key:String;
    public var tokens:Object;
    private var postfix:String = "";
    private var prefix:String = "";
    private var map:StringMap;

    private static function get json_():JsonParser {
        return (Global.jsonParser);
    }

    public static function fromJSON(key:String):LineBuilder {
        var json:Object;
        try {
            json = json_.parse(key);
        }
        catch (e:Error) {
            json = { "key":key, "tokens":null };
        }
        return (new (LineBuilder)().setParams(json.key, json.tokens));
    }

    public static function getLocalizedStringFromKey(key:String, tokens:Object = null):String {
        var lb:LineBuilder = new (LineBuilder)();
        lb.setParams(key, tokens);
        var map:StringMap = Global.stringMap;
        lb.setStringMap(map);
        return ((((lb.getString() == "")) ? key : lb.getString()));
    }

    public static function getLocalizedStringFromJSON(key:String):String {
        var lb:LineBuilder;
        var map:StringMap;
        if (key.charAt(0) == "{") {
            lb = LineBuilder.fromJSON(key);
            map = Global.stringMap;
            lb.setStringMap(map);
            return (lb.getString());
        }
        return (key);
    }

    public static function returnStringReplace(_arg1:String, _arg2:Object = null, _arg3:String = "", _arg4:String = ""):String {
        var _local6:String;
        var _local7:String;
        var _local8:String;
        var _local5:String = _arg1;
        for (_local6 in _arg2) {
            _local7 = _arg2[_local6];
            _local8 = (("{" + _local6) + "}");
            while (_local5.indexOf(_local8) != -1) {
                _local5 = _local5.replace(_local8, _local7);
            }
        }
        _local5 = _local5.replace(/\\n/g, "\n");
        return (((_arg3 + _local5) + _arg4));
    }

    public static function getLocalizedString2(key:String, tokens:Object = null):String {
        var lb:LineBuilder = new (LineBuilder)();
        lb.setParams(key, tokens);
        var map:StringMap = Global.stringMap;
        lb.setStringMap(map);
        return (lb.getString());
    }

    public function toJson():String {
        return (json_.stringify({
            "key": this.key,
            "tokens": this.tokens
        }));
    }

    public function setParams(key:String, tokens:Object = null):LineBuilder {
        this.key = ((key) || (""));
        this.tokens = tokens;
        return (this);
    }

    public function setPrefix(prefix:String):LineBuilder {
        this.prefix = prefix;
        return (this);
    }

    public function setPostfix(postfix:String):LineBuilder {
        this.postfix = postfix;
        return (this);
    }

    public function setStringMap(map:StringMap):void {
        this.map = map;
    }

    public function getString():String {
        var _local3:String;
        var _local4:String;
        var _local5:String;
        var _local1:String = this.key;
        var _local2:String = ((this.map.getValue(_local1)) || (""));
        for (_local3 in this.tokens) {
            _local4 = this.tokens[_local3];
            if ((((_local4.charAt(0) == "{")) && ((_local4.charAt((_local4.length - 1)) == "}")))) {
                _local4 = this.map.getValue(_local4.substr(1, (_local4.length - 2)));
            }
            _local5 = (("{" + _local3) + "}");
            while (_local2.indexOf(_local5) != -1) {
                _local2 = _local2.replace(_local5, _local4);
            }
        }
        _local2 = _local2.replace(/\\n/g, "\n");
        return (((this.prefix + _local2) + this.postfix));
    }

}
}
