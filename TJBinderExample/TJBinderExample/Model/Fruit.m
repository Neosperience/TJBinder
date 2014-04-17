//
//  Fruit.m
//  TJBinderExample
//
//  Created by Janos Tolgyesi on 17/04/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import "Fruit.h"

@interface Fruit ()
{
    UIColor* _color;
}

@end

@implementation Fruit

#pragma mark Data parsing

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        for (NSString* key in dictionary) [self setValue:dictionary[key] forKey:key];
    }
    return self;
}

+(instancetype)fruitWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

+(NSArray *)fruitsFromArray:(NSArray *)array
{
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSDictionary* dictionary in array)
    {
        [results addObject:[self fruitWithDictionary:dictionary]];
    }
    return [results copy];
}

#pragma mark Custom property setters

-(UIColor *)color
{
    if (!_color)
    {
        NSString* selectorName = [NSString stringWithFormat:@"%@Color", self.colorName];
        SEL selector = NSSelectorFromString(selectorName);
        NSParameterAssert([[UIColor class] respondsToSelector:selector]);
        IMP imp = [[UIColor class] methodForSelector:selector];
        UIColor* (*func)(id, SEL) = (void *)imp;
        _color = func([UIColor class], selector);
    }
    return _color;
}

#pragma mark NSObject overrides

+(NSSet *)keyPathsForValuesAffectingColor
{
    return [NSSet setWithArray:@[@"colorName"]];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ { name: %@, color: %@, colorName: %@ }", [super description], self.name, self.color, self.colorName];
}

@end
