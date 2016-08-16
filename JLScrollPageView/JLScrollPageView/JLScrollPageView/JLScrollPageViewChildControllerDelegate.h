//
//  JLScrollPageViewChildControllerDelegate.h
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class JLContentView;

@protocol JLScrollPageViewChildControllerDelegate <NSObject>

@optional
// 已经实现
/**
 *
 * 根据不同的下标或者title返回相应的控制器, 但是控制器必须要遵守ZJScrollPageViewChildVcDelegate
 * 并且可以通过实现协议中的方法来加载不同的数据
 * 注意ZJScrollPageView不会保证viewWillAppear等生命周期方法一定会调用
 * 所以建议使用ZJScrollPageViewChildVcDelegate中的方法来加载不同的数据
 * firstTimeAppear - 会告诉你是否页面是第一次出现
 */

- (void)setUpWhenViewWillAppearForTitle:(NSString *)title forIndex:(NSInteger)index firstTimeAppear: (BOOL)isFirstTime;

// 还未实现相关功能
//- (void)setUpWhenViewDidAppearForTitle:(NSString *)title forIndex:(NSInteger)index;
@end


@protocol JLScrollPageViewDelegate <NSObject>
/** 将要显示的子页面的总数 */
- (NSInteger)numberOfChildViewControllers;

/** 获取到将要显示的页面的控制器
 * -reuseViewController : 这个是返回给你的controller, 你应该首先判断这个是否为nil, 如果为nil 创建对应的控制器并返回, 如果不为nil直接使用并返回
 * -index : 对应的下标
 */
- (UIViewController<JLScrollPageViewChildControllerDelegate> *)childViewController:(UIViewController<JLScrollPageViewChildControllerDelegate> *)reuseViewController forIndex:(NSInteger)index;

@end
