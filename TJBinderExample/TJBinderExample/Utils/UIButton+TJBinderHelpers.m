//
//  UIButton+TJBinderHelpers.m
//  TJBinderExample
//
//  Created by Janos Tolgyesi on 18/04/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import "UIButton+TJBinderHelpers.h"

@implementation UIButton (TJBinderHelpers)

-(void)setTitleForNormalState:(NSString *)titleForNormalState
{
    [self setTitle:titleForNormalState forState:UIControlStateNormal];
}

-(NSString *)titleForNormalState
{
    return [self titleForState:UIControlStateNormal];
}

@end
