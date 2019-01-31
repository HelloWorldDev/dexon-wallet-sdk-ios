// Copyright DEXON Org. All rights reserved.

import UIKit
import DekuSanSDK
import AloeStackView

class SignMessageViewController: UIViewController {

    let dekuSanWallet: DekuSanSDK

    var defaultMessage: String {
        return "Any message you wanna sign"
    }

    private lazy var stackView: AloeStackView = {
        let stackView = AloeStackView()
        stackView.hidesSeparatorsByDefault = true
        messageTextView.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        stackView.addRows([
            fromTextField,
            messageTextView,
            signButton,
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

    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        textView.layer.borderWidth = 0.5
        textView.clipsToBounds = true
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.text = defaultMessage
        return textView
    }()

    private lazy var signButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign", for: .normal)
        button.addTarget(self, action: #selector(sign), for: .touchUpInside)
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
    private func sign() {
        guard let message = messageTextView.text else {
            return
        }

        var fromAddress: String?
        if let text = fromTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.count > 2 {
            fromAddress = text
        }

        signMessage(fromAddress: fromAddress, messageData: message.data(using: .utf8)!)
    }

    func signMessage(fromAddress: String?, messageData: Data) {
        let method = SignMessageMethod(
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
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}
