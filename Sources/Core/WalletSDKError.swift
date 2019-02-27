// Copyright DEXON Org. All rights reserved.

import Foundation

public enum WalletSDKError: Int, Error {
    case unknown = -1
    case cancelled = 1
    case invalidRequest = 2
    case invalidResponse = 3
    case addressNotFound = 4
    case dataEncoding = 1000
}
