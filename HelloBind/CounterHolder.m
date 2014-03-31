//
//  CounterHolder.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 31/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "CounterHolder.h"
#import "Counter.h"

@implementation CounterHolder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.counter = [Counter new];
    }
    return self;
}

@end
