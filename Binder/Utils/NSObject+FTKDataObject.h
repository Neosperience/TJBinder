//
//  NSObject+DataObject.h
//  egea
//
//  Created by Janos Tolgyesi on 02/12/13.
//  Copyright (c) 2013 Neosperience. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FTKDataObject <NSObject>

@optional

- (void)updateFromDataObject;

@end

@interface NSObject (FTKDataObject) <FTKDataObject>

@property (nonatomic, strong) id dataObject;

@end
