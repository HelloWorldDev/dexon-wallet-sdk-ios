// Copyright DEXON Org. All rights reserved.

import UIKit
import CryptoSwift
import DexonWalletSDK
import AloeStackView
import BigInt
import web3swift

class SendTransactionViewController: UIViewController {

    private let dexonWalletSDK: DexonWalletSDK
    private let callViaWeb3: Bool
    
    private var web3: Web3?

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

    init(dexonWalletSDK: DexonWalletSDK, callViaWeb3: Bool = false) {
        self.dexonWalletSDK = dexonWalletSDK
        self.callViaWeb3 = callViaWeb3
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
        view.endEditing(true)
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
        
        if callViaWeb3 {
            callFromWeb3(fromAddress: fromAddress, toAddress: toAddress, amount: amount, gasPrice: gasPrice, gasLimit: gasLimit, data: data)
        } else {
            callFromSDK(fromAddress: fromAddress, toAddress: toAddress, amount: amount, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, data: data)
        }
    }
    
    private func callFromWeb3(
        fromAddress: String?,
        toAddress: String,
        amount: BigInt,
        gasPrice: BigInt?,
        gasLimit: UInt64?,
        data: Data?
    ) {
        web3 = Web3(dexonRpcURL: URL(string: "https://api-testnet.dexscan.org/v1/network/rpc")!, dexonWallet: dexonWalletSDK, network: .dexonTestnet)!
        var transaction = EthereumTransaction(to: Address(toAddress), data: data ?? Data(), options: .default)
        transaction.value = BigUInt(amount)
        
        var options = Web3Options()
        if let fromAddress = fromAddress {
            options.from = Address(fromAddress)
        }
        if let gasPrice = gasPrice {
            options.gasPrice = BigUInt(gasPrice)
        }
        if let gasLimit = gasLimit {
            options.gasLimit = BigUInt(gasLimit)
        }
        
        web3?.eth.sendTransactionPromise(transaction, options: options).done { [weak self] result in
            self?.resultLabel.text = "tx: \(result.hash)"
        }.catch { [weak self] error in
            self?.resultLabel.text = "error: \(error)"
        }
    }
    
    private func callFromSDK(
        fromAddress: String?,
        toAddress: String,
        amount: BigInt,
        gasPrice: BigInt?,
        gasLimit: UInt64?,
        nonce: UInt64?,
        data: Data?
    ) {
        let method = SendTransactionMethod(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: amount,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            nonce: nonce,
            data: data) { [weak self] (result) in
                switch result {
                case .success(let txHash):
                    self?.resultLabel.text = "tx: \(txHash)"
                case .failure(let error):
                    self?.resultLabel.text = "error: \(error)"
                }
            }

        dexonWalletSDK.run(method: method)
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
