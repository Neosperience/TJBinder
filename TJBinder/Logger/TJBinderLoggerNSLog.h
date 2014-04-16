//
//  TJBinderLogger.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 11/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TJBinderLogVerbose(fmt, ...)     NSLog(fmt, ##__VA_ARGS__);
#define TJBinderLogInfo(fmt, ...)        NSLog(fmt, ##__VA_ARGS__);
#define TJBinderLogDebug(fmt, ...)       NSLog(fmt, ##__VA_ARGS__);
#define TJBinderLogWarning(fmt, ...)     NSLog(fmt, ##__VA_ARGS__);
#define TJBinderLogError(fmt, ...)       NSLog(fmt, ##__VA_ARGS__);
