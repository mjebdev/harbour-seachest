# Security Policy

This policy supports all versions of SeaChest.

SeaChest does not collect any personal information other than what is necessary for the app to function (access tokens).

In order to enable app functionality, an access token and a refresh token are stored on the device to make calls to the Dropbox API and refresh the access token, as necessary. To remove these from the device, the user can click on 'Erase Access Key' in Settings (this also erases the refresh token). The user is brought back to the app Authorization page which has been set to Private Mode to prevent automatic reauthorization.

As part of the OAuth procedure for authorization and reauthorization, the server https://nodejs.mjeb.dev/seachest is used. This is hosted at DigitalOcean and uses a basic NodeJS script to process the OAuth authorization requests.

## Reporting a Vulnerability

Please send any questions or concerns to feedback@mjeb.dev
