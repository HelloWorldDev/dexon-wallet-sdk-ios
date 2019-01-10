// Copyright DEXON Org. All rights reserved.

import Foundation
import Result

public class SignMessageMethod: Method {

    /// return signature or error
    public typealias Completion = (Result<String, WalletSDKError>) -> Void

    private enum QueryItemName: String {
        case message
        case from
        case signature
    }

    public var name: String {
        return "sign-message"
    }

    /// Message data
    public var message: Data

    /// Optional address for signing
    public var fromAddress: String?

    /// callback from wallet app
    public var completion: Completion

    public init(message: Data, fromAddress: String? = nil, completion: @escaping Completion) {
        self.message = message
        self.fromAddress = fromAddress
        self.completion = completion
    }

    public func requestURL(scheme: String, queryItems items: [URLQueryItem] = []) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = name

        var queryItems: [URLQueryItem] = items
        queryItems.append(URLQueryItem(name: QueryItemName.message.rawValue, value: message.base64EncodedString()))
        if let fromAddress = fromAddress {
            queryItems.append(URLQueryItem(name: QueryItemName.from.rawValue, value: fromAddress))
        }
        components.queryItems = queryItems

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

        guard let signature = components.valueOfQueryItem(name: QueryItemName.signature.rawValue) else {
            return false
        }

        completion(.success(signature))
        return true
    }
}

public extension DekuSanSDK {

    public func sign(message: String, fromAddress: String? = nil, completion: @escaping SignMessageMethod.Completion) {
        guard let data = message.data(using: .utf8) else {
            completion(.failure(.dataEncoding))
            return
        }

        sign(messageData: data, fromAddress: fromAddress, completion: completion)
    }

    public func sign(messageData: Data, fromAddress: String? = nil, completion: @escaping SignMessageMethod.Completion) {
        let method = SignMessageMethod(message: messageData, fromAddress: fromAddress, completion: completion)
        run(method: method)
    }
}
