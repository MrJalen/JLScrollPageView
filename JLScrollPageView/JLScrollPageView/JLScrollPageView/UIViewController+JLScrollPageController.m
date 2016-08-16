//
//  UIViewController+JLScrollPageController.m
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import "UIViewController+JLScrollPageController.h"
#import <objc/runtime.h>

@implementation UIViewController (JLScrollPageController)

static char key;

- (void)setScrollPageParentViewController:(UIViewController *)scrollPageParentViewController {
    objc_setAssociatedObject(self, &key, scrollPageParentViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)scrollPageParentViewController {
    return (UIViewController *)objc_getAssociatedObject(self, &key);
}

@end
