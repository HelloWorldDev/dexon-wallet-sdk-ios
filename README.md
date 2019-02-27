# DekuSanSDK

[![CI Status](https://img.shields.io/travis/dexon-foundation/dekusan-sdk-ios.svg?style=flat)](https://travis-ci.org/dexon-foundation/dekusan-sdk-ios)
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

### Add a scheme for your app

Open Info.plist and add your scheme

```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>{your_scheme}</string>
		</array>
	</dict>
</array>
```

### Handle Callbacks

In your AppDelegate, add the below code:

```swift
import DekuSanSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Handle wallet results
    if let url = launchOptions?[.url] as? URL {
        return dekuSanDXNWallet.handleCallback(url: url) || dekuSanETHWallet.handleCallback(url: url)
    }
    
    ...
    
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    // Handle wallet results
    return dekuSanDXNWallet.handleCallback(url: url) || dekuSanETHWallet.handleCallback(url: url)
}
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

### Web3 Swift Integration

Add one more line to your Podfile and run `pod install`:

```ruby
pod 'DekuSanSDK/Web3'
```

And then init web3 with DekuSanWallet object.

```swift
import DekuSanSDK
import web3swift

let dexonRpcURL = URL(string: "https://api-testnet.dexscan.org/v1/network/rpc")!
web3 = Web3(dexonRpcURL: dexonRpcURL, dekuSanWallet: dekuSanWallet, network: .dexonTestnet)
```

#### Request Accounts

```swift
web3.eth.getAccountsPromise().done { addresses in
    debugPrint(addresses)
}.catch { error in
    debugPrint(error)
}
```

#### Send Personal Message

```swift
web3.personal.signPersonalMessagePromise(message: messageData, from: Address(fromAddress)).done { signature in
    debugPrint(signature)
}.catch { error in
    debugPrint(error)
}
```

#### Send Transaction

```swift
var transaction = EthereumTransaction(to: Address("0x18d9D6d8761fc5E81712e3A0C49A5906AC96bF90"), data: data ?? Data(), options: .default)
transaction.value = BigUInt(1_000_000_000) // 1 Gwei
    
var options = Web3Options()
options.from = Address("0x18d9D6d8761fc5E81712e3A0C49A5906AC96bF90")
options.gasPrice = BigUInt(10)
options.gasLimit = BigUInt(21000)
    
web3.eth.sendTransactionPromise(transaction, options: options).done { result in
    debugPrint("tx: \(result.hash)")
}.catch { error in
    debugPrint(error)
}
```


## License

DekuSanSDK is available under the MIT license. See the LICENSE file for more info.

## Thanks
TrustSDK-iOS and MathWalletSDK-iOS
