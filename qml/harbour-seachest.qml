import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import NetworkAccess 1.0
import "pages"

ApplicationWindow {

    id: mainAppWindow
    initialPage: settings.accessKey === "" ? loadAuthorizeScreen : loadHomeScreen
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
    bottomMargin: downloadsUploadsPanel.visibleSize

    property string folderToList: ""
    property string folderToListName: qsTr("Home");
    property string folderToListPath: ""
    property string currentPath: "/"
    property string defaultDownloadsLocation: mainDownload.getDlFolderPath();
    property bool activeDlTransfer
    property bool activeUlTransfer
    //property int dlTransferOpacity: 0.0
    property int ulTransferOpacity: 0.0

    onActiveDlTransferChanged: {

        if (activeDlTransfer || activeUlTransfer) downloadsUploadsPanel.show();
        else downloadsUploadsPanel.hide();

    }

    onActiveUlTransferChanged: {

        if (activeUlTransfer || activeDlTransfer) downloadsUploadsPanel.show();
        else downloadsUploadsPanel.hide();

    }

    Component {

        id: loadAuthorizeScreen
        Authorize { }

    }

    Component {

        id: loadHomeScreen
        Home { }

    }

    ConfigurationGroup {

        id: settings
        path: "/apps/harbour-seachest"

        property string accessKey: ""
        property string refreshToken: ""
        property string downloadDestination: mainDownload.getDlFolderPath();
        property bool downloadToDownloads: true
        property bool uploadToHomeFolder
        property bool itemTapToDl
        property bool showThumbnailForImageFiles: true
        property bool autorename: true
        property bool overwriteWarning: true

    }

    NetworkAccess {

        id: mainDownload

        onDlProgressUpdate: {

            var dlTransferProgress = dlProgress / dlTotal;
            var dlTransferProgressPctStr = (dlTransferProgress * 100).toFixed(0).toString() + "%";
            downloadModel.set(0, {"downloadedSoFar": dlProgress, "downloadTotal": dlTotal, "downloadProgress": dlTransferProgress, "downloadProgressPct":  dlTransferProgressPctStr});

            /*
            transferProgressSlider.value = dlProgress / dlTotal;
            var dlPercentage = ((dlProgress / dlTotal) * 100).toFixed(0);
            transferProgressSlider.valueText = dlPercentage + "\%";
            */

        }

        onFinished: {

            //transferStatusBar.opacity = 0.0;
            //transferProgressSlider.value = 0;
            //transferProgressSlider.valueText = "0%";
            //transferStatusBar.visible = false;

            if (requestType === "TOKEN_REFRESH") {

                if (responseCode === 200 ) {

                    var responseParsed = JSON.parse(responseText);
                    settings.accessKey = responseParsed.access_token;
                    settings.sync();
                    //notificationMain.previewSummary = "Reauthorized"; // no real need for notification when reauthorized, although it can explain longer than normal request time.
                    //notificationMain.publish();
                    console.log("Reauthorization successful.");
                    downloadFile("https://content.dropboxapi.com/2/files/download", "{\"path\":\"" + downloadModel.get(0).currentDlItemID + "\"}", downloadModel.get(0).currentDlItem, "Bearer " + settings.accessKey, settings.downloadDestination);

                }
/*
                else if (responseCode === 301) {

                    // refresh token with URL included in 301 headers.
                    // used when domain redirected to evennode; have since moved to digitalocean who have domain also so no redirect needed.
                    console.log("Response code is 301 and the responseText is: " + responseText);
                    transferRefresh("DOWNLOAD", responseText + settings.refreshToken, "{\"path\":\"" + downloadModel.get(0).currentDlItemID + "\"}", downloadModel.get(0).currentDlItem);

                }
*/
                else {

                    // handle app not reauthorizing.

                    console.log("Response code: " + responseCode);
                    console.log("Request type: " + requestType);
                    console.log("Response text: " + responseText);
                    notificationMain.previewSummary = qsTr("Error reauthorizing. Please try submitting request again.");
                    notificationMain.publish();
                    activeDlTransfer = false;
                    downloadModel.clear();

                }

            }

            else {

                switch (responseCode) {

                    case 200:

                        notificationMain.previewSummary = "Download of '" + downloadModel.get(0).currentDlItem + "' is complete.";
                        notificationMain.publish();
                        activeDlTransfer = false;
                        downloadModel.clear();
                        break;

                    case 401:

                        // first need to get redirect url from the permanent link.
                        transferRefresh("DOWNLOAD", "https://nodejs.mjeb.dev/seachest/refresh", "{\"path\":\"" + downloadModel.get(0).currentDlItemID + "\"}", downloadModel.get(0).currentDlItem);
                        break;

                    case 999:

                        notificationMain.previewSummary = responseText;
                        notificationMain.publish();

                }

            }

        }

    }

    NetworkAccess {

        id: mainUpload

        onUlProgressUpdate: {

            var ulTransferProgress = ulProgress / ulTotal;
            var ulTransferProgressPctStr = (ulTransferProgress * 100).toFixed(0).toString() + "%";
            uploadModel.set(0, {"uploadedSoFar": ulProgress, "uploadTotal": ulTotal, "uploadProgress": ulTransferProgress, "uploadProgressPct":  ulTransferProgressPctStr});

        }

        onFinished: {

            if (requestType === "TOKEN_REFRESH") {

                if (responseCode === 200) {

                    var responseParsed = JSON.parse(responseText);
                    settings.accessKey = responseParsed.access_token;
                    settings.sync();
                    notificationMain.previewSummary = "Reauthorized";
                    notificationMain.publish();
                    upload("https://content.dropboxapi.com/2/files/upload", uploadModel.get(0).currentUlItemPath, "{\"path\":\"" + uploadModel.get(0).currentLocalFolderPath + "/" + uploadModel.get(0).currentUlItem + "\"}", "Bearer " + settings.accessKey);

                }

                else {

                    console.log("Error reauthorizing: " + responseCode);
                    console.log("Request type: " + requestType);
                    console.log("Response text: " + responseText);
                    notificationMain.previewSummary = qsTr("Error reauthorizing. Please try submitting request again.");
                    notificationMain.publish();
                    activeUlTransfer = false;
                    uploadModel.clear();

                }

            }

            else { // still need way to reauthorize or refresh token if uploading and access has expired.

                if (responseCode === 200) {

                    notificationMain.previewSummary = "Upload of '" + uploadModel.get(0).currentUlItem + "' was successful.";
                    notificationMain.publish();
                    activeUlTransfer = false;
                    uploadModel.clear();

                }

                else if (responseText === "Error - File does not exist.") {

                    notificationMain.previewSummary = qsTr("Error - File does not exist.");
                    notificationMain.publish();

                }

                else if (responseText === "Error - Unable to open file.") {

                    notificationMain.previewSummary = qsTr("Error - Unable to open file.");
                    notificationMain.publish();

                }

                else {

                    notificationMain.previewSummary = qsTr("Other error: %1. Copied to clipboard.").arg(responseCode);
                    Clipboard.text = responseText;
                    notificationMain.publish();

                }

            }

        }

    }

    ListModel {

        id: folderListModel

        ListElement { itemName: ""; itemID: "";  }

    }

    Notification {

        id: notificationMain
        isTransient: true
        expireTimeout: 1800

    }

    ListModel {

        id: downloadModel

        Component.onCompleted: clear();

        ListElement {

            downloadedSoFar: 0; downloadTotal: 0; downloadProgress: 0.0; downloadProgressPct: ""; currentDlItem: ""; currentDlItemID: ""

        }

    }

    ListModel {

        id: uploadModel

        Component.onCompleted: clear();

        ListElement {

            uploadedSoFar: 0; uploadTotal: 0; uploadProgress: 0.0; uploadProgressPct: ""; currentUlItem: ""; currentUlItemPath: ""; currentLocalFolderPath: ""

        }

    }

    DockedPanel {

        id: downloadsUploadsPanel
        open: false
        dock: Dock.Bottom
        width: parent.width
        height: downloadsListview.height + uploadsListview.height

        SilicaListView {

            id: uploadsListview
            model: uploadModel
            height: contentHeight
            width: parent.width

            delegate: ProgressBar {

                width: parent.width
                value: uploadProgress
                valueText: uploadProgressPct
                label: qsTr("Uploading ") + currentUlItem

            }

        }

        SilicaListView {

            id: downloadsListview
            model: downloadModel
            height: contentHeight
            width: parent.width
            anchors.top: uploadsListview.bottom

            delegate: ProgressBar {

                width: parent.width
                value: downloadProgress
                valueText: downloadProgressPct
                label: qsTr("Downloading ") + currentDlItem

            }

        }

    }

}
