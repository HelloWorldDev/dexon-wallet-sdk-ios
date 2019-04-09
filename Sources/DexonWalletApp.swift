// Copyright DEXON Org. All rights reserved.

import Foundation
import Result
import UIKit

public final class DekuSanWallet {

    public weak var delegate: DekuSanWalletDelegate?

    public init(delegate: DekuSanWalletDelegate) {
        self.delegate = delegate
    }

    /// Handles deep-link wallet commands
    ///
    /// - Parameter url: URL passed to the app
    /// - Returns: `true` if the URL was handled; `false` otherwise
    public func handleOpen(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        let id = components.valueOfQueryItem(name: GeneralQueryItemName.id.rawValue)
        let name: String
        let callback = components.valueOfQueryItem(name: GeneralQueryItemName.callback.rawValue)
        let blockchain: Blockchain

        if let nameText = components.valueOfQueryItem(name: GeneralQueryItemName.name.rawValue) {
            name = nameText
        } else {
            handle(callback: callback, id: id, error: WalletSDKError.invalidRequest)
            return true
        }

        if let blockchainText = components.valueOfQueryItem(name: GeneralQueryItemName.blockchain.rawValue),
            let chain = Blockchain(rawValue: blockchainText) {
            blockchain = chain
        } else {
            handle(callback: callback, id: id, error: WalletSDKError.invalidRequest)
            return true
        }

        switch url.host {
        case RequestAccountsMethod.name:
            if let method = RequestAccountsMethod(components: components) {
                delegate?.requestAccounts(method: method, name: name, blockchain: blockchain, completion: { [weak self] (result) in
                    switch result {
                    case .success(let address):
                        self?.handle(callback: callback, id: id, address: address)
                    case .failure(let error):
                        self?.handle(callback: callback, id: id, error: error)
                    }
                })
            } else {
                handle(callback: callback, id: id, error: WalletSDKError.invalidRequest)
            }
            return true

        case SignMessageMethod.name:
            if let method = SignMessageMethod(components: components) {
                delegate?.signMessage(method, name: name, blockchain: blockchain, completion: { [weak self] (result) in
                    switch result {
                    case .success(let signature):
                        self?.handle(callback: callback, id: id, messageSignature: signature)
                    case .failure(let error):
                        self?.handle(callback: callback, id: id, error: error)
                    }
                })
            } else {
                handle(callback: callback, id: id, error: WalletSDKError.invalidRequest)
            }
            return true

        case SignPersonalMessageMethod.name:
            if let method = SignPersonalMessageMethod(components: components) {
                delegate?.signPersonalMessage(method, name: name, blockchain: blockchain, completion: { [weak self] (result) in
                    switch result {
                    case .success(let signature):
                        self?.handle(callback: callback, id: id, messageSignature: signature)
                    case .failure(let error):
                        self?.handle(callback: callback, id: id, error: error)
                    }
                })
            } else {
                handle(callback: callback, id: id, error: WalletSDKError.invalidRequest)
            }
            return true

        case SignTypedMessageMethod.name:
            if let method = SignTypedMessageMethod(components: components) {
                delegate?.signTypeMessage(method, name: name, blockchain: blockchain, completion: { [weak self] (result) in
                    switch result {
                    case .success(let signature):
                        self?.handle(callback: callback, id: id, messageSignature: signature)
                    case .failure(let error):
                        self?.handle(callback: callback, id: id, error: error)
                    }
                })
            } else {
                handle(callback: callback, id: id, error: WalletSDKError.invalidRequest)
            }
            return true

        case SendTransactionMethod.name:
            if let method = SendTransactionMethod(components: components) {
                delegate?.sendTransaction(method, name: name, blockchain: blockchain, completion: { [weak self] (result) in
                    switch result {
                    case .success(let transactionHash):
                        self?.handle(callback: callback, id: id, transactionHash: transactionHash)
                    case .failure(let error):
                        self?.handle(callback: callback, id: id, error: error)
                    }
                })
            } else {
                handle(callback: callback, id: id, error: WalletSDKError.invalidRequest)
            }
            return true

        default:
            return false
        }
    }

    private func handle(callback: String?, id: String?, error: WalletSDKError) {
        let item = URLQueryItem(name: GeneralQueryItemName.error.rawValue, value: String(error.rawValue))
        handle(callback: callback, id: id, queryItems: [item])
    }

    private func handle(callback: String?, id: String?, address: Data) {
        let item = URLQueryItem(name: RequestAccountsMethod.QueryItemName.address.rawValue, value: address.base64EncodedString())
        handle(callback: callback, id: id, queryItems: [item])
    }

    private func handle(callback: String?, id: String?, messageSignature: Data) {
        let item = URLQueryItem(name: SignMessageMethod.QueryItemName.signature.rawValue, value: messageSignature.base64EncodedString())
        handle(callback: callback, id: id, queryItems: [item])
    }

    private func handle(callback: String?, id: String?, transactionHash: String) {
        let item = URLQueryItem(name: SendTransactionMethod.QueryItemName.transactionHash.rawValue, value: transactionHash)
        handle(callback: callback, id: id, queryItems: [item])
    }

    private func handle(callback: String?, id: String?, queryItems items: [URLQueryItem]) {
        var components = URLComponents()
        components.scheme = callback
        components.host = DexonWalletSDK.walletScheme
        components.queryItems = [URLQueryItem(name: GeneralQueryItemName.id.rawValue, value: id)] + items

        if let url = components.url {
            UIApplication.shared.openURL(url)
        }
    }
}

/// Wallets should implement this delegate to handle requests
public protocol DekuSanWalletDelegate: AnyObject {

    /// Signs a message with the specified address
    ///
    /// - Parameters:
    ///   - method: request accounts method
    ///   - name: dapp name
    ///   - blockchain: specific blockchain
    ///   - completion: completing closure to call with the address or error
    func requestAccounts(method: RequestAccountsMethod, name: String, blockchain: Blockchain, completion: @escaping (Result<Data, WalletSDKError>) -> Void)

    /// Signs a message with the specified address
    ///
    /// - Parameters:
    ///   - method: sign message method, including message data
    ///   - name: dapp name
    ///   - blockchain: specific blockchain
    ///   - completion: completing closure to call with the signature or error
    func signMessage(_ method: SignMessageMethod, name: String, blockchain: Blockchain, completion: @escaping (Result<Data, WalletSDKError>) -> Void)

    /// Signs a personal message with the specified address
    ///
    /// - Parameters:
    ///   - method: sign message method, including personal message data
    ///   - name: dapp name
    ///   - blockchain: specific blockchain
    ///   - completion: completing closure to call with the signature or error
    func signPersonalMessage(_ method: SignPersonalMessageMethod, name: String, blockchain: Blockchain, completion: @escaping (Result<Data, WalletSDKError>) -> Void)

    /// Signs a typed message with the specified address
    ///
    /// - Parameters:
    ///   - method: sign message method, including typed message data
    ///   - name: dapp name
    ///   - blockchain: specific blockchain
    ///   - completion: completing closure to call with the signature or error
    func signTypeMessage(_ method: SignTypedMessageMethod, name: String, blockchain: Blockchain, completion: @escaping (Result<Data, WalletSDKError>) -> Void)

    /// Signs a transaction
    ///
    /// - Parameters:
    ///   - method: send transaction method, including transaction properties
    ///   - name: dapp name
    ///   - blockchain: specific blockchain
    ///   - completion: completing closure to call with the tx or error
    func sendTransaction(_ method: SendTransactionMethod, name: String, blockchain: Blockchain, completion: @escaping (Result<String, WalletSDKError>) -> Void)
}
