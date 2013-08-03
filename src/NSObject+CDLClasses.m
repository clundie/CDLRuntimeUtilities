//
//  NSObject+CDLClasses.m
//  CDLRuntimeUtilities
//  https://github.com/clundie/CDLRuntimeUtilities
//
//  Created by Chris Lundie on 03/Aug/2013.
//  Copyright (c) 2013 Chris Lundie.
//  http://www.lundie.ca/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#if !__has_feature(objc_arc)
#error ARC is required (-fobjc-arc)
#endif

#import "NSObject+CDLClasses.h"
#import <objc/runtime.h>
#import <stdlib.h>

static NSSet *getSubclassNames(Class superclass, BOOL descend);
static BOOL getAllClasses(__unsafe_unretained Class **allClasses, int *count);

@implementation NSObject (CDLClasses)

+ (NSSet *)cdl_descendantNames
{
  return getSubclassNames([self class], YES);
}

+ (NSSet *)cdl_subclassNames
{
  return getSubclassNames([self class], NO);
}

@end

static NSSet *getSubclassNames(Class superclass, BOOL descend)
{
  __unsafe_unretained Class *allClasses;
  int allClassesCount;
  if (!getAllClasses(&allClasses, &allClassesCount)) {
    return nil;
  }
  NSMutableSet *subclassNames = [NSMutableSet set];
  for (int i = 0; i < allClassesCount; i++) {
    Class nextClass = allClasses[i];
    if (nextClass == superclass) {
      continue;
    }
    BOOL didMatch = NO;
    if (descend) {
      if (class_getClassMethod(nextClass, @selector(isSubclassOfClass:)) &&
          [nextClass isSubclassOfClass:superclass]) {
        didMatch = YES;
      }
    } else {
      if (class_getSuperclass(nextClass) == superclass) {
        didMatch = YES;
      }
    }
    if (didMatch) {
      [subclassNames addObject:[NSStringFromClass(nextClass) copy]];
    }
  }
  free(allClasses);
  return subclassNames;
}

static BOOL getAllClasses(__unsafe_unretained Class **allClasses, int *count)
{
  BOOL result = NO;
  *count = objc_getClassList(NULL, 0);
  if (*count > 0) {
    *allClasses = (__unsafe_unretained Class *)malloc(sizeof(Class) *
                                                      (size_t)*count);
    *count = objc_getClassList(*allClasses, *count);
    if (*count > 0) {
      result = YES;
    } else {
      free(*allClasses);
    }
  }
  return result;
}
