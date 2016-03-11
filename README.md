TJBinder
========

TJBinder is a lightweight but still powerful iOS implementation of the model -- view binding technology seen in [Cocoa bindings][1] for OS-X. The aim is the same: to create a "technology that provide a means of keeping model and view values synchronized without you having to write a lot of glue code."

Introduction
------------

This section explains why and when `TJBinder` is useful for you in a kind of storytelling style. If you want to jump straight inside the details continue reading with the next section.

### The problem ###

Let's suppose that you have to write one more simple table view -- details view based [MVC][2] application. (If you have never done it before I suggest you to follow the [excellent tutorial of Ray Wenderlich][3].) When it is the second or third time that you are writing such application you surely notice how many boiler plate code and similar actions you have to take:

 1. Create your UI in interface builder adding a for example a table view controller to your storyboard.
 2. Create a `UITableViewController` subclass where you retrieve an array or fetched results controller of your data model objects.
 3. If you need a cell with custom layout then you have to create a table view cell prototype in Interface Builder (if you are using storyboards) or a separate xib file for your cell (if you are using xibs) and add labels, image views and other UI elements to your cell.
 4. You have to write your own `UITableViewCell` subclass, create the IBOutlet `@properties` and connect them with the storyboard/xib elements.
 5. You have to configure the cells with the appropriate data model object when you are asked for it in the `tableView:cellForRowAtIndexPath:` method of your `UITableViewDataSource` implementation.

So now you have your table view functioning, the user taps to a cell and you want to show a details view for the selected data model object. What do you have to do? You have to pass through very similar steps, create a `UIViewController` subclass, design its layout in IB, create the outlets, connect them, write the code that configures the UI elements of your view control based on the data of your model object.

The things get even worse if your data object can change during the time, for example you want to show a clock or the GPS coordinates of the device. Then you have to implement the event listener, most likely through some delegate protocol, and update the view object with the new values every time you notice that the data object has changed.

### The solution exists... ###

but until today it was available only for OS-X developers. It is called [Cocoa bindings][4]. Cocoa bindings is a very powerful technology where you can say directly in Interface Builder things like "I want the `text` property of my label to be bound directly to the `albumName` property of my data model object contained in my table view cell. At runtime the framework automatically takes care of updating the label with the data model. You save a lot of time by _not_ having to do steps 4 and 5 from the previous list:  subclassing the table view cell, creating `@properties` for your labels and other elements, connect them with the IB elements via outlets and write the update code. Matter of envy for iOS developers but now `TJBinder` allows you to do exactly the same. 

Installation
------------

The preferred way of installing `TJBinder` is via [CocoaPods][5]. You can add the dependency to TJBinder in your `Podfile`:

```
pod 'TJBinder'
```

If you do not want to use CocoaPods you can simply download all files from the `TJBinder` folder and add them to your project.

`TJBinder` allows you to use your favourit logger. Currently no logging, `NSLog` and [CocoaLumberjack][6] is supported.

### Selecting logger using CocoaPods ###

You should specify your logger preference directly in your `Podfile` via `post_install` hooks. For example if you want to use CocoaLumberjack you could create a `Podfile` like this:
```
platform :ios, '6.0'

pod 'TJBinder'
pod 'CocoaLumberjack'

# available loggers:
# - TJBINDER_LOGGER_NOLOG
# - TJBINDER_LOGGER_NSLOG
# - TJBINDER_LOGGER_COCOALUMBERJACK

selectedLogger = 'TJBINDER_LOGGER_COCOALUMBERJACK'

post_install do |installer|
  target = installer.project.targets.find{|t| t.to_s == "Pods-TJBinder"}
    target.build_configurations.each do |config|
        s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
        s = [ '$(inherited)' ] if s == nil;
        s.push("TJBINDER_SELECTED_LOGGER=#{selectedLogger}") if config.to_s == "Debug";
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
    end
end
```

You should specify the dependency to the `pod` of CocoaLumberjack and add set the `selectedLogger` variable to `TJBINDER_LOGGER_COCOALUMBERJACK`. You also should copy the `post_install` hook above to your `Podfile`. You can specify `selectedLogger` to one of the following options:

 - `TJBINDER_LOGGER_NOLOG`: no logging. This is the default option.
 - `TJBINDER_LOGGER_NSLOG`: logging with `NSLog` all log levels. No additional dependencies needed.
 - `TJBINDER_LOGGER_COCOALUMBERJACK`: logging with CocoaLumberjack. You should specify also the dependency `pod 'CocoaLumberjack'` in your `Podfile`.

If you use CocoaLumberjack do not forget to define the `ddLogLevel` global variable in one of your `.m` files to your desidered log level:

```
const int ddLogLevel = LOG_LEVEL_VERBOSE;
```

### Selecting logger without CocoaPods ###

If you do not use CocoaPods you should select the logger defining a `TJBINDER_SELECTED_LOGGER` macro to one of the logger options above (`TJBINDER_LOGGER_NOLOG`, `TJBINDER_LOGGER_NSLOG` or `TJBINDER_LOGGER_COCOALUMBERJACK`). If you do not define this macro it will default to `TJBINDER_LOGGER_NOLOG`. You could do this definition in the `MyProject-Prefix.pch` file of your project:

```
#define TJBINDER_SELECTED_LOGGER TJBINDER_LOGGER_COCOALUMBERJACK
```

or as a User-Defined Build Setting of your target in your Xcode project. To do so select: project file in Xcode > Build target > Build Settings > click on the `+` icon in the header > Add User-Defined Setting > set the name of the setting to `TJBINDER_SELECTED_LOGGER` and the value to your preference, for example `TJBINDER_LOGGER_COCOALUMBERJACK`.

How to use TJBinder
-------------------

Unlike other libraries, using `TJBinder` does not require you to write a single line of new code. Contrarily you might have to _delete_ some parts of your old code because `TJBinder` will do the job instead of you. 

Let's suppose you have the following data model:

```
// Fruit.h

@interface Fruit : NSObject

@property (strong) NSString* name;
@property (strong) UIColor* color;

@end
```

```
// Fruit.m

@implementation Fruit
@end
```

You want to write a view controller with a `UILabel` that shows the name of the fruit in the same color as the fruit. With `TJBinder` all what you have to do is:

```
// FruitViewController.h

@interface FruitViewController : UIViewController
@end
```

```
// FruitViewController.m

#import <TJBinder.h>

#import "FruitViewController.h"
#import "Fruit.h"

@implementation FruitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Retrieve your data object from an external resource here
    Fruit* fruit = [Fruit new];
    fruit.name = @"apple";
    fruit.color = [UIColor redColor];
    
    // Tell the root view what is its data object
    self.view.dataObject = fruit;
}

@end
```

The rest of the stuff you can do right in Interface Builder this way:

![screenshot](/Images/TJBinder-Fruit-IB.png?raw=true "Using TJBinder in Interface Builder")

There are two important things to note here:

 - You did not create an IBOutlet property for the label
 - There is no code setting the `text` and the `textColor` property of the label.

Instead you specify the relationship between the label and the fruit with specially formatted "User Defined Runtime Attributes" of the label, shown in the red box on the right side of the image. The two lines in this example says that the `text` property of the label should take its value from the `name` property of the data object of the superview and the `textColor` property of the label should be bound to the `color` property of the fruit. Earlier you assigned the data object to the main view of your view controller in FruitViewController.m and this main view is the superview of your label so TJBinder will be able to find your data object.

The rest will be carried out by `TJBinder`. It will traverse up the view hierarchy as you defined in the Key Path column, find the data object, extract the value from it and pass it to the specified property of your view object. If you run the application you will see a red "apple" text on the screen without writing any more code. 

Advanced usage
--------------

**Table views and collection views**

`TJBinder` works excellently also with table views and collection views. You need to specify the data objects for the cell and the bindings of the UI elements of the cell. You can find more details in the example application on how to utilize these classes together with `TJBinder`.

**Data objects updating over time**

Sometimes your data objects might update their contents over time. They can represent the GPS coordinate of the device or you might want to implement a counter or a clock. Once your bindings between your view objects and the data object are correctly configured, `TJBinder` will automatically update your view when the data objects change.

Defining bindings
-----------------

To be able to find your data object, `TJBinder` traverses the view hierarchy. You have to "guide" `TJBinder` in this hierarchy to the view that contains the data object with the key path defined by you in the User Defined Runtime Attributes field of Interface Builder.

Each key path has to start with `bindTo`. This triggers `TJBinder` to start a new binding process. The elements of the key path are divided by the dot (.) character. After the `bindTo` element `TJBinder` starts to traverse the view hierarchy starting from the _current_ view i.e. the view for that this Runtime Attribute is defined. You can jump to the parent view in the hierarchy with the `@superview` or one of the `@superviewWith...` key path commands and traverse down to a subview by one of the `@subviewWith...` commands (although you will need this much rarer).

Once you arrived to the view that contains the data object you should add the `dataObject` key to the key path. This tells to `TJBinder` that it should stop traversing the view hierarchy and look for the data object of the current view. After the `dataObject` key you can add the property names (standard key path) of your data object so `TJBinder` can find the exact value that should be passed to the view object.

You should insert the key path constructed this way to the "Key Path" column of the "User Defined Runtime Attributes" section of your view object in Interface Builder. The "Type" of the attribute should be always set to "String" and you should specify a property of your view object as "Value". For example you could define `text` for a `UILabel` if you want to bind the value of your data object property to the text of the label. Another example could be the `textColor` value for a `UILabel` view to bind the color of a label to a color object exposed by your data object.

> **Important** 
>
>You should ensure that the data type `TJBinder` finds at the end of the key path is the same type that the property of your view object. 
>
> For example for the `UILabel` view of the `FruitViewController` above we specified a `Fruit` object as `dataObject`. The `Fruit` object has a `color` property of the `UIColor*` type that we can bind to the `textColor` property of the `UILabel` that has the same `UIColor*` type.

How does it work?
-----------------

`TJBinder` heavily uses the [Key-Value Observering][7] technology provided by iOS and OS-X. Key-Value Observing "allows objects to be notified of changes to specified properties of other objects". `TJBinder` adds a category on  `UIView` that defines the `bindTo` property that is the entry point for `TJBinder`. If you add "User Defined Runtime Attributes" to a view object in Interface Builder then at runtime, when the view is instantiated, IB will call the setter or getter method of these properties of your view via Key-Value Coding. 

Specifying `bindTo` as the first element of the key path will cause the `bindTo` method to be called right after the `UIView` object is instantiated and configured by Interface Builder. `bindTo` will create an associated object for the view with the type of `BindProxy` where the rest of the binding mechanism is implemented.

The successive elements of the key path defined by you in IB will be evaluated by `BindProxy`. This class overrides `valueForUndefinedKey:` and `setValue:forUndefinedKey:` methods of `NSObject` allowing `BindProxy` to parse arbitrary key path following the `bindTo` key. `BindProxy` parses the rest of the key path including the special `@superviewWith...` and `@subviewWith...` path elements and traverses the hierarchy of the associated view object based on these elements until it finds the `dataObject` path element.

`dataObject` is another property defined by the `UIView` category and it simple allows to store a named Objective-C `id` object associated with a view. You set this object on the view in the view controller. When `TJBinder` has found the `dataObject` it continues the traverse on the key path of the data object until it founds the leaf property defined by the last element of the key path. 

`BindProxy` subscribes as an observer of the leaf property of the `dataObject` so the Objective-C runtime will notify `BindProxy` every time the property changes value. `BindProxy` will handle this notification extracting the value of the property and updating the associated `UIView` property with its value.

Limitations
-----------

Due to the nature of Key-Value Coding `TJBinder` and the compiler can not check the existence of the properties and the validity of the key path defined by you at compile time. If you receive "this class is not key value coding-compliant for the key ..." exceptions at runtime, double-check the key path you entered in Interface Builder paying particular attention to:

 - All key path elements you define both for the view as for the data object have to be key-value observable. This is true for most of `@properties` defined by you or by other APIs, but for other methods it won't work. For example if your data object is an `NSArray` then the key path `dataObject.lastObject` will not work.
 - When you define a binding `TJBinder` will not check whether the type of the leaf property of the data object matches the property of the view. You should ensure this yourself. For example if `TJBinder` finds a `UIColor` object in the property of the data object it will try to assign it to the property of the view object even if it has a different type. This can cause a series of hard-to-debug bugs, including "unrecognized selector sent to instance" exceptions, `EXC_BAD_ACCESS` signals, or even worse, silent failing. Always check the type matching of your bindings.

Key path operator reference
---------------------------

`TJBinder` supports the standard properties of `UIView` allowing you to define the data object search path with `superview` and `window` properties or if you define a named property of your `UIView` subclass then you can refer to it with the property name. 

You will find more useful however the key path operators defined by `TJBinder` to simplify the traversing of the view hierarchy. These operators are prefixed by the `@` character and allows you to jump to another view in the view hierarchy. Here are a reference table for all key path operators:

| Example      | Argument  | Description |
|--------------|-----------|-------------|
| `@superview` | none      | Alias to `superview`: returns the parent view |
| `@rootview`  | none      | Traverses up the view hierarchy until it finds a view that does not have a superview. *Attention*: if you use container views for showing embedded view controllers the root view might be different from the `view` property of your view controller.                                |
| `@superviewWithTag[12]` | view tag (int) | Traverses up the view hierarchy until it finds a superview with the specified tag. This example returns the closes superview with `tag == 12` |
| `@superviewWithRestorationID[myUd]` | view restoration id (string) | Traverses up the view hierarchy until it finds a superview with the specified restoration ID. This example returns the closes superview with `restorationIdentifier == myID`. |
| `@superviewWithClass[UITableViewCell]` | class name (string) | Traverses up the view hierarchy until it finds a superview with the specified class. This example returns the superview that inherits from `UITableViewCell`. Probably the most useful key path operator. |
| `@subviews[2]` | subview index (int) | Returns the element from the `subviews` array of the view at the specified index. This example returns the 3rd element from the `subviews` array. |
| `@subviewWithTag[12]` | view tag (int) | Finds and returns the element from the `subviews` array of the view with the specified tag. This example returns the subview with `tag == 12`.  |
| `@subviewWithRestorationID[myId]` | view restoration id (string) | Finds and returns the element from the `subviews` array of the view with the specified restoration identifier. This example returns the subview with `restorationIdentifier == 12`. |
| `@subviewWithClass[UILabel]` | class name (string) | Finds and returns the first element from the `subviews` array of the view that is an instance of the specified class. This example returns the first `UILabel` from the `subviews` array. |
| `@cell` | none | Traverses up the view hierarchy until it finds a superview with UITableViewCell or UICollectionViewCell class. A kind of shortcut to `@superviewWithClass[UITableViewCell]` and `@superviewWithClass[UICollectionViewCell]`|


  [1]: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CocoaBindings/ "Cocoa bindings"
  [2]: http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller "Model-View-Controller"
  [3]: http://www.raywenderlich.com/1797/ios-tutorial-how-to-create-a-simple-iphone-app-part-1
  [4]: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CocoaBindings/ "Cocoa bindings"
  [5]: http://cocoapods.org
  [6]: https://github.com/CocoaLumberjack/CocoaLumberjack
  [7]: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html