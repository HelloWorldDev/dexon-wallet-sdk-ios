// Copyright DEXON Org. All rights reserved.

import Foundation

public enum WalletSDKError: Int, Error {
    case unknown = -1
    case cancelled = 1
    case invalidRequest = 2
    case addressNotFound = 3
    case dataEncoding = 1000
}
