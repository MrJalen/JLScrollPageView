//
//  JLViewControllerScrollbar.m
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import "JLViewControllerScrollbar.h"
#import "JLScrollPageView.h"
#import "JLFirstViewController.h"

@interface JLViewControllerScrollbar () <JLScrollPageViewDelegate>

@property (strong, nonatomic) NSArray<NSString *> *titles;
@property (strong, nonatomic) NSArray<UIViewController *> *childVcs;

@end

@implementation JLViewControllerScrollbar

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = @"滚动条效果";

    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;

    JLSegmentStyle *style = [[JLSegmentStyle alloc] init];
    //显示滚动条
    style.showLine = YES;
    // 颜色渐变
    style.gradualChangeTitleColor = YES;

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

    [self.view addSubview:scrollPageView];
}

- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}


- (UIViewController<JLScrollPageViewChildControllerDelegate> *)childViewController:(UIViewController<JLScrollPageViewChildControllerDelegate> *)reuseViewController forIndex:(NSInteger)index {

    UIViewController<JLScrollPageViewChildControllerDelegate> *childVc = reuseViewController;

    if (!childVc) {
        childVc = [[JLFirstViewController alloc] init];
    }



    if (index%2 == 0) {
        childVc.view.backgroundColor = [UIColor blueColor];
    } else {
        childVc.view.backgroundColor = [UIColor greenColor];

    }

    NSLog(@"%ld-----%@",(long)index, childVc);

    return childVc;
}



@end
