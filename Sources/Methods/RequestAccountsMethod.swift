// Copyright DEXON Org. All rights reserved.

import Foundation
import Result

public final class RequestAccountsMethod: Method {

    /// return address or error
    public typealias Completion = (Result<String, WalletSDKError>) -> Void

    private enum QueryItemName: String {
        case address
    }

    public var name: String {
        return "request-accounts"
    }

    /// callback from wallet app
    public var completion: Completion

    public init(completion: @escaping Completion) {
        self.completion = completion
    }

    public func requestURL(scheme: String, queryItems items: [URLQueryItem] = []) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = name
        components.queryItems = items

        return components.url!
    }

    public func handleCallback(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        if let error = handleErrorCallback(components: components) {
            completion(.failure(error))
            return false
        }

        guard let address = components.valueOfQueryItem(name: QueryItemName.address.rawValue) else {
            return false
        }

        completion(.success(address))
        return true
    }
}

public extension DekuSanSDK {

    public func requestAccounts(completion: @escaping RequestAccountsMethod.Completion) {
        let method = RequestAccountsMethod(completion: completion)
        run(method: method)
    }
}
