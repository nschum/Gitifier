// -------------------------------------------------------
// PSFoundationExtensions.h
//
// Copyright (c) 2010-11 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

// ------------------------------------------------------------------------------------------------

@interface NSArray (PsiToolkit)

// returns object at index 0, or nil if array is empty
- (id) psFirstObject;

// returns results of calling given selector on all elements
- (NSArray *) psArrayByCalling: (SEL) selector;

// returns the array with NSNull values removed
- (NSArray *) psCompact;

// returns the array filtered using a given predicate (see NSPredicate docs)
- (NSArray *) psFilterWithPredicate: (NSString *) filter;

// returns the array sorted by values of a given property
- (NSArray *) psSortedArrayUsingField: (NSString *) field ascending: (BOOL) ascending;
- (NSArray *) psSortedArrayUsingField: (NSString *) field ascending: (BOOL) ascending compareWith: (SEL) compareMethod;

// returns a dictionary grouping elements by all possible values of one property: { value => [matching elements] }
- (NSDictionary *) psGroupByKey: (NSString *) key;
@end

// ------------------------------------------------------------------------------------------------

@interface NSDate (PsiToolkit)

// returns a date n days ago
+ (NSDate *) psDaysAgo: (NSInteger) days;

// returns a date n days from now
+ (NSDate *) psDaysFromNow: (NSInteger) days;

// returns a formatter using JSON date format (YYYY-MM-DD)
+ (NSDateFormatter *) psJSONDateFormatter;

// tells if the other date is earlier or is on the same day (even if a few hours later)
- (BOOL) psIsEarlierOrSameDay: (NSDate *) otherDate;

// returns the midnight at the beginning of that day
- (NSDate *) psMidnight;

// returns the date formatted with a JSON formatter
- (NSString *) psJSONDateFormat;
@end

// ------------------------------------------------------------------------------------------------

@interface NSNull (PsiToolkit)

// for NSNull, always returns NO
- (BOOL) psIsPresent;
@end

// ------------------------------------------------------------------------------------------------

@interface NSObject (PsiToolkit)

// returns results of calling given selector on self, passing each element from the array in argument
+ (NSArray *) psArrayByCalling: (SEL) selector withObjectsFrom: (NSArray *) array;
- (NSArray *) psArrayByCalling: (SEL) selector withObjectsFrom: (NSArray *) array;
@end

// ------------------------------------------------------------------------------------------------

@interface NSString (PsiToolkit)

// returns a string constructed from key-value pairs which can be used as POST data (e.g. key=1&other=2&...)
+ (NSString *) psStringWithFormEncodedFields: (NSDictionary *) fields;

// as above, but keys are sent as fields of a model, e.g. model[field1]=1&model[field2]=2&...
+ (NSString *) psStringWithFormEncodedFields: (NSDictionary *) fields ofModelNamed: (NSString *) name;

// returns YES if the string isn't empty any doesn't contain whitespace only
- (BOOL) psIsPresent;

// tells if the string contains a substring
- (BOOL) psContainsString: (NSString *) substring;

// converts this_kind_of_string to thisKindOfString
- (NSString *) psCamelizedString;

// converts 'object' to 'objects' etc.
- (NSString *) psPluralizedString;

// encodes string to be used in URLs, i.e. replaces all dangerous characters with %xx
- (NSString *) psStringWithPercentEscapesForFormValues;

// converts "such string" to "Such string"
- (NSString *) psStringWithUppercaseFirstLetter;

// strips whitespace from both ends of the string
- (NSString *) psTrimmedString;

// the opposite of psCamelizedString
- (NSString *) psUnderscoreSeparatedString;
@end
