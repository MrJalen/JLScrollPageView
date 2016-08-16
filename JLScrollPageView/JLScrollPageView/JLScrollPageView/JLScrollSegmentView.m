//
//  JLScrollSegmentView.m
//  JLScrollPageView
//
//  Created by MrJalen on 16/8/16.
//  Copyright © 2016年 lianjiang. All rights reserved.
//

#import "JLScrollSegmentView.h"
#import "JLCustomLabel.h"
#import "UIView+Extend.h"

@interface JLScrollSegmentView () {
    CGFloat _currentWidth;
    NSUInteger _currentIndex;
    NSUInteger _oldIndex;
    //BOOL _isScroll;
}

/** 滚动条 */
@property (weak, nonatomic) UIView *scrollLine;

/** 遮盖 */
@property (weak, nonatomic) UIView *coverLayer;

/** 滚动scrollView */
@property (weak, nonatomic) UIScrollView *scrollView;

/** 背景ImageView */
@property (weak, nonatomic) UIImageView *backgroundImageView;

/** 附加的按钮 */
@property (weak, nonatomic) UIButton *extraBtn;


/** 用于懒加载计算文字的rgb差值, 用于颜色渐变的时候设置 */
@property (strong, nonatomic) NSArray *deltaRGB;
@property (strong, nonatomic) NSArray *selectedColorRgb;
@property (strong, nonatomic) NSArray *normalColorRgb;

/** 缓存所有标题label */
@property (nonatomic, strong) NSMutableArray *titleLabels;

/** 缓存计算出来的每个标题的宽度 */
@property (nonatomic, strong) NSMutableArray *titleWidths;

/** 响应标题点击 */
@property (copy, nonatomic) TitleBtnOnClickBlock titleBtnOnClick;

@end


@implementation JLScrollSegmentView
#define xGap 5.0
#define wGap 2*xGap
#define contentSizeXOff 20.0

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect )frame segmentStyle:(JLSegmentStyle *)segmentStyle titles:(NSArray *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick {
    if (self = [super initWithFrame:frame]) {
        self.segmentStyle = segmentStyle;
        self.titles = titles;
        self.titleBtnOnClick = titleDidClick;
        _currentIndex = 0;
        _oldIndex = 0;
        _currentWidth = frame.size.width;

        if (!self.segmentStyle.isScrollTitle) {
            // 不能滚动的时候就不要把缩放和遮盖或者滚动条同时使用, 否则显示效果不好
            self.segmentStyle.scaleTitle = !(self.segmentStyle.isShowCover || self.segmentStyle.isShowLine);
        }

        // 设置了frame之后可以直接设置其他的控件的frame了, 不需要在layoutsubView()里面设置
        [self setupTitles];
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"JLScrollSegmentView ---- 销毁");
}

#pragma mark - button action

- (void)titleLabelOnClick:(UITapGestureRecognizer *)tapGes {
    JLCustomLabel *currentLabel = (JLCustomLabel *)tapGes.view;

    if (!currentLabel) {
        return;
    }
    _currentIndex = currentLabel.tag;

    [self adjustUIWhenBtnOnClickWithAnimate:true];
}

- (void)extraBtnOnClick:(UIButton *)extraBtn {

    if (self.extraBtnOnClick) {
        self.extraBtnOnClick(extraBtn);
    }
}

#pragma mark - private helper

- (void)setupTitles {
    NSInteger index = 0;
    for (NSString *title in self.titles) {

        JLCustomLabel *label = [[JLCustomLabel alloc] initWithFrame:CGRectZero];
        label.tag = index;
        label.text = title;
        label.textColor = self.segmentStyle.normalTitleColor;
        label.font = self.segmentStyle.titleFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelOnClick:)];
        [label addGestureRecognizer:tapGes];
        CGRect bounds = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: label.font} context:nil];
        [self.titleWidths addObject:@(bounds.size.width)];
        [self.titleLabels addObject:label];
        [self.scrollView addSubview:label];

        index++;
    }
}

- (void)setupUI {
    [self setupScrollViewAndExtraBtn];
    [self setUpLabelsPosition];
    [self setupScrollLineAndCover];

    if (self.segmentStyle.isScrollTitle) {
        // 设置滚动区域
        JLCustomLabel *lastLabel = (JLCustomLabel *)self.titleLabels.lastObject;

        if (lastLabel) {
            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame) + contentSizeXOff, 0.0);
        }
    }
}

- (void)setupScrollViewAndExtraBtn {
    CGFloat extraBtnW = 44.0;
    CGFloat extraBtnY = 5.0;

    CGFloat scrollW = self.extraBtn ? _currentWidth - extraBtnW : _currentWidth;
    self.scrollView.frame = CGRectMake(0.0, 0.0, scrollW, self.height);

    if (self.extraBtn) {
        self.extraBtn.frame = CGRectMake(scrollW , extraBtnY, extraBtnW, self.height - 2*extraBtnY);
    }
}

- (void)setUpLabelsPosition {
    CGFloat titleX = 0.0;
    CGFloat titleY = 0.0;
    CGFloat titleW = 0.0;
    CGFloat titleH = self.height - self.segmentStyle.scrollLineHeight;

    if (!self.segmentStyle.isScrollTitle) {
        // 标题不能滚动, 平分宽度
        titleW = _currentWidth / self.titles.count;

        NSInteger index = 0;
        for (JLCustomLabel *label in self.titleLabels) {

            titleX = index * titleW;

            label.frame = CGRectMake(titleX, titleY, titleW, titleH);
            index++;
        }
    } else {
        float allTitlesWidth = 0.0;
        for (int i = 0; i<self.titleWidths.count; i++) {
            allTitlesWidth = allTitlesWidth + [self.titleWidths[i] floatValue] + self.segmentStyle.titleMargin;
        }

        float addedMargin = allTitlesWidth < self.scrollView.bounds.size.width ? (self.scrollView.bounds.size.width - allTitlesWidth)/self.titleWidths.count : 0 ;

        NSInteger index = 0;
        float lastLableMaxX = self.segmentStyle.titleMargin;

        for (JLCustomLabel *label in self.titleLabels) {
            titleW = [self.titleWidths[index] floatValue];
            titleX = lastLableMaxX + addedMargin/2;

            lastLableMaxX += (titleW + addedMargin + self.segmentStyle.titleMargin);

            label.frame = CGRectMake(titleX, titleY, titleW, titleH);
            index++;
        }
    }

    JLCustomLabel *firstLabel = (JLCustomLabel *)self.titleLabels[0];
    if (firstLabel) {
        // 缩放, 设置初始的label的transform
        if (self.segmentStyle.isScaleTitle) {
            firstLabel.currentTransformSx = self.segmentStyle.titleBigScale;
        }
        // 设置初始状态文字的颜色
        firstLabel.textColor = self.segmentStyle.selectedTitleColor;
    }
}

- (void)setupScrollLineAndCover {

    JLCustomLabel *firstLabel = (JLCustomLabel *)self.titleLabels[0];
    CGFloat coverX = firstLabel.x;
    CGFloat coverW = firstLabel.width;
    CGFloat coverH = self.segmentStyle.coverHeight;
    CGFloat coverY = (self.bounds.size.height - coverH) * 0.5;

    if (self.scrollLine) {
        if (self.segmentStyle.isScrollTitle) {
            self.scrollLine.frame = CGRectMake(coverX , self.height - self.segmentStyle.scrollLineHeight, coverW , self.segmentStyle.scrollLineHeight);

        } else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                coverW = [self.titleWidths[_currentIndex] floatValue] + wGap;
                coverX = (firstLabel.width - coverW) * 0.5;
            }

            self.scrollLine.frame = CGRectMake(coverX , self.height - self.segmentStyle.scrollLineHeight, coverW , self.segmentStyle.scrollLineHeight);
        }
    }

    if (self.coverLayer) {

        if (self.segmentStyle.isScrollTitle) {
            self.coverLayer.frame = CGRectMake(coverX - xGap, coverY, coverW + wGap, coverH);

        } else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                coverW = [self.titleWidths[_currentIndex] floatValue] + wGap;
                coverX = (firstLabel.width - coverW) * 0.5;
            }

            self.coverLayer.frame = CGRectMake(coverX, coverY, coverW, coverH);
        }
    }
}

#pragma mark - public helper
- (void)adjustUIWhenBtnOnClickWithAnimate:(BOOL)animated {
    if (_currentIndex == _oldIndex) { return; }

    JLCustomLabel *oldLabel = (JLCustomLabel *)self.titleLabels[_oldIndex];
    JLCustomLabel *currentLabel = (JLCustomLabel *)self.titleLabels[_currentIndex];

    CGFloat animatedTime = animated ? 0.30 : 0.0;

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:animatedTime animations:^{
        oldLabel.textColor = weakSelf.segmentStyle.normalTitleColor;
        currentLabel.textColor = weakSelf.segmentStyle.selectedTitleColor;

        if (weakSelf.segmentStyle.isScaleTitle) {
            oldLabel.currentTransformSx = 1.0;
            currentLabel.currentTransformSx = weakSelf.segmentStyle.titleBigScale;
        }

        if (weakSelf.scrollLine) {
            if (weakSelf.segmentStyle.isScrollTitle) {
                weakSelf.scrollLine.x = currentLabel.x;
                weakSelf.scrollLine.width = currentLabel.width;
            } else {
                if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                    CGFloat scrollLineW = [self.titleWidths[_currentIndex] floatValue] + wGap;
                    CGFloat scrollLineX = currentLabel.x + (currentLabel.width - scrollLineW) * 0.5;
                    weakSelf.scrollLine.x = scrollLineX;
                    weakSelf.scrollLine.width = scrollLineW;
                } else {
                    weakSelf.scrollLine.x = currentLabel.x;
                    weakSelf.scrollLine.width = currentLabel.width;
                }
            }
        }

        if (weakSelf.coverLayer) {
            if (weakSelf.segmentStyle.isScrollTitle) {

                weakSelf.coverLayer.x = currentLabel.x - xGap;
                weakSelf.coverLayer.width = currentLabel.width + wGap;
            } else {
                if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                    CGFloat coverW = [self.titleWidths[_currentIndex] floatValue] + wGap;
                    CGFloat coverX = currentLabel.x + (currentLabel.width - coverW) * 0.5;
                    weakSelf.coverLayer.x = coverX;
                    weakSelf.coverLayer.width = coverW;
                } else {
                    weakSelf.coverLayer.x = currentLabel.x;
                    weakSelf.coverLayer.width = currentLabel.width;
                }
            }
        }
    } completion:^(BOOL finished) {
        [weakSelf adjustTitleOffSetToCurrentIndex:_currentIndex];

    }];

    _oldIndex = _currentIndex;
    if (self.titleBtnOnClick) {
        self.titleBtnOnClick(currentLabel, _currentIndex);
    }
    //发布通知
    //[self addCurrentShowIndexNotification];
}

- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex {
    _oldIndex = currentIndex;
    JLCustomLabel *oldLabel = (JLCustomLabel *)self.titleLabels[oldIndex];
    JLCustomLabel *currentLabel = (JLCustomLabel *)self.titleLabels[currentIndex];

    CGFloat xDistance = currentLabel.x - oldLabel.x;
    CGFloat wDistance = currentLabel.width - oldLabel.width;

    if (self.scrollLine) {
        if (self.segmentStyle.isScrollTitle) {
            self.scrollLine.x = oldLabel.x + xDistance * progress;
            self.scrollLine.width = oldLabel.width + wDistance * progress;
        } else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                CGFloat oldScrollLineW = [self.titleWidths[oldIndex] floatValue] + wGap;
                CGFloat currentScrollLineW = [self.titleWidths[currentIndex] floatValue] + wGap;
                wDistance = currentScrollLineW - oldScrollLineW;

                CGFloat oldScrollLineX = oldLabel.x + (oldLabel.width - oldScrollLineW) * 0.5;
                CGFloat currentScrollLineX = currentLabel.x + (currentLabel.width - currentScrollLineW) * 0.5;
                xDistance = currentScrollLineX - oldScrollLineX;
                self.scrollLine.x = oldScrollLineX + xDistance * progress;
                self.scrollLine.width = oldScrollLineW + wDistance * progress;
            } else {
                self.scrollLine.x = oldLabel.x + xDistance * progress;
                self.scrollLine.width = oldLabel.width + wDistance * progress;
            }
        }
    }

    if (self.coverLayer) {
        if (self.segmentStyle.isScrollTitle) {
            self.coverLayer.x = oldLabel.x + xDistance * progress - xGap;
            self.coverLayer.width = oldLabel.width + wDistance * progress + wGap;
        } else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                CGFloat oldCoverW = [self.titleWidths[oldIndex] floatValue] + wGap;
                CGFloat currentCoverW = [self.titleWidths[currentIndex] floatValue] + wGap;
                wDistance = currentCoverW - oldCoverW;
                CGFloat oldCoverX = oldLabel.x + (oldLabel.width - oldCoverW) * 0.5;
                CGFloat currentCoverX = currentLabel.x + (currentLabel.width - currentCoverW) * 0.5;
                xDistance = currentCoverX - oldCoverX;
                self.coverLayer.x = oldCoverX + xDistance * progress;
                self.coverLayer.width = oldCoverW + wDistance * progress;
            } else {
                self.coverLayer.x = oldLabel.x + xDistance * progress;
                self.coverLayer.width = oldLabel.width + wDistance * progress;
            }
        }
    }

    // 渐变
    if (self.segmentStyle.isGradualChangeTitleColor) {

        oldLabel.textColor = [UIColor colorWithRed:[self.selectedColorRgb[0] floatValue] + [self.deltaRGB[0] floatValue] * progress green:[self.selectedColorRgb[1] floatValue] + [self.deltaRGB[1] floatValue] * progress blue:[self.selectedColorRgb[2] floatValue] + [self.deltaRGB[2] floatValue] * progress alpha:1.0];
        currentLabel.textColor = [UIColor colorWithRed:[self.normalColorRgb[0] floatValue] - [self.deltaRGB[0] floatValue] * progress green:[self.normalColorRgb[1] floatValue] - [self.deltaRGB[1] floatValue] * progress blue:[self.normalColorRgb[2] floatValue] - [self.deltaRGB[2] floatValue] * progress alpha:1.0];
    }

    if (!self.segmentStyle.isScaleTitle) {
        return;
    }

    CGFloat deltaScale = self.segmentStyle.titleBigScale - 1.0;
    oldLabel.currentTransformSx = self.segmentStyle.titleBigScale - deltaScale * progress;
    currentLabel.currentTransformSx = 1.0 + deltaScale * progress;
}

- (void)adjustTitleOffSetToCurrentIndex:(NSInteger)currentIndex {
    if (self.scrollView.contentSize.width != self.scrollView.bounds.size.width + contentSizeXOff) {// 需要滚动

        JLCustomLabel *currentLabel = (JLCustomLabel *)self.titleLabels[currentIndex];

        CGFloat offSetx = currentLabel.center.x - _currentWidth * 0.5;
        if (offSetx < 0) {
            offSetx = 0;
        }
        CGFloat extraBtnW = self.extraBtn ? self.extraBtn.width : 0.0;
        CGFloat maxOffSetX = self.scrollView.contentSize.width - (_currentWidth - extraBtnW);

        if (maxOffSetX < 0) {
            maxOffSetX = 0;
        }

        if (offSetx > maxOffSetX) {
            offSetx = maxOffSetX;
        }

        [self.scrollView setContentOffset:CGPointMake(offSetx, 0.0) animated:YES];
    }
    // 重置其他item的缩放和颜色
    NSInteger index = 0;
    for (JLCustomLabel *label in self.titleLabels) {
        if (index != currentIndex) {
            label.textColor = self.segmentStyle.normalTitleColor;
            label.currentTransformSx = 1.0;
        } else {
            label.textColor = self.segmentStyle.selectedTitleColor;
        }
        index++;
    }
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    NSAssert(index >= 0 && index < self.titles.count, @"设置的下标不合法!!");

    if (index < 0 || index >= self.titles.count) {
        return;
    }

    _currentIndex = index;
    [self adjustUIWhenBtnOnClickWithAnimate:animated];
}

- (void)reloadTitlesWithNewTitles:(NSArray *)titles {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 将子控件置为nil 否则懒加载会不正常
    _scrollLine = nil;
    _coverLayer = nil;

    self.titleWidths = nil;
    self.titleLabels = nil;
    self.titles = nil;
    self.titles = titles;

    [self setupTitles];
    [self setupUI];
    [self setSelectedIndex:0 animated:YES];
}

#pragma mark - getter --- setter
- (UIView *)scrollLine {

    if (!self.segmentStyle.isShowLine) {
        return nil;
    }

    if (!_scrollLine) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = self.segmentStyle.scrollLineColor;

        [self.scrollView addSubview:lineView];
        _scrollLine = lineView;
    }

    return _scrollLine;
}

- (UIView *)coverLayer {
    if (!self.segmentStyle.isShowCover) {
        return nil;
    }

    if (_coverLayer == nil) {
        UIView *coverView = [[UIView alloc] init];
        coverView.backgroundColor = self.segmentStyle.coverBackgroundColor;
        coverView.layer.cornerRadius = self.segmentStyle.coverCornerRadius;
        coverView.layer.masksToBounds = YES;
        [self.scrollView insertSubview:coverView atIndex:0];

        _coverLayer = coverView;
    }

    return _coverLayer;
}

- (UIButton *)extraBtn {
    if (!self.segmentStyle.showExtraButton) {
        return nil;
    }
    if (!_extraBtn) {
        UIButton *btn = [UIButton new];
        [btn addTarget:self action:@selector(extraBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        NSString *imageName = self.segmentStyle.extraBtnBackgroundImageName ? self.segmentStyle.extraBtnBackgroundImageName : @"";
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        // 设置边缘的阴影效果
        btn.layer.shadowColor = [UIColor whiteColor].CGColor;
        btn.layer.shadowOffset = CGSizeMake(-5, 0);
        btn.layer.shadowOpacity = 1;

        [self addSubview:btn];
        _extraBtn = btn;
    }
    return _extraBtn;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.bounces = self.segmentStyle.isSegmentViewBounces;
        scrollView.pagingEnabled = NO;
        // weak 需要强引用
        [self addSubview:scrollView];

        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIImageView *)backgroundImageView {

    if (!_backgroundImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];

        [self insertSubview:imageView atIndex:0];

        _backgroundImageView = imageView;
    }
    return _backgroundImageView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    if (backgroundImage) {
        self.backgroundImageView.image = backgroundImage;
    }
}

- (NSMutableArray *)titleLabels {
    if (_titleLabels == nil) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

- (NSMutableArray *)titleWidths {
    if (_titleWidths == nil) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}

- (NSArray *)deltaRGB {
    if (_deltaRGB == nil) {
        NSArray *normalColorRgb = self.normalColorRgb;
        NSArray *selectedColorRgb = self.selectedColorRgb;

        NSArray *delta;
        if (normalColorRgb && selectedColorRgb) {
            CGFloat deltaR = [normalColorRgb[0] floatValue] - [selectedColorRgb[0] floatValue];
            CGFloat deltaG = [normalColorRgb[1] floatValue] - [selectedColorRgb[1] floatValue];
            CGFloat deltaB = [normalColorRgb[2] floatValue] - [selectedColorRgb[2] floatValue];
            delta = [NSArray arrayWithObjects:@(deltaR), @(deltaG), @(deltaB), nil];
            _deltaRGB = delta;

        }
    }
    return _deltaRGB;
}

- (NSArray *)normalColorRgb {
    if (!_normalColorRgb) {
        NSArray *normalColorRgb = [self getColorRgb:self.segmentStyle.normalTitleColor];
        NSAssert(normalColorRgb, @"设置普通状态的文字颜色时 请使用RGB空间的颜色值");
        _normalColorRgb = normalColorRgb;

    }
    return  _normalColorRgb;
}

- (NSArray *)selectedColorRgb {
    if (!_selectedColorRgb) {
        NSArray *selectedColorRgb = [self getColorRgb:self.segmentStyle.selectedTitleColor];
        NSAssert(selectedColorRgb, @"设置选中状态的文字颜色时 请使用RGB空间的颜色值");
        _selectedColorRgb = selectedColorRgb;

    }
    return  _selectedColorRgb;
}

- (NSArray *)getColorRgb:(UIColor *)color {
    CGFloat numOfcomponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *rgbComponents;
    if (numOfcomponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbComponents = [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), nil];
    }
    return rgbComponents;
}

@end

