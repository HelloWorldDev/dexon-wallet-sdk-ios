// Copyright DEXON Org. All rights reserved.

import Foundation
import Result

public class SignTypedMessageMethod: SignMessageMethod {

    override public class var name: String {
        return "sign-typed-message"
    }
}

public extension DexonWalletSDK {

    public func sign(typedMessage: String, fromAddress: String? = nil, completion: @escaping SignTypedMessageMethod.Completion) {
        guard let data = typedMessage.data(using: .utf8) else {
            completion(.failure(.dataEncoding))
            return
        }

        sign(typedMessageData: data, fromAddress: fromAddress, completion: completion)
    }

    public func sign(typedMessageData: Data, fromAddress: String? = nil, completion: @escaping SignTypedMessageMethod.Completion) {
        let method = SignTypedMessageMethod(message: typedMessageData, fromAddress: fromAddress, completion: completion)
        run(method: method)
    }
}
