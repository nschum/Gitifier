// -------------------------------------------------------
// PSMacros.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#define PSFormat(...)     [NSString stringWithFormat: __VA_ARGS__]
#define PSIndex(sec, row) [NSIndexPath indexPathForRow: row inSection: sec]
#define PSNull            [NSNull null]
#define PSTranslate(text) NSLocalizedString(text, @"")
#define PSIsBlank(x)      (![(x) psIsPresent])
#define PSiPadDevice      (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define PSiPhoneDevice    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define PSAbstractMethod(returnType) { [self doesNotRecognizeSelector: _cmd]; return (returnType) 0; }

// from http://www.cimgf.com/2009/01/24/dropping-nslog-in-release-builds/
#ifdef DEBUG
  #define PSLog(...) NSLog(__VA_ARGS__)
#else
  #define PSLog(...) do {} while (0)
#endif

#define PSObserve(sender, notification, callback) \
  [[NSNotificationCenter defaultCenter] addObserver: self \
                                           selector: @selector(callback) \
                                               name: (notification) \
                                             object: (sender)]

#define PSStopObserving(sender, notification) \
  [[NSNotificationCenter defaultCenter] removeObserver: self \
                                                  name: (notification) \
                                                object: (sender)]

#define PSStopObservingAll() [[NSNotificationCenter defaultCenter] removeObserver: self]

#define PSNotifyWithData(notification, data) \
  [[NSNotificationCenter defaultCenter] postNotificationName: (notification) \
                                                      object: self \
                                                    userInfo: (data)]

#define PSNotify(notification) PSNotifyWithData((notification), nil)
