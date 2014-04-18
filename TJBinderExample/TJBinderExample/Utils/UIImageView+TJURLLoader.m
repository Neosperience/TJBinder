//
//  UIImageView+TJURLLoader.m
//  TJBinderExample
//
//  Created by Janos Tolgyesi on 18/04/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import <objc/runtime.h>

#import "UIImageView+TJURLLoader.h"
#import "TJBinderLogger.h"

@implementation UIImageView (TJURLLoader)

-(void)setAspectRatioConstraint:(NSLayoutConstraint *)aspectRatioConstraint
{
    if (self.aspectRatioConstraint) [self removeConstraint:self.aspectRatioConstraint];
    objc_setAssociatedObject(self, @selector(aspectRatioConstraint), aspectRatioConstraint, OBJC_ASSOCIATION_ASSIGN);
    [self addConstraint:aspectRatioConstraint];
}

-(NSLayoutConstraint *)aspectRatioConstraint
{
    return objc_getAssociatedObject(self, @selector(aspectRatioConstraint));
}

-(void)setURL:(NSURL *)URL
{
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    [self addSubview:activityIndicator];

    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithURL:URL
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [activityIndicator removeFromSuperview];
            if (!error)
            {
                UIImage* image = [UIImage imageWithData:data];
                if (image)
                {
                    self.image = image;
                    self.aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:(image.size.height / image.size.width) constant:0.0f];
                }
                else TJBinderLogError(@"Data downloaded from URL: %@ can not be parsed as an image!", url, error);
            }
            else
            {
                TJBinderLogError(@"error downloading URL: %@, error: %@", url, error);
            }
        });
    }];
    [task resume];
}

@end
