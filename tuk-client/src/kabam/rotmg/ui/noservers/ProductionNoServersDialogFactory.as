package kabam.rotmg.ui.noservers {
import com.company.assembleegameclient.ui.dialogs.Dialog;



public class ProductionNoServersDialogFactory implements NoServersDialogFactory {

    private static const forums_link:String = '<font color="#7777EE"><a href="http://forums.wildshadow.com/">forums.wildshadow.com</a></font>';
    private static const TRACKING:String = "/offLine";


    public function makeDialog():Dialog {
        var _local1:Dialog = new Dialog("Oryx Sleeping", "", null, null, TRACKING);
        _local1.textText_.setHTML(true);
        _local1.setTextParams("Realm of the Mad God is currently offline.\n\nGo here for more information: {forums_link}.", {"forums_link": forums_link});
        return (_local1);
    }


}
}
