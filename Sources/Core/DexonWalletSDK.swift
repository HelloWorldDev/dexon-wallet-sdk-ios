// Copyright DEXON Org. All rights reserved.

import Foundation
import UIKit

public final class DexonWalletSDK {

    public static let walletScheme: String = "dexon-wallet"

    public static var isAvailable: Bool {
        return UIApplication.shared.canOpenURL(URL(string: "\(walletScheme)://")!)
    }

    /// The dapp name sent to Dexon Wallet app
    public let name: String

    /// The callback URL scheme.
    public let callbackScheme: String

    /// blockchain type
    public let blockchain: Blockchain

    /// The dictionary for mapping id to method
    private var runningMethods = [String: Method]()

    public init(name: String, callbackScheme: String, blockchain: Blockchain) {
        self.name = name
        self.callbackScheme = callbackScheme
        self.blockchain = blockchain
    }

    public func run(method: Method) {
        let id = Int.random(in: 0 ... 10000000).description
        let items = [URLQueryItem(name: GeneralQueryItemName.id.rawValue, value: id),
                     URLQueryItem(name: GeneralQueryItemName.blockchain.rawValue, value: blockchain.rawValue),
                     URLQueryItem(name: GeneralQueryItemName.callback.rawValue, value: callbackScheme),
                     URLQueryItem(name: GeneralQueryItemName.name.rawValue, value: name)]

        let url = method.requestURL(scheme: type(of: self).walletScheme, queryItems: items)
        runningMethods[id] = method
        DispatchQueue.main.safeAsync {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    /// Handles an open URL callback
    ///
    /// - Returns: `true` is the URL was handled; `false` otherwise.
    public func handleCallback(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == callbackScheme,
            components.host == type(of: self).walletScheme else {
            return false
        }

        // find the corresponding method by id
        guard let id = components.valueOfQueryItem(name: GeneralQueryItemName.id.rawValue),
            let method = runningMethods[id] else {
            return false
        }

        runningMethods.removeValue(forKey: id)
        return method.handleCallback(components: components)
    }
}
