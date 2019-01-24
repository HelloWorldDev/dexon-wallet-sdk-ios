// Copyright DEXON Org. All rights reserved.

import UIKit
import DekuSanSDK

class SignTypedMessageViewController: SignMessageViewController {

    override var defaultMessage: String {
        return """
{"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"Person":[{"name":"name","type":"string"},{"name":"wallet","type":"address"}],"Mail":[{"name":"from","type":"Person"},{"name":"to","type":"Person"},{"name":"contents","type":"string"}]},"primaryType":"Mail","domain":{"name":"Ether Mail","version":"1","chainId":238,"verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"},"message":{"from":{"name":"Cow","wallet":"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"},"to":{"name":"Bob","wallet":"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"},"contents":"Hello, Bob!"}}
"""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func signMessage(fromAddress: String?, messageData: Data) {
        let method = SignTypedMessageMethod(
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
