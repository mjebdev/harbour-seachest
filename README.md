# SeaChest
A simple Dropbox client for Sailfish OS.

Version 0.1

Licensed under GNU GPLv3.

SeaChest is an unofficial app and is in no way associated with Dropbox, Inc.

There are a few things left to do before I'd be comfortable applying for Production status: an icon, enabling Rename and Delete functionality (may just remove these options from the context menu if time runs out, and re-add when ready) and probably adding some kind of warning before overwriting an existing file with the same name. If or when the user count goes over 50, I'll need to apply within two weeks and be approved, otherwise use of the app will be frozen.

<h3>Supports</h3>

- Download individual files (as of now only one at a time).
- Upload files up to 150MB.
- Basic icon categories for file listings.
- Images can be previewed in context menu (jpg, jpeg, png, tiff, tif, gif, webp, ppm and bmp).

<h3>Issues & Limitations</h3>

- IMPORTANT: An identically named file in the same location as a file that's being downloaded by the app will be overwritten without warning.
- Plan to add support for renaming, deletion and other additional features if time allows. As of now, options to rename and delete files and folders are present but non-functional.
- No sorting of files or folders yet. From using the app, a recently added file will be at the bottom of the list but other than that it'll be pretty much random (including folders not being at the top in some cases).
- If downloading a file and uploading at the same time, progress bars at bottom of screen may not look right. Also any subsequent uploads after the first won't display the progress bar correctly (will already be at 100%).
- When loading a folder, reauthorization should work but there may still be issues with uploading or downloading a file first thing after an access token has expired. Workaround would be to refresh folder to reauthorize.

<h3>Usage</h3>

- Downloading files and opening folders can be done with one tap or from a context menu by press-and-hold. This behavior can be adjusted in Settings.
- To upload, go to the folder in Dropbox you'd like to upload to and choose 'Upload' from the pull-down menu, then select the local file to transfer.
- To refresh a folder listing, swipe back and then reselect the folder. For the 'Home' folder there'll be a 'Refresh' option in the pull-down menu.

<h3>Planning to Add or Support</h3>

- Prompt to overwrite existing file or cancel should there already be a file with the same name.
- Enabling Delete and Rename functions on context menu.
- App icon.
- Search.
- Sorting by name / modified / added.
- Show full filename when menu opened or possibly have multiple lines for an item with a longer name.
- Upload button on Cover as shortcut to uploading a file to a default location.
- Upload and download progress indicators on the app Cover.

<h3>Rationale</h3>

- Initially created as a basic way of transferring new RPMs from Dropbox folder without needing Android Support.
- Dropbox syncing no longer functioning in other native apps, appears to mainly be related to a change in the Dropbox API that meant relatively frequent reauthorization would be required. Existing apps were a bit too complex for me to attempt to contribute a change to properly address this--not fully addressed in this app yet!
- Good to have native app if possible, consistent interface with Ambience etc.

<h3>Tips</h3>

- <a href="https://ko-fi.com/mjebdev">Support me on Ko-fi</a>
- <a href="https://buymeacoffee.com/mjebdev">Buy Me a Coffee</a>
- <a href="https://paypal.me/mjebdev">PayPal</a>
