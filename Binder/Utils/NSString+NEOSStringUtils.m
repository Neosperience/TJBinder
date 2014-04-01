//
//  NSString+NEOSStringUtils.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 01/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "NSString+NEOSStringUtils.h"

@implementation NSString (NEOSStringUtils)

-(BOOL)startsWithString:(NSString *)string
{
    NSInteger length = [string length];
    if (length > [self length]) return NO;
    return ([[self substringToIndex:length] isEqualToString:string]);
}

@end
