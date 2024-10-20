import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Sailfish.Pickers 1.0
import NetworkAccess 1.0
import Sailfish.WebView 1.0

Page {

    id: page
    allowedOrientations: Orientation.All

    PageHeader {

        id: webViewHeader
        title: qsTr("Authorize SeaChest")

    }

    WebView {

        id: authorizeUser
        width: page.width
        url: "https://nodejs.mjeb.dev/seachest/auth"
        privateMode: true

        anchors {

            left: parent.left
            right: parent.right
            top: webViewHeader.bottom
            bottom: parent.bottom

        }

        onUrlChanged: {

            var urlString = url.toString();

            if (urlString.indexOf("access_token=") !== -1) {

                loadingDataBusy.running = true;
                settings.accessKey = urlString.slice((urlString.indexOf("access_token=") + 13), (urlString.indexOf("access_token=") + 77));
                settings.refreshToken = urlString.slice((urlString.indexOf("refresh_token=") + 14), (urlString.indexOf("refresh_token=") + 78));
                settings.sync();
                authorizationNotifier.previewSummary = qsTr("Authorization Successful");
                authorizationNotifier.publish();
                loadingDataBusy.running = false;
                pageStack.clear();
                pageStack.push(Qt.resolvedUrl("Home.qml"));

            }
/*
            else {

                authorizationNotifier.previewSummary = "Error obtaining access key.";
                authorizationNotifier.publish();

            }
*/
        }

    }

    Notification {

        id: authorizationNotifier
        isTransient: true
        expireTimeout: 1800

    }

    BusyIndicator {

        id: loadingDataBusy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large

    }

}
