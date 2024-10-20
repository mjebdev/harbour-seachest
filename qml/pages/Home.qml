import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import NetworkAccess 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string currentDownload
    property string localHeaderName
    property string localFolderPath
    property string authorizationToken
    property string selectedLocalFile
    property string selectedFileName
    property int listViewHeight

    ListModel {

        id: folderListModel

        ListElement {

            itemName: ""; itemID: ""; itemTag: ""; itemSize: 0; itemType: ""; itemPath: ""; itemPathDisplay: ""; itemIcon: ""; serverModified: ""; clientModified: ""; typeIsImage: false

        }

    }

    NetworkAccess {

        id: listFolderOrUpload

        onFinished: {

            console.log("responseCode: " + responseCode);
            var moreLeft = false;

            if (requestType === "TOKEN_REFRESH") {

                if (responseCode === 200) {

                    var responseParsed = JSON.parse(responseText);
                    settings.accessKey = responseParsed.access_token;
                    settings.sync();
                    notificationMain.previewSummary = qsTr("Reauthorized");
                    notificationMain.publish();

                    // folderToList should still be the same value? -- no chance for user to have changed it, swipe back destroys page anyway, nothing to tap on
                    // without list of items etc.
                    listFolderContents("https://api.dropboxapi.com/2/files/list_folder", "{\"path\":\"" + folderToList + "\", \"include_non_downloadable_files\": false}", "Bearer " + settings.accessKey);

                }

                else if (responseCode === 301) {

                    console.log("Response code is 301 and the responseText is: " + responseText);
                    folderRefresh(responseText + settings.refreshToken);
                    //moreLeft = true;

                }

                else {

                    // handle app not reauthorizing.
                    notificationMain.previewSummary = qsTr("Error reauthorizing. Please try resubmitting your request.");
                    notificationMain.publish();
                    console.log("Response code: " + responseCode);
                    console.log("Request type: " + requestType);
                    console.log("Response text: " + responseText);

                }

            }

            else {

                switch (responseCode) {

                    case 200: {

                        var parsedResponse = JSON.parse(responseText);

                        for (var i = 0; i < parsedResponse.entries.length; i++) {

                            // Get type -- not included with file list output, will delete if this adds too much time to rendering list. But useful if determining whether to try to get Thumbnail for an image and what icon to use.
                            var fileName = parsedResponse.entries[i].name;
                            var lastFour = "";
                            var iconString = "";
                            var isAnImage = false;

                            if (parsedResponse.entries[i][".tag"] == "folder") {

                                iconString = "image://theme/icon-m-file-folder";
                                isAnImage = false;

                            }
/*
                            else if (fileName.indexOf(".") == -1) {

                                // Avoiding a filename ending e.g. tiff that is not an image..
                                // Either a folder or a file with no period, in either case set lastFour/type to: "NONE".
                                lastFour = "NONE";
                                iconString = "image://theme/icon-m-file-other-dark"; // Folders with override this with the 'tag' value when list is rendered. Even though string includes 'dark', icon does adjust when light Ambience is set.
                                isAnImage = false; // Even if it is, needs an extension!

                            }
*/
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
                                    iconString = "image://theme/icon-m-file-pdf-dark";
                                    isAnImage = false;
                                    break;
                                case ".ZIP":
                                    iconString = "image://theme/icon-m-file-pdf-dark";
                                    isAnImage = false;
                                    break;
                                case ".MP3":
                                    iconString = "image://theme/icon-m-file-audio";
                                    isAnImage = false;
                                    break;
                                case ".M4A":
                                    iconString = "image://theme/icon-m-file-pdf-dark";
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

                            this.listFolderContents("https://api.dropboxapi.com/2/files/list_folder/continue", "{\"cursor\":\"" + parsedResponse.cursor + "\"}", "Bearer " + settings.accessKey);
                            moreLeft = true;

                        }

                        else {

                            console.log("End of entries.");

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

                        // Need a way to keep saved the most recent request?
                        folderRefresh("https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken);
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
                            downloadNotifier.previewSummary = "Error on Dropbox Servers. Check status.dropbox.com for details.";
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

            if (moreLeft === false) listItemsBusy.running = false;

        }

        onRefreshFinished: {

            if (responseCode === 200) {

                var responseParsed = JSON.parse(responseText);
                settings.accessKey = responseParsed.access_token;
                settings.sync();
                notificationMain.previewSummary = "Reauthorized";
                notificationMain.publish();

                switch (requestType) {

                    case "DOWNLOAD": {

                        mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download", path, newFile, "Bearer " + settings.accessKey);
                        break;

                    }

                    case "UPLOAD": {

                        mainUpload.upload("https://content.dropboxapi.com/2/files/upload", path, newFile, "Bearer " + settings.accessKey);
                        break;

                    }

                    case "RENAME": {

                        console.log("Not yet implemented.");
                        break;

                    }

                    case "FILE_INFO": {

                        console.log("Not yet implemented.");
                        break;

                    }

                    case "DELETE": {

                        console.log("Not yet implemented.");

                    }

                }

            }

            else {

                console.log("Error reauthorizing: " + responseCode);
                console.log("Request type: " + requestType);
                console.log("Response text: " + responseText);
                notificationMain.previewSummary = qsTr("Error reauthorizing. Please try resubmitting your request.");
                notificationMain.publish();

            }

        }

    }

    Component.onCompleted: {

        // folder ID will be passed
        // spinner until http request complete, ask for contents of folder ID.

        if (folderToList === "") homeOrRefreshMenu.text = qsTr("Refresh");
        localHeaderName = folderToListName;
        localFolderPath = folderToListPath;
        folderListModel.clear();
        listItemsBusy.running = true;
        listFolderOrUpload.listFolderContents("https://api.dropboxapi.com/2/files/list_folder", "{\"path\":\"" + folderToList + "\", \"include_non_downloadable_files\": false}", "Bearer " + settings.accessKey);

    }

    SilicaListView {

        id: listView
        model: folderListModel
        //leftMargin: Theme.horizontalPageMargin // using x value in each item instead for same reason as below
        //rightMargin: Theme.horizontalPageMargin
        clip: true
        //spacing: Theme.paddingMedium // will use padding rows and BackgroundItem height value instead as it will highlight entire line when tapped

        anchors {

            top: page.top
            left: page.left
            right: page.right
            bottom: uploadStatusBar.top

        }


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
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("Home.qml"), null, PageStackAction.Immediate);

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

        delegate: ListItem { // using columns and rows even though more cumbersome because TextField's leftItem not aligned with text when the field is read-only and no option for leftItem with the Label object.

            id: listItem
            contentHeight: delegateItemRow.height
            openMenuOnPressAndHold: settings.itemTapToDl

            menu: ContextMenu {

                id: itemMenu
                property bool thumbnailRequested

                onStateChanged: {

                    if (open && !thumbnailRequested && typeIsImage && settings.showThumbnailForImageFiles) {

                        thumbnailRequested = true;
                        // Probably a better way to come up with a cache file name but going with this for now.
                        var keepEmSeparated = new Date().getTime();
                        var fileString = itemName + keepEmSeparated.toString() + ".jpeg"; // Need to assign as string first?
                        getThumbnail.downloadThumbnail("https://content.dropboxapi.com/2/files/get_thumbnail_v2", "{\"resource\":{\".tag\":\"path\",\"path\":\"" + itemID + "\"}, \"size\": \"w64h64\"}", fileString, "Bearer " + settings.accessKey);

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

                            if (requestType === "TOKEN_REFRESH") {

                                if (responseCode === 200) {

                                    downloadNotifier.previewSummary = qsTr("Reauthorized");
                                    downloadNotifier.publish();
                                    var responseParsed = JSON.parse(responseText);
                                    settings.accessKey = responseParsed.access_token;
                                    settings.sync();
                                    // Resubmit request for the thumbnail.
                                    var keepEmSeparated = new Date().getTime();
                                    var fileString = itemName + keepEmSeparated.toString() + ".jpeg"; // Need to assign as string first?
                                    getThumbnail.downloadThumbnail("https://content.dropboxapi.com/2/files/get_thumbnail_v2", "{\"resource\":{\".tag\":\"path\",\"path\":\"" + itemID + "\"}, \"size\": \"w128h128\"}", fileString, "Bearer " + settings.accessKey);

                                }

                                else {

                                    console.log("Error when refreshing token.\nResponse code: " + responseCode + "\nResponse text: " + responseText);
                                    downloadNotifier.previewSummary = qsTr("Error refreshing token: ") + responseCode + " - " + responseText;
                                    downloadNotifier.publish();

                                }

                            }

                            else {

                                switch (responseCode) {

                                    case 200: {

                                        // Assign file url to image value etc.
                                        thumbnailImage.source = Qt.resolvedUrl(requestType);
                                        loadThumbnailBusy.running = false;
                                        break;

                                    }
/* -- was needed when redirect may have been necessary using mjeb.dev - to evennode or digitalocean url.
                                    case 301: {

                                        console.log("Response code is 301 and the responseText is: " + responseText);
                                        folderRefresh(responseText + settings.refreshToken); // URL from 301 redirect will be the responseText
                                        break;

                                    }
*/
                                    case 400: {

                                        downloadNotifier.previewSummary = qsTr("Bad input parameter. Error copied.");
                                        downloadNotifier.publish();
                                        Clipboard.text = responseText;
                                        break;

                                    }

                                    case 401: {

                                        folderRefresh("https://nodejs.mjeb.dev/seachest/refresh?refresh_token=" + settings.refreshToken);
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

                                    width: parent.width
                                    height: parent.height
                                    verticalAlignment: "AlignVCenter"
                                    horizontalAlignment: "AlignLeft"
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    color: Theme.secondaryColor
                                    leftPadding: Theme.paddingSmall
                                    text: itemSize + qsTr(" bytes")

                                }

                            }

                            Row {

                                width: parent.width
                                height: parent.height * 0.05
                            }

                        }

                    }

                }
/*
                MenuItem {
                    
                    text: qsTr("Properties")
                    
                    onClicked: {
                        
                        // to new page with file properties
                        
                    }
                    
                }
*/
                MenuItem {
                    
                    text: itemTag === "folder" ? qsTr("Open") : qsTr("Download")
                    
                    onClicked: {
                        
                        if (itemTag === "folder") {

                            openFolder();

                        }

                        else {

                            if (!activeDlTransfer) {

                                startDownload();

                            } // nothing will happen if download is in progress

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

                        // the api call is to move the file / folder.
                        console.log("Rename option tapped.");

                    }

                }
                
                MenuItem {
                    
                    text: itemTag === "folder" ? qsTr("Delete Folder") : qsTr("Delete File")
                    
                    onClicked: {
                        
                        // start remorse timer
                        // remorseAction(string text, object action, int timeout)
                        console.log("Delete menu item tapped.");

                    }
                    
                }

            }

            function startDownload() {

                downloadModel.set(0, {"currentDlItem": itemName, "currentDlItemID": itemID, "downloadProgressPct": "0%"});
                activeDlTransfer = true;
                mainDownload.downloadFile("https://content.dropboxapi.com/2/files/download", "{\"path\":\"" + itemID + "\"}", itemName, "Bearer " + settings.accessKey);

            }

            function openFolder() {

                folderToList = itemID;
                folderToListName = itemName;
                folderToListPath = itemPath;
                pageStack.push(Qt.resolvedUrl("Home.qml"));

            }

            onClicked: { // Separate the immediate download from the menu for more options.

                if (settings.itemTapToDl) {

                    if (itemTag === "folder") {

                        openFolder();

                    }

                    else {

                        if (!activeDlTransfer) {

                            startDownload();

                        } // nothing will happen if download is in progress

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

                    if (itemTag === "folder") {

                        openFolder();

                    }

                    else {

                        if (!activeDlTransfer) {

                            startDownload();

                        } // nothing will happen if download is in progress

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
                x: Theme.horizontalPageMargin

                Column {

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

                        Column {

                            id: fileIconColumn
                            width: fileIcon.width
                            height: fileIcon.height

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
                            height: fileIconColumn.height

                            Row {

                                id: fileNameRow
                                width: parent.width - Theme.paddingMedium
                                x: Theme.paddingSmall

                                Label {

                                    id: fileOrFolderItem
                                    text: itemName
                                    width: parent.width
                                    height: fileNameColumn.height
                                    verticalAlignment: Text.AlignVCenter
                                    truncationMode: TruncationMode.Fade

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

    ListView   {

        id: uploadStatusBar
        model: uploadModel
        height: visible ? contentHeight + Theme.paddingMedium : 0
        visible: false //activeUlTransfer
        opacity: ulTransferOpacity
        interactive: false
        clip: true
        anchors.bottom: downloadStatusBar.top
        anchors.left: page.left
        anchors.right: page.right

        onVisibleChanged: {

            if (visible) ulTransferOpacity = 1.0;

        }

        onOpacityChanged: {

            if (opacity <= 0.1) activeUlTransfer = false;

        }

        Behavior on opacity {

            FadeAnimator {

                duration: 150

            }

        }

        delegate: ProgressBar {

            Component.onCompleted: {

                listViewHeight = height; // will only ever be one delegate but need to assign height to ListView...
                console.log("listViewHeight = " + listViewHeight);

            }

            id: uploadProgressSlider
            width: parent.width
            enabled: false
            value: uploadProgress
            valueText: uploadProgressPct
            label: "Uploading " + currentUlItem

        }

    }

    ListView   {

        id: downloadStatusBar
        model: downloadModel
        height: visible ? contentHeight + Theme.paddingMedium : 0
        visible: false //mainAppWindow.activeDlTransfer
        opacity: mainAppWindow.dlTransferOpacity
        interactive: false
        clip: true
        anchors.bottom: page.bottom
        anchors.left: page.left
        anchors.right: page.right

        onVisibleChanged: {

            if (visible) mainAppWindow.dlTransferOpacity = 1.0;

        }

        onOpacityChanged: {

            if (opacity <= 0.1) mainAppWindow.activeDlTransfer = false;

        }

        Behavior on opacity {

            FadeAnimator {

                duration: 150

            }

        }

        Behavior on visible {



        }

        delegate: ProgressBar {

            Component.onCompleted: {

                listViewHeight = height; // will only ever be one delegate but need to assign height to ListView...
                console.log("listViewHeight = " + listViewHeight);

            }

            id: downloadProgressSlider
            width: parent.width
            enabled: false
            value: downloadProgress
            valueText: downloadProgressPct
            label: "Downloading " + currentDlItem

        }

    }

    Component {

        id: filePickerPage

        FilePickerPage {

            title: "Upload"

            onSelectedContentPropertiesChanged: {

                // localFolderPath variable is misnamed, should be serverFolderPath?
                page.selectedFileName = selectedContentProperties.fileName;
                page.selectedLocalFile = selectedContentProperties.filePath;
                if (settings.uploadToHomeFolder) localFolderPath = "";
                uploadModel.set(0, {"currentUlItem": page.selectedFileName, "currentUlItemPath": page.selectedLocalFile, "currentLocalFolderPath": localFolderPath, "uploadProgress": 0.0, "uploadProgressPct": "0%"});
                activeUlTransfer = true;
                ulTransferOpacity = 1.0;
                mainUpload.upload("https://content.dropboxapi.com/2/files/upload", page.selectedLocalFile, "{\"path\":\"" + localFolderPath + "/" + page.selectedFileName + "\"}", "Bearer " + settings.accessKey);

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
