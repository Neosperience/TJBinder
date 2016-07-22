//
//  BindProxy.h
//  HelloBind
//
//  Created by Janos Tolgyesi on 29/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "UIView+TJBinder.h"

#import <Foundation/Foundation.h>

@interface TJBinder : NSObject

-(instancetype)initWithView:(UIView*)view;

-(void)resetKeyPath;

@property (strong, nonatomic) id dataObject;

-(void)updateView;

@end
