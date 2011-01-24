// -------------------------------------------------------
// PSConstants.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#define PSGenericCell @"PSGenericCell"

#define PSKilobyte (1024)
#define PSMegabyte (1024 * PSKilobyte)
#define PSGigabyte (1024 * PSMegabyte)
#define PSMinute   (60)
#define PSHour     (60 * PSMinute)
#define PSDay      (24 * PSHour)

#define PsiToolkitErrorDomain @"PsiToolkitErrorDomain"

#define PSGetMethod    @"GET"
#define PSPostMethod   @"POST"
#define PSPutMethod    @"PUT"
#define PSDeleteMethod @"DELETE"

#define PSHTTPStatusOK                  200
#define PSHTTPStatusCreated             201
#define PSHTTPStatusAccepted            202
#define PSHTTPStatusNoContent           204
#define PSHTTPStatusBadRequest          400
#define PSHTTPStatusUnauthorized        401
#define PSHTTPStatusForbidden           403
#define PSHTTPStatusNotFound            404
#define PSHTTPStatusConflict            409
#define PSHTTPStatusPreconditionFailed  412
#define PSHTTPStatusInternalServerError 500
#define PSHTTPStatusBadGateway          502
#define PSHTTPStatusServiceUnavailable  503

#define PSIncorrectContentTypeError     -1
#define PSJSONParsingError              -2
