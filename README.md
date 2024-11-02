# SeaChest
A simple, unofficial Dropbox client for Sailfish OS.

Version 0.2

Licensed under GNU GPLv3.

SeaChest is an unofficial app and is in no way associated with Dropbox, Inc.

Have added Rename and Delete functionality for version 0.2. Also, there is now a warning by default when downloading a file with the same name as an already existing file before overwriting.

<h3>Supports</h3>

- Download individual files (as of now only one at a time).
- Upload files up to 150MB.
- Basic icon categories for file listings.
- Images can be previewed in context menu (jpg/jpeg/png/tiff/tif/gif/webp/ppm/bmp).

<h3>Issues & Limitations</h3>

- No sorting of files or folders yet. From using the app, a recently added file will be at the bottom of the list but other than that it'll appear to be random (including folders not being at the top in sometimes).
- If downloading a file and uploading at the same time, progress bars at bottom of screen may not look right. Also the upload progress bar doesn't always close when an upload is complete, meaning an app restart will be necessary to upload another file.
- There may still be issues with uploading or downloading a file first thing after an access token has expired. Workaround would be to refresh folder to reauthorize.

<h3>Usage</h3>

- Downloading files and opening folders can be done with one tap or from a context menu by press-and-hold. This behavior can be adjusted in Settings.
- To upload, go to the folder in Dropbox you'd like to upload to and choose 'Upload' from the pull-down menu, then select the local file to transfer.
- To refresh a folder listing, swipe back and then reselect the folder. For the 'Home' folder there'll be a 'Refresh' option in the pull-down menu.
- When renaming a file or folder, Enter key will save the changes made. 

<h3>Planning to Add or Support</h3>

- App icon.
- Downloading of complete folders in ZIP format.
- Search.
- Sorting by name / modified / added.
- Show full filename when menu opened or possibly have multiple lines for an item with a longer name.
- Upload button on Cover as shortcut to uploading a file to a default location.
- Upload and download progress indicators on the app Cover.

<h3>Rationale</h3>

- Initially created as a basic way of transferring new RPMs from Dropbox folder without needing Android Support.
- Dropbox syncing no longer functioning in other native apps, possibly related to a change in the Dropbox API regarding authorization tokens. Existing apps were a bit too complex for me to attempt to contribute a fix, although hopefully devs for those apps might find something useful with the approach taken here. FYI it's not fully addressed in this app as of yet but can always refresh a folder to reauthorize if needed. Rename and Delete functions should also work after token has expired.
- Good to have a native app where possible, consistent interface with Ambience etc.

<h3>Tips</h3>

- <a href="https://ko-fi.com/mjebdev">Support me on Ko-fi</a>
- <a href="https://buymeacoffee.com/mjebdev">Buy Me a Coffee</a>
- <a href="https://paypal.me/mjebdev">PayPal</a>
