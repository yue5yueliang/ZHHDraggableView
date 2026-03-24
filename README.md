# ZHHDraggableView

[![CI Status](https://img.shields.io/travis/yue5yueliang/ZHHDraggableView.svg?style=flat)](https://travis-ci.org/yue5yueliang/ZHHDraggableView)
[![Version](https://img.shields.io/cocoapods/v/ZHHDraggableView.svg?style=flat)](https://cocoapods.org/pods/ZHHDraggableView)
[![License](https://img.shields.io/cocoapods/l/ZHHDraggableView.svg?style=flat)](https://cocoapods.org/pods/ZHHDraggableView)
[![Platform](https://img.shields.io/cocoapods/p/ZHHDraggableView.svg?style=flat)](https://cocoapods.org/pods/ZHHDraggableView)

## 简介

`ZHHDraggableView` 让你可以将任意视图变为可拖动并悬浮在屏幕上的元素，类似于 iOS 中的 AssistiveTouch。支持自定义拖动方向、边界控制等功能，可以广泛应用于悬浮按钮、拖动视图等场景。

## 示例

要运行示例项目，克隆仓库后，首先进入 `Example` 目录并执行 `pod install`。

```bash
git clone https://github.com/yue5yueliang/ZHHDraggableView.git
cd ZHHDraggableView/Example
pod install
```

## 安装

在 `Podfile` 中添加：

```ruby
pod 'ZHHDraggableView'
```

## 支持语言

- Swift
- Objective-C

## Swift 使用示例

```swift
import ZHHDraggableView

let dragView = ZHHDraggableView(frame: CGRect(x: 100, y: 200, width: 80, height: 80))
dragView.button.setTitle("可拖曳", for: .normal)
dragView.isKeepBounds = true
view.addSubview(dragView)
```

## Objective-C 使用示例

```objc
@import ZHHDraggableView;

ZHHDraggableView *dragView = [[ZHHDraggableView alloc] initWithFrame:CGRectMake(100, 200, 80, 80)];
[dragView.button setTitle:@"可拖曳" forState:UIControlStateNormal];
dragView.isKeepBounds = YES;
[self.view addSubview:dragView];
```