import SwiftUI

public struct CellStyle {
    var alignment: SwiftUI.Alignment?
    var padding: EdgeInsets?
    var backgroundColor: Color?
    var borders: Borders
    
    public struct Borders {
        var top: (color: Color, width: CGFloat)?
        var leading: (color: Color, width: CGFloat)?
        var bottom: (color: Color, width: CGFloat)?
        var trailing: (color: Color, width: CGFloat)?
        
        func composed(with other: Borders) -> Borders {
            var ret = self
            if ret.leading == nil { ret.leading = other.leading }
            if ret.trailing == nil { ret.trailing = other.trailing }
            if ret.top == nil { ret.top = other.top }
            if ret.bottom == nil { ret.bottom = other.bottom }
            return ret
        }
        
        public static let none = Self.init(top: nil, leading: nil, bottom: nil, trailing: nil)
    }
    
    public static let none = CellStyle(alignment: nil, padding: nil, backgroundColor: nil, borders: .none)
    
    static func compose(_ styles: CellStyle...) -> ComposedCellStyle {
        var ret = CellStyle.none
        for style in styles {
            if ret.alignment == nil { ret.alignment = style.alignment }
            if ret.padding == nil { ret.padding = style.padding }
            if ret.backgroundColor == nil { ret.backgroundColor = style.backgroundColor }
            ret.borders = ret.borders.composed(with: style.borders)
        }
        
        return ComposedCellStyle(
            alignment: ret.alignment ?? .center,
            padding: ret.padding ?? EdgeInsets(),
            backgroundColor: ret.backgroundColor ?? .clear,
            borders: .init(
                leading: ret.borders.leading ?? (.black, 0),
                trailing: ret.borders.trailing ?? (.black, 0),
                top: ret.borders.top ?? (.black, 0),
                bottom: ret.borders.bottom ?? (.black, 0)
            )
        )
    }
}

public extension CellStyle {
    static func alignment(_ a: SwiftUI.Alignment) -> CellStyle {
        Self.init(alignment: a, padding: nil, backgroundColor: nil, borders: .none)
    }
    
    static func padding(_ p: EdgeInsets) -> CellStyle {
        Self.init(alignment: nil, padding: p, backgroundColor: nil, borders: .none)
    }
    
    static func padding(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> CellStyle {
        Self.init(alignment: nil, padding: EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing), backgroundColor: nil, borders: .none)
    }
    
    static func padding(h: CGFloat = 0, v: CGFloat = 0) -> CellStyle {
        Self.init(alignment: nil, padding: EdgeInsets(top: v, leading: h, bottom: v, trailing: h), backgroundColor: nil, borders: .none)
    }
    
    static func padding(_ f: CGFloat) -> CellStyle {
        Self.init(alignment: nil, padding: EdgeInsets(top: f, leading: f, bottom: f, trailing: f), backgroundColor: nil, borders: .none)
    }
    
    static func backgroundColor(_ c: Color) -> CellStyle {
        Self.init(alignment: nil, padding: nil, backgroundColor: c, borders: .none)
    }
    
    static func borders(top: (Color, CGFloat)? = nil, leading: (Color, CGFloat)? = nil, bottom: (Color, CGFloat)? = nil, trailing: (Color, CGFloat)? = nil) -> CellStyle {
        Self.init(alignment: nil, padding: nil, backgroundColor: nil, borders: .init(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }
    
    static func borders(all b: (Color, CGFloat)) -> CellStyle {
        Self.init(alignment: nil, padding: nil, backgroundColor: nil, borders: .init(top: b, leading: b, bottom: b, trailing: b))
    }
    
    func alignment(_ a: SwiftUI.Alignment) -> CellStyle {
        var copy = self
        copy.alignment = a
        return copy
    }
    
    func padding(_ p: EdgeInsets) -> CellStyle {
        var copy = self
        copy.padding = p
        return copy
    }
    
    func padding(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> CellStyle {
        var copy = self
        copy.padding = EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
        return copy
    }
    
    func padding(h: CGFloat = 0, v: CGFloat = 0) -> CellStyle {
        var copy = self
        copy.padding = EdgeInsets(top: v, leading: h, bottom: v, trailing: h)
        return copy
    }
    
    func padding(_ f: CGFloat) -> CellStyle {
        var copy = self
        copy.padding = EdgeInsets(top: f, leading: f, bottom: f, trailing: f)
        return copy
    }
    
    func backgroundColor(_ c: Color) -> CellStyle {
        var copy = self
        copy.backgroundColor = c
        return copy
    }
    
    func borders(top: (Color, CGFloat)? = nil, leading: (Color, CGFloat)? = nil, bottom: (Color, CGFloat)? = nil, trailing: (Color, CGFloat)? = nil) -> CellStyle {
        var copy = self
        copy.borders = .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
        return copy
    }
    
    func borders(all b: (Color, CGFloat)) -> CellStyle {
        var copy = self
        copy.borders = .init(top: b, leading: b, bottom: b, trailing: b)
        return copy
    }
}

struct ComposedCellStyle {
    var alignment: SwiftUI.Alignment
    var padding: EdgeInsets
    var backgroundColor: Color
    var borders: Borders
    
    static let none = ComposedCellStyle(alignment: .center, padding: .init(), backgroundColor: .clear, borders: .init(leading: (.black, 0), trailing: (.black, 0), top: (.black, 0), bottom: (.black, 0)))
    
    struct Borders {
        var leading: (color: Color, width: CGFloat)
        var trailing: (color: Color, width: CGFloat)
        var top: (color: Color, width: CGFloat)
        var bottom: (color: Color, width: CGFloat)
        
        @ViewBuilder func leadingBorder() -> some View {
            Rectangle().fill(leading.color).frame(width: leading.width).zIndex(1)
        }
        @ViewBuilder func trailingBorder() -> some View {
            Rectangle().fill(trailing.color).frame(width: trailing.width).zIndex(1)
        }
        @ViewBuilder func topBorder() -> some View {
            Rectangle().fill(top.color).frame(height: top.width).zIndex(1)
        }
        @ViewBuilder func bottomBorder() -> some View {
            Rectangle().fill(bottom.color).frame(height: bottom.width).zIndex(1)
        }
        
        @ViewBuilder func makeViews(frame: CGRect) -> some View {
            ZStack {
                if leading.width > 0 {
                    leadingBorder().frame(height: frame.height).position(x: frame.minX, y: frame.midY)
                }
                if trailing.width > 0 {
                    trailingBorder().frame(height: frame.height).position(x: frame.maxX, y: frame.midY)
                }
                if top.width > 0 {
                    topBorder().frame(width: frame.width).position(x: frame.midX, y: frame.minY)
                }
                if bottom.width > 0 {
                    bottomBorder().frame(width: frame.width).position(x: frame.midX, y: frame.maxY)
                }
            }
            .zIndex(1)
        }
    }
}
