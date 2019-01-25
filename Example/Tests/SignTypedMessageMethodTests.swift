// Copyright DEXON Org. All rights reserved.

import XCTest
import DekuSanSDK
import CryptoSwift

class SignTypedMessageMethodTests: XCTestCase {

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
        let address = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a6"
        let message = "DekuSan is cool"
        let method = SignTypedMessageMethod(message: message.data(using: .utf8)!, fromAddress: address) { _ in }
        let url = method.requestURL(scheme: "dekusan", queryItems: items)
        XCTAssertEqual(url.absoluteString, "dekusan://sign-typed-message?id=1122&blockchain=dexon&callback=example&name=dapp&message=RGVrdVNhbiBpcyBjb29s&from=" + address)
    }

    func testRequestURLWithEthereum() {
        let items = [URLQueryItem(name: GeneralQueryItemName.id.rawValue, value: "1122"),
                     URLQueryItem(name: GeneralQueryItemName.blockchain.rawValue, value: Blockchain.ethereum.rawValue),
                     URLQueryItem(name: GeneralQueryItemName.callback.rawValue, value: "example"),
                     URLQueryItem(name: GeneralQueryItemName.name.rawValue, value: "dapp")]
        let address = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a6"
        let message = "DekuSan is cool"
        let method = SignTypedMessageMethod(message: message.data(using: .utf8)!, fromAddress: address) { _ in }
        let url = method.requestURL(scheme: "dekusan", queryItems: items)
        XCTAssertEqual(url.absoluteString, "dekusan://sign-typed-message?id=1122&blockchain=ethereum&callback=example&name=dapp&message=RGVrdVNhbiBpcyBjb29s&from=" + address)
    }

    func testInitWithURLComponents() {
        let address = "0xb25d07735d5B9B5601C549e901b04bd3A5Af93a6"
        let message = "DekuSan is cool"
        let components = URLComponents(
            string: "dekusan://sign-typed-message?id=1122&blockchain=dexon&callback=example&name=dapp" +
                "&message=RGVrdVNhbiBpcyBjb29s" +
                "&from=" + address)!
        let method = SignTypedMessageMethod(components: components)
        XCTAssertNotNil(method)
        XCTAssertEqual(method?.message, message.data(using: .utf8))
        XCTAssertEqual(method?.fromAddress, address)
    }

    func testHandleSucceedCallback() {
        let signature = "0x6451a8b3bf95df73c16258d6fe2eb3d896bff4b8d40f8c250973226287506f28278cfe1b147504ec75ce0b1e9f896298ed4bf7bddc33f5a8bb115192e2c021ce1b"
        let data = Data(hex: signature.drop0x)

        let components = URLComponents(string: "example://dekusan?id=1122&signature=" + data.base64EncodedString())!
        let method = SignTypedMessageMethod(message: Data()) { (result) in
            XCTAssertEqual(result.value, signature.lowercased())
        }
        let handled = method.handleCallback(components: components)
        XCTAssertTrue(handled)
    }

    func testHandleErrorCallback() {
        let components = URLComponents(string: "example://dekusan?id=1122&error=1")!
        let method = SignTypedMessageMethod(message: Data()) { (result) in
            XCTAssertEqual(result.error, WalletSDKError.cancelled)
        }
        let handled = method.handleCallback(components: components)
        XCTAssertFalse(handled)
    }
}
