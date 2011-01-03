# PsiToolkit

This project was started as my personal collection of various useful ObjC methods - extensions to native Cocoa, UIKit
and Foundation classes, which I used in several projects, and I figured it's better to keep them in one place. I've been
adding more and more things to it over time and it grew into a kind of micro framework. I hope someone else will finds
this stuff useful too. I can't guarantee anything though, so if it kills your cat or something, that's your problem
(and your cat's).

If you like the idea but not the implementation, check out [RestKit](https://github.com/twotoasters/RestKit) too - which
is something very similar, though probably more mature (I admit I ripped off a few ideas from them...).

## Usage

Add the whole directory to your Xcode project. You don't need to add the stuff on the root level, except `PsiToolkit.h`,
and you don't need the bridge support files (`Bridges/*`), unless you're writing an app in MacRuby or other similar
language. If you do use MacRuby, then add the bridge support files too, otherwise you may get some hard to spot bugs
(like boolean methods returning true when they shouldn't, etc.).

The code is divided into several "modules" which can be enabled or disabled. Only the "Base" one is required, the rest
is optional. You don't have to add the modules which you don't use into Xcode, though if you do, they will just be
ignored (the compiler will skip them during build).

To import and configure PsiToolkit, add an import line to your `Prefix.pch` file, and before that line declare
which modules you'd like to import (Cocoa and UIKit obviously shouldn't be used together):

    #define PSITOOLKIT_ENABLE_COCOA
    #define PSITOOLKIT_ENABLE_MODELS
    #define PSITOOLKIT_ENABLE_NETWORK
    #define PSITOOLKIT_ENABLE_SECURITY
    #define PSITOOLKIT_ENABLE_UIKIT
    #import "PsiToolkit.h"

The configuration lines have to be added before the import, otherwise they won't matter.

Another thing you can configure this way is the choice of a JSON parsing library, if you need one. 4 libraries are
supported: [YAJL](http://github.com/gabriel/yajl-objc), [JSON Framework](http://stig.github.com/json-framework),
[TouchJSON](https://github.com/schwa/TouchJSON) and [JSONKit](https://github.com/johnezang/JSONKit) (see also a
[blog post that compares them](http://psionides.jogger.pl/2010/12/12/cocoa-json-parsing-libraries-part-2)).

To use one of them, add one of these lines to the prefix file:

    #define PSITOOLKIT_USE_YAJL
    #define PSITOOLKIT_USE_JSON_FRAMEWORK
    #define PSITOOLKIT_USE_TOUCHJSON
    #define PSITOOLKIT_USE_JSONKIT

If you don't add any of these, methods related to JSON parsing will be unavailable.

## Dependencies

For using some methods of PSModel, a JSON parser is required. The Network module requires
[ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest) library.

The Security module uses either [SDKeychain](https://github.com/sdegutis/SDKeychain) by Steven Degutis or
[SFHFKeychainUtils](https://github.com/ldandersen/scifihifi-iphone) by Buzz Andersen (both are already bundled inside
PsiToolkit). Both of these require adding `Security.framework` (provided in the SDK) to the project (see Add -> Existing
Frameworks...).

## Available classes

### Base

* PSConstants - useful constants, e.g. for data size units, time units, and HTTP methods and status codes
* PSFoundationExtensions - categories adding methods to Foundation classes like NSString, NSArray, NSDate
* PSIntArray - an array that stores integers (actual integers, not NSNumbers)
* PSMacros - useful macros, e.g. for creating Foundation objects or sending notifications

### Cocoa

* PSCocoaExtensions - categories adding useful methods to Cocoa classes

### Models

* PSAccount - class representing user accounts, provides methods for loading and saving data to settings and Keychain. **Requires Security module**.
* PSModel - base class for implementing models built from JSON data. **Some methods require a JSON library**.

### Network

Requires [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest).

* PSConnector - base class for building "server connectors" that send requests to a remote server and parse responses. **Some methods require Models module and/or a JSON library**.
* PSPathBuilder - a tool for building URLs with parameters
* PSRequest - represents a single request to a remote server
* PSResponse - represents a response to a request
* PSRestRouter - generates URLs for some helper methods in PSConnector. **Requires Models module**.

### Security

Requires `Security.framework`.

* PSSecurityExtensions - methods for setting and reading passwords from the Keychain (both on MacOSX and iOS)

### UIKit

* PSUIKitExtensions - categories adding useful methods to UIKit classes


## License

Copyright by Jakub Suder <jakub.suder at gmail.com>, licensed under
[MIT license](https://github.com/psionides/PsiToolkit/blob/master/MIT-LICENSE.txt).
