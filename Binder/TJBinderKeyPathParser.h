//
//  BinderKeyPathParser.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 01/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef UIView* (^TJBinderKeyPathNoArgumentTransformerBlock)(UIView* view, NSString* originalKeyPathComponent);
typedef UIView* (^TJBinderKeyPathIntegerArgumentTransformerBlock)(UIView* view, NSInteger argument);
typedef UIView* (^TJBinderKeyPathStringArgumentTransformerBlock)(UIView* view, NSString* argument);

@interface TJBinderKeyPathParser : NSObject

-(instancetype)initWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathNoArgumentTransformerBlock)block;
-(instancetype)initIntParserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathIntegerArgumentTransformerBlock)block;
-(instancetype)initStringParserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathStringArgumentTransformerBlock)block;

+(instancetype)parserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathNoArgumentTransformerBlock)block;
+(instancetype)intParserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathIntegerArgumentTransformerBlock)block;
+(instancetype)stringParserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathStringArgumentTransformerBlock)block;

-(UIView*)tryToParseWithKeyPathComponent:(NSString *)keyPathComponent forView:(UIView *)view;

@property (readonly) NSString* functionName;

@end
