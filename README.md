# SeaChest
An unofficial Dropbox client for Sailfish OS.

Version 0.6  
Licensed under GNU GPLv3

Swedish translation by [eson57](https://github.com/eson57)  
Italian translation by [Legacychimera247](https://github.com/Legacychimera247)  
Translation submissions are welcome.

Tested on SFOS versions 4.6 and 5.0

### Features

- Downloading of individual files and folders (as of now, just one at a time).
- Uploading of individual files, including from an SD card.
- Deleting and renaming files and folders.
- Search entire Dropbox or just the currently viewed folder with up to 100 results.
- Creating folders.
- Creating temporary (4-hour) links to files.
- Choosing a custom download folder location on the device.
- Previewing images in context menu (formats supported are jpg/jpeg/png/tiff/tif/gif/webp/ppm/bmp).

### Issues & Limitations

- No sorting of files or folders in the list view, however there is search functionality to locate files quickly.
- If downloading a file and uploading at the same time, progress bars at bottom of screen may not render properly. Upload progress bar sometimes stays visible after transfer completed; app restart would be a necessary workaround here.

### Navigation

- Tap to download files or open folders, press-and-hold to open context menu. This can be switched around in Settings.
- To search, swipe right to left in any folder list view. There's an option to only search within the current folder (to include subfolders).
- To upload, choose 'Upload' from the pull-down menu and select the local file. It'll be saved in the currently viewed Dropbox folder.
- To refresh a folder listing, swipe back and then reselect the folder, or if in the Home folder, choose 'Refresh' from the pull-down menu.
- When renaming a file or folder, Enter key will send request.
- When creating a 4-hour link to a file, the URL will be copied to the clipboard.
- If a custom download folder location is unavailable when attempting a download, the app will revert to using the default Downloads folder until the relevent setting is changed again.
- Upload button on app cover will upload a file to the Dropbox main folder.

### Rationale

- Good to have a native app with an interface consistent with Ambience.
- Less dependence on Android App Support.

### Donations welcome!

- [Ko-fi](https://ko-fi.com/mjebdev)
- [PayPal](https://paypal.me/mjebdev)
