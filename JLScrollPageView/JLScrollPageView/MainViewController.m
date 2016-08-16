//
//  MainViewController.m
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import "MainViewController.h"
#import "UIView+Extend.h"
#import "JLViewControllerZoom.h"
#import "JLViewControllerScrollbar.h"
#import "JLViewControllerCover.h"
#import "JLViewControllerCostom.h"

#define K_Width  [UIScreen mainScreen].bounds.size.width
#define K_Height [UIScreen mainScreen].bounds.size.height

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = @"功能型按键";

    CGFloat btn_W = 0;//保存前一个button的宽以及前一个button距离屏幕边缘的距离
    CGFloat sub_H = 80;//用来控制button距离父视图的高

    NSArray *titleArray = @[@"缩放+颜色渐变", @"滚动条+颜色渐变", @"遮盖+缩放+无颜色渐变", @"自定义分段控制器"];
    for (int i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [self randomColor];
        [btn setTitle:titleArray[i] forState:0];
        [btn addTarget:self action:@selector(browse:) forControlEvents:1<<6];
        btn.tag = i;

        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        //根据计算文字的大小
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
        CGFloat length = [titleArray[i] boundingRectWithSize:CGSizeMake(K_Width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
        btn.frame = CGRectMake(15 + btn_W, sub_H, length + 15 , 40);

        if (30 + btn_W + length + 15 > K_Width) {
            btn_W = 0; //换行时将w置为0
            sub_H = sub_H + btn.height + 10;//距离父视图也变化
            btn.frame = CGRectMake(15 + btn_W, sub_H, length + 15, 40);//重设button的frame
        }
        btn_W = btn.width + btn.x;

        [self.view addSubview:btn];
    }
}

- (void)browse:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.navigationController pushViewController:[[JLViewControllerZoom alloc] init] animated:YES];
    }else if (sender.tag == 1) {
        [self.navigationController pushViewController:[[JLViewControllerScrollbar alloc] init] animated:YES];
    }else if (sender.tag == 2) {
        [self.navigationController pushViewController:[[JLViewControllerCover alloc] init] animated:YES];
    }else if (sender.tag == 3) {
        [self.navigationController pushViewController:[[JLViewControllerCostom alloc] init] animated:YES];
    }
}

- (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
