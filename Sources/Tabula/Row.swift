import SwiftUI

public struct Row {
    let sizing: Sizing
    let defaultCellStyle: CellStyle
    var cells: [Cell]

    public init(sizing: Sizing = .fit, defaultCellStyle: CellStyle = .none, @CellBuilder _ cells: () -> [Cell]) {
        self.sizing = sizing
        self.defaultCellStyle = defaultCellStyle
        self.cells = cells()
    }
    
    // Internal init that defines colrange/rowrange according to previous cells'
    // colspan/rowspan, and mine.
    init(row: Row, previousRows previous: [Row], columns: [Column], tableDefaultCellStyle: CellStyle) {
        var col = 0
        self.sizing = row.sizing
        self.defaultCellStyle = row.defaultCellStyle
        self.cells = row.cells.map { cell in
            defer { col += cell.colSpan }
            let myRowIndex = previous.count
            // Does a previous cell spans over where I should be? If so, shift myself
            // to the right
            for previousRow in previous {
                for previousCell in previousRow.cells {
                    if previousCell.rowRange.contains(myRowIndex) && previousCell.colRange.contains(col) {
                        col += previousCell.colSpan
                    }
                }
            }
            
            return cell.placed(
                row: myRowIndex, column: col,
                rowStyle: row.defaultCellStyle,
                colStyle: columns[col].defaultCellStyle,
                tableStyle: tableDefaultCellStyle
            )
        }
    }
}

extension Row {
    public enum Sizing {
        case fit // default
        case fixed(height: CGFloat)
        case ratio(_ ratio: CGFloat, toColumn: Int = 0)
    }
}

//MARK: - Result builder

public protocol RowGroup {
    var rows: [Row] { get }
}

extension Row: RowGroup {
    public var rows: [Row] { [self] }
}

extension Array: RowGroup where Element == Row {
    public var rows: [Row] { self }
}

@resultBuilder public struct RowBuilder {
    public static func buildBlock(_ components: RowGroup...) -> [Row] {
        components.flatMap(\.rows)
    }
}
