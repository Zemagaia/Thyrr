package kabam.lib.json
{

import com.adobe.serialization.json.JSON;

public class SoftwareJsonParser implements JsonParser
{
    public function stringify(object:Object):String
    {
        return com.adobe.serialization.json.JSON.encode(object);
    }

    public function parse(json:String):Object
    {
        return com.adobe.serialization.json.JSON.decode(json);
    }
}
}