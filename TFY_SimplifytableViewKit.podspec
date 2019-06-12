

Pod::Spec.new do |spec|

  spec.name         = "TFY_SimplifytableViewKit"

  spec.version      = "2.0.9"

  spec.summary      = "简化的TableView 一行代码完成所有布局。"

  spec.description  = "简化的TableView 一行代码完成所有布局。"

  spec.homepage     = "https://github.com/13662049573/TFY_SimplifytableView"

  spec.license      = "MIT"
  
  spec.author       = { "tianfengyou" => "420144542@qq.com" }
  
  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/13662049573/TFY_SimplifytableView.git", :tag => spec.version }

  spec.source_files  = "TFY_SimplifytableView/TFY_SimplifytableViewKit/TFY_SimplifytableHeader.h", "TFY_SimplifytableView/TFY_SimplifytableViewKit/**/*.{h,m}"

  spec.frameworks    = "Foundation","UIKit"

  spec.xcconfig      = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include" }

  spec.requires_arc  = true

  

end
