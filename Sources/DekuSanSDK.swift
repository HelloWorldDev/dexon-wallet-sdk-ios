// Copyright DEXON Org. All rights reserved.

import Foundation
import UIKit

public final class DekuSanSDK {

    private static let walletScheme: String = "DekuSan"

    public static var isAvailable: Bool {
        return UIApplication.shared.canOpenURL(URL(string: "\(walletScheme)://")!)
    }

    private enum QueryItemName: String {
        case id
        case blockchain
        case callback
        case error
    }

    /// The callback URL scheme.
    public let callbackScheme: String

    public let blockchain: Blockchain

    /// The dictionary for mapping id to method
    private var runningMethods = [String: Method]()

    public init(callbackScheme: String, blockchain: Blockchain) {
        self.callbackScheme = callbackScheme
        self.blockchain = blockchain
    }

    public func run(method: Method) {
        let items = [URLQueryItem(name: QueryItemName.id.rawValue, value: Int.random(in: 0 ... 10000000).description),
                     URLQueryItem(name: QueryItemName.blockchain.rawValue, value: blockchain.rawValue),
                     URLQueryItem(name: QueryItemName.callback.rawValue, value: callbackScheme)]

        let url = method.requestURL(scheme: DekuSanSDK.walletScheme, queryItems: items)

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    /// Handles an open URL callback
    ///
    /// - Returns: `true` is the URL was handled; `false` otherwise.
    public func handleCallback(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == callbackScheme,
            components.host == DekuSanSDK.walletScheme else {
            return false
        }

        // find the corresponding method by id
        guard let id = components.valueOfQueryItem(name: QueryItemName.id.rawValue),
            let method = runningMethods[id] else {
            return false
        }

        runningMethods.removeValue(forKey: id)

        return method.handleCallback(url: url)
    }
}
