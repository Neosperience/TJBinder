//
//  BinderKeyPathParser.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 01/04/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "BinderKeyPathParser.h"
#import "NSString+NEOSStringUtils.h"
#import "UIView+Bind.h"

typedef enum : NSUInteger {
    BinderKeyPathParserTypeUnknown,
    BinderKeyPathParserTypeNoArgument,
    BinderKeyPathParserTypeIntegerArgument,
    BinderKeyPathParserTypeStringArgument,
} BinderKeyPathParserType;

@interface BinderKeyPathParser ()

@property (assign) BinderKeyPathParserType type;
@property (strong) NSString* functionName;
@property (nonatomic, copy) BinderKeyPathIntegerArgumentTransformerBlock integerTransformerBlock;
@property (nonatomic, copy) BinderKeyPathStringArgumentTransformerBlock stringTransformerBlock;
@property (nonatomic, copy) BinderKeyPathNoArgumentTransformerBlock transformerBlock;

@end

@implementation BinderKeyPathParser

- (instancetype)initIntParserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathIntegerArgumentTransformerBlock)block
{
    self = [super init];
    if (self) {
        self.functionName = functionName;
        self.type = BinderKeyPathParserTypeIntegerArgument;
        self.integerTransformerBlock = block;
    }
    return self;
}

-(instancetype)initStringParserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathStringArgumentTransformerBlock)block
{
    self = [super init];
    if (self) {
        self.functionName = functionName;
        self.type = BinderKeyPathParserTypeStringArgument;
        self.stringTransformerBlock = block;
    }
    return self;
}

- (instancetype)initWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathNoArgumentTransformerBlock)block
{
    self = [super init];
    if (self) {
        self.functionName = functionName;
        self.type = BinderKeyPathParserTypeNoArgument;
        self.transformerBlock = block;
    }
    return self;
}

-(void)setTransformerBlock:(BinderKeyPathNoArgumentTransformerBlock)transformerBlock
{
    NSParameterAssert(transformerBlock);
    _transformerBlock = [transformerBlock copy];
}

-(void)setStringTransformerBlock:(BinderKeyPathStringArgumentTransformerBlock)stringTransformerBlock
{
    NSParameterAssert(stringTransformerBlock);
    _stringTransformerBlock = [stringTransformerBlock copy];
}

-(void)setIntegerTransformerBlock:(BinderKeyPathIntegerArgumentTransformerBlock)integerTransformerBlock
{
    NSParameterAssert(integerTransformerBlock);
    _integerTransformerBlock = [integerTransformerBlock copy];
}

+(instancetype)intParserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathIntegerArgumentTransformerBlock)block
{
    return [[self alloc] initIntParserWithFunction:functionName withTransformerBlock:block];
}

+(instancetype)stringParserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathStringArgumentTransformerBlock)block
{
    return [[self alloc] initStringParserWithFunction:functionName withTransformerBlock:block];
}

+(instancetype)parserWithFunction:(NSString *)functionName withTransformerBlock:(BinderKeyPathNoArgumentTransformerBlock)block
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
    
    DDLogVerbose(@"%@ tryToParseWithKeyPathComponent: %@ forView: %@", self, keyPathComponent, [view shortDescription]);
    
    BOOL matches = [self.functionName isEqualToString:@"*"];
    
    if (!matches)
    {
        if (self.type == BinderKeyPathParserTypeNoArgument) matches = [keyPathComponent isEqualToString:self.functionName];
        else matches = [keyPathComponent startsWithString:self.functionName];
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
        DDLogVerbose(@"success, resolved view: %@", [result shortDescription]);
    }
    else
    {
        DDLogVerbose(@"no match");
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
