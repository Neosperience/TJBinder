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

#ifndef TJBINDER_SELECTED_LOGGER
#define TJBINDER_SELECTED_LOGGER            TJBINDER_LOGGER_NSLOG
#endif

#if (TJBINDER_SELECTED_LOGGER == TJBINDER_LOGGER_NSLOG)

#import "TJBinderLoggerNSLog.h"

#elif (TJBINDER_SELECTED_LOGGER == TJBINDER_LOGGER_COCOALUMBERJACK)

#import "TJBinderLoggerLumberjack.h"

#endif
