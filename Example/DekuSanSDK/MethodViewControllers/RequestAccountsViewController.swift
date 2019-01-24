// Copyright DEXON Org. All rights reserved.

import UIKit
import DekuSanSDK
import AloeStackView

class RequestAccountsViewController: UIViewController {

    private let dekuSanWallet: DekuSanSDK

    private lazy var stackView: AloeStackView = {
        let stackView = AloeStackView()
        stackView.hidesSeparatorsByDefault = true
        stackView.addRows([
            requestAccountsButton,
            resultLabel,
            ])

        return stackView
    }()

    private lazy var requestAccountsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Request Accounts", for: .normal)
        button.addTarget(self, action: #selector(requestAccounts), for: .touchUpInside)
        return button
    }()

    private lazy var resultLabel: UILabel = {
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
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @objc
    private func requestAccounts() {
        let method = RequestAccountsMethod { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let address):
                self.resultLabel.text = "address: \(address)"
            case .failure(let error):
                self.resultLabel.text = "error: \(error)"
            }
        }

        dekuSanWallet.run(method: method)
    }
}
