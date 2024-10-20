import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: cover
    allowResize: true

    Label {

        id: label
        anchors.centerIn: parent
        text: "SeaChest"
        font.pixelSize: Theme.fontSizeSmall

    }

}
