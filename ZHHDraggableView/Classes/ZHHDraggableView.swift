//
//  ZHHDraggableView.swift
//  ZHHAnneKitExample
//
//  Created by Ranyu222 on 2025/2/20.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

/// 拖曳view的方向
@objc public enum ZHHDragDirection: Int {
    /// 任意方向
    case any
    /// 水平方向
    case horizontal
    /// 垂直方向
    case vertical
}

@objc public protocol ZHHDraggableViewDelegate: AnyObject {
    /// 点击时的回调
    @objc optional func dragViewDidClick(_ dragView: ZHHDraggableView)
    /// 开始拖动时的回调
    @objc optional func dragViewDidBeginDrag(_ dragView: ZHHDraggableView)
    /// 拖动过程中更新的回调
    @objc optional func dragViewIsDuringDrag(_ dragView: ZHHDraggableView)
    /// 结束拖动时的回调
    @objc optional func dragViewDidEndDrag(_ dragView: ZHHDraggableView)
}

@objcMembers
public final class ZHHDraggableView: UIView, UIGestureRecognizerDelegate {
    /// 内容视图
    private let containerView = UIView()
    /// 滑动手势识别器
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragAction(_:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        return pan
    }()
    /// 震动反馈
    private lazy var feedbackGenerator = UISelectionFeedbackGenerator()
    /// 上一次所在半区（-1:左 1:右）
    private var lastHorizontalZone: Int = 0

    /// 是不是能拖曳，默认为YES
    public var dragEnable: Bool = true
    /// 活动范围，默认为父视图的 `frame` 范围内。
    /// 如果设置了此属性，则视图会在给定的 `CGRect` 范围内活动；
    /// 如果未设置，则会在父视图的范围内活动。
    /// 设置的 `frame` 不可大于父视图范围。
    /// 设置为 `0, 0, 0, 0` 表示使用默认的父视图范围，
    /// 如果不希望视图活动，可以将 `dragEnable` 属性设置为 NO。
    public var freeRect: CGRect = .zero {
        didSet { keepBounds(withVelocity: .zero) }
    }
    /// 拖动方向，默认为 `any`，即任意方向。
    /// 可以限制为特定方向，如上、下、左、右等。
    public var dragDirection: ZHHDragDirection = .any
    /// contentView 内部懒加载的 `UIImageView`，可用于显示图片。
    /// 开发者也可以在此视图中自定义控件。
    /// 注意：尽量避免同时使用内部的 `imageView` 和 `button`。
    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.clipsToBounds = true
        containerView.addSubview(view)
        return view
    }()
    /// contentView 内部懒加载的 `UIButton`，可用于响应用户操作。
    /// 开发者也可以在此视图中自定义控件。
    /// 注意：尽量避免同时使用内部的 `imageView` 和 `button`。
    public lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false
        containerView.addSubview(button)
        return button
    }()
    /// 是否保持在父视图边界内。默认为 NO。
    /// 当 isKeepBounds = YES 时，视图会自动粘附到最近的边界。
    /// 当 isKeepBounds = NO 时，视图处于自由状态，可以随手指移动，但不会超出父视图的范围。
    public var isKeepBounds: Bool = false {
        didSet {
            if isKeepBounds {
                keepBounds(withVelocity: .zero)
            }
        }
    }
    /// 代理
    public weak var delegate: ZHHDraggableViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // 设置各个视图的 frame
        imageView.frame = bounds
        button.frame = bounds
        containerView.frame = bounds
    }

    private func setup() {
        clipsToBounds = true
        backgroundColor = .lightGray

        containerView.clipsToBounds = true
        addSubview(containerView)

        // 单击手势识别器
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(clickDragView))
        addGestureRecognizer(singleTap)

        // 拖动手势识别器
        addGestureRecognizer(panGestureRecognizer)
    }

    // 计算并裁剪活动范围，确保不超出父视图
    private func effectiveFreeRect() -> CGRect {
        guard let superview else { return freeRect }
        let superBounds = superview.bounds
        if freeRect == .zero { return superBounds }
        let intersectRect = freeRect.intersection(superBounds)
        if intersectRect.isNull || intersectRect.isEmpty { return superBounds }
        return intersectRect
    }

    /// 拖动事件处理
    /// - Parameter pan: 拖动手势识别器
    @objc private func dragAction(_ pan: UIPanGestureRecognizer) {
        guard dragEnable else { return } // 如果拖动被禁用，直接返回
        guard superview != nil else { return }

        switch pan.state {
        case .began: // 拖动开始
            // 代理回调：通知开始拖动
            delegate?.dragViewDidBeginDrag?(self)
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()

            // 重置 translation，避免位置叠加
            pan.setTranslation(.zero, in: superview)

        case .changed: // 拖动中
            // 代理回调：通知正在拖动
            delegate?.dragViewIsDuringDrag?(self)

            let point = pan.translation(in: superview)
            let dx: CGFloat
            let dy: CGFloat

            // 根据拖动方向计算位移
            switch dragDirection {
            case .any:
                dx = point.x
                dy = point.y
            case .horizontal:
                dx = point.x
                dy = 0
            case .vertical:
                dx = 0
                dy = point.y
            }

            // 更新视图中心位置
            center = CGPoint(x: center.x + dx, y: center.y + dy)
            if isKeepBounds {
                let midX = effectiveFreeRect().midX
                let currentZone = center.x < midX ? -1 : 1
                if lastHorizontalZone != 0, currentZone != lastHorizontalZone {
                    feedbackGenerator.selectionChanged()
                    feedbackGenerator.prepare()
                }
                lastHorizontalZone = currentZone
            }

            // 重置 translation，避免位置叠加
            pan.setTranslation(.zero, in: superview)

        case .ended: // 拖动结束
            // 保持视图在有效范围内
            let velocity = pan.velocity(in: superview)
            keepBounds(withVelocity: velocity)
            lastHorizontalZone = 0

            // 代理回调：通知拖动结束
            delegate?.dragViewDidEndDrag?(self)

        case .cancelled, .failed:
            lastHorizontalZone = 0
        default:
            break
        }
    }

    // 单击事件处理
    @objc private func clickDragView() {
        // 代理回调：通知单击事件
        delegate?.dragViewDidClick?(self)
    }

    // 保持视图在有效范围内
    private func keepBounds(withVelocity velocity: CGPoint) {
        let freeRect = effectiveFreeRect()
        // 计算中心点
        let centerX = freeRect.origin.x + (freeRect.size.width - frame.size.width) / 2
        var targetX = frame.origin.x
        var targetY = frame.origin.y

        // 判断是否启用自动黏贴边界效果
        if !isKeepBounds {
            // 没有设置黏贴边界效果，左侧
            if frame.origin.x < freeRect.origin.x {
                targetX = freeRect.origin.x
            }
            // 右侧
            else if freeRect.origin.x + freeRect.size.width < frame.origin.x + frame.size.width {
                targetX = freeRect.origin.x + freeRect.size.width - frame.size.width
            }
        } else {
            // 设置了自动黏贴边界效果，左侧
            if frame.origin.x < centerX {
                targetX = freeRect.origin.x
            }
            // 右侧
            else {
                targetX = freeRect.origin.x + freeRect.size.width - frame.size.width
            }
        }

        // 上侧
        if frame.origin.y < freeRect.origin.y {
            targetY = freeRect.origin.y
        }
        // 下侧
        else if freeRect.origin.y + freeRect.size.height < frame.origin.y + frame.size.height {
            targetY = freeRect.origin.y + freeRect.size.height - frame.size.height
        }

        if targetX == frame.origin.x, targetY == frame.origin.y {
            return
        }

        let speed = hypot(velocity.x, velocity.y)
        let duration: TimeInterval = speed > 1800 ? 0.18 : 0.24
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.6,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.frame.origin = CGPoint(x: targetX, y: targetY)
            }
        )
    }
}
