//
//  UIImageView+TJURLLoader.h
//  TJBinderExample
//
//  Created by Janos Tolgyesi on 18/04/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (TJURLLoader)

-(void)setURL:(NSURL *)URL;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* aspectRatioConstraint;

@end
