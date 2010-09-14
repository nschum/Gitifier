# PsiToolkit

This repository is my personal collection of various useful ObjC methods - extensions (additions) to native Cocoa,
UIKit and Foundation classes, which I used in several projects, and I figured it's better to keep them in one place
as a whole set instead of copying the methods one by one when necessary.

Feel free to use the code if you happen to find it useful, but don't expect much...

## Usage

Add all `*.h` and `*.m` files to your Xcode project, import `PsiToolkit.h` where needed or simply add it to your
`Prefix.pch` file to import it everywhere. You don't need the bridge support files, unless you have an app in MacRuby
or other similar language. If you do have an app in MacRuby, then add the bridge support files too, otherwise you may
introduce some hard to spot bugs.

PsiToolkit can be included in a UIKit (iPhone) or Cocoa (Mac) app, the other platform's methods just won't be loaded.

## Contents

* PSCocoaExtensions - categories adding useful methods to Cocoa classes
* PSUIKitExtensions - categories adding useful methods to UIKit classes
* PSFoundationExtensions - categories adding useful methods to Foundation classes
* PSIntArray - an array that stores integers (actual integers, not NSNumbers)
* PSMacros - useful macros and constants
* PSModel - base class for implementing models built from JSON data
* PSModelManager - used internally by PSModel
* PSPathBuilder - a tool for building URLs with parameters

## Requirements

For using PSModel, YAJL JSON parser is required (get it at
[http://github.com/gabriel/yajl-objc](http://github.com/gabriel/yajl-objc)).

## License

Copyright by Jakub Suder <jakub.suder at gmail.com>, licensed under [WTFPL license](http://sam.zoy.org/wtfpl/)
(which means you can do what the ... whatever you want to with it).
