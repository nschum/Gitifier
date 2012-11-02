// -------------------------------------------------------
// PSFoundationExtensions.m
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "PSFoundationExtensions.h"
#import "PSMacros.h"

// ------------------------------------------------------------------------------------------------

@implementation NSArray (PsiToolkit)

- (id) psFirstObject {
  if (self.count > 0) {
    return [self objectAtIndex: 0];
  } else {
    return nil;
  }
}

- (NSArray *) psArrayByCalling: (SEL) selector {
  NSMutableArray *collected = [[NSMutableArray alloc] initWithCapacity: self.count];

  for (id element in self) {
    [collected addObject: [element performSelector: selector]];
  }

  return [NSArray arrayWithArray: collected];
}

- (NSArray *) psCompact {
  return [self psFilterWithPredicate: @"SELF != NIL"];
}

- (NSArray *) psFilterWithPredicate: (NSString *) filter {
  return [self filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: filter]];
}

- (NSArray *) psSortedArrayUsingField: (NSString *) field ascending: (BOOL) ascending {
  return [self psSortedArrayUsingField: field ascending: ascending compareWith: @selector(compare:)];
}

- (NSArray *) psSortedArrayUsingField: (NSString *) field ascending: (BOOL) ascending compareWith: (SEL) compareMethod {
  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey: field
                                                             ascending: ascending
                                                              selector: compareMethod];
  return [self sortedArrayUsingDescriptors: PSArray(descriptor)];
}

- (NSDictionary *) psGroupByKey: (NSString *) key {
  NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
  for (id object in self) {
    id keyForObject = [object valueForKey: key];
    NSMutableArray *list = [groups objectForKey: keyForObject];
    if (!list) {
      list = [NSMutableArray arrayWithCapacity: 5];
      [groups setObject: list forKey: keyForObject];
    }
    [list addObject: object];
  }
  return groups;
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSDate (PsiToolkit)

+ (NSDate *) psDaysAgo: (NSInteger) days {
  return [NSDate psDaysFromNow: -days];
}

+ (NSDate *) psDaysFromNow: (NSInteger) days {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *interval = [[NSDateComponents alloc] init];
  [interval setDay: days];

  return [calendar dateByAddingComponents: interval toDate: [NSDate date] options: 0];
}

+ (NSDateFormatter *) psJSONDateFormatter {
  static NSDateFormatter *formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
  }
  return formatter;
}

- (BOOL) psIsEarlierOrSameDay: (NSDate *) otherDate {
  NSDate *current = [self psMidnight];
  NSDate *other = [otherDate psMidnight];
  return ([current earlierDate: other] == current);
}

- (NSDate *) psMidnight {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSUInteger fieldFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
  NSDateComponents *fields = [calendar components: fieldFlags fromDate: self];
  return [calendar dateFromComponents: fields];
}

- (NSString *) psJSONDateFormat {
  return [[NSDate psJSONDateFormatter] stringFromDate: self];
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSDictionary (PsiToolkit)

+ (NSDictionary *) psDictionaryWithKeysAndObjects: (id) firstObject, ... {
  if (!firstObject) {
    return [NSDictionary dictionary];
  } else {
    va_list args;
    va_start(args, firstObject);

    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity: 5];
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity: 5];
    id object = firstObject;
    BOOL isKey = YES;

    do {
      if (isKey) {
        [keys addObject: object];
      } else {
        [objects addObject: object];
      }
      object = va_arg(args, id);
      isKey = !isKey;
    } while (object);

    va_end(args);

    return [NSDictionary dictionaryWithObjects: objects forKeys: keys];
  }
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSNull (PsiToolkit)

- (BOOL) psIsPresent {
  return NO;
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSObject (PsiToolkit)

+ (NSArray *) psArrayByCalling: (SEL) selector withObjectsFrom: (NSArray *) array {
  NSMutableArray *collected = [[NSMutableArray alloc] initWithCapacity: array.count];
  for (id element in array) {
    [collected addObject: [self performSelector: selector withObject: element]];
  }

  return [NSArray arrayWithArray: collected];
}

- (NSArray *) psArrayByCalling: (SEL) selector withObjectsFrom: (NSArray *) array {
  NSMutableArray *collected = [[NSMutableArray alloc] initWithCapacity: array.count];
  for (id element in array) {
    [collected addObject: [self performSelector: selector withObject: element]];
  }

  return [NSArray arrayWithArray: collected];
}

@end

// ------------------------------------------------------------------------------------------------

@implementation NSString (PsiToolkit)

+ (NSString *) psStringWithFormEncodedFields: (NSDictionary *) fields {
  NSMutableArray *parts = [[NSMutableArray alloc] initWithCapacity: fields.count];

  for (NSString *field in fields) {
    [parts addObject: PSFormat(@"%@=%@", field, [fields objectForKey: field])];
  }

  return [parts componentsJoinedByString: @"&"];
}

+ (NSString *) psStringWithFormEncodedFields: (NSDictionary *) fields ofModelNamed: (NSString *) name {
  NSMutableArray *parts = [[NSMutableArray alloc] initWithCapacity: fields.count];

  for (NSString *field in fields) {
    [parts addObject: PSFormat(@"%@[%@]=%@", name, field, [fields objectForKey: field])];
  }

  return [parts componentsJoinedByString: @"&"];
}

- (BOOL) psIsPresent {
  return ([[self psTrimmedString] length] > 0);
}

- (BOOL) psContainsString: (NSString *) substring {
  NSRange found = [self rangeOfString: substring];
  return (found.location != NSNotFound);
}

- (NSString *) psCamelizedString {
  NSArray *words = [self componentsSeparatedByString: @"_"];
  if (words.count == 1) {
    return [self copy];
  } else {
    NSMutableString *camelized = [[NSMutableString alloc] initWithString: [words psFirstObject]];
    for (NSInteger i = 1; i < words.count; i++) {
      [camelized appendString: [[words objectAtIndex: i] capitalizedString]];
    }
    return camelized;
  }
}

- (NSString *) psPluralizedString {
  static NSDictionary *exceptions;
  if (!exceptions) {
    exceptions = PSHash(
      @"person", @"people",
      @"man", @"men",
      @"woman", @"women",
      @"child", @"children"
    );
  }

  NSString *downcased = [self lowercaseString];
  NSString *result = [exceptions objectForKey: downcased];
  if (result) {
    // one of the exceptions above
    return result;
  } else if ([downcased hasSuffix: @"ch"]) {
    // e.g. match -> matches
    return [downcased stringByAppendingString: @"es"];
  } else if ([downcased hasSuffix: @"fe"]) {
    // e.g. knife -> knives
    return [[downcased substringToIndex: downcased.length - 2] stringByAppendingString: @"ves"];
  } else if ([downcased hasSuffix: @"sh"]) {
    // e.g. flash -> flashes
    return [downcased stringByAppendingString: @"es"];
  } else if ([downcased hasSuffix: @"ss"]) {
    // e.g. boss -> bosses
    return [downcased stringByAppendingString: @"es"];
  } else if ([downcased hasSuffix: @"us"]) {
    // e.g. bus -> buses
    return [downcased stringByAppendingString: @"es"];
  } else if ([downcased hasSuffix: @"x"]) {
    // e.g. box -> boxes
    return [downcased stringByAppendingString: @"es"];
  } else if ([downcased hasSuffix: @"y"]) {
    // e.g. activity -> activities
    return [[downcased substringToIndex: downcased.length - 1] stringByAppendingString: @"ies"];
  } else if ([downcased hasSuffix: @"s"]) {
    return downcased;
  } else {
    return [downcased stringByAppendingString: @"s"];
  }
}

- (NSString *) psStringWithPercentEscapesForFormValues {
  CFStringRef escapedSymbols = CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/");
  CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(
    NULL,
    (__bridge CFStringRef) self,
    NULL,
    escapedSymbols,
    kCFStringEncodingUTF8
  );

  return CFBridgingRelease(escaped);
}

- (NSString *) psStringWithUppercaseFirstLetter {
  NSString *head = [self substringToIndex: 1];
  NSString *tail = [self substringFromIndex: 1];
  return [[head uppercaseString] stringByAppendingString: tail];
}

- (NSString *) psTrimmedString {
  return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) psUnderscoreSeparatedString {
  NSCharacterSet *uppercaseLetters = [NSCharacterSet uppercaseLetterCharacterSet];
  NSScanner *scanner = [NSScanner localizedScannerWithString: self];
  [scanner setCaseSensitive: YES];
  NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity: self.length];
  NSString *part;
  BOOL found;

  while (true) {
    found = [scanner scanUpToCharactersFromSet: uppercaseLetters intoString: &part];
    if (!found) {
      break;
    }

    [buffer appendString: part];

    found = [scanner scanCharactersFromSet: uppercaseLetters intoString: &part];
    if (!found) {
      break;
    }

    if (![buffer hasSuffix: @"_"]) {
      [buffer appendString: @"_"];
    }

    if (part.length > 1) {
      [buffer appendString: [[part substringToIndex: part.length - 1] lowercaseString]];
      [buffer appendString: @"_"];
      [buffer appendString: [[part substringFromIndex: part.length - 1] lowercaseString]];
    } else {
      [buffer appendString: [part lowercaseString]];
    }
  }

  return [NSString stringWithString: buffer];
}

@end
