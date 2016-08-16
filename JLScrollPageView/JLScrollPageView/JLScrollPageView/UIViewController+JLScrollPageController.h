//
//  UIViewController+JLScrollPageController.h
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JLScrollPageController)

/**
 *  所有子控制的父控制器, 方便在每个子控制页面直接获取到父控制器进行其他操作
 */
@property (nonatomic, weak) UIViewController *scrollPageParentViewController;

@end
