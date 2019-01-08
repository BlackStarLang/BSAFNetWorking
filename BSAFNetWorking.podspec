#
#  Be sure to run `pod spec lint BSAFNetWorking.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "BSAFNetWorking"
  s.version      = "0.1.0"
  s.summary      = "AFNetWorking changed BSAFNetWorking"
  s.description  = <<-DESC
                        封装AFNetWorking 提供提供body体请求（setHTTPBody方式），提供表单格式方式请求（application/x-www-form-urlencoded）
                        提供上传、下载、普通网络请求
                      DESC

  s.homepage        = "https://github.com/BlackStarLang/BSAFNetWorking.git"
  s.author          = { "BlackStar" => "blackstar_lang@163.com" }
  s.platform        = :ios, "8.0"
  s.source          = { :git => "https://github.com/BlackStarLang/BSAFNetWorking.git", :tag => s.version, :submodules => true}
  s.source_files    = "BSAFNetWorking/SQBaseApi/BSAFNetwroking.h"
  s.public_header_files    = "BSAFNetWorking/SQBaseApi/BSAFNetwroking.h"
  s.framework       = "UIKit"
  s.dependency "AFNetworking", "~> 3.0"
  s.license= { :type => "MIT", :file => "LICENSE" }

  s.subspec 'BSApi' do |ss|
    ss.source_files = "BSAFNetWorking/SQBaseApi/BSApi/*"
    ss.framework    = "UIKit"
end

end
