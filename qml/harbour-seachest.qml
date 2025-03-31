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
    bottomMargin: downloadsUploadsPanel.visibleSize

    property string folderToList: ""
    property string folderToListName: qsTr("Home");
    property string folderToListPath: ""
    property string defaultDownloadsLocation: mainDownload.getDlFolderPath();
    property bool activeDlTransfer
    property bool activeUlTransfer

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
        property bool justSearchFolder: true

    }

    NetworkAccess {

        id: mainDownload

        onDlProgressUpdate: {

            var dlTransferProgress = dlProgress / dlTotal;
            var dlTransferProgressPctStr = (dlTransferProgress * 100).toFixed(0).toString() + "%";
            downloadModel.set(0, {"downloadedSoFar": dlProgress, "downloadTotal": dlTotal, "downloadProgress": dlTransferProgress, "downloadProgressPct":  dlTransferProgressPctStr});

        }

        onFinished: {

            switch (responseCode) {

                case 200:

                    notificationMain.previewSummary = "Download of '" + downloadModel.get(0).currentDlItem + "' is complete.";
                    notificationMain.publish();
                    activeDlTransfer = false;
                    downloadModel.clear();
                    break;

                case 401:

                    // may need to change this approach at some point as would like to have up to four simultaneous downloads (not a problem with uploads as that'll stay at one).
                    // need to look at regular finished function having extra parameters?
                    tokenRefresh("DOWNLOAD", "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, "{\"path\":\"" + downloadModel.get(0).currentDlItemID + "\"}", downloadModel.get(0).currentDlItem);
                    //transferRefresh("DOWNLOAD", "https://nodejs.mjeb.dev/seachest/refresh", "{\"path\":\"" + downloadModel.get(0).currentDlItemID + "\"}", downloadModel.get(0).currentDlItem);
                    break;

                case 999:

                    console.log("Unknown error - response text: " + responseText);
                    notificationMain.previewSummary = responseText;
                    notificationMain.publish();

            }

        }

        onRefreshFinished: {

            if (responseCode === 200) {

                var responseParsed = JSON.parse(responseText);
                settings.accessKey = responseParsed.access_token;
                settings.sync();
                downloadFile("https://content.dropboxapi.com/2/files/download", origData, origSupplemental, "Bearer " + settings.accessKey, settings.downloadDestination);

            }

            else {

                notificationMain.previewSummary = qsTr("Error reauthorizing. Please try submitting request again.");
                notificationMain.publish();
                activeDlTransfer = false;
                downloadModel.clear();

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

            if (responseCode === 200) {

                notificationMain.previewSummary = "Upload of '" + uploadModel.get(0).currentUlItem + "' was successful.";
                notificationMain.publish();
                activeUlTransfer = false;
                uploadModel.clear();

            }

            else if (responseCode === 401) {

                uploadModel.set(0, {"uploadProgress": 0.0, "uploadProgressPct": "0%"});
                // Adding notification as file will need to be re-uploaded.
                notificationMain.previewSummary = qsTr("Reauthorizing and resubmitting upload request...");
                notificationMain.publish();
                tokenRefresh("UPLOAD", "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, responseText, "{}");

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

                notificationMain.previewSummary = qsTr("Error code %1. Description copied to clipboard.").arg(responseCode);
                console.log("Response code: " + responseCode + "\nResponse text: " + responseText);
                Clipboard.text = responseText;
                notificationMain.publish();

            }

        }

        onRefreshFinished: {

            if (responseCode === 200) {

                var responseParsed = JSON.parse(responseText);
                settings.accessKey = responseParsed.access_token;
                settings.sync();
                upload("https://content.dropboxapi.com/2/files/upload", uploadModel.get(0).currentUlItemPath, origData, "Bearer " + settings.accessKey);

            }

            else {

                console.log("Error reauthorizing: " + responseCode);
                console.log("Response text: " + responseText);
                notificationMain.previewSummary = qsTr("Error reauthorizing. Please try submitting request again.");
                notificationMain.publish();
                activeUlTransfer = false;
                uploadModel.clear();

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
