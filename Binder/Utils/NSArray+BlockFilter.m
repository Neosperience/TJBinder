//
//  NSArray+BlockFilter.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 01/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "NSArray+BlockFilter.h"

@implementation NSArray (BlockFilter)

-(id)firstObjectMatchingPredicate:(NSPredicate *)predicate
{
    id matchingObject = nil;
    for (id item in self)
    {
        if ([predicate evaluateWithObject:item])
        {
            matchingObject = item;
            break;
        }
    }
    return matchingObject;
}

-(id)firstObjectMatchingWithBlock:(BOOL (^)(id))block
{
    id matchingObject = nil;
    for (id item in self)
    {
        if (block(item))
        {
            matchingObject = item;
            break;
        }
    }
    return matchingObject;
}

-(NSArray*)filteredArrayUsingBlock:(BOOL (^)(id item))block
{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self count]];
    for (id item in self) if (block(item)) [result addObject:item];
    return [result copy];
}

@end
