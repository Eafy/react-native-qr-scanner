Pod::Spec.new do |s|

  s.name         = "react-native-scanner-kit"
  s.version      = "0.0.8"
  s.summary      = "QRscanner for React Native"
  s.description  = <<-DESC
  QR Scanner modules and view for React Native(Android & iOS), support react native 0.58+.
                   DESC

  s.homepage     = "https://github.com/Eafy/react-native-scanner-kit"
  s.license      = "MIT"

  s.author       = { "Eafy" => "lizhijian_21@163.com" }
  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source       = { :git => "https://github.com/Eafy/react-native-scanner-kit.git", :tag => "#{s.version}" }

  s.source_files  = "ios/RCTQRScanner/*.{h,m}"

  s.frameworks = "AVFoundation"
  s.dependency "React"
end
