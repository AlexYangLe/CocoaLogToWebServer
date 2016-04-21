Pod::Spec.new do |s|

  s.name         = "CocoaLogToWebServer"
  s.version      = "1.0.0"
  s.summary      = "通过使用CocoaLumberjack 和GCDWebServer实现日志NSLog打印的重定向，并且可以使用浏览器访问日志"
  s.description  = <<-DESC
  通过使用CocoaLumberjack 和GCDWebServer实现日志NSLog打印>    的重定向，并且可以使用浏览器访问日志
                   DESC

  s.homepage     = "https://github.com/yanduhantan563/CocoaLogToWebServer"

  s.license      = "MIT"

  s.author       = { "yanduhantan563" => "yanduhantan563@sina.com" }
  s.source       = { :git => "https://github.com/yanduhantan563/CocoaLogToWebServer.git", :commit => "ebf02ee7068571b24453ede54a6d01ae02641c9b", :tag => "1.0.0" }
  s.requires_arc = true
  s.source_files = 'CocoaLogToWebServer/Classes/**/*'
  s.library = 'sqlite3', 'z', 'xml2'
  s.frameworks = "MobileCoreServices","CFNetwork"
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "5.0"

  s.resource  = "CocoaLogToWebServer/Classes/template.html"
  s.public_header_files = "CocoaLogToWebServer/Classes/Common.h"
  # s.prefix_header_contents = "CocoaLogToWebServer/Classes/CocoaLogToWebServerPrefix.pch"
  # s.prefix_header_contents = "CocoaLogToWebServer/Classes/*.pch"
  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"
end
