import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Sailfish.Pickers 1.0
import NetworkAccess 1.0
import Amber.Web.Authorization 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height

        Column {

            id: column
            width: parent.width

            Row {

                id: titleRow
                width: parent.width
                height: Theme.itemSizeHuge + Theme.paddingLarge

                Label {

                    id: titleLabel
                    text: "SeaChest"
                    width: parent.width
                    font.pixelSize: Theme.fontSizeHuge
                    color: Theme.highlightColor
                    bottomPadding: 0
                    height: parent.height
                    verticalAlignment: Text.AlignBottom
                    horizontalAlignment: Text.AlignHCenter

                }

            }

            Row {

                width: parent.width
                id: versionRow
                height: Theme.itemSizeSmall

                Label {

                    id: appVersionLabel
                    text: "v0.4.1"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignTop
                    topPadding: 0
                    height: parent.height

                }

            }

            Row {

                width: parent.width
                height: Theme.paddingLarge * 2

            }

            Row {

                width: Theme.iconSizeExtraLarge
                x: 0.5 * (page.width - Theme.iconSizeExtraLarge)
                id: iconRow
                height: Theme.iconSizeExtraLarge + Theme.paddingLarge

                Image {

                    height: parent.width
                    width: height
                    source: Qt.resolvedUrl("harbour-seachest.png")

                }

            }

            Row {

                width: parent.width
                height: Theme.paddingLarge * 3

            }

            Separator {

                width: parent.width - (Theme.horizontalPageMargin * 4)
                x: Theme.horizontalPageMargin * 2
                horizontalAlignment: Qt.AlignHCenter
                color: Theme.primaryColor

            }

            Row {

                width: parent.width

                Label {

                    width: parent.width
                    text: qsTr("To being using the app, please authorize it to access your Dropbox account. This will open a new browser window.")
                    leftPadding: Theme.horizontalPageMargin * 2
                    rightPadding: Theme.horizontalPageMargin * 2
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    topPadding: Theme.paddingLarge * 2
                    bottomPadding: Theme.paddingLarge * 3

                }

            }

            Row {

                width: parent.width

                ButtonLayout {

                    Button {

                        text: qsTr("Authorize");

                        onClicked: {

                            oauthRun.redirectListener.startListening();
                            Qt.openUrlExternally("https://nodejs.mjeb.dev/seachest/auth");

                        }

                    }

                }

            }

            Row {

                width: parent.width
                height: Theme.paddingLarge * 2

            }

        }

    }

    OAuth2Ac {

        id: oauthRun
        redirectListener.port: 56567
        redirectListener.httpContent: "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n<!DOCTYPE html>

        <html>
        <head>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Authorization Successful</title>
        <style>
        .theme {
          background: white;
          color: black;
          font-family: Tahoma, sans-serif;
        }
        @media (prefers-color-scheme: dark) {
          .theme.adaptive {
            background: black;
            color: white;
          }
        }
        img {
          display: block;
          margin-left: auto;
          margin-right: auto;
          width: 40%;
          height: 40%;
        }
        </style>
        </head>
        <body class='theme adaptive'>
        <br>
        <br>
        <h2 style='text-align:center'>SeaChest authorization complete.</h2>
        <br>
        <img src='https://mjeb.dev/seachest/harbour-seachest.png' alt='App icon'>
        <br>
        <br>
        <p style='text-align:center'>This browser tab can be closed.</p>
        </body>
        </html>
        \r\n\r\n"

        redirectListener.onReceivedRedirect: {

            var urlString = redirectUri;

            if (urlString.indexOf("access_token=") !== -1) {

                loadingDataBusy.running = true;
                settings.accessKey = urlString.slice((urlString.indexOf("access_token=") + 13), urlString.indexOf("&expires_in="));
                settings.refreshToken = urlString.slice((urlString.indexOf("refresh_token=") + 14));
                settings.sync();
                authorizationNotifier.previewSummary = qsTr("Authorization Successful");
                authorizationNotifier.publish();
                loadingDataBusy.running = false;
                pageStack.clear();
                pageStack.push(Qt.resolvedUrl("Home.qml"));

            }

        }

    }

    Notification {

        id: authorizationNotifier
        isTransient: true
        expireTimeout: 1800

    }

    BusyIndicator {

        id: loadingDataBusy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large

    }

}
