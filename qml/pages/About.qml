import QtQuick 2.6
import Sailfish.Silica 1.0

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

                title: qsTr("About")

            }

            Row {

                width: parent.width

                Column {

                    width: parent.width

                    Row {

                        width: parent.width * 0.25
                        x: (parent.width - this.width) / 2

                        Image {

                            width: parent.width
                            source: "harbour-seachest.png";
                            height: width

                        }

                    }

                    Row {

                        width: appTitleLabel.width
                        x: (parent.width - appTitleLabel.width) * 0.5
                        spacing: 0

                        Label {

                            text: "SeaChest"
                            width: text.width
                            height: text.height
                            horizontalAlignment: Qt.AlignHCenter
                            id: appTitleLabel
                            font.pixelSize: Theme.fontSizeLarge
                            color: Theme.highlightColor
                            topPadding: Theme.paddingLarge
                            bottomPadding: Theme.paddingLarge * 2

                        }

                    }

                    Separator {

                        id: titleSeparator
                        width: parent.width * 0.66
                        x: (page.width - this.width) * 0.5
                        horizontalAlignment: Separator.Center
                        color: Theme.highlightColor

                    }

                    Row {

                        width: parent.width * 0.66
                        x: parent.width * 0.17
                        height: aboutTextLabel.height

                        Label {

                            topPadding: Theme.paddingLarge
                            width: parent.width
                            id: aboutTextLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("An unofficial Dropbox client for Sailfish OS.\n\nby Michael J. Barrett\nmjeb.dev\n\nVersion 0.3.1\nLicensed under GNU GPLv3\n\nSwedish translation by Åke Engelbrektson");
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Separator {

                        width: parent.width * 0.66
                        x: (page.width - this.width) * 0.5
                        horizontalAlignment: Separator.Center
                        color: Theme.highlightColor

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }

                    Row {

                        width: parent.width * 0.34
                        x: parent.width * 0.33
                        height: parent.width * 0.2

                        Image {

                            id: linkToGitHub
                            source: Theme.colorScheme == Theme.DarkOnLight ? "GitHub_Logo_cropped_to_content.png" : "GitHub_Logo_White_cropped_to_content.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://github.com/mjebdev/harbour-seachest");

                            }

                        }

                    }

                    Row {

                        id: linkToKoFiRow
                        width: parent.width * 0.34
                        x: parent.width * 0.33
                        height: parent.width * 0.2

                        Image {

                            id: linkToKoFi
                            source: "kofi_logo.webp"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.ko-fi.com/mjebdev");

                            }

                        }

                    }
/*
                    Row {

                        id: linkToPayPalRow
                        width: parent.width * 0.4
                        x: parent.width * 0.3
                        height: parent.width * 0.25

                        Image {

                            id: linkToPayPal
                            source: Theme.colorScheme == Theme.DarkOnLight ? "PayPal_logo_black_cropped_to_content.png" : "PayPal_logo_white_cropped_to_content.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.paypal.me/mjebdev");

                            }

                        }

                    }
*/
                    Row {

                        height: Theme.paddingLarge
                        width: parent.width

                    }

                }

            }

        }

    }

}
