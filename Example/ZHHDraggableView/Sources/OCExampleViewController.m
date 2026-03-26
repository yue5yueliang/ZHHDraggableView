//
//  OCExampleViewController.m
//  ZHHDraggableView_Example
//
//  Created by 桃色三岁 on 2025/02/23.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

#import "OCExampleViewController.h"
@import ZHHDraggableView;

@interface OCExampleViewController () <ZHHDraggableViewDelegate>

@property(nonatomic,strong)ZHHDraggableView *dragView;
@property(nonatomic,strong)UIButton *dragButton;
@property(nonatomic,strong)UILabel *leftLabel;
@property(nonatomic,strong)UILabel *rightLabel;
@property(nonatomic,strong)UISwitch *leftSwitch;
@property(nonatomic,strong)UISwitch *rightSwitch;
@property(nonatomic,strong)UILabel *tipsLabel;
@property(nonatomic,strong)UIView *containerView;
@property(nonatomic,strong)UISlider *keepBoundsInsetsSlider;
@property(nonatomic,strong)UILabel *keepBoundsInsetsValueLabel;

@end

@implementation OCExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OC 示例";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.keepBoundsInsetsValueLabel = [[UILabel alloc] init];
    self.keepBoundsInsetsSlider = [[UISlider alloc] init];

    [self.view addSubview:self.leftLabel];
    [self.view addSubview:self.rightLabel];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.leftSwitch];
    [self.view addSubview:self.rightSwitch];
    [self.view addSubview:self.keepBoundsInsetsValueLabel];
    [self.view addSubview:self.keepBoundsInsetsSlider];
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.dragView];

    self.leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tipsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.keepBoundsInsetsValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.keepBoundsInsetsSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;

    self.keepBoundsInsetsValueLabel.textColor = [UIColor blackColor];
    self.keepBoundsInsetsValueLabel.font = [UIFont systemFontOfSize:15];
    self.keepBoundsInsetsValueLabel.text = @"贴边距：10";

    self.keepBoundsInsetsSlider.minimumValue = 0;
    self.keepBoundsInsetsSlider.maximumValue = 30;
    self.keepBoundsInsetsSlider.value = 10;
    [self.keepBoundsInsetsSlider addTarget:self action:@selector(keepBoundsInsetsChanged:) forControlEvents:UIControlEventValueChanged];

    [NSLayoutConstraint activateConstraints:@[
        [self.leftSwitch.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-140],
        [self.rightSwitch.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-100],

        [self.leftLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.leftLabel.centerYAnchor constraintEqualToAnchor:self.leftSwitch.centerYAnchor],
        [self.leftSwitch.leadingAnchor constraintEqualToAnchor:self.leftLabel.trailingAnchor constant:20],

        [self.rightLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.rightLabel.centerYAnchor constraintEqualToAnchor:self.rightSwitch.centerYAnchor],
        [self.rightSwitch.leadingAnchor constraintEqualToAnchor:self.rightLabel.trailingAnchor constant:20],

        [self.keepBoundsInsetsValueLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.keepBoundsInsetsValueLabel.bottomAnchor constraintEqualToAnchor:self.leftSwitch.topAnchor constant:-16],

        [self.keepBoundsInsetsSlider.leadingAnchor constraintEqualToAnchor:self.keepBoundsInsetsValueLabel.trailingAnchor constant:20],
        [self.keepBoundsInsetsSlider.widthAnchor constraintEqualToConstant:160],
        [self.keepBoundsInsetsSlider.centerYAnchor constraintEqualToAnchor:self.keepBoundsInsetsValueLabel.centerYAnchor],

        [self.containerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:50],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-50],
        [self.containerView.heightAnchor constraintEqualToConstant:self.view.bounds.size.width - 100],

        [self.tipsLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.tipsLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40]
    ]];
    self.dragView.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
}

/// 点击时的回调
- (void)dragViewDidClick:(ZHHDraggableView *)dragView {
    self.dragButton.selected = dragView.dragEnable;
    dragView.dragEnable = !dragView.dragEnable;

    self.tipsLabel.hidden = NO;
    UIControlState state = self.dragButton.selected ? UIControlStateSelected : UIControlStateNormal;
    NSString *title = [self.dragButton titleForState:state];
    self.tipsLabel.text = title;
    [self.tipsLabel performSelector:@selector(setHidden:) withObject:@(YES) afterDelay:2];
}

/// 开始拖动时的回调
- (void)dragViewDidBeginDrag:(ZHHDraggableView *)dragView {
    self.tipsLabel.hidden = NO;
    self.tipsLabel.text = @"开始拖曳";
}

/// 拖动过程中更新的回调
- (void)dragViewIsDuringDrag:(ZHHDraggableView *)dragView {
    self.tipsLabel.hidden = NO;
    self.tipsLabel.text = @"拖曳中...";
}

/// 结束拖动时的回调
- (void)dragViewDidEndDrag:(ZHHDraggableView *)dragView {
    self.tipsLabel.text = @"结束拖曳";
    [self.tipsLabel performSelector:@selector(setHidden:) withObject:@(YES) afterDelay:1.5];
}

- (void)setFreeRect:(UISwitch *)sender{
    if (sender.on) {
        self.dragView.freeRect = self.containerView.frame;
    }else{
        self.dragView.freeRect = self.view.frame;
    }
    self.containerView.hidden = !sender.on;
}

- (void)boundsOrNot:(UISwitch *)sender{
    CGFloat v = roundf(self.keepBoundsInsetsSlider.value);
    NSInteger iv = (NSInteger)v;
    self.keepBoundsInsetsValueLabel.text = [NSString stringWithFormat:@"贴边距：%ld", (long)iv];
    self.dragView.keepBoundsInsets = UIEdgeInsetsMake(v, v, v, v);
    self.dragView.isKeepBounds = sender.on;
    [self.view layoutIfNeeded];
}

- (void)keepBoundsInsetsChanged:(UISlider *)sender{
    CGFloat v = roundf(sender.value);
    NSInteger iv = (NSInteger)v;
    self.keepBoundsInsetsValueLabel.text = [NSString stringWithFormat:@"贴边距：%ld", (long)iv];
    self.dragView.keepBoundsInsets = UIEdgeInsetsMake(v, v, v, v);
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor systemGrayColor];
    }
    return _containerView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = [UIColor blackColor];
        _tipsLabel.font = [UIFont systemFontOfSize:15];
    }
    return _tipsLabel;
}

- (UILabel *)leftLabel{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.textColor = [UIColor blackColor];
        _leftLabel.font = [UIFont systemFontOfSize:15];
        _leftLabel.text = @"打开or关闭黏贴边界效果";
    }
    return _leftLabel;
}

- (UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.textColor = [UIColor blackColor];
        _rightLabel.font = [UIFont systemFontOfSize:15];
        _rightLabel.text = @"把dragView限定在框内";
    }
    return _rightLabel;
}

- (UISwitch *)leftSwitch{
    if (!_leftSwitch) {
        _leftSwitch = [[UISwitch alloc] init];
        [_leftSwitch addTarget:self action:@selector(boundsOrNot:) forControlEvents:UIControlEventValueChanged];
    }
    return _leftSwitch;
}

- (UISwitch *)rightSwitch{
    if (!_rightSwitch) {
        _rightSwitch = [[UISwitch alloc] init];
        [_rightSwitch addTarget:self action:@selector(setFreeRect:) forControlEvents:UIControlEventValueChanged];
    }
    return _rightSwitch;
}

- (ZHHDraggableView *)dragView{
    if (!_dragView) {
        _dragView = [[ZHHDraggableView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _dragView.delegate = self;

        self.dragButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dragButton.clipsToBounds = YES;
        self.dragButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.dragButton setTitle:@"可拖曳" forState:UIControlStateNormal];
        [self.dragButton setTitle:@"不可拖曳" forState:UIControlStateSelected];
        // 让点击事件由 `ZHHDraggableView` 的手势处理，避免按钮吞掉点击导致回调不触发
        self.dragButton.userInteractionEnabled = NO;
        self.dragButton.frame = CGRectMake(0, 0, 80, 80);
        [_dragView.contentView addSubview:self.dragButton];

        _dragView.layer.cornerRadius = 5;
        _dragView.layer.masksToBounds = YES;
        _dragView.backgroundColor = [UIColor orangeColor];
    }
    return _dragView;
}

@end
