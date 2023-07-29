package kabam.rotmg.language.control {
import kabam.rotmg.core.model.ScreenModel;
import kabam.rotmg.ui.view.TitleView;

public class ReloadCurrentScreen
{

    public var screensModel:ScreenModel = Global.screenModel;


    public function ReloadCurrentScreen() {
        var screen:Class = ((this.screensModel.getCurrentScreenType()) || (TitleView));
        Global.invalidateData();
        Global.closeDialogs();
        Global.setScreen(new (screen)());
    }


}
}
