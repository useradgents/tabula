import SwiftUI

public struct Cell {
    var view: AnyView
    let colSpan: Int
    let rowSpan: Int
    let style: CellStyle
    
    var colRange: ClosedRange<Int>
    var rowRange: ClosedRange<Int>
    var composedStyle: ComposedCellStyle
    
    public init<T>(colSpan: Int = 1, rowSpan: Int = 1, alignment: SwiftUI.Alignment = .center, style: CellStyle = .none, @ViewBuilder _ content: @escaping () -> T) where T: View {
        self.colSpan = colSpan
        self.rowSpan = rowSpan
        self.style = style
        self.view = AnyView(content())
        self.colRange = 0...0
        self.rowRange = 0...0
        self.composedStyle = .none
    }
    
    func placed(row: Int, column: Int, rowStyle: CellStyle, colStyle: CellStyle, tableStyle: CellStyle) -> Cell {
        var copy = self
        copy.rowRange = row...(row + rowSpan - 1)
        copy.colRange = column...(column + colSpan - 1)
        copy.composedStyle = CellStyle.compose(style, rowStyle, colStyle, tableStyle)
        return copy
    }
}

//MARK: - Result builder

public protocol CellGroup {
    var cells: [Cell] { get }
}

extension Cell: CellGroup {
    public var cells: [Cell] { [self] }
}

extension Array: CellGroup where Element == Cell {
    public var cells: [Cell] { self }
}

@resultBuilder public struct CellBuilder {
    public static func buildBlock(_ components: CellGroup...) -> [Cell] {
        components.flatMap(\.cells)
    }
}
