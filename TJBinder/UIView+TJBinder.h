//
//  UIView+Bind.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "TJDataObject.h"

#import <UIKit/UIKit.h>

@class TJBinder;

@interface UIView (TJBinder) <TJDataObject>

@property (readonly) TJBinder* bindTo;

@property (nonatomic, strong) id dataObject;

-(NSString*)shortDescription;

-(void)updateFromDataObject;

@end
