// Copyright DEXON Org. All rights reserved.

import Foundation
import Result

public class SignPersonalMessageMethod: SignMessageMethod {

    override public class var name: String {
        return "sign-personal-message"
    }
}

public extension DekuSanSDK {

    public func sign(personalMessage: String, fromAddress: String? = nil, completion: @escaping SignPersonalMessageMethod.Completion) {
        guard let data = personalMessage.data(using: .utf8) else {
            completion(.failure(.dataEncoding))
            return
        }

        sign(personalMessageData: data, fromAddress: fromAddress, completion: completion)
    }

    public func sign(personalMessageData: Data, fromAddress: String? = nil, completion: @escaping SignPersonalMessageMethod.Completion) {
        let method = SignPersonalMessageMethod(message: personalMessageData, fromAddress: fromAddress, completion: completion)
        run(method: method)
    }
}
