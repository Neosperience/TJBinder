//
//  BindProxy.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <DDLog.h>

#import "BindProxy.h"
#import "UIView+Bind.h"
#import "NSObject+FTKDataObject.h"
#import "NSString+NEOSStringUtils.h"
#import "BinderKeyPathParser.h"
#import "NSArray+BlockFilter.h"

@interface BindEntry : NSObject

@property (strong) NSString* dataObjectKeyPath;
@property (strong) NSString* viewKey;
@property (weak) UIView* view;
@property (assign) BOOL registered;

-(instancetype)initWithDataObjectKeyPath:(NSString*)dataObjectKeyPath viewKey:(NSString*)viewKey view:(UIView*)view;

@end

@implementation BindEntry

- (instancetype)initWithDataObjectKeyPath:(NSString *)dataObjectKeyPath viewKey:(NSString *)viewKey view:(UIView *)view
{
    self = [super init];
    if (self) {
        self.dataObjectKeyPath = dataObjectKeyPath;
        self.viewKey = viewKey;
        self.view = view;
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ view: %@, dataObjectKeyPath: %@, viewKey: %@, registered: %@",
            [super description], [self.view shortDescription], self.dataObjectKeyPath, self.viewKey, self.registered ? @"YES" : @"NO"];
}

@end

@interface BindProxy ()

@property (weak) UIView* view;
@property (strong) NSMutableArray* bindings;
@property (strong) NSMutableArray* dataObjectKeyPath;

@end

@implementation BindProxy

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bindings = [NSMutableArray array];
        self.dataObjectKeyPath = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view
{
    self = [self init];
    if (self) {
        self.view = view;
    }
    return self;
}

-(void)setDataObject:(id)dataObject
{
    [self unregisterBindings];
    [super setDataObject:dataObject];
    [self registerBindings];
}

-(void)dealloc
{
    [self unregisterBindings];
}

-(void)unregisterBindings
{
    for (BindEntry* entry in self.bindings)
    {
        if (entry.registered)
        {
            DDLogDebug(@"dataObject: %@ unregistering entry: { %@ }", self.dataObject, entry);
            [self.dataObject removeObserver:self forKeyPath:entry.dataObjectKeyPath context:(__bridge void *)(entry)];
            entry.registered = NO;
        }
        else
        {
            DDLogDebug(@"dataObject: %@ NOT unregistering entry: { %@ }", self.dataObject, entry);
        }
    }
}

-(void)registerBindings
{
    if (!self.dataObject) return;

    for (BindEntry* entry in self.bindings)
    {
        [self.dataObject addObserver:self forKeyPath:entry.dataObjectKeyPath options:NSKeyValueObservingOptionNew context:(__bridge void *)(entry)];
        entry.registered = YES;
        DDLogDebug(@"dataObject: %@, registered entry: { %@ }", self.dataObject, entry);
        [self updateViewForBindingEntry:entry];
    }
}

-(void)resetKeyPath
{
    [self.dataObjectKeyPath removeAllObjects];
}

-(void)flushBindingPathForFinalDataObjectKey:(NSString*)finalDataObjectKey viewKey:(NSString*)viewKey
{
    UIView* dataObjectHolderView = self.view;
    
    NSMutableArray* reconstructedDataObjectKeyPath = [NSMutableArray array];
    BOOL didPassDataObjectKey = NO;
    
    for (NSString* pathComponent in self.dataObjectKeyPath)
    {
        if ([pathComponent isEqualToString:@"dataObject"])
        {
            didPassDataObjectKey = YES;
            continue;
        }
        
        if (!didPassDataObjectKey)
        {
            dataObjectHolderView = [self viewForExtendedKeyPathComponent:pathComponent forView:dataObjectHolderView];
            NSAssert([dataObjectHolderView isKindOfClass:[UIView class]],
                     @"Found a non-UIView object %@ proceeding the key path: %@", dataObjectHolderView, self.dataObjectKeyPath);
            // TODO: support subviews array (?)
        }
        else
        {
            [reconstructedDataObjectKeyPath addObject:pathComponent];
        }
    }
    
    [reconstructedDataObjectKeyPath addObject:finalDataObjectKey];
    NSString* dataObjectKeyPathString = [reconstructedDataObjectKeyPath componentsJoinedByString:@"."];
    
    [self.dataObjectKeyPath removeAllObjects];
    
    BindEntry* entry = [[BindEntry alloc] initWithDataObjectKeyPath:dataObjectKeyPathString viewKey:viewKey view:self.view];
    
    [dataObjectHolderView.bindTo.bindings addObject:entry];
    
    [dataObjectHolderView.bindTo updateViewForBindingEntry:entry];
}

+ (NSArray*)parsers
{
    static dispatch_once_t onceToken;
    static NSArray* parsers;
    dispatch_once(&onceToken, ^{
        parsers = @[
        
            [BinderKeyPathParser parserWithFunction:@"@superview" withTransformerBlock:^UIView *(UIView *view, NSString *originalKeyPathComponent)
            {
                 NSAssert(view.superview, @"%@ has no superview", view);
                 return view.superview;
            }],
            
            [BinderKeyPathParser parserWithFunction:@"@rootview" withTransformerBlock:^UIView *(UIView *view, NSString *originalKeyPathComponent)
            {
                 UIView* currentView = view;
                 while (currentView.superview) currentView = currentView.superview;
                 return currentView;
            }],
            
            [BinderKeyPathParser intParserWithFunction:@"@superviewWithTag" withTransformerBlock:^UIView *(UIView *view, NSInteger argument)
            {
                UIView* currentView = view.superview;
                while (currentView && (currentView.tag != argument)) currentView = currentView.superview;
                NSAssert(currentView, @"No superview found with tag: %d", argument);
                return currentView;
            }],
            
            [BinderKeyPathParser stringParserWithFunction:@"@superviewWithRestorationID" withTransformerBlock:^UIView *(UIView *view, NSString *argument)
            {
                UIView* currentView = view.superview;
                while (currentView && (![currentView.restorationIdentifier isEqualToString:argument])) currentView = view.superview;
                NSAssert(currentView, @"No superview found with restorationID: %@", argument);
                return currentView;
            }],
            
            [BinderKeyPathParser stringParserWithFunction:@"@superviewWithClass" withTransformerBlock:^UIView *(UIView *view, NSString *argument)
            {
                UIView* currentView = view.superview;
                Class superviewClass = NSClassFromString(argument);
                NSAssert(superviewClass, @"Invalid class: %@", argument);
                while (currentView && (![currentView isKindOfClass:superviewClass])) currentView = currentView.superview;
                NSAssert(currentView, @"No superview found with class: '%@'", argument);
                return currentView;
            }],
        
            [BinderKeyPathParser intParserWithFunction:@"@subviews"
                                  withTransformerBlock:^UIView *(UIView *view, NSInteger argument)
            {
                 return view.subviews[argument];
            }],
            
            [BinderKeyPathParser intParserWithFunction:@"@subviewWithTag"
                                  withTransformerBlock:^UIView *(UIView *view, NSInteger argument)
            {
                 UIView* matchingView = [view.subviews firstObjectMatchingPredicate:[NSPredicate predicateWithFormat:@"tag == %d", argument]];
                 NSAssert(matchingView, @"No subview found with tag: %d", argument);
                 return matchingView;
            }],
            
            [BinderKeyPathParser stringParserWithFunction:@"@subviewWithRestorationID"
                                     withTransformerBlock:^UIView *(UIView *view, NSString *argument)
            {
                 UIView* matchingView = [view.subviews firstObjectMatchingPredicate:[NSPredicate predicateWithFormat:@"restorationIdentifier == %@", argument]];
                 NSAssert(matchingView, @"No subview found with restorationID: '%@'", argument);
                 return matchingView;
            }],
            
            [BinderKeyPathParser stringParserWithFunction:@"@subviewWithClass" withTransformerBlock:^UIView *(UIView *view, NSString *argument)
            {
                Class superviewClass = NSClassFromString(argument);
                UIView* matchingView = [view.subviews firstObjectMatchingWithBlock:^BOOL(id item) { return [item isKindOfClass:superviewClass]; }];
                NSAssert(matchingView, @"No subview found with class: '%@'", argument);
                return matchingView;
            }],
            
            [BinderKeyPathParser parserWithFunction:@"*" withTransformerBlock:^UIView *(UIView *view, NSString *originalKeyPathComponent)
            {
                return [view valueForKey:originalKeyPathComponent];
            }]
        ];
    });
    return parsers;
}

-(UIView*)viewForExtendedKeyPathComponent:(NSString*)pathComponent forView:(UIView*)view
{
    UIView* result = nil;
    
    for (BinderKeyPathParser* parser in [[self class] parsers])
    {
        result = [parser tryToParseWithKeyPathComponent:pathComponent forView:view];
        if (result) break;
    }
    
    NSAssert(result, @"Unable to parse key path component: %@", pathComponent);
    return result;
}

-(void)updateViewForBindingEntry:(BindEntry*)entry
{
    id extractedValue = [self.dataObject valueForKeyPath:entry.dataObjectKeyPath];
    [entry.view setValue:extractedValue forKey:entry.viewKey];
}

-(id)valueForUndefinedKey:(NSString *)key
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, key);
    [self.dataObjectKeyPath addObject:key];
    return self;
}

-(id)valueForKey:(NSString *)key
{
    if ([key isEqualToString:@"dataObject"])
    {
        [self.dataObjectKeyPath addObject:key];
        return self;
    }
    else
    {
        return [super valueForKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    DDLogVerbose(@"%s { %@ : %@ } \n%@", __PRETTY_FUNCTION__, key, value, self.dataObjectKeyPath);
    [self flushBindingPathForFinalDataObjectKey:key viewKey:value];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BindEntry* entry = (__bridge BindEntry*)context;
    [self updateViewForBindingEntry:entry];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@, view: %@, dataObject: %@, bindings: %@",
            [super description], [self.view shortDescription], self.dataObject, self.bindings];
}

@end
