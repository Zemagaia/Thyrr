package kabam.lib.json
{

public interface JsonParser
{
    function stringify(object:Object):String;

    function parse(json:String):Object;
}
}