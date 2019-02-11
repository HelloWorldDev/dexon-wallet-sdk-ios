# DekuSanSDK

[![CI Status](https://img.shields.io/travis/dexon-foundation/DekuSanSDK.svg?style=flat)](https://travis-ci.org/dexon-foundation/dekusan-sdk-ios)
[![Version](https://img.shields.io/cocoapods/v/DekuSanSDK.svg?style=flat)](https://cocoapods.org/pods/DekuSanSDK)
[![License](https://img.shields.io/cocoapods/l/DekuSanSDK.svg?style=flat)](https://cocoapods.org/pods/DekuSanSDK)
[![Platform](https://img.shields.io/cocoapods/p/DekuSanSDK.svg?style=flat)](https://cocoapods.org/pods/DekuSanSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## System Requirements

- Deployment target iOS 9.0+
- Xcode 10.0+
- swift 4.2+

## Installation

DekuSanSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DekuSanSDK'
```

## Features

### Reqeust Accounts

```swift
import DekuSanSDK

let dekuSanWallet = DekuSanSDK(name: "SDK-Example", callbackScheme: "example-dekusan", blockchain: .dexon)
dekuSanWallet.requestAccounts { (result) in
    switch result {
    case .success(let address):
        debugPrint(address)
    case .failure(let error):
        debugPrint(error)
    }
}
```

### Sign Message / Personal Message / Typed Message

```swift
import DekuSanSDK

let dekuSanWallet = DekuSanSDK(name: "SDK-Example", callbackScheme: "example-dekusan", blockchain: .dexon)
dekuSanWallet.sign(message: "any message you wanna sign") { (result) in
    switch result {
    case .success(let signature):
        debugPrint(signature)
    case .failure(let error)
        debugPrint(error)
    }
}

// For personal message
// dekuSanWallet.sign(personalMessage:)

// For typed message
// dekuSanWallet.sign(typedMessage:)
```

### Send Transaction

```swift
import DekuSanSDK

let dekuSanWallet = DekuSanSDK(name: "SDK-Example", callbackScheme: "example-dekusan", blockchain: .dexon)
dekuSanWallet.sendTransaction(toAddress: "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a6", amount: 1) { (result) in
    switch result {
    case .success(let tx):
        debugPrint(tx)
    case .failure(let error):
        debugPrint(error)
    }
}
```

## License

DekuSanSDK is available under the MIT license. See the LICENSE file for more info.

## Thanks
TrustSDK-iOS and MathWalletSDK-iOS
