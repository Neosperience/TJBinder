//
//  BindProxy.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "BindProxy.h"
#import "UIView+Bind.h"
#import "NSObject+FTKDataObject.h"

@interface BindEntry : NSObject

@property (strong) NSString* dataObjectKey;
@property (strong) NSString* viewKey;
@property (weak) UIView* view;
@property (assign) BOOL registered;

-(instancetype)initWithDataObjectKey:(NSString*)dataObjectKey viewKey:(NSString*)viewKey view:(UIView*)view;

@end

@implementation BindEntry

- (instancetype)initWithDataObjectKey:(NSString *)dataObjectKey viewKey:(NSString *)viewKey view:(UIView *)view
{
    self = [super init];
    if (self) {
        self.dataObjectKey = dataObjectKey;
        self.viewKey = viewKey;
        self.view = view;
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ view: %@, dataObjectKey: %@, viewKey: %@, registered: %@",
            [super description], [self.view shortDescription], self.dataObjectKey, self.viewKey, self.registered ? @"YES" : @"NO"];
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
            NSLog(@"dataObject: %@ unregistering entry: %@", self.dataObject, entry);
            [self.dataObject removeObserver:self forKeyPath:entry.dataObjectKey context:(__bridge void *)(entry)];
            entry.registered = NO;
        }
        else
        {
            NSLog(@"dataObject: %@ NOT unregistering entry: %@", self.dataObject, entry);
        }
    }
}

-(void)registerBindings
{
    if (!self.dataObject) return;

    for (BindEntry* entry in self.bindings)
    {
        [self.dataObject addObserver:self forKeyPath:entry.dataObjectKey options:NSKeyValueObservingOptionNew context:(__bridge void *)(entry)];
        entry.registered = YES;
        NSLog(@"dataObject: %@ registered entry: { %@ }", self.dataObject, entry);
        [self updateViewForBindingEntry:entry];
    }
}

-(void)flushBindingPathForDataObjectKey:(NSString*)dataObjectKey viewKey:(NSString*)viewKey
{
    UIView* dataObjectHolderView = self.view;
    
    for (NSString* pathComponent in self.dataObjectKeyPath)
    {
        if ([pathComponent isEqualToString:@"superview"])
        {
            dataObjectHolderView = dataObjectHolderView.superview;
        }
        else
        {
            NSAssert(YES, @"Only 'superview' supported!");
        }
    }
    
    [self.dataObjectKeyPath removeAllObjects];
    
    BindEntry* entry = [[BindEntry alloc] initWithDataObjectKey:dataObjectKey viewKey:viewKey view:self.view];
    
    [dataObjectHolderView.bindTo.bindings addObject:entry];
    
    [dataObjectHolderView.bindTo updateViewForBindingEntry:entry];
}

-(void)updateViewForBindingEntry:(BindEntry*)entry
{
    id extractedValue = [self.dataObject valueForKey:entry.dataObjectKey];
    [entry.view setValue:extractedValue forKey:entry.viewKey];
}

-(id)valueForUndefinedKey:(NSString *)key
{
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, key);
    [self.dataObjectKeyPath addObject:key];
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
//    NSLog(@"%s { %@ : %@ } \n%@", __PRETTY_FUNCTION__, key, value, self.dataObjectKeyPath);
    [self flushBindingPathForDataObjectKey:key viewKey:value];
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
