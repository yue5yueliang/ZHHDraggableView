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
/// 滑动手势识别器
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
/// 震动反馈
@property (nonatomic, strong) UISelectionFeedbackGenerator *feedbackGenerator;
/// 上一次所在半区（-1:左 1:右）
@property (nonatomic, assign) NSInteger lastHorizontalZone;
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
        [self addSubview:self.containerView];
        [self setUp];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
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
    self.lastHorizontalZone = 0;
    
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

- (UISelectionFeedbackGenerator *)feedbackGenerator {
    if (!_feedbackGenerator) {
        _feedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
    }
    return _feedbackGenerator;
}

- (void)setIsKeepBounds:(BOOL)isKeepBounds {
    _isKeepBounds = isKeepBounds;
    if (isKeepBounds) {
        [self keepBoundsWithVelocity:CGPointZero];
    }
}

- (void)setFreeRect:(CGRect)freeRect {
    _freeRect = freeRect;
    [self keepBoundsWithVelocity:CGPointZero];
}

// 计算并裁剪活动范围，确保不超出父视图
- (CGRect)effectiveFreeRect {
    if (!self.superview) return self.freeRect;
    CGRect superBounds = self.superview.bounds;
    if (CGRectEqualToRect(self.freeRect, CGRectZero)) return superBounds;
    CGRect intersectRect = CGRectIntersection(self.freeRect, superBounds);
    if (CGRectIsNull(intersectRect) || CGRectIsEmpty(intersectRect)) return superBounds;
    return intersectRect;
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
            [self.feedbackGenerator prepare];
            [self.feedbackGenerator selectionChanged];
            [self.feedbackGenerator prepare];
            
            // 重置 translation，避免位置叠加
            [pan setTranslation:CGPointZero inView:self.superview];
            break;
        }
            
        case UIGestureRecognizerStateChanged: { // 拖动中
            // 代理回调：通知正在拖动
            if ([self.delegate respondsToSelector:@selector(dragViewIsDuringDrag:)]) {
                [self.delegate dragViewIsDuringDrag:self];
            }
            
            CGPoint point = [pan translationInView:self.superview];
            CGFloat dx = 0, dy = 0;
            
            // 根据拖动方向计算位移
            switch (self.dragDirection) {
                case ZHHDragDirectionAny: // 任意方向
                    dx = point.x;
                    dy = point.y;
                    break;
                case ZHHDragDirectionHorizontal: // 水平拖动
                    dx = point.x;
                    break;
                case ZHHDragDirectionVertical: // 垂直拖动
                    dy = point.y;
                    break;
                default: // 默认：任意方向
                    dx = point.x;
                    dy = point.y;
                    break;
            }
            
            // 更新视图中心位置
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            self.center = newCenter;
            if (self.isKeepBounds) {
                CGRect freeRect = [self effectiveFreeRect];
                CGFloat midX = CGRectGetMidX(freeRect);
                NSInteger currentZone = (self.center.x < midX) ? -1 : 1;
                if (self.lastHorizontalZone != 0 && currentZone != self.lastHorizontalZone) {
                    [self.feedbackGenerator selectionChanged];
                    [self.feedbackGenerator prepare];
                }
                self.lastHorizontalZone = currentZone;
            }
            
            // 重置 translation，避免位置叠加
            [pan setTranslation:CGPointZero inView:self.superview];
            break;
        }
            
        case UIGestureRecognizerStateEnded: { // 拖动结束
            // 保持视图在有效范围内
            CGPoint velocity = [pan velocityInView:self.superview];
            [self keepBoundsWithVelocity:velocity];
            self.lastHorizontalZone = 0;
            
            // 代理回调：通知拖动结束
            if ([self.delegate respondsToSelector:@selector(dragViewDidEndDrag:)]) {
                [self.delegate dragViewDidEndDrag:self];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            self.lastHorizontalZone = 0;
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
- (void)keepBoundsWithVelocity:(CGPoint)velocity {
    CGRect freeRect = [self effectiveFreeRect];
    // 计算中心点
    float centerX = freeRect.origin.x + (freeRect.size.width - self.frame.size.width) / 2;
    CGFloat targetX = self.frame.origin.x;
    CGFloat targetY = self.frame.origin.y;
    
    // 判断是否启用自动黏贴边界效果
    if (self.isKeepBounds == NO) {
        // 没有设置黏贴边界效果，左侧
        if (self.frame.origin.x < freeRect.origin.x) {
            targetX = freeRect.origin.x;
        }
        // 右侧
        else if (freeRect.origin.x + freeRect.size.width < self.frame.origin.x + self.frame.size.width) {
            targetX = freeRect.origin.x + freeRect.size.width - self.frame.size.width;
        }
    } else if (self.isKeepBounds == YES) {
        // 设置了自动黏贴边界效果，左侧
        if (self.frame.origin.x < centerX) {
            targetX = freeRect.origin.x;
        }
        // 右侧
        else {
            targetX = freeRect.origin.x + freeRect.size.width - self.frame.size.width;
        }
    }

    // 上侧
    if (self.frame.origin.y < freeRect.origin.y) {
        targetY = freeRect.origin.y;
    }
    // 下侧
    else if (freeRect.origin.y + freeRect.size.height < self.frame.origin.y + self.frame.size.height) {
        targetY = freeRect.origin.y + freeRect.size.height - self.frame.size.height;
    }
    
    if (targetX == self.frame.origin.x && targetY == self.frame.origin.y) {
        return;
    }
    
    CGFloat speed = hypot(velocity.x, velocity.y);
    NSTimeInterval duration = speed > 1800 ? 0.18 : 0.24;
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.86
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect rect = self.frame;
                         rect.origin.x = targetX;
                         rect.origin.y = targetY;
                         self.frame = rect;
                     }
                     completion:nil];
}

@end
