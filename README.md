# SeaChest
An unofficial Dropbox client for Sailfish OS.

Version 0.5
<br>Licensed under GNU GPLv3

Swedish translation by [eson57](https://github.com/eson57)
<br>Italian translation by [Legacychimera247](https://github.com/Legacychimera247)
<br>Any assistance with contributing translations is much appreciated!

Tested on SFOS versions 4.6 and 5.0

<h3>Features</h3>

- Downloading of individual files and folders (as of now, just one at a time).
- Uploading of files up to 150MB in size, including from the SD card.
- Deleting and renaming files and folders.
- Search entire Dropbox or just the currently viewed folder with up to 100 results.
- Creating folders.
- Creating temporary (4-hour) links to files.
- Choosing a custom download folder location on the device.
- Previewing images in context menu (formats supported are jpg/jpeg/png/tiff/tif/gif/webp/ppm/bmp).

<h3>Issues & Limitations</h3>

- No sorting of files or folders in the list view, however there is search functionality to locate files quickly.
- If downloading a file and uploading at the same time, progress bars at bottom of screen may not render properly. Upload progress bar sometimes stays visible after transfer completed; app restart would be a necessary workaround here.
- Reauthorization should work automatically with all requests but if uploading a file when access has expired, note that the upload of the file will need to be completed again after reauthorization.

<h3>Navigation</h3>

- Tap to download files or open folders, press-and-hold to open context menu. This can be switched around in Settings.
- To search, swipe right to left in any folder list view. There's an option to only search within the current folder (to include subfolders).
- To upload, choose 'Upload' from the pull-down menu and select the local file. It'll be saved in the currently viewed Dropbox folder.
- To refresh a folder listing, swipe back and then reselect the folder, or if in the Home folder, choose 'Refresh' from the pull-down menu.
- When renaming a file or folder, Enter key will send request.
- When creating a 4-hour link to a file, the URL will be copied to the clipboard.
- If a custom download folder location is unavailable when attempting a download, the app will revert to using the default Downloads folder until the relevent setting is changed again.

<h3>Rationale</h3>

- Good to have a native app with an interface consistent with Ambience, while working to further reduce the need for Android Support.

<h3>Donations welcome!</h3>

- <a href="https://ko-fi.com/mjebdev">Ko-fi</a>
- <a href="https://buymeacoffee.com/mjebdev">Buy Me a Coffee</a>
- <a href="https://paypal.me/mjebdev">PayPal</a>
