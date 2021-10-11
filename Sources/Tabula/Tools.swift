import SwiftUI

extension Sequence where Element: Numeric {
    func sum() -> Element {
        reduce(0, +)
    }
}

