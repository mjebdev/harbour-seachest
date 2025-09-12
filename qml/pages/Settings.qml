import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Sailfish.Pickers 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    SilicaFlickable {

        id: mainFlickable
        anchors.fill: parent
        contentHeight: column.height

        Column {

            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {

                title: qsTr("Settings")

            }

            SectionHeader {

                text: qsTr("Interface")

            }

            ComboBox {

                label: qsTr("Action to download a file")
                id: downloadActionCombo
                width: parent.width
                currentIndex: settings.itemTapToDl ? 0 : 1
                leftMargin: Theme.horizontalPageMargin
                description: currentIndex === 0 ? qsTr("Press & hold for all options") : qsTr("Tap for all options")

                menu: ContextMenu {

                    MenuItem {

                        text: qsTr("Tap")

                        onClicked: {

                            settings.itemTapToDl = true;
                            settings.sync();

                        }

                    }

                    MenuItem {

                        text: qsTr("Press & hold")

                        onClicked: {

                            settings.itemTapToDl = false;
                            settings.sync();

                        }

                    }

                }

            }

            SectionHeader {

                text: qsTr("Downloads")

            }

            TextSwitch {

                id: overwriteWarningSwitch
                text: qsTr("Show warning prior to overwriting a file on device");
                checked: settings.overwriteWarning

                onClicked: {

                    settings.overwriteWarning = checked;
                    settings.sync();

                }

            }

            TextSwitch {

                id: downloadDestinationSwitch
                text: qsTr("Save files to the Downloads folder")
                checked: settings.downloadToDownloads
                automaticCheck: false
                description: settings.downloadToDownloads ? "" : qsTr("Currently set to ") + settings.downloadDestination

                onClicked: {

                    if (checked) pageStack.push(folderPickerPage);

                    else {

                        checked = true;
                        description = "";
                        settings.downloadToDownloads = true;
                        settings.downloadDestination = defaultDownloadsLocation;
                        settings.sync();

                    }

                }

            }

            SectionHeader {

                text: qsTr("Search")

            }

            TextSwitch {

                id: justSearchFolderSwitch
                text: qsTr("Show option to search current folder only")
                checked: settings.justSearchFolder

                onCheckedChanged: {

                    settings.justSearchFolder = checked;
                    settings.sync();

                }

            }

            SectionHeader {

                text: qsTr("Authorization")

            }

            Item {

                width: parent.width
                height: Theme.paddingMedium

            }

            ButtonLayout {

                Button {

                    id: forgetAccessKey
                    text: qsTr("Erase Access Key")

                    onClicked: {

                        folderToList = "";
                        folderToListName = qsTr("Home");
                        folderToListPath = "";
                        settings.accessKey = "";
                        settings.refreshToken = "";
                        settings.sync();
                        pageStack.clear();
                        pageStack.replace(Qt.resolvedUrl("Authorize.qml"));

                    }

                }

            }

        }

    }

    Component {

        id: folderPickerPage

        FolderPickerPage {

            title: qsTr("Save files in")

            onSelectedPathChanged: {

                if (selectedPath) {

                    settings.downloadToDownloads = false;
                    settings.downloadDestination = selectedPath;
                    settings.sync();
                    downloadDestinationSwitch.checked = false;
                    downloadDestinationSwitch.description = qsTr("Currently set to ") + selectedPath;

                }

            }

        }

    }

    Notification {

        id: settingsNotification
        isTransient: true
        appName: "SeaChest"
        expireTimeout: 2000

    }

}
