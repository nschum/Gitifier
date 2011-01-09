# Gitifier

Gitifier is a MacOSX menu bar application that monitors Git repositories for new commits and displays their info in
Growl notifications. Check out the project home page:
[http://psionides.github.com/gitifier](http://psionides.github.com/gitifier).

## Requirements

* MacOSX 10.5 (Leopard)
* Git
* Growl

## Details

The way Gitifier works is that when you add a repository to the list, it makes a full clone of the repository in a cache
directory (`~/Library/Caches/net.psionides.Gitifier`), and then every few minutes does a fetch in that directory, and if
the fetch reports that commits have been added to any branch, does a separate `git log` to get the details. All that is
done by parsing the results from the command line git executable, so it must be installed in the system. Gitifier will
try to find it by itself by calling `which` in the shell, but if it can't find it, you have to enter the path to Git
binary manually in the preferences.

If something doesn't work (e.g. you can't add a repository to the list, or you get repeated notifications about the same
commit, etc.), check if the same problem occurs when you clone the same URL to a new directory from the command line.
**If Git can't clone it, Gitifier won't be able to clone it either.**

## Tips and tricks

### Cache directory

As mentioned above, Gitifier's clones of the repositories are stored in `~/Library/Caches/net.psionides.Gitifier`. In
case you're wondering, cache directories are automatically excluded from Time Machine backup by OSX.

### Setting SSH key to access the repository

You should be able to configure this in your `.ssh/config` file, like this:

    Host github.com
      IdentityFile /Users/psionides/.ssh/my_github_key

### Using multiple keys with GitHub

Check out this tutorial: [Multiple SSH keys](http://help.github.com/multiple-keys/).

### Monitoring all GitHub activity

If you want to monitor everything that's happening in your GitHub RSS feed,
[GithubNotifier](https://github.com/ctshryock/GithubNotifier) might be a better tool for you.


## Changelog

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

## License

Copyright by Jakub Suder <jakub.suder at gmail.com>. Licensed under MIT license.

Includes open source libraries by Dave Batton (DBPrefsWindowController), John Engelhart (RegexKitLite), Andy Matuschak
(Sparkle), Ira Cooke (SSH NSTask), Ali Rantakari (ANSIEscapeHelper) and Growl framework by the Growl Team.
