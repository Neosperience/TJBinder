//
//  UIView+Bind.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BindProxy.h"

@interface UIView (Bind)

@property (readonly) BindProxy* bindTo;

@end
