//
//  UIView+Bind.m
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <objc/runtime.h>

#import "UIView+TJBinder.h"
#import "TJBinder.h"

@implementation UIView (TJBinder)

-(TJBinder *)bindTo
{
    TJBinder* bindTo = objc_getAssociatedObject(self, @selector(bindTo));
    if (!bindTo)
    {
        bindTo = [[TJBinder alloc] initWithView:self];
        self.bindTo = bindTo;
    }
    [bindTo resetKeyPath];
    return bindTo;
}

-(void)setBindTo:(TJBinder *)bindTo
{
    objc_setAssociatedObject(self, @selector(bindTo), bindTo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)shortDescription
{
    return [super description];
}

-(void)setDataObject:(id)dataObject
{
    objc_setAssociatedObject(self, @selector(dataObject), dataObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.bindTo.dataObject = dataObject;
}

-(id)dataObject
{
    return objc_getAssociatedObject(self, @selector(dataObject));
}

-(void)updateFromDataObject
{
    [self.bindTo updateView];
}

@end
