//
//  UIView+Bind.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "UIView+Bind.h"
#import "NSObject+FTKDataObject.h"
#import "BindProxy.h"

#import <objc/runtime.h>

@implementation UIView (Bind)

-(BindProxy *)bindTo
{
    BindProxy* bindTo = objc_getAssociatedObject(self, @selector(bindTo));
    if (!bindTo)
    {
        bindTo = [[BindProxy alloc] initWithView:self];
        self.bindTo = bindTo;
    }
    [bindTo resetKeyPath];
    return bindTo;
}

-(void)setBindTo:(BindProxy *)bindTo
{
    objc_setAssociatedObject(self, @selector(bindTo), bindTo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

-(void)setDataObject:(id)dataObject
{
    [super setDataObject:dataObject];
    self.bindTo.dataObject = dataObject;
}

-(NSString *)shortDescription
{
    return [super description];
}

@end
