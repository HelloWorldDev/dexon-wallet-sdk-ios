// Copyright DEXON Org. All rights reserved.

import XCTest
import DexonWalletSDK
import CryptoSwift

class SendTransactionMethodTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testRequestURLWithDEXON() {
        let items = [URLQueryItem(name: GeneralQueryItemName.id.rawValue, value: "1122"),
                     URLQueryItem(name: GeneralQueryItemName.blockchain.rawValue, value: Blockchain.dexon.rawValue),
                     URLQueryItem(name: GeneralQueryItemName.callback.rawValue, value: "example"),
                     URLQueryItem(name: GeneralQueryItemName.name.rawValue, value: "dapp")]
        let fromAddress = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a6"
        let toAddress = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a7"
        let message = "DekuSan is cool"
        let method = SendTransactionMethod(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: 1,
            gasPrice: 2,
            gasLimit: 3,
            nonce: 4,
            data: message.data(using: .utf8)) { _ in }
        let url = method.requestURL(scheme: "dexon-wallet", queryItems: items)
        XCTAssertEqual(url.absoluteString, "dexon-wallet://send-transaction?id=1122&blockchain=dexon&callback=example&name=dapp" +
            "&from=\(fromAddress)" + "&to=\(toAddress)" + "&amount=1" + "&gas-price=2" + "&gas-limit=3" + "&nonce=4" + "&data=RGVrdVNhbiBpcyBjb29s")
    }

    func testRequestURLWithEthereum() {
        let items = [URLQueryItem(name: GeneralQueryItemName.id.rawValue, value: "1122"),
                     URLQueryItem(name: GeneralQueryItemName.blockchain.rawValue, value: Blockchain.ethereum.rawValue),
                     URLQueryItem(name: GeneralQueryItemName.callback.rawValue, value: "example"),
                     URLQueryItem(name: GeneralQueryItemName.name.rawValue, value: "dapp")]
        let fromAddress = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a6"
        let toAddress = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a7"
        let message = "DekuSan is cool"
        let method = SendTransactionMethod(
            fromAddress: fromAddress,
            toAddress: toAddress,
            amount: 1,
            gasPrice: 2,
            gasLimit: 3,
            nonce: 4,
            data: message.data(using: .utf8)) { _ in }
        let url = method.requestURL(scheme: "dexon-wallet", queryItems: items)
        XCTAssertEqual(url.absoluteString, "dexon-wallet://send-transaction?id=1122&blockchain=ethereum&callback=example&name=dapp" +
            "&from=\(fromAddress)" + "&to=\(toAddress)" + "&amount=1" + "&gas-price=2" + "&gas-limit=3" + "&nonce=4" + "&data=RGVrdVNhbiBpcyBjb29s")
    }

    func testInitWithURLComponents() {
        let fromAddress = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a6"
        let toAddress = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a7"
        let message = "DekuSan is cool"
        let components = URLComponents(
            string: "dexon-wallet://send-transaction?id=1122&blockchain=ethereum&callback=example&name=dapp" +
                "&from=\(fromAddress)" + "&to=\(toAddress)" + "&amount=1" + "&gas-price=2" + "&gas-limit=3" + "&nonce=4" + "&data=RGVrdVNhbiBpcyBjb29s")!
        let method = SendTransactionMethod(components: components)
        XCTAssertNotNil(method)
        XCTAssertEqual(method?.fromAddress, fromAddress)
        XCTAssertEqual(method?.toAddress, toAddress)
        XCTAssertEqual(method?.amount, 1)
        XCTAssertEqual(method?.gasPrice, 2)
        XCTAssertEqual(method?.gasLimit, 3)
        XCTAssertEqual(method?.nonce, 4)
        XCTAssertEqual(method?.data, message.data(using: .utf8))
    }

    func testHandleSucceedCallback() {
        let tx = "0xa5e2930c25e73b3fd07b2c84986ac466254ff2aece194b8fafaf4ae96daac414"

        let components = URLComponents(string: "example://dexon-wallet?id=1122&transaction-hash=" + tx)!
        let method = SendTransactionMethod(toAddress: "", amount: 0) { (result) in
            XCTAssertEqual(result.value, tx.lowercased())
        }
        let handled = method.handleCallback(components: components)
        XCTAssertTrue(handled)
    }

    func testHandleErrorCallback() {
        let components = URLComponents(string: "example://dexon-wallet?id=1122&error=1")!
        let method = SendTransactionMethod(toAddress: "", amount: 0) { (result) in
            XCTAssertEqual(result.error, WalletSDKError.cancelled)
        }
        let handled = method.handleCallback(components: components)
        XCTAssertFalse(handled)
    }
}
