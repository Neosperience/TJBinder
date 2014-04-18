//
//  TJURLOpenerButton.m
//  TJBinderExample
//
//  Created by Janos Tolgyesi on 21/03/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import "TJURLOpenerButton.h"

@implementation TJURLOpenerButton

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self addTarget:self action:@selector(URLButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray* states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled), @(UIControlStateSelected)];
    
    for (NSNumber* stateNumber in states)
    {
        UIControlState state = [stateNumber integerValue];
        NSString* title = [self titleForState:state];
        [self setTitle:title forState:state];
    }
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    if (title)
    {
        NSDictionary *underlineAttribute = @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
        NSAttributedString* attributedTitle =
            [[NSAttributedString alloc] initWithString:title
                                            attributes:underlineAttribute];
        [self setAttributedTitle:attributedTitle forState:state];
    }
}

- (void)URLButtonAction:(id)sender
{
    if (self.URLStringToOpen)
    {
        NSURL* URLToOpen = [NSURL URLWithString:self.URLStringToOpen];
        [[UIApplication sharedApplication] openURL:URLToOpen];
    }
}

@end
