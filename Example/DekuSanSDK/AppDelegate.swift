// Copyright DEXON Org. All rights reserved.

import UIKit
import DekuSanSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dekuSanWallet = DekuSanSDK(callbackScheme: "example-dekusan", blockchain: .ethereum)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /// Handle wallet results
        if let url = launchOptions?[.url] as? URL {
            return dekuSanWallet.handleCallback(url: url)
        }

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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        /// Handle wallet results
        return dekuSanWallet.handleCallback(url: url)
    }
}

