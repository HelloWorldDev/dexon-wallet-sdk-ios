// Copyright DEXON Org. All rights reserved.

import XCTest
import DekuSanSDK
import CryptoSwift

class RequestAccountsMethodTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRequestURLWithDEXON() {
        let items = [URLQueryItem(name: GeneralQueryItemName.id.rawValue, value: "1122"),
                     URLQueryItem(name: GeneralQueryItemName.blockchain.rawValue, value: Blockchain.dexon.rawValue),
                     URLQueryItem(name: GeneralQueryItemName.callback.rawValue, value: "example"),
                     URLQueryItem(name: GeneralQueryItemName.name.rawValue, value: "dapp")]
        let method = RequestAccountsMethod { _ in }
        let url = method.requestURL(scheme: "dekusan", queryItems: items)
        XCTAssertEqual(url.absoluteString, "dekusan://request-accounts?id=1122&blockchain=dexon&callback=example&name=dapp")
    }

    func testRequestURLWithEthereum() {
        let items = [URLQueryItem(name: GeneralQueryItemName.id.rawValue, value: "1122"),
                     URLQueryItem(name: GeneralQueryItemName.blockchain.rawValue, value: Blockchain.ethereum.rawValue),
                     URLQueryItem(name: GeneralQueryItemName.callback.rawValue, value: "example"),
                     URLQueryItem(name: GeneralQueryItemName.name.rawValue, value: "dapp")]
        let method = RequestAccountsMethod { _ in }
        let url = method.requestURL(scheme: "dekusan", queryItems: items)
        XCTAssertEqual(url.absoluteString, "dekusan://request-accounts?id=1122&blockchain=ethereum&callback=example&name=dapp")
    }

    func testInitWithURLComponents() {
        let components = URLComponents(string: "dekusan://request-accounts?id=1122&blockchain=dexon&callback=example&name=dapp")!
        let method = RequestAccountsMethod(components: components)
        XCTAssertNotNil(method)
    }

    func testHandleSucceedCallback() {
        let address = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a6"
        let data = Data(hex: address.drop0x)

        let components = URLComponents(string: "example://dekusan?id=1122&address=" + data.base64EncodedString())!
        let method = RequestAccountsMethod { (result) in
            XCTAssertEqual(result.value, address.lowercased())
        }
        let handled = method.handleCallback(components: components)
        XCTAssertTrue(handled)
    }

    func testHandleErrorCallback() {
        let components = URLComponents(string: "example://dekusan?id=1122&error=1")!
        let method = RequestAccountsMethod { (result) in
            XCTAssertEqual(result.error, WalletSDKError.cancelled)
        }
        let handled = method.handleCallback(components: components)
        XCTAssertFalse(handled)
    }
}
