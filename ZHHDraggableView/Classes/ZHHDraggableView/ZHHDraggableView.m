//
//  ZHHDraggableView.m
//  ZHHAnneKitExample
//
//  Created by Ranyu222 on 2025/2/20.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHDraggableView.h"

@interface ZHHDraggableView ()<UIGestureRecognizerDelegate>
/// 内容视图
@property (nonatomic, strong) UIView *containerView;
/// 拖动起始点
@property (nonatomic, assign) CGPoint startPoint;
/// 滑动手势识别器
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
/// 上一次的缩放比例
@property (nonatomic, assign) CGFloat previousScale;
@end

@implementation ZHHDraggableView

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        [self.containerView addSubview:_imageView];
    }
    return _imageView;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.clipsToBounds = YES;
        _button.userInteractionEnabled = NO;
        [self.containerView addSubview:_button];
    }
    return _button;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.containerView];
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // 如果设置了活动范围 freeRect，使用它；否则，使用父视图的 frame 作为默认活动范围
    if (CGRectEqualToRect(self.freeRect, CGRectZero)) {
        self.freeRect = (CGRect){CGPointZero, self.superview.bounds.size};
    }

    // 设置各个视图的 frame
    _imageView.frame = self.bounds;
    _button.frame = self.bounds;
    self.containerView.frame = self.bounds;
}

- (void)setUp {
    self.dragEnable = YES;  // 默认可以拖曳
    self.clipsToBounds = YES;
    self.isKeepBounds = NO;
    self.backgroundColor = [UIColor lightGrayColor];
    
    // 单击手势识别器
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragView)];
    [self addGestureRecognizer:singleTap];
    
    // 拖动手势识别器
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (void)setIsKeepBounds:(BOOL)isKeepBounds {
    _isKeepBounds = isKeepBounds;
    if (isKeepBounds) {
        [self keepBounds];
    }
}

- (void)setFreeRect:(CGRect)freeRect {
    _freeRect = freeRect;
    [self keepBounds];
}

/// 拖动事件处理
/// @param pan 拖动手势识别器
- (void)dragAction:(UIPanGestureRecognizer *)pan {
    if (!self.dragEnable) return; // 如果拖动被禁用，直接返回
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: { // 拖动开始
            // 代理回调：通知开始拖动
            if ([self.delegate respondsToSelector:@selector(dragViewDidBeginDrag:)]) {
                [self.delegate dragViewDidBeginDrag:self];
            }
            
            // 重置 translation，避免位置叠加
            [pan setTranslation:CGPointZero inView:self];
            // 保存拖动的起始位置
            self.startPoint = [pan translationInView:self];
            break;
        }
            
        case UIGestureRecognizerStateChanged: { // 拖动中
            // 代理回调：通知正在拖动
            if ([self.delegate respondsToSelector:@selector(dragViewIsDuringDrag:)]) {
                [self.delegate dragViewIsDuringDrag:self];
            }
            
            CGPoint point = [pan translationInView:self];
            CGFloat dx = 0, dy = 0;
            
            // 根据拖动方向计算位移
            switch (self.dragDirection) {
                case ZHHDragDirectionAny: // 任意方向
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
                case ZHHDragDirectionHorizontal: // 水平拖动
                    dx = point.x - self.startPoint.x;
                    break;
                case ZHHDragDirectionVertical: // 垂直拖动
                    dy = point.y - self.startPoint.y;
                    break;
                default: // 默认：任意方向
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
            }
            
            // 更新视图中心位置
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            self.center = newCenter;
            
            // 重置 translation，避免位置叠加
            [pan setTranslation:CGPointZero inView:self];
            break;
        }
            
        case UIGestureRecognizerStateEnded: { // 拖动结束
            // 保持视图在有效范围内
            [self keepBounds];
            
            // 代理回调：通知拖动结束
            if ([self.delegate respondsToSelector:@selector(dragViewDidEndDrag:)]) {
                [self.delegate dragViewDidEndDrag:self];
            }
            break;
        }
            
        default:
            break;
    }
}

// 单击事件处理
- (void)clickDragView {
    // 代理回调：通知单击事件
    if ([self.delegate respondsToSelector:@selector(dragViewDidClick:)]) {
        [self.delegate dragViewDidClick:self];
    }
}

// 保持视图在有效范围内
- (void)keepBounds {
    // 计算中心点
    float centerX = self.freeRect.origin.x + (self.freeRect.size.width - self.frame.size.width) / 2;
    CGRect rect = self.frame;
    
    // 判断是否启用自动黏贴边界效果
    if (self.isKeepBounds == NO) {
        // 没有设置黏贴边界效果，左侧
        if (self.frame.origin.x < self.freeRect.origin.x) {
            [self animateToX:self.freeRect.origin.x];
        }
        // 右侧
        else if (self.freeRect.origin.x + self.freeRect.size.width < self.frame.origin.x + self.frame.size.width) {
            [self animateToX:self.freeRect.origin.x + self.freeRect.size.width - self.frame.size.width];
        }
    } else if (self.isKeepBounds == YES) {
        // 设置了自动黏贴边界效果，左侧
        if (self.frame.origin.x < centerX) {
            [self animateToX:self.freeRect.origin.x];
        }
        // 右侧
        else {
            [self animateToX:self.freeRect.origin.x + self.freeRect.size.width - self.frame.size.width];
        }
    }

    // 上侧
    if (self.frame.origin.y < self.freeRect.origin.y) {
        [self animateToY:self.freeRect.origin.y];
    }
    // 下侧
    else if (self.freeRect.origin.y + self.freeRect.size.height < self.frame.origin.y + self.frame.size.height) {
        [self animateToY:self.freeRect.origin.y + self.freeRect.size.height - self.frame.size.height];
    }
}

// 通过动画更新X轴位置
- (void)animateToX:(CGFloat)x {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect rect = self.frame;
                         rect.origin.x = x;
                         self.frame = rect;
                     }
                     completion:nil];
}

// 通过动画更新Y轴位置
- (void)animateToY:(CGFloat)y {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect rect = self.frame;
                         rect.origin.y = y;
                         self.frame = rect;
                     }
                     completion:nil];
}

@end
