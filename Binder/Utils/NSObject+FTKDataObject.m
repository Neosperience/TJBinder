//
//  NSObject+DataObject.m
//  egea
//
//  Created by Janos Tolgyesi on 02/12/13.
//  Copyright (c) 2013 Neosperience. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+FTKDataObject.h"

@implementation NSObject (FTKDataObject)

-(void)setDataObject:(id)dataObject
{
    objc_setAssociatedObject(self, @selector(dataObject), dataObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)dataObject
{
    return objc_getAssociatedObject(self, @selector(dataObject));
}

@end
