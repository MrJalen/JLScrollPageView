//
//  JLCustomLabel.m
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import "JLCustomLabel.h"

@implementation JLCustomLabel

- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero]) {
        self.currentTransformSx = 1.0;
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.currentTransformSx = 1.0;
    }

    return self;
}

- (void)setCurrentTransformSx:(CGFloat)currentTransformSx {
    _currentTransformSx = currentTransformSx;
    self.transform = CGAffineTransformMakeScale(currentTransformSx, currentTransformSx);
}

@end
