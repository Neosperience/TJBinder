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

@interface UIImageView (TJURLLoaderInternal)

@property (nonatomic, strong) NSURLSessionDataTask* imageLoadingTask;

@end

@implementation UIImageView (TJURLLoader)

-(void)setImageLoadingTask:(NSURLSessionDataTask *)imageLoadingTask
{
    if (self.imageLoadingTask && self.imageLoadingTask.state == NSURLSessionTaskStateRunning) {
        [self.imageLoadingTask cancel];
    }
    objc_setAssociatedObject(self, @selector(imageLoadingTask), imageLoadingTask, OBJC_ASSOCIATION_RETAIN);
}

-(NSURLSessionDataTask *)imageLoadingTask
{
    return objc_getAssociatedObject(self, @selector(imageLoadingTask));
}

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

-(void)setAddAspectRatioConstraint:(BOOL)addAspectRatioConstraint
{
    objc_setAssociatedObject(self, @selector(addAspectRatioConstraint), @(addAspectRatioConstraint), OBJC_ASSOCIATION_RETAIN);
}

-(BOOL)addAspectRatioConstraint
{
    return [objc_getAssociatedObject(self, @selector(addAspectRatioConstraint)) boolValue];
}

-(void)setImageWithAspectRatioConstraint:(UIImage *)image
{
    self.image = image;
    if (self.addAspectRatioConstraint) {
        self.aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:(image.size.height / image.size.width)
                                                                   constant:0.0f];
    }
}

-(void)setURL:(NSURL *)URL
{
    if (!URL) {
        self.image = nil;
        return;
    }

    TJImageCache* cache = [TJImageCache sharedInstance];
    UIImage* image = [cache imageForURL:URL];
    if (image) {
        [self setImageWithAspectRatioConstraint:image];
        return;
    }

    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    [self addSubview:activityIndicator];

    self.imageLoadingTask = [[NSURLSession sharedSession] dataTaskWithURL:URL
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [activityIndicator removeFromSuperview];
            if (!error) {
                UIImage* image = [UIImage imageWithData:data];
                if (image) {
                    [self setImageWithAspectRatioConstraint:image];
                    [cache setImage:image forURL:URL];
                } else {
                    TJBinderLogError(@"Data downloaded from URL: %@ can not be parsed as an image!", url, error);
                }
            } else {
                TJBinderLogError(@"error downloading URL: %@, error: %@", url, error);
            }
        });
    }];
    [self.imageLoadingTask resume];
}

@end

@implementation TJImageCache

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)setImage:(UIImage *)image forURL:(NSURL *)url
{
    [self setObject:image forKey:[url absoluteString]];
}

-(UIImage *)imageForURL:(NSURL *)url
{
    return [self objectForKey:[url absoluteString]];
}

@end
