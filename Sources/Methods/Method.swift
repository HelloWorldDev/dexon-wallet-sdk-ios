// Copyright DEXON Org. All rights reserved.

import Foundation

public protocol Method {

    /// Method name
    var name: String { get }

    /// Wallet request URL
    func requestURL(scheme: String, queryItems items: [URLQueryItem]) -> URL

    /// Handles a callback URL
    func handleCallback(url: URL) -> Bool
}

private enum QueryItemName: String {
    case error
}

public extension Method {

    public func handleErrorCallback(components: URLComponents) -> WalletSDKError? {
        if let value = components.queryItems?.first(where: { $0.name == QueryItemName.error.rawValue })?.value,
            let errorCode = Int(value),
            let error = WalletSDKError(rawValue: errorCode) {
            return error
        }

        return nil
    }
}
