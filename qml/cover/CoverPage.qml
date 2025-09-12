import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: cover
    allowResize: true

    Image {

        id: coverBackgroundIcon
        source: "harbour-seachest-grayscale.png"
        width: parent.height - (Theme.paddingMedium * 2)
        height: width
        fillMode: Image.PreserveAspectFit
        opacity: 0.15

        anchors {

            verticalCenter: parent.verticalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium

        }

    }

    CoverActionList {

        CoverAction {

            id: uploadFromCoverButton
            iconSource: Theme.colorScheme == Theme.LightOnDark ? "icon-cover-up.png" : "icon-cover-up-light-theme.png"

            onTriggered: {

                if (settings.accessKey !== "" && !activeUlTransfer) {

                    currentUploadFolderPath = "";
                    pageStack.push(filePickerPage);
                    mainAppWindow.activate();

                }

                else if (activeUlTransfer) mainAppWindow.activate(); // just bring app to focus -- ongoing UL transfer will be then visible.

            }

        }

    }

}
