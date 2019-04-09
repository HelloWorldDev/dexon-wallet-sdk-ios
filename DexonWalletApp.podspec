Pod::Spec.new do |s|
  s.name             = 'DexonWalletApp'
  s.version          = '0.3.0'
  s.summary          = 'DEXON Wallet SDK for App'

  s.homepage         = 'https://dexon.org/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DEXON Foundation' => 'support@dexon.org' }
  s.source           = { :git => 'https://github.com/dexon-foundation/dexon-wallet-sdk-ios.git', :tag => "v#{ s.version.to_s }" }
  s.social_media_url = 'https://twitter.com/dexonfoundation'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'Sources/Core/**/*.{swift}', 'Sources/DexonWalletApp.swift'

  s.dependency 'Result'
  s.dependency 'BigInt'
end
