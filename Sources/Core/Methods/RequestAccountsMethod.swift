// Copyright DEXON Org. All rights reserved.

import Foundation
import Result

public final class RequestAccountsMethod: Method {

    public class var name: String {
        return "request-accounts"
    }

    /// return address or error
    public typealias Completion = (Result<String, WalletSDKError>) -> Void

    public enum QueryItemName: String {
        case address
    }

    public var name: String {
        return type(of: self).name
    }

    /// callback from wallet app
    public var completion: Completion?

    public init(completion: @escaping Completion) {
        self.completion = completion
    }

    required public init?(components: URLComponents) {
    }

    public func requestURL(scheme: String, queryItems items: [URLQueryItem] = []) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = name
        components.queryItems = items

        return components.url!
    }

    public func handleCallback(components: URLComponents) -> Bool {
        if let error = handleErrorCallback(components: components) {
            completion?(.failure(error))
            return false
        }

        guard let addressBase64 = components.valueOfQueryItem(name: QueryItemName.address.rawValue),
            let addressData = Data(base64Encoded: addressBase64) else {
                completion?(.failure(WalletSDKError.invalidResponse))
                return false
        }

        let address = addressData.hexEncoded
        completion?(.success(address))
        return true
    }
}

public extension DexonWalletSDK {

    public func requestAccounts(completion: @escaping RequestAccountsMethod.Completion) {
        let method = RequestAccountsMethod(completion: completion)
        run(method: method)
    }
}
