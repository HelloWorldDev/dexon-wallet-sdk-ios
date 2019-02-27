// Copyright DEXON Org. All rights reserved.

import Foundation

extension URLComponents {

    func valueOfQueryItem(name: String) -> String? {
        return queryItems?.first(where: { $0.name == name })?.value
    }
}
