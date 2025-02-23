Pod::Spec.new do |s|
  s.name             = 'ZHHDraggableView'
  s.version          = '0.0.1'
  s.summary          = 'ZHHDraggableView 提供可拖动和悬浮的视图，类似 iOS 的 AssistiveTouch 功能。'

  # 详细描述 pod 的功能、用途及特点
  s.description      = <<-DESC
ZHHDraggableView 让你可以将任意视图变为可拖动并悬浮在屏幕上的元素，
其行为与 iOS 中的 AssistiveTouch 类似。它支持自定义拖动行为，适用于创建悬浮按钮、拖动视图或需要常驻屏幕的 UI 组件。
这个库为交互式应用提供了更多的灵活性，可以使视图随意悬浮并拖动到任何位置。
  DESC

  s.homepage         = 'https://github.com/yueyueliang/ZHHDraggableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '桃色三岁' => '136769890@qq.com' }
  s.source           = { :git => 'https://github.com/yue5yueliang/ZHHDraggableView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'

  # 源文件路径，指明需要包含的源代码文件
  s.source_files = 'ZHHDraggableView/Classes/**/*'

  # 如果需要包含资源文件，可以通过下面的代码添加
  # s.resource_bundles = {
  #   'ZHHDraggableView' => ['ZHHDraggableView/Assets/*.png']
  # }

  # 如果有公共的头文件，可以指定公共头文件路径
  # s.public_header_files = 'Pod/Classes/**/*.h'

  # 如果库依赖其他框架，可以在这里声明依赖
  # s.frameworks = 'UIKit', 'MapKit'

  # 如果库依赖其他第三方 pod，可以通过 s.dependency 来声明
  # s.dependency 'AFNetworking', '~> 2.3'
end
