// Copyright DEXON Org. All rights reserved.

import Foundation
import web3swift
import PromiseKit
import CryptoSwift
import BigInt
#if !COCOAPODS
import DexonWalletSDK
#endif

/// Dexon wallet http provider.
public class DexonWalletProvider: Web3Provider {
    /// node url address
    public var url: URL
    /// dexon wallet
    public var dexonWallet: DexonWalletSDK
    /// network id which used for local signing
    public var network: NetworkId?
    /// keystore manager which contains private keys
    public var attachedKeystoreManager: KeystoreManager
    /// url session
    public var session = URLSession(configuration: .default)
    
    /// default init with any address and network id. works with infura, localnode and any other node
    public init?(_ httpProviderURL: URL, dexonWallet: DexonWalletSDK, network net: NetworkId? = nil, keystoreManager manager: KeystoreManager = KeystoreManager()) {
        self.dexonWallet = dexonWallet
        do {
            guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else { return nil }
            url = httpProviderURL
            if net == nil {
                let request = JsonRpcRequest(method: .getNetwork)
                let response = try DexonWalletProvider.post(request, providerURL: httpProviderURL, queue: DispatchQueue.global(qos: .userInteractive), session: session).wait()
                if response.error != nil {
                    if response.message != nil {
                        print(response.message!)
                    }
                    return nil
                }
                guard let result: String = response.getValue(), let intNetworkNumber = Int(result) else { return nil }
                network = NetworkId(intNetworkNumber)
                if network == nil { return nil }
            } else {
                network = net
            }
        } catch {
            return nil
        }
        attachedKeystoreManager = manager
    }
    
    static func post(_ request: JsonRpcRequest, providerURL: URL, queue: DispatchQueue = .main, session: URLSession) -> Promise<JsonRpcResponse> {
        let rp = Promise<Data>.pending()
        var task: URLSessionTask?
        queue.async {
            do {
                let encoder = JSONEncoder()
                let requestData = try encoder.encode(request)
                var urlRequest = URLRequest(url: providerURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                urlRequest.httpBody = requestData
                task = session.dataTask(with: urlRequest) { data, _, error in
                    guard error == nil else {
                        rp.resolver.reject(error!)
                        return
                    }
                    guard data != nil else {
                        rp.resolver.reject(Web3Error.nodeError("Node response is empty"))
                        return
                    }
                    rp.resolver.fulfill(data!)
                }
                task?.resume()
            } catch {
                rp.resolver.reject(error)
            }
        }
        return rp.promise.ensure(on: queue) {
            task = nil
        }.map(on: queue) { (data: Data) throws -> JsonRpcResponse in
            let parsedResponse = try JSONDecoder().decode(JsonRpcResponse.self, from: data)
            if parsedResponse.error != nil {
                throw Web3Error.nodeError("Received an error message from node\n" + String(describing: parsedResponse.error!))
            }
            return parsedResponse
        }
    }
    
    static func post(_ request: JsonRpcRequestBatch, providerURL: URL, queue: DispatchQueue = .main, session: URLSession) -> Promise<JsonRpcResponseBatch> {
        fatalError("Dexon Wallet Provider doesn't support batch request")
    }
    
    public func sendAsync(_ request: JsonRpcRequest, queue: DispatchQueue = .main) -> Promise<JsonRpcResponse> {
        switch request.method {
        case JsonRpcMethod.getAccounts:
            return requestAccounts(request, queue: queue)
        case JsonRpcMethod.personalSign:
            return personalSign(request, queue: queue)
        case JsonRpcMethod.sendTransaction:
            return sendTransaction(request, queue: queue)
        default:
            return DexonWalletProvider.post(request, providerURL: url, queue: queue, session: session)
        }
    }
    
    public func sendAsync(_ requests: JsonRpcRequestBatch, queue: DispatchQueue = .main) -> Promise<JsonRpcResponseBatch> {
        return DexonWalletProvider.post(requests, providerURL: url, queue: queue, session: session)
    }
    
    private func requestAccounts(_ request: JsonRpcRequest, queue: DispatchQueue) -> Promise<JsonRpcResponse> {
        let rp = Promise<String>.pending()
        queue.async { [weak self] in
            guard let self = self else {
                rp.resolver.reject(Web3Error.inputError("DexonWalletProvider has been released"))
                return
            }
            
            self.dexonWallet.requestAccounts { (result) in
                switch result {
                case .success(let account):
                    rp.resolver.fulfill(account)
                    
                case .failure(let error):
                    rp.resolver.reject(error)
                }
            }
        }
        return rp.promise.map(on: queue) { (account) -> JsonRpcResponse in
            return JsonRpcResponse(id: request.id, jsonrpc: request.jsonrpc, result: [account], error: nil)
        }
    }
    
    private func personalSign(_ request: JsonRpcRequest, queue: DispatchQueue) -> Promise<JsonRpcResponse> {
        let rp = Promise<String>.pending()
        queue.async { [weak self] in
            guard let self = self else {
                rp.resolver.reject(Web3Error.inputError("DexonWalletProvider has been released"))
                return
            }
            
            guard request.params.params.count == 2,
                let address = request.params.params[0] as? String,
                let hexMessage = request.params.params[1] as? String else {
                rp.resolver.reject(Web3Error.inputError("wrong request parameters"))
                return
            }
            
            let data = Data(hex: hexMessage.drop0x)
            
            self.dexonWallet.sign(personalMessageData: data, fromAddress: address, completion: { (result) in
                switch result {
                case .success(let signature):
                    rp.resolver.fulfill(signature)
                    
                case .failure(let error):
                    rp.resolver.reject(error)
                }
            })
        }
        return rp.promise.map(on: queue) { (signature) -> JsonRpcResponse in
            return JsonRpcResponse(id: request.id, jsonrpc: request.jsonrpc, result: signature, error: nil)
        }
    }
    
    private func sendTransaction(_ request: JsonRpcRequest, queue: DispatchQueue) -> Promise<JsonRpcResponse> {
        let rp = Promise<String>.pending()
        queue.async { [weak self] in
            guard let self = self else {
                rp.resolver.reject(Web3Error.inputError("DexonWalletProvider has been released"))
                return
            }
            
            guard let parameters = request.params.params.first as? TransactionParameters else {
                rp.resolver.reject(Web3Error.inputError("wrong request parameters"))
                return
            }
            
            guard let toAddress = parameters.to else {
                rp.resolver.reject(Web3Error.inputError("wrong request parameter type"))
                return
            }
            
            let amount: BigInt
            if let valueHex = parameters.value {
                amount = BigInt(valueHex.drop0x, radix: 16) ?? 0
            } else {
                amount = 0
            }
            
            let gasPrice: BigInt?
            if let gasPriceHex = parameters.gasPrice {
                gasPrice = BigInt(gasPriceHex.drop0x, radix: 16)
            } else {
                gasPrice = nil
            }
            
            let gasLimit: UInt64?
            if let gasPriceHex = parameters.gas {
                gasLimit = UInt64(gasPriceHex.drop0x, radix: 16)
            } else {
                gasLimit = nil
            }
            
            let data: Data?
            if let dataHex = parameters.data {
                data = dataHex.hex
            } else {
                data = nil
            }
            
            self.dexonWallet.sendTransaction(
                fromAddress: parameters.from,
                toAddress: toAddress,
                amount: amount,
                gasPrice: gasPrice,
                gasLimit: gasLimit,
                nonce: nil,
                data: data,
                completion: { (result) in
                switch result {
                case .success(let txHash):
                    rp.resolver.fulfill(txHash)
                    
                case .failure(let error):
                    rp.resolver.reject(error)
                }
            })
        }
        return rp.promise.map(on: queue) { (txHash) -> JsonRpcResponse in
            return JsonRpcResponse(id: request.id, jsonrpc: request.jsonrpc, result: txHash, error: nil)
        }
    }
}

public extension Web3 {
    
    public convenience init?(dexonRpcURL: URL, dexonWallet: DexonWalletSDK, network: NetworkId? = nil) {
        guard let provider = DexonWalletProvider(dexonRpcURL, dexonWallet: dexonWallet, network: network) else { return nil }
        let dispatcher = JsonRpcRequestDispatcher(provider: provider, queue: DispatchQueue.global(qos: .userInteractive), policy: .NoBatching)
        self.init(provider: provider, queue: nil, requestDispatcher: dispatcher)
    }
}

