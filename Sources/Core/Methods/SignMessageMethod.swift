// Copyright DEXON Org. All rights reserved.

import Foundation
import Result

public class SignMessageMethod: Method {

    public class var name: String {
        return "sign-message"
    }

    /// return signature or error
    public typealias Completion = (Result<String, WalletSDKError>) -> Void

    public enum QueryItemName: String {
        case message
        case from
        case signature
    }

    public var name: String {
        return type(of: self).name
    }

    /// Message data
    public var message: Data

    /// Optional address for signing
    public var fromAddress: String?

    /// callback from wallet app
    public var completion: Completion?

    public init(message: Data, fromAddress: String? = nil, completion: @escaping Completion) {
        self.message = message
        self.fromAddress = fromAddress
        self.completion = completion
    }

    required public init?(components: URLComponents) {
        guard let message = components.valueOfQueryItem(name: QueryItemName.message.rawValue).flatMap({ Data(base64Encoded: $0) }) else {
            return nil
        }

        if let fromAddress = components.valueOfQueryItem(name: QueryItemName.from.rawValue) {
            self.fromAddress = fromAddress
        }

        self.message = message
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

    public func handleCallback(components: URLComponents) -> Bool {
        if let error = handleErrorCallback(components: components) {
            completion?(.failure(error))
            return false
        }

        guard let signatureBase64 = components.valueOfQueryItem(name: QueryItemName.signature.rawValue),
            let signatureData = Data(base64Encoded: signatureBase64) else {
                completion?(.failure(WalletSDKError.invalidResponse))
                return false
        }

        let signature = signatureData.hexEncoded
        completion?(.success(signature))
        return true
    }
}

public extension DexonWalletSDK {

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
