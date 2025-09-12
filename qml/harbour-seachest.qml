import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
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
    property string uploadLargeItemSession
    property string selectedLocalFile
    property string selectedFileName
    property string currentUploadFolderPath
    property int uploadLargeItemSize
    property int uploadTotalSegments
    property int uploadOffsetValue
    property int uploadCurrentSegment
    property var tokenWillExpireAt
    property bool activeDlTransfer
    property bool activeUlTransfer
    property bool activeUlLarge

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

    Component {

        id: filePickerPage

        FilePickerPage {

            title: qsTr("Upload")

            onSelectedContentPropertiesChanged: {

                mainAppWindow.selectedFileName = selectedContentProperties.fileName;
                mainAppWindow.selectedLocalFile = selectedContentProperties.filePath;

                var uploadToHere = currentUploadFolderPath;
                if (settings.uploadToHomeFolder) uploadToHere = "";
                activeUlTransfer = true;
                var fileSize = mainUpload.getFileSize(mainAppWindow.selectedLocalFile);

                console.log("The full path of the file is " + mainAppWindow.selectedLocalFile);
                console.log("The var 'filesize' equals " + fileSize);

                var rightNow = Number(Date.now());
                rightNow = rightNow / 1000;

                console.log("Values of rightNow - " + rightNow);
                console.log("The expire time is: " + tokenWillExpireAt);

                // If token refresh is necessary after an upload request, this will be known only after the file (or partial file
                // if larger than 150MiB) data is done uploading to the server. Avoiding likelihood of this happening by checking
                // time left on authorization token first.

                if (fileSize > 157286400) { // 150 MiB = 157,286,400 Bytes

                    if ((tokenWillExpireAt - rightNow) < 7200) { // allowing for 2 hours for large uploads (all parts) if on a slow connection etc.

                        console.log("Refreshing token prior to the upload request being made.");
                        mainUpload.tokenRefresh("UPLOAD_START", "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, "{\"close\":false}", "{}");

                    }

                    else {

                        uploadTotalSegments = Math.ceil(fileSize / 157286400);
                        uploadLargeItemSize = fileSize;
                        uploadOffsetValue = 0;
                        activeUlLarge = true;
                        uploadModel.set(0, {"currentUlItem": mainAppWindow.selectedFileName, "currentUlItemPath": mainAppWindow.selectedLocalFile, "currentFolderPath": uploadToHere, "uploadProgress": 0.0, "uploadProgressPct": "0%", "currentUlItemLarge": "[1/" + totalSegments + "] " + mainAppWindow.selectedFileName});
                        mainUpload.largeUpload("https://content.dropboxapi.com/2/files/upload_session/start", mainAppWindow.selectedLocalFile, "{\"close\":false}", "UPLOAD_START", 0, "Bearer " + settings.accessKey);

                    }

                }

                else {

                    if ((tokenWillExpireAt - rightNow) < 1800) { // 30 minutes for smaller uploads if slow.

                        console.log("Refreshing token prior to the upload request being made.");
                        mainUpload.tokenRefresh("UPLOAD", "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, "{\"path\":\"" + uploadToHere + "/" + mainAppWindow.selectedFileName + "\"}", "{}");

                    }

                    else {

                        activeUlLarge = false;
                        uploadModel.set(0, {"currentUlItem": mainAppWindow.selectedFileName, "currentUlItemPath": mainAppWindow.selectedLocalFile, "currentFolderPath": uploadToHere, "uploadProgress": 0.0, "uploadProgressPct": "0%"});
                        mainUpload.upload("https://content.dropboxapi.com/2/files/upload", mainAppWindow.selectedLocalFile, "{\"path\":\"" + uploadToHere + "/" + mainAppWindow.selectedFileName + "\"}", "Bearer " + settings.accessKey);

                    }

                }

            }

        }

    }

    ConfigurationGroup {

        id: settings
        path: "/apps/harbour-seachest"

        property string accessKey: ""
        property string refreshToken: ""
        property string downloadDestination: mainDownload.getDlFolderPath();
        property bool downloadToDownloads: true
        property bool uploadToHomeFolder
        property bool itemTapToDl: true
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
                var rightNow = Date.now();
                rightNow = rightNow / 1000;
                console.log("rightNow var equals " + rightNow);
                var expiresIn = responseParsed.expires_in;
                console.log("expiresIn equals " + expiresIn);
                tokenWillExpireAt = expiresIn + rightNow;
                console.log("Time calcs, have they worked? tokenWillExpireAt equals " + tokenWillExpireAt);
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

                if (requestType == "UPLOAD") {

                    notificationMain.previewSummary = "Upload of '" + uploadModel.get(0).currentUlItem + "' was successful.";
                    notificationMain.publish();
                    activeUlTransfer = false;
                    uploadModel.clear();

                }

                else {

                    const currentFile = uploadModel.get(0).currentUlItem;

                    switch (requestType) {

                    case "UPLOAD_START":

                        console.log("Back from UPLOAD_START with 200 response code.");
                        var returnedJson = JSON.parse(responseText);
                        uploadLargeItemSession = returnedJson.session_id;

                        // will be 2nd segment for next request
                        uploadCurrentSegment = 2;

                        uploadModel.set(0, {"uploadedSoFar": 0, "uploadTotal": 0, "uploadProgress": 0, "uploadProgressPct":  "0%"});

                        uploadModel.set(0, {"currentUlItemLarge": "[2/" + uploadTotalSegments + "] " + currentFile});

                        uploadOffsetValue = 157286400;

                        // if it's just two parts go straight to last part
                        if (uploadLargeItemSize <= 314572800) this.largeUpload("https://content.dropboxapi.com/2/files/upload_session/finish", uploadModel.get(0).currentUlItemPath, "{\"commit\": {\"autorename\":true,\"mode\":\"add\",\"mute\":false,\"path\":\"" + uploadModel.get(0).currentFolderPath + "/" + uploadModel.get(0).currentUlItem + "\",\"strict_conflict\": false},\"cursor\": {\"offset\": 157286400, \"session_id\":\"" + uploadLargeItemSession + "\"}}", "FINISH", 157286400, "Bearer " + settings.accessKey);
                        else this.largeUpload("https://content.dropboxapi.com/2/files/upload_session/append_v2", uploadModel.get(0).currentUlItemPath, "{\"close\": false,\"cursor\": {\"offset\": 157286400,\"session_id\":\"" + uploadLargeItemSession + "\"}}", "IN_PROGRESS", 157286400, "Bearer " + settings.accessKey);
                        break;

                    case "IN_PROGRESS":

                        console.log("Back from IN_PROGRESS with 200 response code.");
                        uploadCurrentSegment++;

                        uploadOffsetValue = uploadOffsetValue + 157286400;
                        uploadModel.set(0, {"uploadedSoFar": 0, "uploadTotal": 0, "uploadProgress": 0, "uploadProgressPct":  "0%"});
                        uploadModel.set(0, {"currentUlItemLarge": "[" + uploadCurrentSegment + "/" + uploadTotalSegments + "] " + currentFile});

                        // adding again to account for a full next segment if required.
                        if (uploadLargeItemSize <= (uploadOffsetValue + 157286400)) this.largeUpload("https://content.dropboxapi.com/2/files/upload_session/finish", uploadModel.get(0).currentUlItemPath, "{\"commit\": {\"autorename\":true,\"mode\":\"add\",\"mute\":false,\"path\":\"" + uploadModel.get(0).currentFolderPath + "/" + uploadModel.get(0).currentUlItem + "\",\"strict_conflict\": false},\"cursor\": {\"offset\":" + uploadOffsetValue + ", \"session_id\":\"" + uploadLargeItemSession + "\"}}", "FINISH", uploadOffsetValue, "Bearer " + settings.accessKey);
                        else this.largeUpload("https://content.dropboxapi.com/2/files/upload_session/append_v2", uploadModel.get(0).currentUlItemPath, "{\"close\": false,\"cursor\": {\"offset\":" + uploadOffsetValue + ", \"session_id\":\"" + uploadLargeItemSession + "\"}}", "IN_PROGRESS", uploadOffsetValue, "Bearer " + settings.accessKey);
                        break;

                    case "FINISH":

                        console.log("Large upload successfully completed.");
                        notificationMain.previewSummary = "Upload of '" + uploadModel.get(0).currentUlItem + "' was successful.";
                        notificationMain.publish();
                        activeUlTransfer = false;
                        uploadModel.clear();
                        uploadCurrentSegment = 1;
                        uploadOffsetValue = 0;

                    }

                }

            }

            else if (responseCode === 401) {

                notificationMain.previewSummary = qsTr("Reauthorizing and resubmitting upload request...");
                notificationMain.publish();
                console.log("Refreshing token and will then resubmit " + requestType + " request.");
                uploadModel.set(0, {"uploadProgress": 0.0, "uploadProgressPct": "0%"});
                tokenRefresh(requestType, "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, responseText, "{}");

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

                notificationMain.previewSummary = qsTr("Error code %1 - Description copied to clipboard").arg(responseCode);
                console.log("Response code: " + responseCode + "\nResponse text: " + responseText);
                Clipboard.text = responseText;
                notificationMain.publish();

            }

        }

        onRefreshFinished: {

            if (responseCode === 200) {

                var responseParsed = JSON.parse(responseText);
                var rightNow = Date.now();
                rightNow = rightNow / 1000;
                console.log("rightNow var equals " + rightNow);
                var expiresIn = responseParsed.expires_in;
                console.log("expiresIn equals " + expiresIn);
                tokenWillExpireAt = expiresIn + rightNow;
                console.log("Time calcs, have they worked? tokenWillExpireAt equals " + tokenWillExpireAt);
                settings.accessKey = responseParsed.access_token;
                settings.sync();
                console.log("Reauthorized, resubmitting the " + origRequestType + " request.");

                switch (origRequestType) {

                case "UPLOAD_START":

                    largeUpload("https://content.dropboxapi.com/2/files/upload_session/start", uploadModel.get(0).currentUlItemPath, origData, "UPLOAD_START", 0, "Bearer " + settings.accessKey);
                    break;

                case "IN_PROGRESS":

                    largeUpload("https://content.dropboxapi.com/2/files/upload_session/append_v2", uploadModel.get(0).currentUlItemPath, origData, "IN_PROGRESS", uploadOffsetValue, "Bearer " + settings.accessKey);
                    break;

                case "FINISH":

                    largeUpload("https://content.dropboxapi.com/2/files/upload_session/finish", uploadModel.get(0).currentUlItemPath, origData, "FINISH", uploadOffsetValue, "Bearer " + settings.accessKey);
                    break;

                case "UPLOAD":

                    upload("https://content.dropboxapi.com/2/files/upload", uploadModel.get(0).currentUlItemPath, origData, "Bearer " + settings.accessKey);

                }

            }

            else {

                console.log("Error reauthorizing: " + responseCode);
                console.log("Response text: " + responseText);
                notificationMain.previewSummary = qsTr("Error reauthorizing. Please try submitting request again.");
                notificationMain.publish();
                activeUlTransfer = false;
                uploadLargeItemSession = "";
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

            uploadedSoFar: 0; uploadTotal: 0; uploadProgress: 0.0; uploadProgressPct: ""; currentUlItem: ""; currentUlItemPath: ""; currentLocalFolderPath: ""; currentUlItemLarge: ""; currentUlItemTotalSegments: 0;

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
                label: activeUlLarge ? qsTr("Uploading ") + currentUlItemLarge : qsTr("Uploading ") + currentUlItem

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
