//
//  SwiftExampleViewController.swift
//  ZHHDraggableView_Example
//
//  Created by 桃色三岁 on 2025/02/23.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

import UIKit
import SnapKit
import ZHHDraggableView

class SwiftExampleViewController: UIViewController {
    private lazy var dragView: ZHHDraggableView = {
        let view = ZHHDraggableView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.delegate = self
        view.button.titleLabel?.font = .systemFont(ofSize: 15)
        view.button.setTitle("可拖曳", for: .normal)
        view.button.setTitle("不可拖曳", for: .selected)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.backgroundColor = .orange
        return view
    }()

    private lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15)
        label.text = "打开or关闭黏贴边界效果"
        return label
    }()

    private lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15)
        label.text = "把dragView限定在框内"
        return label
    }()

    private lazy var leftSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(boundsOrNot(_:)), for: .valueChanged)
        return toggle
    }()

    private lazy var rightSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(setFreeRect(_:)), for: .valueChanged)
        return toggle
    }()

    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.

        view.addSubview(leftLabel)
        view.addSubview(rightLabel)
        view.addSubview(tipsLabel)
        view.addSubview(leftSwitch)
        view.addSubview(rightSwitch)
        view.addSubview(containerView)
        view.addSubview(dragView)

        leftSwitch.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-100)
        }
        rightSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-100)
        }
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(leftSwitch)
            make.top.equalTo(leftSwitch.snp.bottom)
        }
        rightLabel.snp.makeConstraints { make in
            make.right.equalTo(rightSwitch)
            make.top.equalTo(rightSwitch.snp.bottom)
        }
        containerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(view.bounds.size.width - 100)
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        dragView.center = view.center

    }

    @objc private func setFreeRect(_ sender: UISwitch) {
        if sender.isOn {
            dragView.freeRect = containerView.frame
        } else {
            dragView.freeRect = view.frame
        }
        containerView.isHidden = !sender.isOn
    }

    @objc private func boundsOrNot(_ sender: UISwitch) {
        dragView.isKeepBounds = sender.isOn
        view.layoutIfNeeded()
    }

    @objc private func hideTips() {
        tipsLabel.isHidden = true
    }

}

extension SwiftExampleViewController: ZHHDraggableViewDelegate {
    /// 点击时的回调
    func dragViewDidClick(_ dragView: ZHHDraggableView) {
        dragView.button.isSelected = dragView.dragEnable
        dragView.dragEnable = !dragView.dragEnable

        tipsLabel.isHidden = false
        tipsLabel.text = dragView.button.titleLabel?.text
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideTips), object: nil)
        perform(#selector(hideTips), with: nil, afterDelay: 2)
    }

    /// 开始拖动时的回调
    func dragViewDidBeginDrag(_ dragView: ZHHDraggableView) {
        tipsLabel.isHidden = false
        tipsLabel.text = "开始拖曳"
    }

    /// 拖动过程中更新的回调
    func dragViewIsDuringDrag(_ dragView: ZHHDraggableView) {
        tipsLabel.isHidden = false
        tipsLabel.text = "拖曳中..."
    }

    /// 结束拖动时的回调
    func dragViewDidEndDrag(_ dragView: ZHHDraggableView) {
        tipsLabel.text = "结束拖曳"
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideTips), object: nil)
        perform(#selector(hideTips), with: nil, afterDelay: 1.5)
    }
}

