//
//  UIView+Bind.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBinder.h"
#import "TJDataObject.h"

@interface UIView (TJBinder) <TJDataObject>

@property (readonly) TJBinder* bindTo;

@property (nonatomic, strong) id dataObject;

-(NSString*)shortDescription;

@end
