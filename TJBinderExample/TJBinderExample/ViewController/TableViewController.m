//
//  TableViewController.m
//  TJBinderExample
//
//  Created by Janos Tolgyesi on 17/04/14.
//  Copyright (c) 2014 Janos Tolgyesi. All rights reserved.
//

#import "UIView+TJBinder.h"

#import "TableViewController.h"
#import "Fruit.h"

@interface TableViewController ()

/**
 Array holding the Fruit objects
 */
@property (strong) NSArray* data;

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the data objects from resource
    NSURL* resourceURL = [[NSBundle mainBundle] URLForResource:@"Fruits" withExtension:@"plist"];
    NSArray* resourceArray = [NSArray arrayWithContentsOfURL:resourceURL];
    self.data = [Fruit fruitsFromArray:resourceArray];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (section == 0)
    {
        return [self.data count];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FruitCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        // To see the bindings:
        //  - open the storyboard
        //  - find and select the fruitNameLabel or fruitColorView object in the Prototype cell
        //    of the table view controller in the Table View Controller Scene
        //  - swith to Identity inspector (Alt + Cmd + 3)
        //  - examine the "User Defined Runtime Attributes" section
        //
        // Note: we did not have to create any UITableViewCell subclass and neither do we use the
        // the standard textLabel or imageView properties of of the cell.
        
        cell.dataObject = self.data[indexPath.row];
    }
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSParameterAssert([sender isKindOfClass:[UITableViewCell class]]);
    UITableViewCell* cell = sender;
    UIViewController* destinationViewController = segue.destinationViewController;
    
    // We did not create a custom UIViewController subclass!
    // We simple pass the data object to the view of the destination view controller
    // and the bindings will configure the views appropriatately.
    
    // You can find the bindings in the storyboard:
    //  - open the storyboard
    //  - find and select the fruitNameLabel, ftuitColorNameLabel or fruitColorView object
    //    in the Details View Controller Scene.
    //  - swith to Identity inspector (Alt + Cmd + 3)
    //  - examine the "User Defined Runtime Attributes" section
    
    destinationViewController.view.dataObject = cell.dataObject;
    
    // The navigation item is not (yet) accessible by the binder. However this is an
    // excellent time to set the navigation title from code providing you know the key
    // path of the data object you want to use as a title.
    // However it will not be updated automatically if the data object changes.
    destinationViewController.navigationItem.title = [cell.dataObject valueForKey:@"name"];
}

@end
