package kabam.rotmg.editor.view.components.loaddialog {
import com.company.assembleegameclient.ui.dialogs.Dialog;


import kabam.rotmg.text.view.stringBuilder.LineBuilder;

public class DeletePictureDialog extends Dialog {

    public var id_:String;

    public function DeletePictureDialog(_arg_1:String, _arg_2:String) {
        super("Delete Picture", "", "Cancel", "Delete", "/deletePicture");
        textText_.setStringBuilder(new LineBuilder().setParams("Are you sure you want to delete \\{name}\\? This can not be undone.", {"name": _arg_1}));
        this.id_ = _arg_2;
    }

}
}
