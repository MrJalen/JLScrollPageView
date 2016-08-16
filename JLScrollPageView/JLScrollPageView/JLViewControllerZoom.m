//
//  JLViewControllerZoom.m
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import "JLViewControllerZoom.h"
#import "JLScrollPageView.h"
#import "JLFirstViewController.h"

@interface JLViewControllerZoom () <JLScrollPageViewDelegate>

@property (strong, nonatomic) NSArray <NSString *> *titles;

@end

@implementation JLViewControllerZoom

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = @"缩放效果";

    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;

    JLSegmentStyle *style = [[JLSegmentStyle alloc] init];
    // 缩放标题
    style.scaleTitle = YES;
    // 颜色渐变
    style.gradualChangeTitleColor = YES;
    // 设置附加按钮的背景图片

    self.titles = @[@"新闻头条",
                    @"国际要闻",
                    @"体育",
                    @"中国足球",
                    @"汽车",
                    @"囧途旅游",
                    @"幽默搞笑",
                    @"视频"
                    ];
    // 初始化
    JLScrollPageView *scrollPageView = [[JLScrollPageView alloc] initWithFrame:CGRectMake(0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0) segmentStyle:style titles:self.titles parentViewController:self delegate:self];
    // 这里可以设置头部视图的属性(背景色, 圆角, 背景图片...)
    scrollPageView.segmentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollPageView];
}

#pragma ZJScrollPageViewDelegate 代理方法
- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}

- (UIViewController<JLScrollPageViewChildControllerDelegate> *)childViewController:(UIViewController<JLScrollPageViewChildControllerDelegate> *)reuseViewController forIndex:(NSInteger)index {
    UIViewController<JLScrollPageViewChildControllerDelegate> *childVc = reuseViewController;

    if (!childVc) {
        childVc = [[JLFirstViewController alloc] init];
        childVc.title = self.titles[index];
    }


    if (index%2 == 0) {
        childVc.view.backgroundColor = [UIColor blueColor];
    } else {
        childVc.view.backgroundColor = [UIColor greenColor];

    }

    return childVc;
}


@end
