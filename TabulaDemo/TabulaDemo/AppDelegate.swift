import UIKit
import SwiftUI
import Tabula

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIHostingController(rootView: TabulaRoot())
        window?.makeKeyAndVisible()
        return true
    }
}

struct TabulaRoot: View {
    var body: some View {
        NavigationView {
            Form {
                NavigationLink("Basic table", destination: TabulaBasic())
                NavigationLink("Alignments", destination: TabulaAlignments())
                NavigationLink("Colspan, rowspan", destination: TabulaSpans())
                NavigationLink("Sudoku (borders, fills)", destination: TabulaSudoku())
                NavigationLink("List of items (ForEach)", destination: TabulaList())
            }
            .navigationBarTitle(Text("Tabula Demo"))
        }
    }
}

struct TabulaBasic: View {
    var body: some View {
        Tabula(columns: { (0..<3).map { _ in Column() } }) {
            Row {
                Cell { Text("A1") }
                Cell { Text("B1") }
                Cell { Text("C1") }
            }
            Row {
                Cell { Text("A2") }
                Cell { Text("B2") }
                Cell { Text("C2") }
            }
            Row {
                Cell { Text("A3") }
                Cell { Text("B3") }
                Cell { Text("C3") }
            }
        }
    }
}


struct TabulaAlignments: View {
    var body: some View {
        Tabula(
            defaultCellStyle: .borders(all: (.black, 1)),
            columns: { (0..<3).map { _ in Column() } }
        ) {
            Row {
                Cell(style: .alignment(.topLeading))  { Text("A1\nText").border(Color.blue, width: 0.5) }
                Cell(style: .alignment(.top))         { Text("B1").border(Color.blue, width: 0.5) }
                Cell(style: .alignment(.topTrailing)) { Text("C1").border(Color.blue, width: 0.5) }
            }
            Row {
                Cell(style: .alignment(.leading))  { Text("A2").border(Color.blue, width: 0.5) }
                Cell(style: .alignment(.center))   { Text("B2\nLong\nText").border(Color.blue, width: 0.5) }
                Cell(style: .alignment(.trailing)) { Text("C2").border(Color.blue, width: 0.5) }
            }
            Row {
                Cell(style: .alignment(.bottomLeading))  { Text("A3").border(Color.blue, width: 0.5) }
                Cell(style: .alignment(.bottom))         { Text("B3").border(Color.blue, width: 0.5) }
                Cell(style: .alignment(.bottomTrailing)) { Text("C3\nText").border(Color.blue, width: 0.5) }
            }
        }
        .padding(24)
    }
}

struct TabulaSpans: View {
    var body: some View {
        Tabula(
            defaultCellStyle: .borders(all: (.black, 1)).padding(8),
            columns: {
                Column(sizing: .fit)
                Column()
                Column(sizing: .proportional(factor: 3))
                Column()
                Column(sizing: .fit)
            }
        ) {
            Row {
                Cell { Text("A") }
                Cell { Text("B") }
                Cell { Text("C") }
                Cell { Text("D") }
                Cell { Text("E") }
            }
            
            Row {
                Cell { Text("F") }
                Cell(colSpan: 3, style: .backgroundColor(.black)) { Text("G").foregroundColor(.white) }
                Cell { Text("H") }
            }
            
            Row {
                Cell { Text("I") }
                Cell(rowSpan: 3, style: .backgroundColor(.blue)) { Text("J") }
                Cell { Text("K") }
                Cell(rowSpan: 3, style: .backgroundColor(.red)) { Text("L") }
                Cell { Text("M") }
            }
            
            Row {
                Cell { Text("N") }
                Cell { Text("O") }
                Cell { Text("P") }
            }
            
            Row {
                Cell { Text("Q") }
                Cell { Text("R") }
                Cell { Text("S") }
            }
            
            Row {
                Cell { Text("T") }
                Cell { Text("U") }
                Cell { Text("V") }
                Cell { Text("W") }
                Cell { Text("X") }
            }
        }
        .padding(24)
    }
}

struct TabulaSudoku: View {
    
    let grid: [[Int?]] = [
        [5, 4, nil, nil, 7, 1, 9, 6, nil],
        [8, nil, nil, 9, nil, nil, nil, nil, nil],
        [nil, nil, nil, 5, nil, 2, nil, 8, nil],
        [nil, nil, nil, nil, nil, nil, nil, 3, 5],
        [nil, nil, nil, 1, nil, nil, nil, nil, nil],
        [nil, nil, 9, nil, nil, nil, 4, nil, 6],
        [nil, nil, nil, nil, nil, 6, nil, 9, nil],
        [7, 1, nil, 4, nil, nil, nil, nil, nil],
        [6, nil, 3, 2, nil, nil, nil, nil, 4]
    ]
    
    @State var highlighted = 4
    
    var body: some View {
        VStack(spacing: 24) {
            Stepper("Highlighted value: \(highlighted)", value: $highlighted)
            Tabula(
                defaultCellStyle: .padding(8),
                columns: { grid[0].indices.map { x in
                    Column(defaultCellStyle: .borders(
                        leading:  (.black, x % 3 == 0 ? 3 : 1),
                        trailing: (.black, x % 3 == 2 ? 3 : 1)
                    ))
                }}
            ) {
                grid.indices.map { y in
                    Row(
                        sizing: .ratio(1, toColumn: 0),
                        defaultCellStyle: .borders(
                            top:    (.black, y % 3 == 0 ? 3 : 1),
                            bottom: (.black, y % 3 == 2 ? 3 : 1)
                        )
                    ) {
                        grid[y].indices.map { x in
                            Cell(style: .backgroundColor(grid[y][x] == highlighted ? .black : .white)) {
                                if let val = grid[y][x] {
                                    Text("\(val)").foregroundColor(val == highlighted ? .white : .black)
                                }
                                else {
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
    }
}

struct TabulaList: View {
    struct Item: Hashable {
        let size: String
        let EAN: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(size)
            hasher.combine(EAN)
        }
    }
    
    let items: [Item] = [
        .init(size: "36",   EAN: "45984753498457"),
        .init(size: "36.5", EAN: "50948304958234"),
        .init(size: "37",   EAN: "65869043283245"),
        .init(size: "37.5", EAN: "09841468720395")
    ]
    
    var body: some View {
        Tabula(
            defaultCellStyle: .padding(h: 8, v: 2),
            columns: {
                Column(sizing: .fit, defaultCellStyle: .alignment(.trailing).borders(trailing: (.black.opacity(0.15), 1)))
                Column(defaultCellStyle: .alignment(.leading))
            }
        ) {
            Row(defaultCellStyle: .borders(bottom: (.black, 1)).backgroundColor(.black.opacity(0.15))) {
                Cell { Text("Size") }
                Cell { Text("EAN") }
            }
            
            items.map { item in
                Row {
                    Cell { Text(item.size) }
                    Cell { Text(item.EAN) }
                }
            }
        }.padding(24)
    }
}
