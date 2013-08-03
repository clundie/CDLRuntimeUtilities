CDLRuntimeUtilities
===================

## Utilities for the Objective-C Runtime

Welcome to my junk drawer! Currently there is just one class here.

```objc
@interface NSObject (CDLClasses)

/** Get the names of classes that directly inherit from this class. */
+ (NSSet *)cdl_subclassNames;

/** Get the names of all descendant classes of this class. */
+ (NSSet *)cdl_descendantNames;

@end
```

Example usage:

Find all ```UIViewController``` descendants:

```objc
#import "NSObject+CDLClasses.h"

NSSet *classNames = [UIViewController cdl_descendantNames];
```

It should find any classes that are compiled in to your project, plus any
frameworks that have been loaded, including private ones.
