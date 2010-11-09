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
done by parsing the results from the command line git executable, so it must be installed in the system. If something
doesn't work (e.g. you can't add a repository to the list), check if you're able to clone the same URL from the command
line.

## License

Copyright by Jakub Suder <jakub.suder at gmail.com>. Licensed under MIT license.

Includes open source libraries by Dave Batton (DBPrefsWindowController), John Engelhart (RegexKitLite), Andy Matuschak
(Sparkle), Ira Cooke (SSH NSTask), Ali Rantakari (ANSIEscapeHelper) and Growl framework by the Growl Team.
