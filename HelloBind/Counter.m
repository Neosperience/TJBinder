//
//  Counter.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "Counter.h"
#import "UIColor+Random.h"

@interface Counter ()

@property (nonatomic, assign) NSInteger counter;

@end

@implementation Counter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.counter = 0;
        self.counterColor = [UIColor randomColor];
        [self scheduleIncrement];
    }
    return self;
}

-(void)incrementCounter
{
    self.counter++;
    self.counterColor = [UIColor randomColor];
    [self scheduleIncrement];
}

-(NSString *)counterString
{
    return [@(self.counter) stringValue];
}

+(NSSet *)keyPathsForValuesAffectingCounterString
{
    return [NSSet setWithObject:@"counter"];
}

-(void)scheduleIncrement
{
    [self performSelector:@selector(incrementCounter) withObject:nil afterDelay:1];
}

@end
