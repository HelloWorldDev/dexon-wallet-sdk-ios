// Copyright DEXON Org. All rights reserved.

import UIKit
import DexonWalletSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dexonDXNWallet = DexonWalletSDK(name: "SDK-Example", callbackScheme: "example-dexon-wallet", blockchain: .dexon)
    let dexonETHWallet = DexonWalletSDK(name: "SDK-Example", callbackScheme: "example-dexon-wallet", blockchain: .ethereum)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Handle wallet results
        if let url = launchOptions?[.url] as? URL {
            return dexonDXNWallet.handleCallback(url: url) || dexonETHWallet.handleCallback(url: url)
        }

        window?.rootViewController = UINavigationController(rootViewController: MethodListViewController())
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle wallet results
        return dexonDXNWallet.handleCallback(url: url) || dexonETHWallet.handleCallback(url: url)
    }
}
