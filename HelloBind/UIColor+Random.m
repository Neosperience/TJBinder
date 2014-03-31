//
//  UIColor+Random.m
//  HelloUIKitDynamics
//
//  Created by Janos Tolgyesi on 19/02/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import "UIColor+Random.h"

float randomFloat255()
{
    int r = rand() % 256;
    return (float)r / 256.0f;
}

@implementation UIColor (Random)

+(UIColor *)randomColor
{
    return [UIColor colorWithRed:randomFloat255() green:randomFloat255() blue:randomFloat255() alpha:1.0f];
}

-(UIColor *)complementerColor
{
    CGFloat hue, saturation, brightness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    CGFloat complementerHue = hue > 0.5f ? hue - 0.5f : hue + 0.5f;
    return [UIColor colorWithHue:complementerHue saturation:saturation brightness:brightness alpha:alpha];
}

@end
