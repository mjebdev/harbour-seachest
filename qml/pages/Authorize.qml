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

                width: parent.width
                height: Theme.itemSizeSmall

            }

            Row {

                id: titleRow
                width: parent.width
                height: titleLabel.height //Theme.itemSizeHuge + Theme.paddingLarge

                Label {

                    id: titleLabel
                    text: "SeaChest"
                    width: parent.width
                    font.pixelSize: Theme.fontSizeHuge
                    color: Theme.highlightColor
                    bottomPadding: 0
                    //verticalAlignment: Text.AlignBottom
                    horizontalAlignment: Text.AlignHCenter

                }

            }

            Row {

                width: parent.width
                id: versionRow
                height: appVersionLabel.height + Theme.paddingMedium

                Label {

                    id: appVersionLabel
                    text: "v0.6"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    topPadding: 0

                }

            }

            Row {

                width: parent.width
                height: Theme.itemSizeSmall

            }

            Row {

                width: Theme.iconSizeExtraLarge
                x: 0.5 * (page.width - Theme.iconSizeExtraLarge)
                id: iconRow
                height: Theme.iconSizeExtraLarge

                Image {

                    height: parent.width
                    width: height
                    source: Qt.resolvedUrl("harbour-seachest.png")

                }

            }

            Row {

                width: parent.width
                height: Theme.itemSizeSmall

            }

            Row {

                width: parent.width
                height: authInstrLabel.height

                Label {

                    id: authInstrLabel
                    width: parent.width
                    text: qsTr("To begin using the app, please authorize it to access your Dropbox account. This will open a new browser window.")
                    leftPadding: Theme.horizontalPageMargin
                    rightPadding: Theme.horizontalPageMargin
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    //topPadding: Theme.paddingLarge * 2
                    //bottomPadding: Theme.paddingLarge * 3
                    //horizontalAlignment: Text.AlignHCenter

                }

            }

            Row {

                width: parent.width
                height: Theme.itemSizeSmall

            }

            Separator {

                width: parent.width - (Theme.horizontalPageMargin * 2)
                x: Theme.horizontalPageMargin
                horizontalAlignment: Qt.AlignHCenter
                color: Theme.highlightColor

            }

            Row {

                width: parent.width
                height: Theme.itemSizeSmall

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
                var expiresIn = Number(urlString.slice((urlString.indexOf("expires_in=") + 11), urlString.indexOf("&refresh_token=")));
                console.log("On Authorize page - expiresIn value is " + expiresIn);
                var rightNow = Number(Date.now());
                rightNow = rightNow / 1000;
                console.log("On Authorize page - should be in seconds - expiresIn value is " + expiresIn + " and rightNow is " + rightNow);
                tokenWillExpireAt = expiresIn + rightNow;
                console.log("Did expire time math work out? Value of tokenWillExpireAt equals " + tokenWillExpireAt);
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
