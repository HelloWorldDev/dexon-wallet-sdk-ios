// Copyright DEXON Org. All rights reserved.

import UIKit
import DexonWalletSDK
import AloeStackView
import web3swift

class RequestAccountsViewController: UIViewController {

    private let dexonWalletSDK: DexonWalletSDK
    private let callViaWeb3: Bool
    
    private var web3: Web3?
    
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
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @objc
    private func requestAccounts() {
        view.endEditing(true)
        if callViaWeb3 {
            callFromWeb3()
        } else {
            callFromSDK()
        }
    }
    
    private func callFromWeb3() {
        web3 = Web3(dexonRpcURL: URL(string: "https://api-testnet.dexscan.org/v1/network/rpc")!, dexonWallet: dexonWalletSDK, network: .dexonTestnet)!
        web3?.eth.getAccountsPromise().done { result in
            self.resultLabel.text = "address: \(result.first ?? "")"
        }.catch { error in
            self.resultLabel.text = "error: \(error)"
        }
    }
    
    private func callFromSDK() {
        let method = RequestAccountsMethod { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let address):
                self.resultLabel.text = "address: \(address)"
            case .failure(let error):
                self.resultLabel.text = "error: \(error)"
            }
        }

        dexonWalletSDK.run(method: method)
    }
}
