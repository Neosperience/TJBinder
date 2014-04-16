//
//  BinderKeyPathParser.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 01/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "TJBinderKeyPathParser.h"
#import "UIView+TJBinder.h"
#import "TJBinderLogger.h"

typedef enum : NSUInteger {
    BinderKeyPathParserTypeUnknown,
    BinderKeyPathParserTypeNoArgument,
    BinderKeyPathParserTypeIntegerArgument,
    BinderKeyPathParserTypeStringArgument,
} BinderKeyPathParserType;

@interface TJBinderKeyPathParser ()

@property (assign) BinderKeyPathParserType type;
@property (strong) NSString* functionName;
@property (nonatomic, copy) TJBinderKeyPathIntegerArgumentTransformerBlock integerTransformerBlock;
@property (nonatomic, copy) TJBinderKeyPathStringArgumentTransformerBlock stringTransformerBlock;
@property (nonatomic, copy) TJBinderKeyPathNoArgumentTransformerBlock transformerBlock;

@end

@implementation TJBinderKeyPathParser

- (instancetype)initIntParserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathIntegerArgumentTransformerBlock)block
{
    self = [super init];
    if (self) {
        self.functionName = functionName;
        self.type = BinderKeyPathParserTypeIntegerArgument;
        self.integerTransformerBlock = block;
    }
    return self;
}

-(instancetype)initStringParserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathStringArgumentTransformerBlock)block
{
    self = [super init];
    if (self) {
        self.functionName = functionName;
        self.type = BinderKeyPathParserTypeStringArgument;
        self.stringTransformerBlock = block;
    }
    return self;
}

- (instancetype)initWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathNoArgumentTransformerBlock)block
{
    self = [super init];
    if (self) {
        self.functionName = functionName;
        self.type = BinderKeyPathParserTypeNoArgument;
        self.transformerBlock = block;
    }
    return self;
}

-(void)setTransformerBlock:(TJBinderKeyPathNoArgumentTransformerBlock)transformerBlock
{
    NSParameterAssert(transformerBlock);
    _transformerBlock = [transformerBlock copy];
}

-(void)setStringTransformerBlock:(TJBinderKeyPathStringArgumentTransformerBlock)stringTransformerBlock
{
    NSParameterAssert(stringTransformerBlock);
    _stringTransformerBlock = [stringTransformerBlock copy];
}

-(void)setIntegerTransformerBlock:(TJBinderKeyPathIntegerArgumentTransformerBlock)integerTransformerBlock
{
    NSParameterAssert(integerTransformerBlock);
    _integerTransformerBlock = [integerTransformerBlock copy];
}

+(instancetype)intParserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathIntegerArgumentTransformerBlock)block
{
    return [[self alloc] initIntParserWithFunction:functionName withTransformerBlock:block];
}

+(instancetype)stringParserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathStringArgumentTransformerBlock)block
{
    return [[self alloc] initStringParserWithFunction:functionName withTransformerBlock:block];
}

+(instancetype)parserWithFunction:(NSString *)functionName withTransformerBlock:(TJBinderKeyPathNoArgumentTransformerBlock)block
{
    return [[self alloc] initWithFunction:functionName withTransformerBlock:block];
}

+(NSString *)stringFromType:(BinderKeyPathParserType)type
{
    switch (type)
    {
        case BinderKeyPathParserTypeStringArgument:
            return @"STRING";
            break;
            
        case BinderKeyPathParserTypeIntegerArgument:
            return @"INT";
            break;
            
        case BinderKeyPathParserTypeNoArgument:
            return @"NO ARG";
            break;
            
        default:
            return @"UNKNOWN";
            break;
    }
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ type: %@ functionName: %@", [super description], [[self class] stringFromType:self.type], self.functionName];
}

-(UIView*)tryToParseWithKeyPathComponent:(NSString *)keyPathComponent forView:(UIView *)view
{
    UIView* result = nil;
    
    TJBinderLogVerbose(@"%@ tryToParseWithKeyPathComponent: %@ forView: %@", self, keyPathComponent, [view shortDescription]);
    
    BOOL matches = [self.functionName isEqualToString:@"*"];
    
    if (!matches)
    {
        if (self.type == BinderKeyPathParserTypeNoArgument) matches = [keyPathComponent isEqualToString:self.functionName];
        else matches = [keyPathComponent hasPrefix:self.functionName];
    }
    
    if (matches)
    {
        switch (self.type)
        {
            case BinderKeyPathParserTypeNoArgument:
            {
                NSAssert(self.transformerBlock, @"nil transformer block");
                result = self.transformerBlock(view, keyPathComponent);
                break;
            }
        
            case BinderKeyPathParserTypeIntegerArgument:
            {
                NSInteger argument = [self parseIntegerFromBracketsFromString:keyPathComponent withPrefix:self.functionName];
                NSAssert(argument != NSNotFound, @"Unable to parse key path component: %@", keyPathComponent);
                result = self.integerTransformerBlock(view, argument);
                break;
            }
            
            case BinderKeyPathParserTypeStringArgument:
            {
                NSString* argument = [self parseStringFromBracketsFromString:keyPathComponent withPrefix:self.functionName];
                NSAssert(argument, @"Unable to parse key path component: %@", keyPathComponent);
                result = self.stringTransformerBlock(view, argument);
                break;
            }

            default:
                break;
        }
    }
    
    if (result)
    {
        TJBinderLogVerbose(@"success, resolved view: %@", [result shortDescription]);
    }
    else
    {
        TJBinderLogVerbose(@"no match");
    }
    
    return result;
}

-(NSInteger)parseIntegerFromBracketsFromString:(NSString*)string withPrefix:(NSString*)prefix
{
    NSScanner* scanner = [NSScanner scannerWithString:string];
    NSInteger result = NSNotFound;
    BOOL success = YES;
    success &= [scanner scanString:prefix intoString:NULL];
    success &= [scanner scanString:@"[" intoString:NULL];
    success &= [scanner scanInteger:&result];
    success &= [scanner scanString:@"]" intoString:NULL];
    return success ? result : NSNotFound;
}

-(NSString*)parseStringFromBracketsFromString:(NSString*)string withPrefix:(NSString*)prefix
{
    NSScanner* scanner = [NSScanner scannerWithString:string];
    NSString* result = nil;
    BOOL success = YES;
    success &= [scanner scanString:prefix intoString:NULL];
    success &= [scanner scanString:@"[" intoString:NULL];
    success &= [scanner scanUpToString:@"]" intoString:&result];
    success &= [scanner scanString:@"]" intoString:NULL];
    return success ? result : nil;
}

@end
