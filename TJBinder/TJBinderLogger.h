//
//  TJBinderLogger.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 11/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TJBINDER_LOGGER_NOLOG           1
#define TJBINDER_LOGGER_NSLOG           2
#define TJBINDER_LOGGER_COCOALUMBERJACK 3

#ifndef TJBINDER_SELECTED_LOGGER

#define TJBINDER_SELECTED_LOGGER        TJBINDER_LOGGER_NOLOG

#endif

#if (TJBINDER_SELECTED_LOGGER == TJBINDER_LOGGER_NOLOG)

#define TJBinderLogVerbose(fmt, ...)
#define TJBinderLogInfo(fmt, ...)
#define TJBinderLogDebug(fmt, ...)
#define TJBinderLogWarning(fmt, ...)
#define TJBinderLogError(fmt, ...)

#elif (TJBINDER_SELECTED_LOGGER == TJBINDER_LOGGER_NSLOG)

#define TJBinderLogVerbose(fmt, ...)     NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define TJBinderLogInfo(fmt, ...)        NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define TJBinderLogDebug(fmt, ...)       NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define TJBinderLogWarning(fmt, ...)     NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define TJBinderLogError(fmt, ...)       NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);

#elif (TJBINDER_SELECTED_LOGGER == TJBINDER_LOGGER_COCOALUMBERJACK)

#import <DDLog.h>

extern const int ddLogLevel;

#define TJBinderLogVerbose(fmt, ...)     DDLogVerbose(fmt, ##__VA_ARGS__);
#define TJBinderLogInfo(fmt, ...)        DDLogInfo(fmt, ##__VA_ARGS__);
#define TJBinderLogDebug(fmt, ...)       DDLogDebug(fmt, ##__VA_ARGS__);
#define TJBinderLogWarn(fmt, ...)        DDLogWarn(fmt, ##__VA_ARGS__);
#define TJBinderLogError(fmt, ...)       DDLogError(fmt, ##__VA_ARGS__);

#endif
