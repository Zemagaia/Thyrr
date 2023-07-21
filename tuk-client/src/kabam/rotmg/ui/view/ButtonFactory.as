package kabam.rotmg.ui.view {
import com.company.assembleegameclient.constants.ScreenTypes;
import com.company.assembleegameclient.screens.TitleMenuOption;

public class ButtonFactory {

    public static function getPlayButton():TitleMenuOption {
        return makeButton(ScreenTypes.PLAY);
    }

    public static function getClassesButton():TitleMenuOption {
        return makeButton(ScreenTypes.CLASSES);
    }

    public static function getBackButton():TitleMenuOption {
        return makeButton(ScreenTypes.BACK);
    }

    public static function getAccountButton():TitleMenuOption {
        return makeButton(ScreenTypes.ACCOUNT);
    }

    public static function getLegendsButton():TitleMenuOption {
        return makeButton(ScreenTypes.LEGENDS);
    }

    public static function getServersButton():TitleMenuOption {
        return makeButton(ScreenTypes.SERVERS);
    }

    public static function getSupportButton():TitleMenuOption {
        return makeButton(ScreenTypes.SUPPORT);
    }

    public static function getEditorButton():TitleMenuOption {
        return makeButton(ScreenTypes.EDITOR);
    }

    private static function makeButton(text:String):TitleMenuOption {
        return new TitleMenuOption(text, 32, 18);
    }


}
}
