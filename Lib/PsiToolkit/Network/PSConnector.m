// -------------------------------------------------------
// PSConnector.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#ifdef PSITOOLKIT_ENABLE_NETWORK

#import "PSConnector.h"
#import "PSMacros.h"
#import "PSRequest.h"
#import "PSResponse.h"

#ifdef PSITOOLKIT_ENABLE_MODELS
  #import "PSRestRouter.h"
#endif

#define DEFAULT_REQUEST_TIMEOUT 20.0

#if TARGET_OS_IPHONE
  #define IMAGE_CLASS UIImage
#else
  #define IMAGE_CLASS NSImage
#endif

static PSConnector *sharedConnector = nil;

@interface PSConnector ()
- (NSError *) errorWithCode: (NSInteger) code message: (NSString *) message;
@end

@implementation PSConnector

@synthesize baseURL, userAgent, usesHTTPAuthentication, router, account, loggingEnabled;

+ (id) sharedConnector {
  if (!sharedConnector) {
    sharedConnector = [[PSConnector alloc] init];
  }
  return sharedConnector;
}

+ (void) setSharedConnector: (PSConnector *) connector {
  if (connector != sharedConnector) {
    [sharedConnector release];
    sharedConnector = [connector retain];
  }
}

+ (void) setSharedConnectorClass: (Class) klass {
  id connector = [[[klass alloc] init] autorelease];
  [self setSharedConnector: connector];
}

- (id) init {
  self = [super init];
  if (self) {
    currentRequests = [[NSMutableArray alloc] initWithCapacity: 5];
    #ifdef PSITOOLKIT_ENABLE_MODELS
      router = [[PSRestRouter alloc] init];
    #endif
    #ifdef DEBUG
      loggingEnabled = YES;
    #else
      loggingEnabled = NO;
    #endif
  }
  return self;
}

- (id) initWithBaseURL: (NSString *) url {
  self = [super init];
  if (self) {
    baseURL = [url copy];
  }
  return self;
}

- (void) setRouter: (id) newRouter {
  NSAssert1(newRouter == nil || [newRouter conformsToProtocol: @protocol(PSRouter)],
    @"This object doesn't implement PSRouter protocol and can't be used as a router: %@", newRouter);
  if (newRouter != router) {
    [router release];
    router = [newRouter retain];
  }
}

- (void) setAccount: (id) newAccount {
  NSAssert1(newAccount == nil || [newAccount conformsToProtocol: @protocol(PSConnectorAccount)],
    @"This object doesn't implement PSConnectorAccount protocol and can't be used as an account: %@", newAccount);
  if (newAccount != account) {
    [account release];
    account = [newAccount retain];
  }
}

- (void) log: (NSString *) text {
  if (loggingEnabled) {
    NSLog(@"%@", text);
  }
}

#ifdef PSITOOLKIT_ENABLE_MODELS

- (PSRequest *) createRequestForObject: (PSModel *) object {
  PSRequest *request = [self requestToPath: [router pathForModel: [object class]] method: PSPostMethod];
  request.userInfo = PSHash(@"object", object);
  request.postData = [object encodeToPostData];
  return request;
}

- (PSRequest *) showRequestForObject: (PSModel *) object {
  PSRequest *request = [self requestToPath: [router pathForObject: object]];
  request.userInfo = PSHash(@"object", object);
  return request;
}

- (PSRequest *) updateRequestForObject: (PSModel *) object {
  PSRequest *request = [self requestToPath: [router pathForObject: object] method: PSPutMethod];
  request.userInfo = PSHash(@"object", object);
  request.postData = [object encodeToPostData];
  return request;
}

- (PSRequest *) deleteRequestForObject: (PSModel *) object {
  PSRequest *request = [self requestToPath: [router pathForObject: object] method: PSDeleteMethod];
  request.userInfo = PSHash(@"object", object);
  return request;
}

#endif // ifdef PSITOOLKIT_ENABLE_MODELS

- (void) prepareRequest: (PSRequest *) request {
  // override in subclasses to add headers and shit
}

- (PSRequest *) requestToPath: (NSString *) path {
  return [self requestToPath: path method: PSGetMethod];
}

- (PSRequest *) requestToURL: (NSString *) url {
  return [self requestToURL: url method: PSGetMethod];
}

- (PSRequest *) requestToPath: (NSString *) path method: (NSString *) method {
  NSString *url = [[self baseURL] stringByAppendingString: path];
  return [self requestToURL: url method: method];
}

- (PSRequest *) requestToURL: (NSString *) url method: (NSString *) method {
  PSRequest *request = [[PSRequest alloc] initWithURL: url connector: self];
  [request setRequestMethod: method];
  [request setTimeOutSeconds: DEFAULT_REQUEST_TIMEOUT];
  [request setExpectedContentType: PSJSONResponseType];
  if (usesHTTPAuthentication && account) {
    [request setUsername: [account username]];
    [request setPassword: [account password]];
  }
  if (userAgent) {
    [request addRequestHeader: @"User-Agent" value: userAgent];
  }
  [self prepareRequest: request];
  return [request autorelease];
}

- (void) requestStarted: (PSRequest *) request {
  if (loggingEnabled) {
    NSLog(@"sending request to %@", request.url);
  }

  [currentRequests addObject: request];
}

- (void) requestFinished: (PSRequest *) request {
  if (loggingEnabled) {
    NSLog(@"finished %@", request.response);
  }

  [self cleanupRequest: request];
  [self checkResponseForErrors: request];

  if (request.error) {
    [self handleFailedRequest: request];
  } else {
    [self performSelector: request.successHandler withObject: request];
  }
}

- (void) requestFailed: (PSRequest *) request {
  if (loggingEnabled) {
    NSLog(@"failed %@", request.response);
  }

  [self cleanupRequest: request];
  [self handleFailedRequest: request];
}

- (void) authenticationNeededForRequest: (PSRequest *) request {
  if (loggingEnabled) {
    NSLog(@"authentication failed in %@", request.response);
  }

  [self cleanupRequest: request];
  [self handleFailedAuthentication: request];
}

- (void) handleFinishedRequest: (PSRequest *) request {
  id response = [self parseResponseFromRequest: request];
  if (response) {
    [request notifyTargetOfSuccessWithObject: response];
  }
}

- (void) handleFailedRequest: (PSRequest *) request {
  [request notifyTargetOfError: request.error];
}

- (void) handleFailedAuthentication: (PSRequest *) request {
  [request cancel];
  [request notifyTargetOfAuthenticationError];
}

- (void) checkResponseForErrors: (PSRequest *) request {
  if (request.response.status >= 400) {
    request.error = [self errorWithCode: request.response.status message: @"Incorrect response"];
    return;
  }

  if (![request.response matchesExpectedContentType]) {
    request.error = [self errorWithCode: PSIncorrectContentTypeError message: @"Incorrect response"];
    return;
  }
}

- (NSError *) errorWithCode: (NSInteger) code message: (NSString *) message {
  return [NSError errorWithDomain: PsiToolkitErrorDomain
                             code: code
                         userInfo: PSHash(NSLocalizedDescriptionKey, PSTranslate(message))];
}

- (id) parseResponseFromRequest: (PSRequest *) request {
  PSResponse *response = request.response;
  NSString *string;

  switch (request.expectedContentType) {
    case PSHTMLResponseType:
    case PSXMLResponseType:
      return [response.text psTrimmedString];

    case PSImageResponseType:
      return [[[IMAGE_CLASS alloc] initWithData: response.data] autorelease];

    case PSJSONResponseType:
      string = [response.text psTrimmedString];
      #ifdef PSITOOLKIT_ENABLE_MODELS_JSON
        if (string.length == 0) {
          return PSNull;
        } else {
          @try {
            return [PSModel valueFromJSONString: string];
          } @catch (NSException *exception) {
            request.error = [self errorWithCode: PSJSONParsingError message: @"Data parsing error"];
            [self handleFailedRequest: request];
            return nil;
          }
        }
      #else
        return string;
      #endif

    case PSImageDataResponseType:
    case PSBinaryResponseType:
      return response.data;

    case PSAnyResponseType:
      return response;

    default:
      return nil;
  }
}

#ifdef PSITOOLKIT_ENABLE_MODELS_JSON

- (id) parseObjectFromRequest: (PSRequest *) request model: (Class) klass {
  NSDictionary *json = [self parseResponseFromRequest: request];
  if (!json || [json isEqual: PSNull]) {
    return json;
  } else {
    return [klass objectFromJSON: json];
  }
}

- (NSArray *) parseObjectsFromRequest: (PSRequest *) request model: (Class) klass {
  NSArray *json = [self parseResponseFromRequest: request];
  if (!json || [json isEqual: PSNull]) {
    return json;
  } else {
    return [klass objectsFromJSON: json];
  }
}

#endif

- (void) cleanupRequest: (PSRequest *) request {
  [[request retain] autorelease];
  [currentRequests removeObject: request];
}

- (void) cancelAllRequests {
  [currentRequests makeObjectsPerformSelector: @selector(cancel)];
  [currentRequests removeAllObjects];
}

- (void) dealloc {
  [self cancelAllRequests];

  [baseURL release];
  [currentRequests release];
  [account release];
  [router release];
  [userAgent release];

  [super dealloc];
}

@end

#endif
