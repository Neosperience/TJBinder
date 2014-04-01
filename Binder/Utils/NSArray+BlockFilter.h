//
//  NSArray+BlockFilter.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 01/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (BlockFilter)

-(id)firstObjectMatchingPredicate:(NSPredicate*)predicate;
-(id)firstObjectMatchingWithBlock:(BOOL (^)(id item))block;
-(NSArray*)filteredArrayUsingBlock:(BOOL (^)(id item))block;

@end
