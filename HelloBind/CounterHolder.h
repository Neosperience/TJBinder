//
//  CounterHolder.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 31/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Counter;

@interface CounterHolder : NSObject

@property (nonatomic, strong) Counter* counter;

@end
