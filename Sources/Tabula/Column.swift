import SwiftUI

public struct Column {
    let sizing: Sizing
    let defaultCellStyle: CellStyle
    
    public init(sizing: Sizing = .proportional(factor: 1), defaultCellStyle: CellStyle = .none) {
        self.sizing = sizing
        self.defaultCellStyle = defaultCellStyle
    }
}

extension Column {
    public enum Sizing {
        case proportional(factor: CGFloat) // default
        case fit
        case fixed(width: CGFloat)
        
        internal var proportionalFactor: CGFloat {
            switch self {
                case .proportional(let factor): return factor
                default: return 0
            }
        }
    }
}

//MARK: - Result builder

public protocol ColumnGroup {
    var columns: [Column] { get }
}

extension Column: ColumnGroup {
    public var columns: [Column] { [self] }
}

extension Array: ColumnGroup where Element == Column {
    public var columns: [Column] { self }
}

@resultBuilder public struct ColumnBuilder {
    public static func buildBlock(_ components: ColumnGroup...) -> [Column] {
        components.flatMap(\.columns)
    }
}
