// Copyright DEXON Org. All rights reserved.

import UIKit
import DekuSanSDK
import BigInt

class ViewController: UIViewController {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 12

        stackView.addArrangedSubview(requestAccountsButton)
        stackView.addArrangedSubview(messageTextField)
        stackView.addArrangedSubview(signMessageButton)
        stackView.addArrangedSubview(signPersonalMessageButton)
        stackView.addArrangedSubview(typedMessageTextView)
        stackView.addArrangedSubview(signTypedMessageButton)
        stackView.addArrangedSubview(sendTransactionButton)

        return stackView
    }()

    private lazy var requestAccountsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Request Accounts", for: .normal)
        button.addTarget(self, action: #selector(requestAccounts), for: .touchUpInside)
        return button
    }()

    private lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = "Any Message you wanna sign"
        return textField
    }()

    private lazy var signMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Message", for: .normal)
        button.addTarget(self, action: #selector(signMessage), for: .touchUpInside)
        return button
    }()

    private lazy var signPersonalMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Personal Message", for: .normal)
        button.addTarget(self, action: #selector(signPersonalMessage), for: .touchUpInside)
        return button
    }()

    private lazy var typedMessageTextView: UITextView = {
        let textView = UITextView()
        textView.text = """
{"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"Person":[{"name":"name","type":"string"},{"name":"wallet","type":"address"}],"Mail":[{"name":"from","type":"Person"},{"name":"to","type":"Person"},{"name":"contents","type":"string"}]},"primaryType":"Mail","domain":{"name":"Ether Mail","version":"1","chainId":238,"verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"},"message":{"from":{"name":"Cow","wallet":"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"},"to":{"name":"Bob","wallet":"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"},"contents":"Hello, Bob!"}}
"""
        return textView
    }()

    private lazy var signTypedMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Typed Message", for: .normal)
        button.addTarget(self, action: #selector(signTypedMessage), for: .touchUpInside)
        return button
    }()

    private lazy var sendTransactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Transaction", for: .normal)
        button.addTarget(self, action: #selector(sendTransaction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setupViews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            ])
    }

    @objc
    private func requestAccounts() {
        guard let dekusanWallet = (UIApplication.shared.delegate as? AppDelegate)?.dekuSanWallet else {
            return
        }

        let method = RequestAccountsMethod { (result) in
            switch result {
            case .success(let address):
                debugPrint("address: \(address)")
            case .failure(let error):
                debugPrint("error: \(error)")
            }
        }

        dekusanWallet.run(method: method)
    }

    @objc
    private func signMessage() {
        guard let message = messageTextField.text else {
            return
        }

        guard let dekusanWallet = (UIApplication.shared.delegate as? AppDelegate)?.dekuSanWallet else {
            return
        }

        dekusanWallet.sign(message: message) { (result) in
            switch result {
            case .success(let signature):
                debugPrint("signature: \(signature)")
            case .failure(let error):
                debugPrint("error: \(error)")
            }
        }
    }

    @objc
    private func signPersonalMessage() {
        guard let message = messageTextField.text else {
            return
        }

        guard let dekusanWallet = (UIApplication.shared.delegate as? AppDelegate)?.dekuSanWallet else {
            return
        }

        dekusanWallet.sign(personalMessage: message) { (result) in
            switch result {
            case .success(let signature):
                debugPrint("signature: \(signature)")
            case .failure(let error):
                debugPrint("error: \(error)")
            }
        }
    }

    @objc
    private func signTypedMessage() {
        guard let message = typedMessageTextView.text else {
            return
        }

        guard let dekusanWallet = (UIApplication.shared.delegate as? AppDelegate)?.dekuSanWallet else {
            return
        }

        dekusanWallet.sign(typedMessage: message) { (result) in
            switch result {
            case .success(let signature):
                debugPrint("signature: \(signature)")
            case .failure(let error):
                debugPrint("error: \(error)")
            }
        }
    }

    @objc
    private func sendTransaction() {
        guard let dekusanWallet = (UIApplication.shared.delegate as? AppDelegate)?.dekuSanWallet else {
            return
        }

        dekusanWallet.sendTransaction(toAddress: "0x06012c8cf97bead5deae237070f9587f8e7a266d", amount: BigInt(2)) { (result) in
            switch result {
            case .success(let signature):
                debugPrint("tx: \(signature)")
            case .failure(let error):
                debugPrint("error: \(error)")
            }
        }
    }
}
