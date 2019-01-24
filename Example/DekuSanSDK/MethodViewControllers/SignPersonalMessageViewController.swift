// Copyright DEXON Org. All rights reserved.

import UIKit
import DekuSanSDK

class SignPersonalMessageViewController: SignMessageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func signMessage(fromAddress: String?, messageData: Data) {
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
