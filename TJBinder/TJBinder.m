//
//  BindProxy.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "TJBinder.h"
#import "UIView+TJBinder.h"
#import "TJBinderKeyPathParser.h"
#import "TJBinderLogger.h"

#pragma mark - BindEntry

@interface TJBindEntry : NSObject

@property (strong) NSString* dataObjectKeyPath;
@property (strong) NSString* viewKey;
@property (weak) UIView* view;
@property (assign) BOOL registered;

-(instancetype)initWithDataObjectKeyPath:(NSString*)dataObjectKeyPath viewKey:(NSString*)viewKey view:(UIView*)view;

@end

@implementation TJBindEntry

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

#pragma mark - BindProxy

@interface TJBinder ()

@property (weak) UIView* view;
@property (strong) NSMutableArray* bindings;
@property (strong) NSMutableArray* dataObjectKeyPath;

@end

@implementation TJBinder

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

-(void)updateView
{
    for (TJBindEntry* entry in self.bindings)
    {
        [self updateViewForBindingEntry:entry];
    }
}

-(void)setDataObject:(id)dataObject
{
    _dataObject = dataObject;
    [self updateView];
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
        }
        else
        {
            [reconstructedDataObjectKeyPath addObject:pathComponent];
        }
    }
    
    [reconstructedDataObjectKeyPath addObject:finalDataObjectKey];
    NSString* dataObjectKeyPathString = [reconstructedDataObjectKeyPath componentsJoinedByString:@"."];
    
    [self.dataObjectKeyPath removeAllObjects];
    
    TJBindEntry* entry = [[TJBindEntry alloc] initWithDataObjectKeyPath:dataObjectKeyPathString viewKey:viewKey view:self.view];
    
    [dataObjectHolderView.bindTo.bindings addObject:entry];
    
    [dataObjectHolderView.bindTo updateViewForBindingEntry:entry];
}

+ (NSArray*)parsers
{
    static dispatch_once_t onceToken;
    static NSArray* parsers;
    dispatch_once(&onceToken, ^{
        parsers = @[
        
            [TJBinderKeyPathParser parserWithFunction:@"@superview" withTransformerBlock:^UIView *(UIView *view, NSString *originalKeyPathComponent)
            {
                 NSAssert(view.superview, @"%@ has no superview", view);
                 return view.superview;
            }],
            
            [TJBinderKeyPathParser parserWithFunction:@"@rootview" withTransformerBlock:^UIView *(UIView *view, NSString *originalKeyPathComponent)
            {
                 UIView* currentView = view;
                 while (currentView.superview) currentView = currentView.superview;
                 return currentView;
            }],
            
            [TJBinderKeyPathParser intParserWithFunction:@"@superviewWithTag" withTransformerBlock:^UIView *(UIView *view, NSInteger argument)
            {
                UIView* currentView = view.superview;
                while (currentView && (currentView.tag != argument)) currentView = currentView.superview;
                NSAssert(currentView, @"No superview found with tag: %@", @(argument));
                return currentView;
            }],
            
            [TJBinderKeyPathParser stringParserWithFunction:@"@superviewWithRestorationID" withTransformerBlock:^UIView *(UIView *view, NSString *argument)
            {
                UIView* currentView = view.superview;
                while (currentView && (![currentView.restorationIdentifier isEqualToString:argument])) currentView = view.superview;
                NSAssert(currentView, @"No superview found with restorationID: %@", argument);
                return currentView;
            }],
            
            [TJBinderKeyPathParser stringParserWithFunction:@"@superviewWithClass" withTransformerBlock:^UIView *(UIView *view, NSString *argument)
            {
                UIView* currentView = view.superview;
                Class superviewClass = NSClassFromString(argument);
                NSAssert(superviewClass, @"Invalid class: %@", argument);
                while (currentView && (![currentView isKindOfClass:superviewClass])) currentView = currentView.superview;
                NSAssert(currentView, @"No superview found with class: '%@'", argument);
                return currentView;
            }],
        
            [TJBinderKeyPathParser intParserWithFunction:@"@subviews"
                                  withTransformerBlock:^UIView *(UIView *view, NSInteger argument)
            {
                return view.subviews[argument];
            }],
            
            [TJBinderKeyPathParser intParserWithFunction:@"@subviewWithTag"
                                  withTransformerBlock:^UIView *(UIView *view, NSInteger argument)
            {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"tag == %@", @(argument)];
                NSUInteger matchingViewIndex = [view.subviews indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [predicate evaluateWithObject:obj];
                }];
                NSAssert(matchingViewIndex != NSNotFound, @"No subview found with tag: %@", @(argument));
                return view.subviews[matchingViewIndex];
            }],
            
            [TJBinderKeyPathParser stringParserWithFunction:@"@subviewWithRestorationID"
                                     withTransformerBlock:^UIView *(UIView *view, NSString *argument)
            {
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"restorationIdentifier == %@", argument];
                NSUInteger matchingViewIndex = [view.subviews indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [predicate evaluateWithObject:obj];
                }];
                NSAssert(matchingViewIndex != NSNotFound, @"No subview found with restorationID: '%@'", argument);
                return view.subviews[matchingViewIndex];
            }],
            
            [TJBinderKeyPathParser stringParserWithFunction:@"@subviewWithClass" withTransformerBlock:^UIView *(UIView *view, NSString *argument)
            {
                Class superviewClass = NSClassFromString(argument);
                NSUInteger matchingViewIndex = [view.subviews indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    return [obj isKindOfClass:superviewClass];
                }];
                NSAssert(matchingViewIndex != NSNotFound, @"No subview found with class: '%@'", argument);
                return view.subviews[matchingViewIndex];
            }],

            [TJBinderKeyPathParser parserWithFunction:@"@cell" withTransformerBlock:^UIView *(UIView *view, NSString *originalKeyPathComponent) {
                UIView* currentView = view.superview;
                while (currentView && (![currentView isKindOfClass:[UITableViewCell class]] && ![currentView isKindOfClass:[UICollectionViewCell class]]))
                    currentView = currentView.superview;
                NSAssert(currentView, @"No superview found with class UITableViewCell or UICollectionViewCell");
                return currentView;
            }],
            
            [TJBinderKeyPathParser parserWithFunction:@"*" withTransformerBlock:^UIView *(UIView *view, NSString *originalKeyPathComponent)
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
    
    for (TJBinderKeyPathParser* parser in [[self class] parsers])
    {
        result = [parser tryToParseWithKeyPathComponent:pathComponent forView:view];
        if (result) break;
    }
    
    NSAssert(result, @"Unable to parse key path component: %@", pathComponent);
    return result;
}

-(void)updateViewForBindingEntry:(TJBindEntry*)entry
{
    id extractedValue = [self.dataObject valueForKeyPath:entry.dataObjectKeyPath];
    [entry.view setValue:extractedValue forKey:entry.viewKey];
}

#pragma mark NSObject overrides

-(id)valueForUndefinedKey:(NSString *)key
{
    TJBinderLogVerbose(@"%s %@", __PRETTY_FUNCTION__, key);
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
    TJBinderLogVerbose(@"%s { %@ : %@ } \n%@", __PRETTY_FUNCTION__, key, value, self.dataObjectKeyPath);
    [self flushBindingPathForFinalDataObjectKey:key viewKey:value];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    TJBindEntry* entry = (__bridge TJBindEntry*)context;
    [self updateViewForBindingEntry:entry];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@, view: %@, dataObject: %@, bindings: %@",
            [super description], [self.view shortDescription], self.dataObject, self.bindings];
}

@end
