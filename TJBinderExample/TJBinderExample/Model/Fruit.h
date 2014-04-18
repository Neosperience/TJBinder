//
//  Fruit.h
//  TJBinderExample
//
//  Created by Janos Tolgyesi on 17/04/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Simple data object example.
 
 It parses the color names to colors.
 */
@interface Fruit : NSObject

/**
 Initializes the Fruit object with the resource dictionary
 
 @param dictionary A dictionary with @{ name: @"Apple", colorName: @"red" } format.
 
 @return The initialized Fruit object.
 */
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

/**
 Returns a new Fruit object initialized with the resource dictionary.
 
 @param dictionary A dictionary with @{ name: @"Apple", colorName: @"red" } format.
 
 @return The new Fruit object initialized with the dictionary.
 */
+(instancetype)fruitWithDictionary:(NSDictionary*)dictionary;

/**
 Creates an array of Fruit objects from an array of resource dictionaries.
 
 @param array An array of resource dictionaries.
 
 @return An array of Fruit objects.
 */
+(NSArray*)fruitsFromArray:(NSArray*)array;

@property (strong) NSString* name;

/**
 Must be a color name supported by UIColor presets (black, darkGray, lightGray,
 white, gray, red, green, blueColor, cyan, yellow, magenta, orange, purple, brown
 or clear).
 */
@property (strong, nonatomic) NSString* colorName;

/**
 Derived property containing the color parsed from colorName
 */
@property (readonly) UIColor* color;

@property (strong, nonatomic) NSString* imageURLString;
@property (readonly) NSURL* imageURL;

@property (strong) NSString* imageLicense;

@property (strong, nonatomic) NSString* imageLicenseURLString;
@property (readonly) NSURL* imageLicenseURL;

@end
