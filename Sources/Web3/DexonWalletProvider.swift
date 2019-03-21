// Copyright DEXON Org. All rights reserved.

import Foundation
import Web3swift
import PromiseKit
import CryptoSwift
import BigInt
#if !COCOAPODS
import DekuSanSDK
#endif

/// DekuSan http provider.
public class DekuSanHTTPProvider: Web3Provider {

    /// dekuSanSDK
    public var dekuSanWallet: DekuSanSDK
    
    public var url: URL
    public var network: Networks?
    public var attachedKeystoreManager: KeystoreManager? = nil
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()
    public init?(_ httpProviderURL: URL, dekuSanWallet: DekuSanSDK, network net: Networks? = nil, keystoreManager manager: KeystoreManager? = nil) {
        self.dekuSanWallet = dekuSanWallet
        do {
            guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else {return nil}
            url = httpProviderURL
            if net == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.getNetwork, parameters: [])
                let response = try DekuSanHTTPProvider.post(request, providerURL: httpProviderURL, queue: DispatchQueue.global(qos: .userInteractive), session: session).wait()
                if response.error != nil {
                    if response.message != nil {
                        print(response.message!)
                    }
                    return nil
                }
                guard let result: String = response.getValue(), let intNetworkNumber = Int(result) else {return nil}
                network = Networks.Custom(networkID: BigUInt(intNetworkNumber))
                if network == nil {return nil}
            } else {
                network = net
            }
        } catch {
            return nil
        }
        attachedKeystoreManager = manager
    }
    
    static func post(_ request: JSONRPCrequest, providerURL: URL, queue: DispatchQueue = .main, session: URLSession) -> Promise<JSONRPCresponse> {
        let rp = Promise<Data>.pending()
        var task: URLSessionTask? = nil
        queue.async {
            do {
                let encoder = JSONEncoder()
                let requestData = try encoder.encode(request)
                var urlRequest = URLRequest(url: providerURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                urlRequest.httpBody = requestData
                task = session.dataTask(with: urlRequest){ (data, response, error) in
                    guard error == nil else {
                        rp.resolver.reject(error!)
                        return
                    }
                    guard data != nil else {
                        rp.resolver.reject(Web3Error.nodeError(desc: "Node response is empty"))
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
        }.map(on: queue){ (data: Data) throws -> JSONRPCresponse in
            let parsedResponse = try JSONDecoder().decode(JSONRPCresponse.self, from: data)
            if parsedResponse.error != nil {
                throw Web3Error.nodeError(desc: "Received an error message from node\n" + String(describing: parsedResponse.error!))
            }
            return parsedResponse
        }
    }
    
    static func post(_ request: JSONRPCrequestBatch, providerURL: URL, queue: DispatchQueue = .main, session: URLSession) -> Promise<JSONRPCresponseBatch> {
        fatalError("DekuSan provider doesn't support batch request")
    }
    
    public func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue = .main) -> Promise<JSONRPCresponse> {
        guard let method = request.method else {
            return Promise(error: Web3Error.nodeError(desc: "RPC method is nill"))
        }

        switch method {
        case .getAccounts:
            return requestAccounts(request, queue: queue)
        case .personalSign:
            return personalSign(request, queue: queue)
        case .sendTransaction:
            return sendTransaction(request, queue: queue)
        default:
            return DekuSanHTTPProvider.post(request, providerURL: url, queue: queue, session: session)
        }
    }
    
    public func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue = .main) -> Promise<JSONRPCresponseBatch> {
        return DekuSanHTTPProvider.post(requests, providerURL: url, queue: queue, session: self.session)
    }

    private func requestAccounts(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse> {
        let rp = Promise<String>.pending()
        queue.async { [weak self] in
            guard let self = self else {
                rp.resolver.reject(Web3Error.inputError(desc: "DexonWalletProvider has been released"))
                return
            }

            self.dekuSanWallet.requestAccounts { (result) in
                switch result {
                case .success(let account):
                    rp.resolver.fulfill(account)

                case .failure(let error):
                    rp.resolver.reject(error)
                }
            }
        }
        return rp.promise.map(on: queue) { (account) -> JSONRPCresponse in
            return JSONRPCresponse(id: Int(request.id), jsonrpc: request.jsonrpc, result: [account], error: nil)
        }
    }

    private func personalSign(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse> {
        let rp = Promise<String>.pending()
        queue.async { [weak self] in
            guard let self = self else {
                rp.resolver.reject(Web3Error.inputError(desc: "DexonWalletProvider has been released"))
                return
            }
            
            guard request.params?.params.count == 2,
                let address = request.params?.params[0] as? String,
                let hexMessage = request.params?.params[1] as? String else {
                rp.resolver.reject(Web3Error.inputError(desc: "wrong request parameters"))
                return
            }

            let data = Data(hex: hexMessage.drop0x)

            self.dekuSanWallet.sign(personalMessageData: data, fromAddress: address, completion: { (result) in
                switch result {
                case .success(let signature):
                    rp.resolver.fulfill(signature)

                case .failure(let error):
                    rp.resolver.reject(error)
                }
            })
        }
        return rp.promise.map(on: queue) { (signature) -> JSONRPCresponse in
            return JSONRPCresponse(id: Int(request.id), jsonrpc: request.jsonrpc, result: signature, error: nil)
        }
    }

    private func sendTransaction(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse> {
        let rp = Promise<String>.pending()
        queue.async { [weak self] in
            guard let self = self else {
                rp.resolver.reject(Web3Error.inputError(desc: "DexonWalletProvider has been released"))
                return
            }

            guard let parameters = request.params?.params.first as? TransactionParameters else {
                rp.resolver.reject(Web3Error.inputError(desc: "wrong request parameters"))
                return
            }

            guard let toAddress = parameters.to else {
                rp.resolver.reject(Web3Error.inputError(desc: "wrong request parameter type"))
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
                data = Data(hex: dataHex)
            } else {
                data = nil
            }

            self.dekuSanWallet.sendTransaction(
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
        return rp.promise.map(on: queue) { (txHash) -> JSONRPCresponse in
            return JSONRPCresponse(id: Int(request.id), jsonrpc: request.jsonrpc, result: txHash, error: nil)
        }
    }
}

public extension Web3 {
    
    public static func new(dexonRpcURL: URL, dekuSanWallet: DekuSanSDK, network: Networks = Networks.Custom(networkID: 237)) -> web3? {
        guard let provider = DekuSanHTTPProvider(dexonRpcURL, dekuSanWallet: dekuSanWallet, network: network) else { return nil }
        let dispatcher = JSONRPCrequestDispatcher(provider: provider, queue: DispatchQueue.global(qos: .userInteractive), policy: .NoBatching)
        return web3(provider: provider, queue: nil, requestDispatcher: dispatcher)
    }
}
