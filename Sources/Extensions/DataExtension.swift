// Copyright DEXON Org. All rights reserved.

import Foundation

extension Data {

    var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    var hexEncoded: String {
        return "0x" + self.hex
    }
}
