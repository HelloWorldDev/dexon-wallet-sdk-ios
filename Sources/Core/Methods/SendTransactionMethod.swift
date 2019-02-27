// Copyright DEXON Org. All rights reserved.

import Foundation
import Result
import BigInt

public class SendTransactionMethod: Method {

    public class var name: String {
        return "send-transaction"
    }

    /// return transaction hash or error
    public typealias Completion = (Result<String, WalletSDKError>) -> Void

    public enum QueryItemName: String {
        case from
        case to
        case amount
        case gasPrice = "gas-price"
        case gasLimit = "gas-limit"
        case nonce
        case data
        case transactionHash = "transaction-hash"
    }

    public var name: String {
        return type(of: self).name
    }

    /// Optional address for signing
    public var fromAddress: String?

    /// to address
    public var toAddress: String

    /// amount to be transferred
    public var amount: BigInt

    /// suggested gas price
    public var gasPrice: BigInt?

    /// suggested gas limit
    public var gasLimit: UInt64?

    /// nonce
    public var nonce: UInt64?

    /// data to be transferred
    public var data: Data?

    /// callback from wallet app
    public var completion: Completion?

    public init(
        fromAddress: String? = nil,
        toAddress: String,
        amount: BigInt,
        gasPrice: BigInt? = nil,
        gasLimit: UInt64? = nil,
        nonce: UInt64? = nil,
        data: Data? = nil,
        completion: @escaping Completion
    ) {
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.amount = amount
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.nonce = nonce
        self.data = data
        self.completion = completion
    }

    required public init?(components: URLComponents) {
        guard let toAddress = components.valueOfQueryItem(name: QueryItemName.to.rawValue) else {
            return nil
        }
        guard let amountText = components.valueOfQueryItem(name: QueryItemName.amount.rawValue),
            let amount = BigInt(amountText) else {
                return nil
        }
        self.fromAddress = components.valueOfQueryItem(name: QueryItemName.from.rawValue)
        self.toAddress = toAddress
        self.amount = amount
        if let gasPriceText = components.valueOfQueryItem(name: QueryItemName.gasPrice.rawValue),
            let gasPrice = BigInt(gasPriceText) {
            self.gasPrice = gasPrice
        }
        if let gasLimitText = components.valueOfQueryItem(name: QueryItemName.gasLimit.rawValue),
            let gasLimit = UInt64(gasLimitText) {
            self.gasLimit = gasLimit
        }
        if let nonceText = components.valueOfQueryItem(name: QueryItemName.nonce.rawValue),
            let nonce = UInt64(nonceText) {
            self.nonce = nonce
        }
        if let dataText = components.valueOfQueryItem(name: QueryItemName.data.rawValue),
            let data = Data(base64Encoded: dataText) {
            self.data = data
        }
    }

    public func requestURL(scheme: String, queryItems items: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = name

        var queryItems: [URLQueryItem] = items
        if let fromAddress = fromAddress {
            queryItems.append(URLQueryItem(name: QueryItemName.from.rawValue, value: fromAddress))
        }
        queryItems.append(URLQueryItem(name: QueryItemName.to.rawValue, value: toAddress))
        queryItems.append(URLQueryItem(name: QueryItemName.amount.rawValue, value: amount.description))
        if let gasPrice = gasPrice {
            queryItems.append(URLQueryItem(name: QueryItemName.gasPrice.rawValue, value: gasPrice.description))
        }
        if let gasLimit = gasLimit {
            queryItems.append(URLQueryItem(name: QueryItemName.gasLimit.rawValue, value: gasLimit.description))
        }
        if let nonce = nonce {
            queryItems.append(URLQueryItem(name: QueryItemName.nonce.rawValue, value: nonce.description))
        }
        if let data = data {
            queryItems.append(URLQueryItem(name: QueryItemName.data.rawValue, value: data.base64EncodedString()))
        }
        components.queryItems = queryItems

        return components.url!
    }

    public func handleCallback(components: URLComponents) -> Bool {
        if let error = handleErrorCallback(components: components) {
            completion?(.failure(error))
            return false
        }

        guard let transactionHash = components.valueOfQueryItem(name: QueryItemName.transactionHash.rawValue) else {
            completion?(.failure(WalletSDKError.invalidResponse))
            return false
        }

        completion?(.success(transactionHash))
        return true
    }
}

public extension DekuSanSDK {

    public func sendTransaction(
        fromAddress: String? = nil,
        toAddress: String,
        amount: BigInt,
        gasPrice: BigInt? = nil,
        gasLimit: UInt64? = nil,
        nonce: UInt64? = nil,
        data: Data? = nil,
        completion: @escaping SendTransactionMethod.Completion
    ) {
        let method = SendTransactionMethod(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: amount,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            nonce: nonce,
            data: data,
            completion: completion)
        run(method: method)
    }
}
