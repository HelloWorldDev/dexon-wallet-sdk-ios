// Copyright DEXON Org. All rights reserved.

import UIKit
import SnapKit
import DekuSanSDK

class Web3SampleViewController: UIViewController {
    
    private enum Row: Int, CaseIterable {
        case requestAccounts
        case signPersonalMessage
        case sendTransaction
        
        var title: String {
            switch self {
            case .requestAccounts:
                return "Request Accounts"
            case .signPersonalMessage:
                return "Sign Personal Message"
            case .sendTransaction:
                return "Send Transaction"
            }
        }
    }
    
    private let dekuSanWallet: DekuSanSDK
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
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
        title = "Method List"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.indexPathForSelectedRow.flatMap { tableView.deselectRow(at: $0, animated: true) }
    }

    private func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension Web3SampleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            return cell
        }()
        
        if let row = Row(rawValue: indexPath.row) {
            cell.textLabel?.text = row.title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = Row(rawValue: indexPath.row) else {
            return
        }
        
        var viewController: UIViewController?
        switch row {
        case .requestAccounts:
            viewController = RequestAccountsViewController(dekuSanWallet: dekuSanWallet, callViaWeb3: true)
        case .signPersonalMessage:
            viewController = SignPersonalMessageViewController(dekuSanWallet: dekuSanWallet, callViaWeb3: true)
        case .sendTransaction:
            viewController = SendTransactionViewController(dekuSanWallet: dekuSanWallet, callViaWeb3: true)
        }
        
        if let viewController = viewController {
            viewController.title = row.title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
