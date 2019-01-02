#
#  Be sure to run `pod spec lint BSAFNetWorking.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "BSAFNetWorking"
  s.version      = "0.0.1"
  s.summary      = "AFNetWorking changed BSAFNetWorking"
  s.description  = <<-DESC
                        封装AFNetWorking 提供提供body体请求（setHTTPBody方式），提供表单格式方式请求（application/x-www-form-urlencoded）
                        目前没有对上传、下载进行封装，后续会补充
                      DESC

  s.homepage        = "https://github.com/BlackStarLang/BSAFNetWorking.git"
  s.author          = { "BlackStar" => "blackstar_lang@163.com" }
  s.ios.deployment_target = '8.0'
  s.source          = { :git => "https://github.com/BlackStarLang/BSAFNetWorking.git", :tag => "v0.0.1"}
  s.source_files    = "BSAFNetWorking/BSAFNetWorking/SQBaseApi/**/*"
  s.framework       = "UIKit"
  s.dependency "AFNetworking", "~> 3.0"
  s.license= { :type => "MIT", :file => "LICENSE" }

  # s.requires_arc  = true
  # s.xcconfig      = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

end
