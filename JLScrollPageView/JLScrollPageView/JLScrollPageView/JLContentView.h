//
//  JLContentView.h
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLScrollPageViewChildControllerDelegate.h"

@class JLScrollSegmentView;
@class JLContentView;

@interface JLContentView : UIView

/** 必须设置代理和实现相关的方法 */
@property(weak, nonatomic)id<JLScrollPageViewDelegate> delegate;

/** 初始化方法 */
- (instancetype)initWithFrame:(CGRect)frame segmentView:(JLScrollSegmentView *)segmentView parentViewController:(UIViewController *)parentViewController delegate:(id<JLScrollPageViewDelegate>) delegate;

/** 给外界可以设置ContentOffSet的方法 */
- (void)setContentOffSet:(CGPoint)offset animated:(BOOL)animated;

/** 给外界 重新加载内容的方法 */
- (void)reload;

@end
