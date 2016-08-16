//
//  JLScrollPageView.h
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extend.h"
#import "UIViewController+JLScrollPageController.h"
#import "JLContentView.h"
#import "JLCustomLabel.h"
#import "JLScrollSegmentView.h"
#import "JLSegmentStyle.h"
#import "JLScrollPageViewChildControllerDelegate.h"

@interface JLScrollPageView : UIView

typedef void(^ExtraBtnOnClick)(UIButton *extraBtn);

@property (copy, nonatomic) ExtraBtnOnClick extraBtnOnClick;
@property (weak, nonatomic, readonly) JLContentView *contentView;
@property (weak, nonatomic, readonly) JLScrollSegmentView *segmentView;

/** 必须设置代理并且实现相应的方法 */
@property(weak, nonatomic)id<JLScrollPageViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame segmentStyle:(JLSegmentStyle *)segmentStyle titles:(NSArray<NSString *> *)titles parentViewController:(UIViewController *)parentViewController delegate:(id<JLScrollPageViewDelegate>) delegate ;

/** 给外界设置选中的下标的方法 */
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

/**  给外界重新设置的标题的方法(同时会重新加载页面的内容) */
- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles;


@end
