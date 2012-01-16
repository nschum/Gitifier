### Version 1.3

* Snow Leopard is now required
* updated Growl SDK - fixes problems with Growl 1.3
* option to limit number of notifications in one batch
* added history of recent commit notifications to the top bar menu
* fixed 'windows on top' option hiding the menu bar icon on Lion
* fixed crash if git path is incorrect
* fixed problem with truncated output from Git which caused missing commits or git path issues

### Version 1.2

* "Check Now" option in the system tray menu
* fixed bug that could silently break monitoring in Gitifier if it was running for a longer period of time
* improved guessing of repository name from its URL
* preferences window can be resized (on the repository list panel only)
* if a clone takes more than a few seconds to finish, Gitifier will show a growl notification when it finishes
* deleting large repositories from the list shouldn't block the UI
* added links to project page and "tips and tricks" wiki page on "about" panel
* custom ENV variables for git can be set in the settings file (see "tips and tricks")
* multiple repositories can be imported quickly by adding them directly to the settings file (see "tips and tricks")

### Version 1.1.1

* fixed layout issues in commit diff window
* fixed Sparkle update window hiding behind preferences window

### Version 1.1

* showing commit diffs by clicking on growl notifications
* some commits (e.g. from GitHub) can also be opened in the browser
* keep windows on top option (on by default)
* error notifications appear less often
* switched repo/author order in growl header
* fixed some issues with password dialog
* checking if growl is installed at startup

