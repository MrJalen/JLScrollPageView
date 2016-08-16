//
//  JLViewControllerCostom.m
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import "JLViewControllerCostom.h"
#import "JLScrollPageView.h"
#import "JLFirstViewController.h"
#import "JLSecondViewController.h"

@interface JLViewControllerCostom () <JLScrollPageViewDelegate>

@property (strong, nonatomic) NSArray<NSString *> *titles;
@property (strong, nonatomic) NSArray<UIViewController<JLScrollPageViewChildControllerDelegate> *> *childVcs;
@property (weak, nonatomic) JLScrollSegmentView *segmentView;
@property (weak, nonatomic) JLContentView *contentView;

@end

@implementation JLViewControllerCostom

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = @"自定义分段控制器";
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.childVcs = [self setupChildVc];
    // 初始化
    [self setupSegmentView];
    [self setupContentView];
}

- (void)setupSegmentView {
    JLSegmentStyle *style = [[JLSegmentStyle alloc] init];
    style.showCover = YES;
    // 不要滚动标题, 每个标题将平分宽度
    style.scrollTitle = NO;
    // 渐变
    style.gradualChangeTitleColor = YES;
    // 遮盖背景颜色
    style.coverBackgroundColor = [UIColor whiteColor];
    //标题一般状态颜色 --- 注意一定要使用RGB空间的颜色值
    style.normalTitleColor = [UIColor orangeColor];//[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    //标题选中状态颜色 --- 注意一定要使用RGB空间的颜色值
    style.selectedTitleColor = [UIColor colorWithRed:235.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];

    self.titles = @[@"国内新闻", @"新闻头条"];

    // 注意: 一定要避免循环引用!!
    __weak typeof(self) weakSelf = self;
    JLScrollSegmentView *segment = [[JLScrollSegmentView alloc] initWithFrame:CGRectMake(0, 64.0, 160.0, 28.0) segmentStyle:style titles:self.titles titleDidClick:^(UILabel *label, NSInteger index) {

        [weakSelf.contentView setContentOffSet:CGPointMake(weakSelf.contentView.bounds.size.width * index, 0.0) animated:YES];

    }];
    // 自定义标题的样式
    segment.layer.cornerRadius = 14.0;
    segment.backgroundColor = [UIColor redColor];
    // 当然推荐直接设置背景图片的方式
    //    segment.backgroundImage = [UIImage imageNamed:@"extraBtnBackgroundImage"];

    self.segmentView = segment;
    self.navigationItem.titleView = self.segmentView;

}

- (void)setupContentView {
    JLContentView *content = [[JLContentView alloc] initWithFrame:CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0) segmentView:self.segmentView parentViewController:self delegate:self];
    self.contentView = content;
    [self.view addSubview:self.contentView];
}

#pragma mark - 设置子控制器
- (NSArray *)setupChildVc {
    JLFirstViewController *vc1 = [JLFirstViewController new];
    vc1.view.backgroundColor = [UIColor redColor];

    JLFirstViewController *vc2 = [JLFirstViewController new];
    vc2.view.backgroundColor = [UIColor greenColor];

    NSArray *childVcs = [NSArray arrayWithObjects:vc2, vc1, nil];
    return childVcs;
}

- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}

- (UIViewController<JLScrollPageViewChildControllerDelegate> *)childViewController:(UIViewController<JLScrollPageViewChildControllerDelegate> *)reuseViewController forIndex:(NSInteger)index {
    UIViewController<JLScrollPageViewChildControllerDelegate> *childVc = reuseViewController;

    if (!childVc) {
        childVc = self.childVcs[index];
    }


    if (index%2==0) {
        childVc.view.backgroundColor = [UIColor blueColor];
    } else {
        childVc.view.backgroundColor = [UIColor greenColor];

    }

    return childVc;
}


@end
