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
    NSURL* _imageURL;
    NSURL* _imageLicenseURL;
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

-(void)setColorName:(NSString *)colorName
{
    _colorName = colorName;
    _color = nil;
}

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

-(void)setImageURLString:(NSString *)imageURLString
{
    _imageURLString = imageURLString;
    _imageURL = nil;
}

-(NSURL *)imageURL
{
    if (!_imageURL)
    {
        _imageURL = [NSURL URLWithString:self.imageURLString];
    }
    return _imageURL;
}

-(void)setImageLicenseURLString:(NSString *)imageLicenseURLString
{
    _imageLicenseURLString = imageLicenseURLString;
    _imageLicenseURL = nil;
}

-(NSURL *)imageLicenseURL
{
    if (!_imageLicenseURL)
    {
        _imageLicenseURL = [NSURL URLWithString:self.imageLicenseURLString];
    }
    return _imageLicenseURL;
}

#pragma mark NSObject overrides

+(NSSet *)keyPathsForValuesAffectingColor
{
    return [NSSet setWithArray:@[@"colorName"]];
}

+(NSSet *)keyPathsForValuesAffectingImageURL
{
    return [NSSet setWithArray:@[@"imageURLString"]];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ { name: %@, color: %@, colorName: %@ }", [super description], self.name, self.color, self.colorName];
}

@end
