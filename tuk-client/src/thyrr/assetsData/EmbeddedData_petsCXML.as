package thyrr.assetsData {
import thyrr.assets.*;

import mx.core.*;

[Embed(source="pets/EmbeddedData_PetsCXML.xml", mimeType="application/octet-stream")]
public class EmbeddedData_petsCXML extends ByteArrayAsset {
    public function EmbeddedData_petsCXML() {
        super();
        return;
    }
}
}
