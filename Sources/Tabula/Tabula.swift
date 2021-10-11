import SwiftUI

public struct Tabula: View {
    @State var debugLayout: Bool
    
    let defaultCellStyle: CellStyle
    let columns: [Column]
    let rows: [Row]
    
    public init(
        defaultCellStyle: CellStyle = .none,
        debugLayout: Bool = false,
        @ColumnBuilder columns: () -> [Column],
        @RowBuilder rows: () -> [Row]
    ) {
        let columns = columns()
        let rows = rows()
        
        self.debugLayout = debugLayout
        self.defaultCellStyle = defaultCellStyle
        self.columns = columns
        // Recompose rows, calculating cell coordinates based on col-/rowspan
        self.rows = rows.reduce([], { previous, this in
            previous + [Row(row: this, previousRows: previous, columns: columns, tableDefaultCellStyle: defaultCellStyle)]
        })
        // Inherent cell sizes
        self.cellSizes = .init(repeating: .init(repeating: .zero, count: rows.count), count: columns.count)
        // Actual column widths
        self.columnWidths = .init(repeating: 0, count: columns.count)
        self.rowHeights = .init(repeating: 0, count: rows.count)
    }
    
    @State private var bounds: CGRect = .zero
    @State private var cellSizes: [[CGSize]]
    @State private var columnWidths: [CGFloat]
    @State private var rowHeights: [CGFloat]
    
    
    func base26(_ num: Int) -> String {
        num < 26 ? String(UnicodeScalar(UInt8(num + 65))) : base26((num / 26)-1) + String(UnicodeScalar(UInt8((num%26) + 65)))
    }
    
    func excelCoords(col: Int, row: Int) -> String {
        "\(base26(col))\(row+1)"
    }
    
    private let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 1
        nf.minimumIntegerDigits = 1
        return nf
    }()
    
    public var body: some View {

        Rectangle()
            .fill(Color.clear)
            .frame(height: rowHeights.sum())
            .measureLocalFrame(into: $bounds)
        
            .overlay(cellMeasures())
            .overlay(actualCells(), alignment: .topLeading)
        
            .onChange(of: cellSizes) { _ in relayout() }
            .onChange(of: bounds) { _ in relayout() }
    }
    
    func relayout() {
        if debugLayout {
            print("Tabula: cell sizes changed, recomputing layout")
            
            rows.enumerated().forEach { (y, row) in
                row.cells.enumerated().forEach { (x, cell) in
                    let minCol = cell.colRange.lowerBound
                    let minRow = cell.rowRange.lowerBound
                    let maxCol = cell.colRange.upperBound
                    let maxRow = cell.rowRange.upperBound
                    
                    if maxRow > minRow || maxCol > minCol {
                        print("Cell \(excelCoords(col: minCol, row: minRow))→\(excelCoords(col: maxCol, row: maxRow)): size = \(nf.string(from: cellSizes[minCol][minRow].width as NSNumber)!) × \(nf.string(from: cellSizes[minCol][minRow].height as NSNumber)!)")
                    }
                    else {
                        print("Cell \(excelCoords(col: minCol, row: minRow)): size = \(nf.string(from: cellSizes[minCol][minRow].width as NSNumber)!) × \(nf.string(from: cellSizes[minCol][minRow].height as NSNumber)!)")
                    }
                }
            }
        }
        
        // Compute available width after removing fixed+fit columns
        let remaining = bounds.width - columns.enumerated().map({ (x, column) in
            switch column.sizing {
                case .fixed(let width): return width
                case .fit: return cellSizes[x].map(\.width).max() ?? 0
                default: return 0
            }
        }).sum()
        
        // Compute the value of 1 proportion factor
        let oneProportion = remaining / columns.map(\.sizing.proportionalFactor).sum()
        
        // Apply computations
        columnWidths = columns.enumerated().map({ (x, column) in
            switch column.sizing {
                case .fixed(let width): return width
                case .fit: return cellSizes[x].map(\.width).max() ?? 0
                case .proportional(let factor): return factor * oneProportion
            }
        })
        
        rowHeights = rows.indices.map { y in
            let row = rows[y]
            switch row.sizing {
                case .fixed(let height):
                    return height
                case .ratio(let ratio, let column) where columnWidths.indices.contains(column):
                    return ratio * columnWidths[column]
                default:
                    return columns.indices.map { col in
                        cellSizes[col][y]
                    }.map(\.height).max() ?? 0
            }
            
        }
        
        if debugLayout {
            print("Column widths: \(columnWidths.map({ nf.string(from: $0 as NSNumber)! }).joined(separator: " ; "))")
            print("Row heights: \(rowHeights.map({ nf.string(from: $0 as NSNumber)! }).joined(separator: " ; "))")
            print("---------------------------------------------------------------------------")
        }
    }
    
    @ViewBuilder func cellMeasures() -> some View {
        ForEach(rows.indices, id: \.self) { y in
            let row = rows[y]
            ForEach(row.cells.indices, id: \.self) { x in
                let cell: Cell = row.cells[x]
                let firstColumn: Column = columns[cell.colRange.lowerBound]
                
                switch firstColumn.sizing {
                    case .proportional:
                        cell.view
                            .constrainedToWidth(columnWidths[cell.colRange].sum(), withPadding: cell.composedStyle.padding)
                            .measureFixedSizeHidden(into: $cellSizes[cell.colRange.lowerBound][y])
                        
                    case .fit:
                        cell.view
                            .padding(cell.composedStyle.padding)
                            .measureFixedSizeHidden(into: $cellSizes[cell.colRange.lowerBound][y])
                        
                    case .fixed:
                        cell.view
                            .constrainedToWidth(columnWidths[cell.colRange].sum(), withPadding: cell.composedStyle.padding)
                            .measureFixedSizeHidden(into: $cellSizes[cell.colRange.lowerBound][y])
                }
            }
        }
    }
    
    @ViewBuilder private func actualCells() -> some View {
        ZStack {
            ForEach(rows.indices, id: \.self) { y in
                let row = rows[y]
                ForEach(row.cells.indices, id: \.self) { x in
                    let cell = row.cells[x]

                    let X: CGFloat = (0..<cell.colRange.lowerBound).map({ columnWidths[$0] }).sum()
                    let W: CGFloat = cell.colRange.map({ columnWidths[$0] }).sum()
                    let Y: CGFloat = (0..<cell.rowRange.lowerBound).map({ rowHeights[$0] }).sum()
                    let H: CGFloat = cell.rowRange.map({ rowHeights[$0] }).sum()
                    
                    cell.view
                        .zIndex(0)
                        .padding(cell.composedStyle.padding)
                        .frame(width: W, height: H, alignment: cell.composedStyle.alignment)
                        .background(cell.composedStyle.backgroundColor)
                        .position(x: X + W/2, y: Y + H/2)
                    
                    cell.composedStyle.borders.makeViews(frame: CGRect(x: X, y: Y, width: W, height: H))
                }
            }
        }
    }
}


