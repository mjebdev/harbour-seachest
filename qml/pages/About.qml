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
/* -- for when an icon is ready
                    Row {

                        width: parent.width * 0.25
                        x: (parent.width - this.width) / 2

                        Image {

                            width: parent.width
                            source: "harbour-seachest.svg";
                            height: width

                        }

                    }
*/
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
                            color: Theme.primaryColor
                            topPadding: Theme.paddingLarge
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Separator {

                        id: titleSeparator
                        width: appTitleLabel.width
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
                            color: Theme.primaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("An unofficial Dropbox client for Sailfish OS.\n\nby Michael J. Barrett\nmjeb.dev\n\nVersion 0.1\nLicensed under GNU GPLv3");
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Row {

                        width: parent.width
                        //height: Theme.paddingMedium
                        height: Theme.paddingLarge + Theme.paddingMedium

                    }
/*
                    SectionHeader {

                        text: qsTr("Tips, Feedback & Source")

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingMedium

                    }
*/
                    Row {

                        id: linkToKoFiRow
                        //width: linkToKoFi.width
                        width: parent.width * 0.4
                        //x: (parent.width - linkToKoFi.width) / 2
                        x: parent.width * 0.3
                        height: parent.width * 0.25
                        //height: Theme.itemSizeExtraSmall + (Theme.paddingMedium * 2)

                        Image {

                            id: linkToKoFi
                            //source: Theme.colorScheme == Theme.DarkOnLight ? "Ko-fi_Logo_RGB_Dark.png" : "Ko-fi_Logo_RGB_DarkBg.png"
                            source: "kofi_logo.webp"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            //height: Theme.itemSizeExtraSmall
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.ko-fi.com/mjebdev");

                            }

                        }

                    }
/*
                    Row {

                        width: parent.width
                        height: Theme.paddingMedium

                    } */
/*
                    Row {

                        id: linkToBmacRow
                        width: linkToBmac.width
                        x: (parent.width - linkToBmac.width) / 2
                        height: Theme.itemSizeExtraSmall + (Theme.paddingMedium * 2)

                        Image {

                            id: linkToBmac
                            source: Theme.colorScheme == Theme.DarkOnLight ? "BMClogowithwordmark-black.png" : "BMClogowithwordmark-white.png"
                            fillMode: Image.PreserveAspectFit
                            height: Theme.itemSizeExtraSmall
                            y: Theme.paddingMedium

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.buymeacoffee.com/mjebdev");

                            }

                        }

                    }
*/ /*
                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }
*/

/*
                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }
*/
                    Row {

                        width: parent.width * 0.4
                        x: parent.width * 0.3
                        height: parent.width * 0.25

                        Image {

                            id: linkToGitHub
                            source: Theme.colorScheme == Theme.DarkOnLight ? "GitHub_Logo_cropped_to_content.png" : "GitHub_Logo_White_cropped_to_content.png"
                            fillMode: Image.PreserveAspectFit
                            //height: Theme.itemSizeExtraSmall
                            width: parent.width
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://github.com/mjebdev/harbour-seachest");

                            }

                        }

                    }

                    Row {

                        id: linkToPayPalRow
                        //width: linkToPayPal.width
                        width: parent.width * 0.4
                        //x: (parent.width - linkToPayPal.width) / 2
                        x: parent.width * 0.3
                        //height: Theme.itemSizeExtraSmall + (Theme.paddingMedium * 2)
                        height: parent.width * 0.25

                        Image {

                            id: linkToPayPal
                            source: Theme.colorScheme == Theme.DarkOnLight ? "PayPal_logo_black_cropped_to_content.png" : "PayPal_logo_white_cropped_to_content.png"

                            fillMode: Image.PreserveAspectFit
                            //height: Theme.itemSizeExtraSmall
                            width: parent.width
                            //y: Theme.paddingMedium
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.paypal.me/mjebdev");

                            }

                        }

                    }

                    Row {

                        id: bmacGapRow
                        height: Theme.paddingLarge
                        width: parent.width

                    }

                }

            }

        }

    }

}
