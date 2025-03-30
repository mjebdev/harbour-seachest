import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import NetworkAccess 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    property string currentDownload
    property string localHeaderName
    property string currentFolderPath
    property string selectedLocalFile
    property string selectedFileName
    property bool homeFolder

    ListModel {

        id: folderListModel

        ListElement {

            itemName: ""; itemID: ""; itemTag: ""; itemSize: 0; itemType: ""; itemPath: ""; itemPathDisplay: ""; itemIcon: ""; serverModified: ""; clientModified: ""; typeIsImage: false

        }

    }

    NetworkAccess {

        id: containerRequest

        onFinished: {

            console.log("responseCode: " + responseCode);
            var moreLeft = false;

            if (requestType == "CREATE_FOLDER") {

                if (responseCode == 200) {

                    postRequest("https://api.dropboxapi.com/2/files/list_folder", "{\"path\":\"" + folderToList + "\", \"include_non_downloadable_files\": false}", "Bearer " + settings.accessKey, "LIST_FOLDER");

                }

                else if (responseCode == 401) {

                    tokenRefresh("CREATE_FOLDER", "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, responseText, "{}");

                }

                else {

                    console.log("Error " + responseCode + " - Request type is CREATE_FOLDER - Response text: " + responseText);

                    if (responseText.indexOf("\"error summary\": \"path/conflict/folder" !== 0)) {

                        notificationMain.previewSummary = qsTr("Error - Conflict with an existing folder path. Please choose a different name and try again.");
                        notificationMain.publish();

                    }

                    else {

                        notificationMain.previewSummary = qsTr("Error creating folder - Code %1").arg(responseCode);
                        notificationMain.publish();

                    }

                    postRequest("https://api.dropboxapi.com/2/files/list_folder", "{\"path\":\"" + folderToList + "\", \"include_non_downloadable_files\": false}", "Bearer " + settings.accessKey, "LIST_FOLDER");

                }

            }

            else { // folder listing request

                switch (responseCode) {

                    case 200: {

                        var parsedResponse = JSON.parse(responseText);

                        for (var i = 0; i < parsedResponse.entries.length; i++) {

                            var fileName = parsedResponse.entries[i].name;
                            var lastFour = "";
                            var iconString = "";
                            var isAnImage = false;

                            if (parsedResponse.entries[i][".tag"] == "folder") {

                                iconString = "image://theme/icon-m-file-folder";
                                isAnImage = false;

                            }

                            else {

                                lastFour = parsedResponse.entries[i].name.slice((fileName.length - 4), fileName.length);
                                lastFour = lastFour.toUpperCase();

                                switch (lastFour) {

                                case ".JPG":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case "JPEG":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case ".PNG":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case "TIFF":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case ".TIF":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case ".GIF":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case "WEBP":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case ".PPM":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case ".BMP":
                                    iconString = "image://theme/icon-m-file-image";
                                    isAnImage = true;
                                    break;
                                case ".RPM":
                                    iconString = "image://theme/icon-m-file-rpm";
                                    isAnImage = false;
                                    break;
                                case ".PDF":
                                    iconString = "image://theme/icon-m-file-pdf-dark";
                                    isAnImage = false;
                                    break;
                                case ".MP4":
                                    iconString = "image://theme/icon-m-file-video";
                                    isAnImage = false;
                                    break;
                                case ".TXT":
                                    iconString = "image://theme/icon-m-file-document-dark";
                                    isAnImage = false;
                                    break;
                                case "TEXT":
                                    iconString = "image://theme/icon-m-file-document-dark";
                                    isAnImage = false;
                                    break;
                                case ".ZIP":
                                    iconString = "image://theme/icon-m-file-archive-folder";
                                    isAnImage = false;
                                    break;
                                case ".MP3":
                                    iconString = "image://theme/icon-m-file-audio";
                                    isAnImage = false;
                                    break;
                                case ".M4A":
                                    iconString = "image://theme/icon-m-file-audio";
                                    isAnImage = false;
                                    break;
                                case ".APK":
                                    iconString = "image://theme/icon-m-file-apk";
                                    isAnImage = false;
                                    break;
                                default:
                                    iconString = "image://theme/icon-m-file-other-dark";
                                    isAnImage = false;

                                }

                            }

                            var tempClientMod = new Date(parsedResponse.entries[i].client_modified);
                            var tempServerMod = new Date(parsedResponse.entries[i].server_modified);
                            folderListModel.append({itemName: fileName, itemID: parsedResponse.entries[i].id, itemTag: parsedResponse.entries[i][".tag"], itemSize: parsedResponse.entries[i].size, itemPath: parsedResponse.entries[i].path_lower, itemPathDisplay: parsedResponse.entries[i].path_display, serverModified: tempServerMod.toLocaleString(Locale.ShortFormat), clientModified: tempClientMod.toLocaleString(Locale.ShortFormat), typeIsImage: isAnImage, itemIcon: iconString});

                        }

                        if (parsedResponse.has_more) {

                            this.postRequest("https://api.dropboxapi.com/2/files/list_folder/continue", "{\"cursor\":\"" + parsedResponse.cursor + "\"}", "Bearer " + settings.accessKey, "LIST_FOLDER");
                            moreLeft = true;

                        }

                        break;

                    }

                    case 400: {

                        downloadNotifier.previewSummary = qsTr("Bad input parameter. Error copied.");
                        downloadNotifier.publish();
                        Clipboard.text = responseText;
                        break;

                    }

                    case 401: {

                        console.log("Response code 401. Response text: " + responseText);
                        tokenRefresh("LIST_FOLDER", "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, responseText, "{}");
                        moreLeft = true; // Keep indicator spinning even though not listing any new items.
                        break;

                    }

                    case 403: {

                        downloadNotifier.previewSummary = "Access to this feature was denied.";
                        downloadNotifier.publish();
                        break;

                    }

                    case 409: {

                        downloadNotifier.previewSummary = "Endpoint-specific error. Error copied to clipboard.";
                        downloadNotifier.publish();
                        Clipboard.text = responseText;
                        break;

                    }

                    case 429: {

                        downloadNotifier.previewSummary = "Too many requests.";
                        downloadNotifier.publish();
                        break;

                    }

                    default: {

                        if (responseCode.toString().slice(0, 1) === "5") {

                            downloadNotifier.expireTimeout = 2800;
                            downloadNotifier.previewSummary = "Error on Dropbox servers. Check status.dropbox.com for details.";
                            downloadNotifier.publish();
                            downloadNotifier.expireTimeout = 1800;

                        }

                        else {

                            downloadNotifier.previewSummary = "Unknown Error " + responseCode + ". Copied to Clipboard.";
                            downloadNotifier.publish();
                            Clipboard.text = responseText;

                        }

                    }

                }

            }

            console.log("currentFolderPath is " + currentFolderPath + ".");
            pageStack.pushAttached(Qt.resolvedUrl("Search.qml"), {"folderName": localHeaderName, "folderPath": currentFolderPath, "homeFolder": homeFolder});
            // the above was not working when placed in a Component.onCompleted function so placing at the end of a successful-http-request response processing.
            if (moreLeft === false) listItemsBusy.running = false;

        }

        onRefreshFinished: {

            if (responseCode == 200) {

                var responseParsed = JSON.parse(responseText);
                settings.accessKey = responseParsed.access_token;
                settings.sync();
                console.log("Reauthorized.");
                if (origRequestType == "CREATE_FOLDER") postRequest("https://api.dropboxapi.com/2/files/create_folder_v2", origData, "Bearer " + settings.accessKey, origRequestType);
                else postRequest("https://api.dropboxapi.com/2/files/list_folder", origData, "Bearer " + settings.accessKey, origRequestType);

            }

            else console.log("Error reauthorizing in containerRequest. responseCode: " + responseCode + "\nresponseText: " + responseText);

        }

    }

    Component.onCompleted: {

        if (folderToList === "") {

            homeFolder = true;
            homeOrRefreshMenu.text = qsTr("Refresh");

        }

        localHeaderName = folderToListName;
        console.log("folderToList is " + folderToList + ".");
        currentFolderPath = folderToListPath;
        folderListModel.clear();
        listItemsBusy.running = true;
        containerRequest.postRequest("https://api.dropboxapi.com/2/files/list_folder", "{\"path\":\"" + folderToList + "\", \"include_non_downloadable_files\": false}", "Bearer " + settings.accessKey, "LIST_FOLDER");

    }

    SilicaListView {

        id: listView
        model: folderListModel
        clip: true
        anchors.fill: parent

        PullDownMenu {

            MenuItem {

                text: qsTr("About");

                onClicked: {

                    pageStack.push(Qt.resolvedUrl("About.qml"));

                }

            }

            MenuItem {

                text: qsTr("Settings");

                onClicked: {

                    pageStack.push(Qt.resolvedUrl("Settings.qml"));

                }

            }

            MenuItem {

                id: homeOrRefreshMenu
                text: qsTr("Home");

                onClicked: {

                    folderToList = "";
                    folderToListName = qsTr("Home");
                    folderToListPath = "";
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("Home.qml"), null, PageStackAction.Immediate);

                }

            }

            MenuItem {

                id: createFolderMenu
                text: qsTr("Create Folder")

                onClicked: {

                    pageStack.push(createFolderDialog, {"currentPath": currentFolderPath});

                }

            }

            MenuItem {

                text: activeUlTransfer ? qsTr("Upload in progress") : qsTr("Upload");
                enabled: !activeUlTransfer

                onClicked: {

                    pageStack.push(filePickerPage);

                }

            }

        }

        header: PageHeader {

            title: localHeaderName

        }

        delegate: ListItem {

            id: listItem
            contentHeight: delegateItemRow.height
            openMenuOnPressAndHold: settings.itemTapToDl

            BusyIndicator {

                id: itemRequestBusy
                running: false
                anchors.centerIn: parent
                size: BusyIndicatorSize.Small

            }

            menu: ContextMenu {

                id: itemMenu
                property bool thumbnailRequested

                onStateChanged: {

                    if (open && !thumbnailRequested && typeIsImage && settings.showThumbnailForImageFiles) {

                        thumbnailRequested = true;
                        // Probably a better way to come up with a cache file name but going with this for now.
                        var keepEmSeparated = new Date().getTime();
                        var fileString = itemName + keepEmSeparated.toString() + ".jpeg"; // Need to assign as string first?
                        getThumbnail.downloadThumbnail("https://content.dropboxapi.com/2/files/get_thumbnail_v2", "{\"resource\":{\".tag\":\"path\",\"path\":\"" + itemID + "\"}, \"size\": \"w256h256\"}", fileString, "Bearer " + settings.accessKey);

                    }

                }

                MenuItem {

                    enabled: false
                    height: Theme.itemSizeHuge + (Theme.paddingMedium * 2)
                    visible: typeIsImage && settings.showThumbnailForImageFiles

                    BusyIndicator {

                        id: loadThumbnailBusy
                        anchors.centerIn: parent
                        running: true
                        size: BusyIndicatorSize.Small

                    }

                    NetworkAccess {

                        id: getThumbnail

                        onFinished: {

                            switch (responseCode) {

                                case 200: {

                                    // Assign file url to image value etc.
                                    thumbnailImage.source = Qt.resolvedUrl(requestType);
                                    loadThumbnailBusy.running = false;
                                    break;

                                }

                                case 400: {

                                    downloadNotifier.previewSummary = qsTr("Bad input parameter. Error copied.");
                                    downloadNotifier.publish();
                                    Clipboard.text = responseText;
                                    break;

                                }

                                case 401: {

                                    tokenRefresh("THUMBNAIL", "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, responseText, "{}");
                                    break;

                                }

                                case 403: {

                                    downloadNotifier.previewSummary = qsTr("Access to this feature was denied.");
                                    downloadNotifier.publish();
                                    break;

                                }

                                case 409: {

                                    downloadNotifier.previewSummary = qsTr("Endpoint-specific error. Error copied to clipboard.");
                                    downloadNotifier.publish();
                                    Clipboard.text = responseText;
                                    break;

                                }

                                case 429: {

                                    downloadNotifier.previewSummary = qsTr("Too many requests.");
                                    downloadNotifier.publish();
                                    break;

                                }

                                case 999: {

                                    downloadNotifier.previewSummary = qsTr("Error saving thumbnail to cache folder.");
                                    downloadNotifier.publish();

                                }

                            }

                        }

                        onRefreshFinished: {

                            if (responseCode === 200) {

                                console.log("onRefreshFinished - responseCode 200. Retrying the upload function with new accessKey.")
                                var responseParsed = JSON.parse(responseText);
                                settings.accessKey = responseParsed.access_token;
                                settings.sync();
                                var keepEmSeparated = new Date().getTime();
                                console.log("testing access to model values -- itemName: " + itemName);
                                var fileString = itemName + keepEmSeparated.toString() + ".jpeg";
                                downloadThumbnail("https://content.dropboxapi.com/2/files/get_thumbnail_v2", origData, fileString, "Bearer " + settings.accessKey);

                            }

                            else {

                                console.log("Error when refreshing token.\nResponse code: " + responseCode + "\nResponse text: " + responseText);
                                downloadNotifier.previewSummary = qsTr("Error reauthorizing - ") + responseCode;
                                downloadNotifier.publish();

                            }

                        }

                    }

                    Image {

                        id: thumbnailImage
                        height: Theme.itemSizeHuge
                        width: height
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent

                    }

                }

                MenuItem {

                    enabled: false
                    height: Theme.itemSizeLarge + Theme.paddingMedium
                    visible: itemTag === "folder" ? false : true

                    Row {

                        width: parent.width
                        height: parent.height

                        Column {

                            width: parent.width * 0.5
                            height: parent.height

                            Row {

                                width: parent.width
                                height: parent.height * 0.05
                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.3

                                Label {

                                    width: parent.width
                                    height: parent.height
                                    verticalAlignment: "AlignVCenter"
                                    horizontalAlignment: "AlignRight"
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    color: Theme.secondaryColor
                                    rightPadding: Theme.paddingSmall
                                    text: qsTr("Modified on server:")

                                }

                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.3

                                Label {

                                    width: parent.width
                                    height: parent.height
                                    verticalAlignment: "AlignVCenter"
                                    horizontalAlignment: "AlignRight"
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    color: Theme.secondaryColor
                                    rightPadding: Theme.paddingSmall
                                    text: qsTr("Modified on client:")

                                }

                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.3

                                Label {

                                    width: parent.width
                                    height: parent.height
                                    verticalAlignment: "AlignVCenter"
                                    horizontalAlignment: "AlignRight"
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    color: Theme.secondaryColor
                                    rightPadding: Theme.paddingSmall
                                    text: qsTr("Size:")

                                }

                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.05
                            }

                        }

                        Column {

                            width: parent.width * 0.5
                            height: parent.height

                            Row {

                                width: parent.width
                                height: parent.height * 0.05
                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.3

                                Label {

                                    width: parent.width
                                    height: parent.height
                                    verticalAlignment: "AlignVCenter"
                                    horizontalAlignment: "AlignLeft"
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    color: Theme.secondaryColor
                                    leftPadding: Theme.paddingSmall
                                    text: serverModified

                                }

                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.3

                                Label {

                                    width: parent.width
                                    height: parent.height
                                    verticalAlignment: "AlignVCenter"
                                    horizontalAlignment: "AlignLeft"
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    color: Theme.secondaryColor
                                    leftPadding: Theme.paddingSmall
                                    text: clientModified

                                }
                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.3

                                Label {

                                    Component.onCompleted: {

                                        if (itemTag === "file") {

                                            const bytes = itemSize;
                                            const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
                                            if (bytes == 0) text = '0 B';

                                            else {

                                                var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
                                                if (i == 0) text = bytes + ' ' + sizes[i];
                                                else text = (bytes / Math.pow(1024, i)).toFixed(2) + ' ' + sizes[i];

                                            }

                                        }

                                    }

                                    width: parent.width
                                    height: parent.height
                                    verticalAlignment: "AlignVCenter"
                                    horizontalAlignment: "AlignLeft"
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    color: Theme.secondaryColor
                                    leftPadding: Theme.paddingSmall

                                }

                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.05

                            }

                        }

                    }

                }

                MenuItem {

                    text: qsTr("Open")
                    visible: itemTag === "folder"

                    onClicked: {

                        openFolder();

                    }

                }

                MenuItem {

                    text: itemTag === "folder" ? qsTr("Download ZIP") : qsTr("Download")

                    onClicked: {

                        if (itemTag === "folder") {

                            if (!activeDlTransfer) startZipDownload();

                            else {

                                downloadNotifier.previewSummary = "Download already in progress";
                                downloadNotifier.publish();

                            }

                        }

                        else {

                            if (!activeDlTransfer) startDownload();

                            else {

                                downloadNotifier.previewSummary = "Download already in progress";
                                downloadNotifier.publish();

                            }

                        }

                    }

                }

                MenuItem {

                    text: qsTr("Rename")

                    onClicked: {

                        delegateItemColumn.visible = false;
                        editText.text = itemName;
                        editText.visible = true;
                        editText.forceActiveFocus();

                    }

                }

                MenuItem {

                    text: qsTr("Create Link")
                    visible: itemTag == "file"

                    onClicked: {

                        itemRequestBusy.running = true;
                        itemRequest.postRequest("https://api.dropboxapi.com/2/files/get_temporary_link", "{\"path\":\"" + itemID + "\"}", "Bearer " + settings.accessKey, "CREATE_LINK");

                    }

                }

                MenuItem {

                    enabled: false
                    height: Theme.paddingLarge

                    Separator {

                        width: parent.width - (Theme.horizontalPageMargin * 2)
                        x: Theme.horizontalPageMargin
                        y: (parent.height - this.height) * 0.5
                        horizontalAlignment: Qt.AlignHCenter
                        color: Theme.secondaryColor

                    }

                }

                MenuItem {

                    text: itemTag === "folder" ? qsTr("Delete Folder") : qsTr("Delete File")
                    color: Theme.errorColor

                    onClicked: {

                        listItem.remorseDelete(function() {

                            itemRequestBusy.running = true;
                            itemRequest.postRequest("https://api.dropboxapi.com/2/files/delete_v2", "{\"path\":\"" + itemID + "\"}", "Bearer " + settings.accessKey, "DELETE");

                        });

                    }

                }

            }

            NetworkAccess {

                id: itemRequest

                onFinished: {

                    switch (responseCode) {

                    case 200:

                        itemRequestBusy.running = false;
                        var idx = index;

                        if (requestType === "RENAME") {

                            folderListModel.set(index, {"itemName": editText.text});
                            editText.focus = false;

                        }

                        else if (requestType == "CREATE_LINK") {

                            var jsonLink = JSON.parse(responseText);
                            console.log("Link gathered from response: " + jsonLink.link);
                            Clipboard.text = jsonLink.link;
                            notificationMain.previewSummary = qsTr("4-hour link copied to clipboard.");
                            notificationMain.publish();
                            itemRequestBusy.running = false;

                        }

                        else {

                            folderListModel.remove(idx);

                        }

                        break;

                    case 401:

                        var url = "";

                        switch (requestType) {

                        case "RENAME":
                            url = "https://api.dropboxapi.com/2/files/move_v2";
                            break;
                        case "CREATE_LINK":
                            url = "https://api.dropboxapi.com/2/files/get_temporary_link";
                            break;
                        case "DELETE":
                            url = "https://api.dropboxapi.com/2/files/delete_v2";

                        }

                        tokenRefresh(requestType, "https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken, responseText, url);
                        break;

                    case 409:

                        console.log("Response code is 409\nResponse text: " + responseText);
                        // could be various reasons, same name as before being one.
                        itemRequestBusy.running = false;
                        editText.focus = false;
                        if (requestType === "RENAME") downloadNotifier.previewSummary = qsTr("Unable to rename item. Please try again & avoid entering the same name.");
                        else if (requestType === "DELETE" ) downloadNotifier.previewSummary = qsTr("Unable to delete item. Error code 409.");
                        else downloadNotifier.previewSummary = qsTr("Unable to create link. Error code 409.");
                        downloadNotifier.publish();
                        break;

                    default:

                        itemRequestBusy.running = false;
                        editText.focus = false;
                        downloadNotifier.previewSummary = qsTr("Unexpected error - Code ") + responseCode;
                        downloadNotifier.publish();
                        console.log("Error code: " + responseCode + "\nResponse text: " + responseText);

                    }

                }

                onRefreshFinished: {

                    if (responseCode === 200) {

                        var responseParsed = JSON.parse(responseText);
                        settings.accessKey = responseParsed.access_token;
                        settings.sync();
                        postRequest(origSupplemental, origData, "Bearer " + settings.accessKey, origRequestType);

                    }

                    else {

                        downloadNotifier.previewSummary = qsTr("Error reauthorizing - ") + responseCode;
                        downloadNotifier.publish();
                        console.log("Token refresh attempt failed - response code: " + responseCode + "\nResponse text: " + responseText + "\nOriginal request type: " + origRequestType);
                        listItemsBusy.running = false;

                    }

                }

            }

            function startDownload() {

                if (settings.downloadToDownloads) {

                    if (containerRequest.fileAlreadyExists(settings.downloadDestination + '/' + itemName) && settings.overwriteWarning) pageStack.push(confirmOverwriteDialog, {"fileName": itemName, "fileId": itemID});

                    else {

                        downloadModel.set(0, {"currentDlItem": itemName, "currentDlItemID": itemID, "downloadProgressPct": "0%"});
                        activeDlTransfer = true;
                        mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download", "{\"path\":\"" + itemID + "\"}", itemName, "Bearer " + settings.accessKey, settings.downloadDestination);

                    }

                }

                else {

                    if (containerRequest.directoryExists(settings.downloadDestination)) { // incase SD card removed or folder deleted etc.

                        if (containerRequest.fileAlreadyExists(settings.downloadDestination + '/' + itemName) && settings.overwriteWarning) pageStack.push(confirmOverwriteDialog, {"fileName": itemName, "fileId": itemID});

                        else {

                            downloadModel.set(0, {"currentDlItem": itemName, "currentDlItemID": itemID, "downloadProgressPct": "0%"});
                            activeDlTransfer = true;
                            mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download", "{\"path\":\"" + itemID + "\"}", itemName, "Bearer " + settings.accessKey, settings.downloadDestination);

                        }

                    }

                    else { // revert to default download folder being system Downloads folder.

                        settings.downloadToDownloads = true;
                        settings.downloadDestination = defaultDownloadsLocation;
                        settings.sync();

                        if (containerRequest.fileAlreadyExists(settings.downloadDestination + '/' + itemName) && settings.overwriteWarning) pageStack.push(confirmOverwriteDialog, {"fileName": itemName, "fileId": itemID});

                        else {

                            downloadModel.set(0, {"currentDlItem": itemName, "currentDlItemID": itemID, "downloadProgressPct": "0%"});
                            activeDlTransfer = true;
                            mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download", "{\"path\":\"" + itemID + "\"}", itemName, "Bearer " + settings.accessKey, settings.downloadDestination);

                        }

                    }

                }

            }

            function startZipDownload() {

                if (settings.downloadToDownloads) {

                    if (containerRequest.fileAlreadyExists(settings.downloadDestination + '/' + itemName + ".zip") && settings.overwriteWarning) pageStack.push(confirmOverwriteDialog, {"fileName": itemName + ".zip", "fileId": itemID});

                    else {

                        downloadModel.set(0, {"currentDlItem": itemName + ".zip", "currentDlItemID": itemID, "downloadProgressPct": "0%"});
                        activeDlTransfer = true;
                        mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download_zip", "{\"path\":\"" + itemID + "\"}", itemName + ".zip", "Bearer " + settings.accessKey, settings.downloadDestination);

                    }

                }

                else {

                    if (containerRequest.directoryExists(settings.downloadDestination)) { // incase SD card removed or folder deleted etc.

                        if (containerRequest.fileAlreadyExists(settings.downloadDestination + '/' + itemName + ".zip") && settings.overwriteWarning) pageStack.push(confirmOverwriteDialog, {"fileName": itemName + ".zip", "fileId": itemID});

                        else {

                            downloadModel.set(0, {"currentDlItem": itemName + ".zip", "currentDlItemID": itemID, "downloadProgressPct": "0%"});
                            activeDlTransfer = true;
                            mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download_zip", "{\"path\":\"" + itemID + "\"}", itemName + ".zip", "Bearer " + settings.accessKey, settings.downloadDestination);

                        }

                    }

                    else {

                        settings.downloadToDownloads = true;
                        settings.downloadDestination = defaultDownloadsLocation;
                        settings.sync();

                        if (containerRequest.fileAlreadyExists(settings.downloadDestination + '/' + itemName + ".zip") && settings.overwriteWarning) pageStack.push(confirmOverwriteDialog, {"fileName": itemName + ".zip", "fileId": itemID});

                        else {

                            downloadModel.set(0, {"currentDlItem": itemName + ".zip", "currentDlItemID": itemID, "downloadProgressPct": "0%"});
                            activeDlTransfer = true;
                            mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download_zip", "{\"path\":\"" + itemID + "\"}", itemName + ".zip", "Bearer " + settings.accessKey, settings.downloadDestination);

                        }

                    }

                }

            }

            function openFolder() {

                folderToList = itemID;
                folderToListName = itemName;
                folderToListPath = itemPath;
                pageStack.push(Qt.resolvedUrl("Home.qml"));

            }

            onClicked: {

                if (settings.itemTapToDl) {

                    if (itemTag === "folder") openFolder();

                    else {

                        if (!activeDlTransfer) startDownload();

                        else {

                            downloadNotifier.previewSummary = "Download already in progress";
                            downloadNotifier.publish();

                        }

                    }

                }

                else {

                    if (menuOpen) closeMenu();
                    else openMenu();

                }

            }

            onPressAndHold: {

                if (!settings.itemTapToDl) {

                    if (itemTag === "folder") openFolder();

                    else {

                        if (!activeDlTransfer) startDownload();

                        else {

                            downloadNotifier.previewSummary = "Download already in progress";
                            downloadNotifier.publish();

                        }

                    }

                }

            }

            Row {

                id: delegateItemRow
                width: parent.width - (Theme.horizontalPageMargin * 2)
                height: editText.visible ? editText.height + (Theme.paddingMedium * 2) : fileOrFolderItemRow.height + topGapRow.height + bottomGapRow.height
                x: Theme.horizontalPageMargin

                TextField {

                    id: editText
                    width: parent.width
                    visible: false
                    anchors.verticalCenter: parent.verticalCenter
                    wrapMode: Text.WordWrap
                    backgroundStyle: TextEditor.NoBackground
                    labelVisible: false
                    horizontalAlignment: Text.AlignHCenter

                    onFocusChanged: {

                        if (!focus) {

                            editText.visible = false;
                            editText.text = "";
                            delegateItemColumn.visible = true;

                        }

                    }

                    EnterKey.onClicked: {

                        itemRequestBusy.running = true;
                        var folderPath = itemPath.slice(0, (itemPath.length - itemName.length));
                        if (settings.autoRename) itemRequest.postRequest("https://api.dropbox.com/2/files/move_v2", "{\"from_path\":\"" + itemPath + "\", \"to_path\":\"" + folderPath + editText.text + "\",\"autorename\":true}", "Bearer " + settings.accessKey, "RENAME");
                        else itemRequest.postRequest("https://api.dropbox.com/2/files/move_v2", "{\"from_path\":\"" + itemPath + "\", \"to_path\":\"" + folderPath + editText.text + "\",\"autorename\":false}", "Bearer " + settings.accessKey, "RENAME");

                    }

                }

                Column {

                    id: delegateItemColumn
                    width: parent.width
                    height: fileOrFolderItemRow.height + topGapRow.height + bottomGapRow.height

                    Row {

                        id: topGapRow
                        height: Theme.paddingSmall
                        width: parent.width

                    }

                    Row {

                        id: fileOrFolderItemRow
                        width: parent.width
                        height: fileNameRow.height

                        Column {

                            id: fileIconColumn
                            width: fileIcon.width
                            height: fileNameRow.height
                            topPadding: (height - fileIcon.height) / 2

                            Row {

                                id: fileIconRow
                                width: parent.width

                                Icon {

                                    id: fileIcon
                                    source: itemIcon

                                }

                            }

                        }

                        Column {

                            id: fileNameColumn
                            width: parent.width - fileIconColumn.width
                            height: fileNameRow.height

                            Row {

                                id: fileNameRow
                                width: parent.width - Theme.paddingMedium
                                height: fileOrFolderItem.lineCount > 1 ? fileOrFolderItem.height : fileIcon.height
                                x: Theme.paddingSmall

                                Label {

                                    id: fileOrFolderItem
                                    text: itemName
                                    width: parent.width
                                    height: lineCount > 1 ? text.height : parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    truncationMode: itemMenu.active ? TruncationMode.None : TruncationMode.Fade
                                    maximumLineCount: itemMenu.active ? 10 : 1
                                    wrapMode: itemMenu.active ? Text.WordWrap : Text.NoWrap
                                    topPadding: lineCount > 1 ? Theme.paddingSmall : 0
                                    bottomPadding: lineCount > 1 ? Theme.paddingSmall : 0

                                }

                            }

                        }

                    }

                    Row {

                        id: bottomGapRow
                        height: Theme.paddingSmall
                        width: parent.width

                    }

                }

            }

        }

        VerticalScrollDecorator { }

    }

    Component {

        id: filePickerPage

        FilePickerPage {

            title: qsTr("Upload")

            onSelectedContentPropertiesChanged: {

                page.selectedFileName = selectedContentProperties.fileName;
                page.selectedLocalFile = selectedContentProperties.filePath;
                var uploadToHere = currentFolderPath;
                if (settings.uploadToHomeFolder) uploadToHere = "";
                uploadModel.set(0, {"currentUlItem": page.selectedFileName, "currentUlItemPath": page.selectedLocalFile, "currentFolderPath": uploadToHere, "uploadProgress": 0.0, "uploadProgressPct": "0%"});
                activeUlTransfer = true;
                mainUpload.upload("https://content.dropboxapi.com/2/files/upload", page.selectedLocalFile, "{\"path\":\"" + uploadToHere + "/" + page.selectedFileName + "\"}", "Bearer " + settings.accessKey);

            }

        }

    }

    Component {

        id: confirmOverwriteDialog

        Dialog {

            property string fileName
            property string fileId

            Column {

                width: parent.width

                DialogHeader { }

                Label {

                    width: parent.width - (Theme.horizontalPageMargin * 2)
                    x: Theme.horizontalPageMargin
                    text: qsTr("A file with the name \"%1\" already exists in the destination folder.").arg(fileName);
                    color: Theme.highlightColor
                    wrapMode: Text.WordWrap
                    bottomPadding: Theme.paddingLarge

                }

                Label {

                    topPadding: Theme.paddingLarge
                    width: parent.width - (Theme.horizontalPageMargin * 2)
                    x: Theme.horizontalPageMargin
                    text: qsTr("Overwrite?");
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.highlightColor

                }

            }

            onAccepted: {

                downloadModel.set(0, {"currentDlItem": fileName, "currentDlItemID": fileId, "downloadProgressPct": "0%"});
                activeDlTransfer = true;
                mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download", "{\"path\":\"" + fileId + "\"}", fileName, "Bearer " + settings.accessKey, settings.downloadDestination);

            }

        }

    }

    Component {

        id: createFolderDialog

        Dialog {

            id: dialog
            property string currentPath

            Column {

                width: parent.width

                DialogHeader { }

                Label {

                    width: parent.width - (Theme.horizontalPageMargin * 2)
                    x: Theme.horizontalPageMargin
                    text: qsTr("Create Folder");
                    color: Theme.highlightColor
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeLarge
                    topPadding: Theme.paddingLarge
                    bottomPadding: Theme.paddingLarge * 2

                }

                TextField {

                    id: folderNameText
                    width: parent.width - (Theme.horizontalPageMargin * 2)
                    x: Theme.horizontalPageMargin
                    label: qsTr("Name")
                    placeholderText: qsTr("Untitled")
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeLarge
                    wrapMode: TextInput.Wrap

                }

            }

            onAccepted: {

                listItemsBusy.running = true;
                folderListModel.clear();
                if (folderNameText.text == "") containerRequest.postRequest("https://api.dropboxapi.com/2/files/create_folder_v2", "{\"path\":\"" + currentFolderPath + "/" + qsTr("Untitled") + "\"}", "Bearer " + settings.accessKey, "CREATE_FOLDER");
                else containerRequest.postRequest("https://api.dropboxapi.com/2/files/create_folder_v2", "{\"path\":\"" + currentFolderPath + "/" + folderNameText.text + "\"}", "Bearer " + settings.accessKey, "CREATE_FOLDER");

            }

        }

    }

    Notification {

        id: downloadNotifier
        isTransient: true
        expireTimeout: 1500

    }

    BusyIndicator {

        id: listItemsBusy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: false

    }

}
