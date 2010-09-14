// -------------------------------------------------------
// PSFoundationExtensions.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under WTFPL license
// -------------------------------------------------------

#import "PSFoundationExtensions.h"
#import "PSMacros.h"

@implementation NSArray (PsiToolkit)

- (NSArray *) psCompact {
  static NSPredicate *notNullPredicate = nil;
  if (!notNullPredicate) {
    notNullPredicate = [[NSPredicate predicateWithFormat: @"SELF != NIL"] retain];
  }
  return [self filteredArrayUsingPredicate: notNullPredicate];
}

- (NSArray *) psSortedArrayUsingField: (NSString *) field ascending: (BOOL) ascending {
  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey: field ascending: ascending];
  NSArray *descriptors = [[NSArray alloc] initWithObjects: descriptor, nil];
  NSArray *sortedArray = [self sortedArrayUsingDescriptors: descriptors];
  [descriptor release];
  [descriptors release];
  return sortedArray;
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
  return [groups autorelease];
}

@end

@implementation NSDate (PsiToolkit)

+ (NSDate *) psDaysAgo: (NSInteger) days {
  return [NSDate psDaysFromNow: -days];
}

+ (NSDate *) psDaysFromNow: (NSInteger) days {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *interval = [[NSDateComponents alloc] init];
  [interval setDay: days];
  NSDate *date = [calendar dateByAddingComponents: interval toDate: [NSDate date] options: 0];
  [interval release];
  return date;
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

@implementation NSNull (PsiToolkit)

- (BOOL) psIsBlank {
  return YES;
}

@end

@implementation NSString (PsiToolkit)

- (BOOL) psIsBlank {
  return (self.length == 0) || ([[self psTrimmedString] length] == 0);
}

- (NSString *) psCamelizedString {
  NSArray *words = [self componentsSeparatedByString: @"_"];
  if (words.count == 1) {
    return [[self copy] autorelease];
  } else {
    NSMutableString *camelized = [[NSMutableString alloc] initWithString: [words objectAtIndex: 0]];
    for (NSInteger i = 1; i < words.count; i++) {
      [camelized appendString: [[words objectAtIndex: i] capitalizedString]];
    }
    return [camelized autorelease];
  }
}

- (NSString *) psStringWithPercentEscapesForFormValues {
  CFStringRef escapedSymbols = CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/");
  CFStringRef string = (CFStringRef) [[self mutableCopy] autorelease];
  NSString *escaped =
    (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, string, NULL, escapedSymbols, kCFStringEncodingUTF8);
  return NSMakeCollectable([escaped autorelease]);
}

- (NSString *) psStringWithUppercaseFirstLetter {
  NSString *head = [self substringToIndex: 1];
  NSString *tail = [self substringFromIndex: 1];
  return [[head uppercaseString] stringByAppendingString: tail];
}

- (NSString *) psTrimmedString {
  return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
