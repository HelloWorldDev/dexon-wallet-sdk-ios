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

extension String {

    var drop0x: String {
        if hasPrefix("0x") {
            return String(dropFirst(2))
        }
        return self
    }
}
