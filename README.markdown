# Gitifier

Gitifier is a MacOSX menu bar application that monitors Git repositories for new commits and displays their info in
Growl notifications. Check out the project home page:
[http://psionides.github.com/Gitifier](http://psionides.github.com/Gitifier).

Gitifier was originally developed by Jakub Suder and is now maintained by Nikolaj Schumacher.

## Requirements

* MacOSX 10.7 (Lion)
* Git
* optionally: Growl (recommended on 10.7, on 10.8+ system notifications are used as a fallback)

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

See [this wiki page](https://github.com/jsuder/Gitifier/wiki/Tips-%26-tricks).

## Changelog

See [this page](https://github.com/jsuder/Gitifier/blob/master/CHANGELOG.markdown).

## License

Copyright by Jakub Suder <jakub.suder at gmail.com>. Licensed under Eclipse Public License v1.0.

Includes open source libraries by Vadim Shpakovski (MASPreferences), John Engelhart (RegexKitLite), Andy Matuschak
(Sparkle), Ira Cooke (SSH NSTask), Ali Rantakari (ANSIEscapeHelper) and Growl framework by the Growl Team.
