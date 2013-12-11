//
//  UITableView+DynamicTypeReloading.m
//
//  Created by hirakiuc on 2013/11/10.
//  Copyright (c) 2013 altab.jp works. All rights reserved.
//

#import "UITableView+DynamicTypeReloading.h"
#import <objc/runtime.h>

@interface UITableView (DynamicTypeReloading)
- (void)startObserve;
- (void)stopObserve;
- (void)__reloadData;
@end

@implementation UITableView (DynamicTypeReloading)

static const char *UITableViewDynamicTypeReloading = "UITableViewDynamicTypeReloadingKey";

- (void)setEnableDynamicTypeReloading:(BOOL)enableDynamicTypeReloading
{
  if (self.enableDynamicTypeReloading == enableDynamicTypeReloading) {
    return;
  }

  if (enableDynamicTypeReloading) {
    if (!(self.enableDynamicTypeReloading)) {
      [self startObserve];
    }
  } else {
    if (self.enableDynamicTypeReloading) {
      [self stopObserve];
    }
  }

  NSNumber *v = [NSNumber numberWithBool:enableDynamicTypeReloading];
  objc_setAssociatedObject(self, UITableViewDynamicTypeReloading, v, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)enableDynamicTypeReloading
{
  NSNumber *v = (NSNumber *)objc_getAssociatedObject(self, UITableViewDynamicTypeReloading);
  return (v == nil) ? NO : [v boolValue];
}

- (void)dealloc
{
  if (self.enableDynamicTypeReloading) {
    [self stopObserve];
  }
}

#pragma mark - private methods

- (void)__reloadData
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self reloadData];
  });
}

- (void)startObserve
{
  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
  [defaultCenter addObserver:self
                    selector:@selector(__reloadData)
                        name:UIContentSizeCategoryDidChangeNotification
                      object:nil];
}

- (void)stopObserve
{
  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
  [defaultCenter removeObserver:self
                           name:UIContentSizeCategoryDidChangeNotification
                         object:nil];
}

@end
