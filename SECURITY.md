# Security Policy

This policy supports all versions of SeaChest.

SeaChest does not collect any personal information other than what is necessary for the app to function (access tokens).

In order to enable app functionality, an access token and a refresh token are stored on the device to make calls to the Dropbox API and refresh the access token. To remove these from the device, the user can click on 'Erase Access Key' in Settings (this also erases the refresh token). The user is brought back to the Welcome page to re-authorize if so desired.

As part of the OAuth procedure for authorization and reauthorization, the server nodejs.mjeb.dev/seachest is used. This is hosted at DigitalOcean and uses a basic NodeJS script to process the OAuth authorization requests.

For versions 0.3 and earlier, the OAuth authorization flow was done via a WebView component within the app.

From version 0.3.1 onward, the OAuth authorization flow utilizes the Amber Web Authorization Framework and is done via the SFOS Browser. The RedirectListener component detects the final redirect to localhost that has the required tokens as parameters.

## Reporting a Vulnerability

Please send any questions or concerns to feedback@mjeb.dev
