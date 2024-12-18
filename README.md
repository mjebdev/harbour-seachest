# SeaChest
An unofficial Dropbox client for Sailfish OS.

Version 0.3.1
<br>Licensed under GNU GPLv3

Much-appreciated Swedish translation by [eson57](https://github.com/eson57)
<br>Any further help with translations is very welcome!

<h3>Features</h3>

- Downloading of individual files and folders (as of now, just one at a time).
- Uploading of files up to 150MB in size.
- Basic icon categories displayed for file listings.
- Images previewed in context menu (formats supported are jpg/jpeg/png/tiff/tif/gif/webp/ppm/bmp).

<h3>Issues & Limitations</h3>

- No sorting of files or folders apart from sorting obtained directly from the API output (appears to be by modified date, oldest to newest, with folders generally on top but not always).
- If downloading a file and uploading at the same time, progress bars at bottom of screen may not render properly. Upload progress bar sometimes stays visible after transfer completed; app restart will allow for continued uploading.
- Reauthorization still not working with all requests, e.g. uploading or downloading a file/folder. Workaround is to refresh folder and retry.

<h3>Navigation</h3>

- Tap to download files or open folders, press-and-hold to open context menu. This can be switched around in Settings.
- To upload, choose 'Upload' from the pull-down menu and select the local file. It'll be saved in the currently viewed Dropbox folder.
- To refresh a folder listing, swipe back and then reselect the folder, or if in the Home folder, choose 'Refresh' from the pull-down menu.
- When renaming a file or folder, Enter key will rename. 

<h3>Not Yet Supported</h3>

- Search.
- Sorting by name / modified / added.
- Showing full filename when menu opened or having multiple lines for filenames when listed.

<h3>Rationale</h3>

- Good to have a native app with an interface consistent with Ambience, while working to further reduce the need for Android Support.

<h3>Donate</h3>

- <a href="https://ko-fi.com/mjebdev">Ko-fi</a>
- <a href="https://buymeacoffee.com/mjebdev">Buy Me a Coffee</a>
- <a href="https://paypal.me/mjebdev">PayPal</a>
