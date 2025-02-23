//
//  ZHHDraggableView.h
//  ZHHAnneKitExample
//
//  Created by Ranyu222 on 2025/2/20.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 拖曳view的方向

typedef NS_ENUM(NSInteger, ZHHDragDirection) {
    /// 任意方向
    ZHHDragDirectionAny,
    /// 水平方向
    ZHHDragDirectionHorizontal,
    /// 垂直方向
    ZHHDragDirectionVertical,
};

@class ZHHDraggableView;
@protocol ZHHDraggableViewDelegate <NSObject>

@optional
/// 点击时的回调
- (void)dragViewDidClick:(ZHHDraggableView *)dragView;

/// 开始拖动时的回调
- (void)dragViewDidBeginDrag:(ZHHDraggableView *)dragView;

/// 拖动过程中更新的回调
- (void)dragViewIsDuringDrag:(ZHHDraggableView *)dragView;

/// 结束拖动时的回调
- (void)dragViewDidEndDrag:(ZHHDraggableView *)dragView;

@end

@interface ZHHDraggableView : UIView

/// 是不是能拖曳，默认为YES
@property (nonatomic,assign) BOOL dragEnable;

/// 活动范围，默认为父视图的 `frame` 范围内。
/// 如果设置了此属性，则视图会在给定的 `CGRect` 范围内活动；
/// 如果未设置，则会在父视图的范围内活动。
/// 设置的 `frame` 不可大于父视图范围。
/// 设置为 `0, 0, 0, 0` 表示使用默认的父视图范围，
/// 如果不希望视图活动，可以将 `dragEnable` 属性设置为 NO。
@property (nonatomic, assign) CGRect freeRect;

/// 拖动方向，默认为 `any`，即任意方向。
/// 可以限制为特定方向，如上、下、左、右等。
@property (nonatomic, assign) ZHHDragDirection dragDirection;

/// contentView 内部懒加载的 `UIImageView`，可用于显示图片。
/// 开发者也可以在此视图中自定义控件。
/// 注意：尽量避免同时使用内部的 `imageView` 和 `button`。
@property (nonatomic, strong) UIImageView *imageView;

/// contentView 内部懒加载的 `UIButton`，可用于响应用户操作。
/// 开发者也可以在此视图中自定义控件。
/// 注意：尽量避免同时使用内部的 `imageView` 和 `button`。
@property (nonatomic, strong) UIButton *button;

/// 是否保持在父视图边界内。默认为 NO。
/// 当 isKeepBounds = YES 时，视图会自动粘附到最近的边界。
/// 当 isKeepBounds = NO 时，视图处于自由状态，可以随手指移动，但不会超出父视图的范围。
@property (nonatomic, assign) BOOL isKeepBounds;

/// 代理
@property (nonatomic, weak) id<ZHHDraggableViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
