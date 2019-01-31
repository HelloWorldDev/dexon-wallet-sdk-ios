// Copyright DEXON Org. All rights reserved.

import UIKit
import CryptoSwift
import DekuSanSDK
import AloeStackView
import BigInt

class SendTransactionViewController: UIViewController {

    private let dekuSanWallet: DekuSanSDK

    private lazy var stackView: AloeStackView = {
        let stackView = AloeStackView()
        stackView.hidesSeparatorsByDefault = true
        stackView.addRows([
            fromTextField,
            toTextField,
            amountTextField,
            gasPriceTextField,
            gasLimitTextField,
            nonceTextField,
            dataTextField,
            sendButton,
            resultLabel,
            ])

        return stackView
    }()

    private lazy var fromTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = ""
        textField.placeholder = "From address (optional), e.g. 0x1a2b..."
        return textField
    }()

    private lazy var toTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = "0x18d9D6d8761fc5E81712e3A0C49A5906AC96bF90"
        textField.placeholder = "To address (required), e.g. 0x1a2b..."
        return textField
    }()

    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = "2000000000000000000" // 2 DXN or 2 ETH
        textField.placeholder = "Amount (required), e.g. 2000000000000000000"
        return textField
    }()

    private lazy var gasPriceTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = ""
        textField.placeholder = "Gas Price (optional), e.g. 1000000000" // 1 Gwei
        return textField
    }()

    private lazy var gasLimitTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = ""
        textField.placeholder = "Gas Limit (optional), e.g. 21000"
        return textField
    }()

    private lazy var nonceTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = ""
        textField.placeholder = "Nonce (optional), e.g. 0"
        return textField
    }()

    private lazy var dataTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = ""
        textField.placeholder = "Data (optional), e.g. 0x1a2b..."
        return textField
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        return button
    }()

    lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    init(dekuSanWallet: DekuSanSDK) {
        self.dekuSanWallet = dekuSanWallet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @objc
    private func send() {
        guard let toAddress = toTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), toAddress.count > 2 else {
            resultLabel.text = "fill in toAddress"
            return
        }

        guard let text = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let amount = BigInt(text) else {
            resultLabel.text = "fill in amount"
            return
        }

        var fromAddress: String?
        if let text = fromTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.count > 2 {
            fromAddress = text
        }

        var gasPrice: BigInt?
        if let text = gasPriceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            gasPrice = BigInt(text)
        }

        var gasLimit: UInt64?
        if let text = gasLimitTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            gasLimit = UInt64(text)
        }

        var nonce: UInt64?
        if let text = nonceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            nonce = UInt64(text)
        }

        var data: Data?
        if let text = dataTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            data = Data(hex: text.drop0x)
        }

        let method = SendTransactionMethod(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: amount,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            nonce: nonce,
            data: data) { [weak self] (result) in
                switch result {
                case .success(let signature):
                    self?.resultLabel.text = "tx: \(signature)"
                case .failure(let error):
                    self?.resultLabel.text = "error: \(error)"
                }
            }

        dekuSanWallet.run(method: method)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

private extension Data {
    init(hex: String) {
        self.init(bytes: Array<UInt8>(hex: hex))
    }
}

private extension String {
    var drop0x: String {
        if hasPrefix("0x") {
            return String(dropFirst(2))
        }
        return self
    }
}
