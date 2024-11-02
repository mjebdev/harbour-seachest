import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    SilicaFlickable {

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

                label: qsTr("Action to download file")
                id: downloadActionCombo
                width: parent.width
                currentIndex: settings.itemTapToDl ? 0 : 1
                leftMargin: Theme.horizontalPageMargin
                description: currentIndex === 0 ? qsTr("Press & hold for other options") : qsTr("Tap for other options")

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

            TextSwitch {

                id: overwriteWarningSwitch
                text: qsTr("Show warning prior to overwriting an identically named file in Downloads");
                checked: settings.overwriteWarning

                onClicked: {

                    settings.overwriteWarning = checked;
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

    Notification {

        id: settingsNotification
        isTransient: true
        appName: "SeaChest"
        expireTimeout: 2000

    }

}
    
