//
//  JLFirstViewController.m
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import "JLFirstViewController.h"

@interface JLFirstViewController ()

@end

@implementation JLFirstViewController

- (void)setUpWhenViewWillAppearForTitle:(NSString *)title forIndex:(NSInteger)index firstTimeAppear:(BOOL)isFirstTime {
    if (isFirstTime) {
        if ([title isEqualToString:@"国际要闻"]) {
            NSLog(@"----加载'国际要闻'相关的内容----");
        }else if ([title isEqualToString:@"体育"]) {
            NSLog(@"----加载'体育'相关的内容----");
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    NSLog(@"%@-----test---销毁", self.description);
}


@end
