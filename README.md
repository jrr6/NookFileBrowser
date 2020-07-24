# NookFileBrowser

### About

This application is intended as a lightweight replacement for Android File Transfer for accessing the file system of the original Nook GlowLight Plus (that is, model BNRV510). It may very well work with other Nook devices; however, it has only been tested with the original GLP.

### Requirements

NookFileBrowser requires `adb`, which can be installed with `brew cask install android-platform-tools` or by following the instructions on the appropriate [Android Developers page](https://developer.android.com/studio/command-line/adb). Also, you'll need to enable USB debugging in your Nook's developer settings (accessed by pressing repeatedly on the "n" icon in the "About" section of the settings list).

### Usage

* To navigate your Nook's file system, open directories by clicking on them, and use the up arrow in the top left to go up a level in the file hierarchy. At any time, click the home button in the top left to return to the My Files folder, where you can sideload files into your Nook library.
* To download a file, double-click on it; or, right-click on a file or directory and select "Download." Downloads are saved to your Downloads folder.
* To upload a document or directory from your computer's disk to the currently selected directory in the Nook's file system, drag and drop the local file onto the file list.
* To delete a file or directory, right-click on it and select "Delete." You'll be prompted to confirm deletion; deletion cannot be undone.
* To show or hide hidden files and directories, toggle the "Show All" checkbox in the top right.

