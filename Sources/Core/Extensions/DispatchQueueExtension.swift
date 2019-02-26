// Copyright DEXON Org. All rights reserved.

import Foundation

extension DispatchQueue {

    func safeAsync(_ block: @escaping () -> ()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
