// Copyright DEXON Org. All rights reserved.

import UIKit
import SnapKit
import DexonWalletSDK

class MethodListViewController: UIViewController {

    private enum Row: Int, CaseIterable {
        case requestAccounts
        case signMessage
        case signPersonalMessage
        case signTypedMessage
        case sendTransaction
        case web3Sample

        var title: String {
            switch self {
            case .requestAccounts:
                return "Request Accounts"
            case .signMessage:
                return "Sign Message"
            case .signPersonalMessage:
                return "Sign Personal Message"
            case .signTypedMessage:
                return "Sign Typed Message"
            case .sendTransaction:
                return "Send Transaction"
            case .web3Sample:
                return "Web3 Samples"
            }
        }
    }

    private lazy var blockchainSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["DEXON", "Ethereum"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        view.addSubview(blockchainSegmentedControl)
        blockchainSegmentedControl.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 50
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

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

    private func wallet() -> DexonWalletSDK? {
        switch blockchainSegmentedControl.selectedSegmentIndex {
        case 0:
            return (UIApplication.shared.delegate as? AppDelegate)?.dexonDXNWallet
        case 1:
            return (UIApplication.shared.delegate as? AppDelegate)?.dexonETHWallet
        default:
            return nil
        }
    }
}

extension MethodListViewController: UITableViewDataSource, UITableViewDelegate {

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
        guard let row = Row(rawValue: indexPath.row), let wallet = wallet() else {
            return
        }

        var viewController: UIViewController?
        switch row {
        case .requestAccounts:
            viewController = RequestAccountsViewController(dexonWalletSDK: wallet)
        case .signMessage:
            viewController = SignMessageViewController(dexonWalletSDK: wallet)
        case .signPersonalMessage:
            viewController = SignPersonalMessageViewController(dexonWalletSDK: wallet)
        case .signTypedMessage:
            viewController = SignTypedMessageViewController(dexonWalletSDK: wallet)
        case .sendTransaction:
            viewController = SendTransactionViewController(dexonWalletSDK: wallet)
        case .web3Sample:
            viewController = Web3SampleViewController(dexonWalletSDK: wallet)
        }

        if let viewController = viewController {
            viewController.title = row.title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
