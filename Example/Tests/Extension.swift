// Copyright DEXON Org. All rights reserved.

import Foundation
import CryptoSwift

extension Data {
    init(hex: String) {
        self.init(bytes: Array<UInt8>(hex: hex))
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
