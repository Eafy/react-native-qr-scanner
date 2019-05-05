Pod::Spec.new do |s|

  s.name         = "react-native-scanner-kit"
  s.version      = "0.0.5"
  s.summary      = "QRscanner for React Native"

  s.description  = <<-DESC
  QR Scanner modules and view for React Native(Android & iOS), support react native 0.58+.
                   DESC

  s.homepage     = "https://github.com/Eafy/react-native-scanner-kit"
  #s.screenshots  = "https://raw.githubusercontent.com/eafy/react-native-scanner-kit/master/images/android.jpg", "https://raw.githubusercontent.com/eafy/react-native-scanner-kit/master/images/ios.jpg"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Eafy" => "lizhijian_21@163.com" }
  # s.authors            = { "Eafy" => "lizhijian_21@163.com" }
  # s.social_media_url   = "https://github.com/Eafy"

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/Eafy/react-native-scanner-kit.git", :tag => "#{s.version}" }

  s.source_files  = "ios/RCTQRScanner/**/*.{h,m}"
  s.exclude_files = ""

  # s.public_header_files = "**/*.h"

  s.frameworks = "AVFoundation"

  s.dependency "React"
end
