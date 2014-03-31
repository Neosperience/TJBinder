//
//  ArrayTableViewController.m
//  HelloRSSReader
//
//  Created by Janos Tolgyesi on 25/03/14.
//  Copyright (c) 2014 Neosperience SpA. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+FTKDataObject.h"
#import "CounterHolder.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.dataObject = [CounterHolder new];
}

@end
