// Copyright DEXON Org. All rights reserved.

import UIKit
import DekuSanSDK
import web3swift

class SignPersonalMessageViewController: SignMessageViewController {
    
    private var web3: Web3?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func signMessage(fromAddress: String?, messageData: Data) {
        if callViaWeb3 {
            callFromWeb3(fromAddress: fromAddress, messageData: messageData)
        } else {
            callFromSDK(fromAddress: fromAddress, messageData: messageData)
        }
    }
    
    private func callFromWeb3(fromAddress: String?, messageData: Data) {
        guard let fromAddress = fromAddress else {
            self.resultLabel.text = "need to fill the address in"
            return
        }
        web3 = Web3(dexonRpcURL: URL(string: "https://api-testnet.dexscan.org/v1/network/rpc")!, dekuSanWallet: dekuSanWallet, network: .dexonTestnet)!
        web3?.personal.signPersonalMessagePromise(message: messageData, from: Address(fromAddress)).done { [weak self] signature in
            self?.resultLabel.text = "signature: 0x\(signature.hex)"
        }.catch { [weak self] error in
            self?.resultLabel.text = "error: \(error)"
        }
    }
    
    private func callFromSDK(fromAddress: String?, messageData: Data) {
        let method = SignPersonalMessageMethod(
            message: messageData,
            fromAddress: fromAddress) { [weak self] (result) in
                switch result {
                case .success(let signature):
                    self?.resultLabel.text = "signature: \(signature)"
                case .failure(let error):
                    self?.resultLabel.text = "error: \(error)"
                }
        }

        dekuSanWallet.run(method: method)
    }
}
