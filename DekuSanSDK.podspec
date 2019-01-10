Pod::Spec.new do |s|
  s.name             = 'DekuSanSDK'
  s.version          = '0.1.0'
  s.summary          = 'DekuSan SDK for iOS'

  s.homepage         = 'https://dexon.org/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DEXON Foundation' => 'support@dexon.org' }
  s.source           = { :git => 'https://github.com/dexon-foundation/dekusan-sdk-ios', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/dexonfoundation'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'Sources/**/*.{.swift}'

  s.dependency 'Result'
  s.dependency 'BigInt'
end
