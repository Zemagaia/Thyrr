package kabam.rotmg.account.core {
public interface Account {

    function updateUser(userId:String, password:String, token:String):void;

    function getUserName():String;

    function getUserId():String;

    function getPassword():String;

    function getToken():String;

    function getSecret():String;

    function getCredentials():Object;

    function isRegistered():Boolean;

    function clear():void;

    function reportIntStat(name:String, value:int):void;

    function getRequestPrefix():String;

    function gameNetworkUserId():String;

    function gameNetwork():String;

    function playPlatform():String;

    function getEntryTag():String;

    function verify(verified:Boolean):void;

    function isVerified():Boolean;

    function getMoneyUserId():String;

    function getMoneyAccessToken():String;

}
}
