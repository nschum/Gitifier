// -------------------------------------------------------
// PSDependencies.h
//
// Copyright (c) 2011 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#define PSITOOLKIT_ENABLE_MODELS_JSON

#if defined(PSITOOLKIT_USE_YAJL)
  #import <YAJL/YAJL.h>
#elif defined(PSITOOLKIT_USE_JSON_FRAMEWORK)
  #import "JSON.h"
#elif defined(PSITOOLKIT_USE_TOUCHJSON)
  #import "CJSONDeserializer.h"
#elif defined(PSITOOLKIT_USE_JSONKIT)
  #import "JSONKit.h"
#else
  #undef PSITOOLKIT_ENABLE_MODELS_JSON
#endif
