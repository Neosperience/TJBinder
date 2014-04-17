//
//  TJDataObject.h
//  TJBinderExample
//
//  Created by Janos Tolgyesi on 17/04/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJDataObject <NSObject>

@property (nonatomic) id dataObject;

@optional

- (void)updateFromDataObject;

@end
