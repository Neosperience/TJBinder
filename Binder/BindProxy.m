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
            dataObjectHolderView = [dataObjectHolderView valueForKey:pathComponent];
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
    
    BindEntry* entry = [[BindEntry alloc] initWithDataObjectKeyPath:dataObjectKeyPathString viewKey:viewKey view:self.view];
    
    [dataObjectHolderView.bindTo.bindings addObject:entry];
    
    [dataObjectHolderView.bindTo updateViewForBindingEntry:entry];
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
