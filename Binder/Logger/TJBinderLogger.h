//
//  TJBinderLogger.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 11/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TJBINDER_LOGGER_NSLOG               1
#define TJBINDER_LOGGER_COCOALUMBERJACK     2

// Select your preferred logger here
#define TJBINDER_SELECTED_LOGGER            TJBINDER_LOGGER_COCOALUMBERJACK

#if (TJBINDER_SELECTED_LOGGER == TJBINDER_LOGGER_NSLOG)

#define TJBinderLogVerbose(fmt, ...)     NSLog(fmt, ##__VA_ARGS__);
#define TJBinderLogInfo(fmt, ...)        NSLog(fmt, ##__VA_ARGS__);
#define TJBinderLogDebug(fmt, ...)       NSLog(fmt, ##__VA_ARGS__);
#define TJBinderLogWarning(fmt, ...)     NSLog(fmt, ##__VA_ARGS__);
#define TJBinderLogError(fmt, ...)       NSLog(fmt, ##__VA_ARGS__);

#elif (TJBINDER_SELECTED_LOGGER == TJBINDER_LOGGER_COCOALUMBERJACK)

#import <DDLog.h>

#define TJBinderLogVerbose(fmt, ...)     DDLogVerbose(fmt, ##__VA_ARGS__);
#define TJBinderLogInfo(fmt, ...)        DDLogInfo(fmt, ##__VA_ARGS__);
#define TJBinderLogDebug(fmt, ...)       DDLogDebug(fmt, ##__VA_ARGS__);
#define TJBinderLogWarn(fmt, ...)        DDLogWarn(fmt, ##__VA_ARGS__);
#define TJBinderLogError(fmt, ...)       DDLogError(fmt, ##__VA_ARGS__);

#endif
