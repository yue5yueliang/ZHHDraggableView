//
//  ExampleViewController.swift
//  ZHHDraggableView_Example
//
//  Created by 桃色三岁 on 2025/02/23.
//  Copyright © 2026 桃色三岁. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    private lazy var swiftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Swift 示例", for: .normal)
        button.addTarget(self, action: #selector(openSwiftExample), for: .touchUpInside)
        return button
    }()

    private lazy var ocButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OC 示例", for: .normal)
        button.addTarget(self, action: #selector(openOCExample), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "示例列表"
        view.backgroundColor = .white

        let stack = UIStackView(arrangedSubviews: [swiftButton, ocButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openSwiftExample() {
        navigationController?.pushViewController(SwiftExampleViewController(), animated: true)
    }

    @objc private func openOCExample() {
        let fullName = "ExampleApp.OCExampleViewController"
        let cls = NSClassFromString(fullName) as? UIViewController.Type
            ?? NSClassFromString("OCExampleViewController") as? UIViewController.Type
        guard let cls else {
            return
        }
        navigationController?.pushViewController(cls.init(), animated: true)
    }
}
