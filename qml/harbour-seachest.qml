import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import NetworkAccess 1.0
import "pages"

ApplicationWindow {

    id: mainAppWindow
    initialPage: settings.accessKey === "" ? loadAuthorizeScreen : loadHomeScreen
    // initialPage: loadHomeScreen // until webview can work with dropbox authorization
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
    bottomMargin: downloadsUploadsPanel.visibleSize

    property string folderToList: ""
    property string folderToListName: qsTr("Home");
    property string folderToListPath: ""
    // property bool uploadInProgress
    property string currentPath: "/"
    property bool activeDlTransfer
    property bool activeUlTransfer
    // property int dlTransferProgress: 0.0
    // property int ulTransferProgress: 0.0
    property int dlTransferOpacity: 0.0
    property int ulTransferOpacity: 0.0
    // property string dlTransferProgressPctStr: ""
    // property string ulTransferProgressPctStr: ""
    // property string currentUlItemName
    // property string currentDlItemName
    // property int currentTransferTotal
    // property int currentTransferLoaded
    //onActiveUlTransferChanged: downloadsUploadsPanel.open = activeUlTransfer;

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
        property bool uploadToHomeFolder
        property bool itemTapToDl
        property bool showThumbnailForImageFiles: true

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
                    notificationMain.previewSummary = "Reauthorized";
                    notificationMain.publish();

                    downloadFile("https://content.dropboxapi.com/2/files/download", "{\"path\":\"" + downloadModel.get(0).currentDlItemID + "\"}", downloadModel.get(0).currentDlItem, "Bearer " + settings.accessKey);

                }

                else if (responseCode === 301) {

                    // refresh token with URL included in 301 headers.
                    console.log("Response code is 301 and the responseText is: " + responseText);
                    transferRefresh("DOWNLOAD", responseText + settings.refreshToken, "{\"path\":\"" + downloadModel.get(0).currentDlItemID + "\"}", downloadModel.get(0).currentDlItem);

                }

                else {

                    // handle app not reauthorizing.

                    console.log("Response code: " + responseCode);
                    console.log("Request type: " + requestType);
                    console.log("Response text: " + responseText);
                    notificationMain.previewSummary = qsTr("Error reauthorizing. Please try submitting request again.");
                    notificationMain.publish();
                    downloadModel.clear();
                    activeDlTransfer = false;

                }

            }

            else {

                switch (responseCode) {

                    case 200:

                        dlTransferOpacity = 0.0;
                        notificationMain.previewSummary = "Download of '" + downloadModel.get(0).currentDlItem + "' is complete.";
                        notificationMain.publish();
                        activeDlTransfer = false;
                        downloadModel.clear();
                        //downloadModel.set(0, {"downloadedSoFar": 0, "downloadTotal": 0, "downloadProgress": 0.0, "downloadProgressPct": "0%"});

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

                else if (responseCode == 301) {

                    console.log("(Upload object -- not yet completed fully. Response code is 301 and the responseText is: " + responseText);

                }

                else {

                    console.log("Error reauthorizing: " + responseCode);
                    console.log("Request type: " + requestType);
                    console.log("Response text: " + responseText);
                    notificationMain.previewSummary = qsTr("Error reauthorizing. Please try submitting request again.");
                    notificationMain.publish();
                    ulTransferOpacity = 0.0;
                    uploadModel.clear();
                    //uploadModel.set(0, {"uploadProgress": 0.0, "uploadProgressPct": "0%"});

                }

            }

            else { // still need way to reauthorize or refresh token if uploading and access has expired.

                if (responseCode === 200) {

                    ulTransferOpacity = 0.0;
                    notificationMain.previewSummary = "Upload of '" + uploadModel.get(0).currentUlItem + "' was successful.";
                    notificationMain.publish();
                    uploadModel.clear();
                    //uploadModel.set(0, {"uploadProgress": 0.0, "uploadProgressPct": "0%"});

                }

                else if (responseText === "Error - File does not exist.") {

                    notificationMain.previewSummary = "Error - File does not exist.";
                    notificationMain.publish();

                }

                else if (responseText === "Error - Unable to open file.") {

                    notificationMain.previewSummary = "Error - Unable to open file.";
                    notificationMain.publish();

                }

                else {

                    notificationMain.previewSummary = "Other error: " + responseCode + ". Copied to clipboard.";
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

        Component.onCompleted: clear(); // avoid existing blank ListElement here if uploading something first or vice versa.

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
        // open: some way to check if any downloads currently
        open: false //--to begin with at least.    activeDlTransfer // || activeUlTransfer
        dock: Dock.Bottom
        width: parent.width
        height: downloadsUploadsListview.height + uploadsListview.height

        SilicaListView {

            id: uploadsListview
            model: uploadModel
            height: contentHeight
            width: parent.width

            delegate: ProgressBar {

                width: parent.width
                //height: downloadSlider.height
                value: uploadProgress
                valueText: uploadProgressPct
                label: qsTr("Uploading " + currentUlItem)

            }

        }

        SilicaListView {

            id: downloadsUploadsListview
            model: downloadModel
            height: contentHeight
            width: parent.width
            anchors.top: uploadsListview.bottom

            delegate: ProgressBar {

                width: parent.width
                //height: downloadSlider.height
                value: downloadProgress
                valueText: downloadProgressPct
                label: qsTr("Downloading " + currentDlItem)

            }

        }

    }

}
