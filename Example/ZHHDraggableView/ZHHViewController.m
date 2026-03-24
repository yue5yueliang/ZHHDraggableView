//
//  ZHHViewController.m
//  ZHHDraggableView
//
//  Created by 桃色三岁 on 02/23/2025.
//  Copyright (c) 2025 桃色三岁. All rights reserved.
//

#import "ZHHViewController.h"
#import <Masonry/Masonry.h>
#import <ZHHDraggableView/ZHHDraggableView.h>

@interface ZHHViewController () <ZHHDraggableViewDelegate>

@property(nonatomic,strong)ZHHDraggableView *dragView;
@property(nonatomic,strong)UILabel *leftLabel;
@property(nonatomic,strong)UILabel *rightLabel;

@property(nonatomic,strong)UISwitch *leftSwitch;
@property(nonatomic,strong)UISwitch *rightSwitch;
@property(nonatomic,strong)UILabel *tipsLabel;

@property(nonatomic,strong)UIView *containerView;

@end

@implementation ZHHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.leftLabel];
    [self.view addSubview:self.rightLabel];
    [self.view addSubview:self.tipsLabel];

    [self.view addSubview:self.leftSwitch];
    [self.view addSubview:self.rightSwitch];

    [self.view addSubview:self.containerView];
    [self.view addSubview:self.dragView];

    [self.leftSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.bottom.mas_equalTo(self.view).offset(-100);
    }];
    [self.rightSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-20);
        make.bottom.mas_equalTo(self.view).offset(-100);
    }];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftSwitch);
        make.top.mas_equalTo(self.leftSwitch.mas_bottom);
    }];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rightSwitch);
        make.top.mas_equalTo(self.rightSwitch.mas_bottom);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
        make.height.mas_equalTo(self.view.bounds.size.width-100);
    }];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
    }];
}

/// 点击时的回调
- (void)dragViewDidClick:(ZHHDraggableView *)dragView {
    dragView.button.selected = dragView.dragEnable;
    dragView.dragEnable = !dragView.dragEnable;

    self.tipsLabel.hidden = NO;
    self.tipsLabel.text = dragView.button.titleLabel.text;
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
    self.dragView.isKeepBounds = sender.on;
    [self.view layoutIfNeeded];
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor colorWithRed:0.90 green:0.95 blue:1.00 alpha:1.0];
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
        _dragView.button.titleLabel.font = [UIFont systemFontOfSize:15];
        [_dragView.button setTitle:@"可拖曳" forState:UIControlStateNormal];
        [_dragView.button setTitle:@"不可拖曳" forState:UIControlStateSelected];
        _dragView.layer.cornerRadius = 5;
        _dragView.layer.masksToBounds = YES;
        _dragView.backgroundColor = [UIColor colorWithRed:0.98 green:0.76 blue:0.82 alpha:1.0];
        _dragView.center = self.view.center;
    }
    return _dragView;
}

@end
