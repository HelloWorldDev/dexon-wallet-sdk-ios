Pod::Spec.new do |s|
  s.name             = 'DekuSanSDK'
  s.version          = '0.2.0'
  s.summary          = 'DekuSan SDK for iOS'

  s.homepage         = 'https://dexon.org/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DEXON Foundation' => 'support@dexon.org' }
  s.source           = { :git => 'https://github.com/dexon-foundation/dekusan-sdk-ios.git', :tag => "v#{ s.version.to_s }" }
  s.social_media_url = 'https://twitter.com/dexonfoundation'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
  
  s.default_subspecs = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Core/**/*.{swift}'

    ss.dependency 'Result', '~> 4.0.0'
    ss.dependency 'BigInt', '~> 3.1.0'
  end
  
  s.subspec 'Web3' do |ss|
    ss.source_files = 'Sources/Web3/**/*.{swift}'

    ss.dependency 'DekuSanSDK/Core', '~> 0.2.0'
    ss.dependency 'CryptoSwift', '~> 0.14.0'
    ss.dependency 'web3swift', '~> 2.0.0'
  end
end
