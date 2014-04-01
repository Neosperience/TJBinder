//
//  BinderKeyPathParser.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 01/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef UIView* (^BinderKeyPathNoArgumentTransformerBlock)(UIView* view, NSString* originalKeyPathComponent);
typedef UIView* (^BinderKeyPathIntegerArgumentTransformerBlock)(UIView* view, NSInteger argument);
typedef UIView* (^BinderKeyPathStringArgumentTransformerBlock)(UIView* view, NSString* argument);

@interface BinderKeyPathParser : NSObject

-(instancetype)initWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathNoArgumentTransformerBlock)block;
-(instancetype)initIntParserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathIntegerArgumentTransformerBlock)block;
-(instancetype)initStringParserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathStringArgumentTransformerBlock)block;

+(instancetype)parserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathNoArgumentTransformerBlock)block;
+(instancetype)intParserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathIntegerArgumentTransformerBlock)block;
+(instancetype)stringParserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathStringArgumentTransformerBlock)block;

-(UIView*)tryToParseWithKeyPathComponent:(NSString *)keyPathComponent forView:(UIView *)view;

@property (readonly) NSString* functionName;

@end
