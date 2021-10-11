import SwiftUI

struct FrameMeasurer: ViewModifier {
    struct Key: PreferenceKey {
        typealias Value = CGRect
        static var defaultValue: CGRect = .zero
        static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
            value = nextValue()
        }
    }
    
    var frameGetter: (GeometryProxy) -> CGRect
    @Binding var binding: CGRect
    
    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { p in
                Color.clear
                    .preference(key: Key.self, value: frameGetter(p))
                    .onPreferenceChange(Key.self, perform: { binding = $0 })
            })
    }
}

struct SizeMeasurer: ViewModifier {
    struct Key: PreferenceKey {
        typealias Value = CGSize
        static var defaultValue: CGSize = .zero
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
    
    var sizeGetter: (GeometryProxy) -> CGSize
    @Binding var binding: CGSize
    
    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { p in
                Color.clear
                    .preference(key: Key.self, value: sizeGetter(p))
                    .onPreferenceChange(Key.self, perform: { binding = $0 })
            })
    }
}

extension View {
    func measureFrame(into binding: Binding<CGRect>, with frameGetter: @escaping (GeometryProxy) -> CGRect) -> some View {
        self.modifier(FrameMeasurer(frameGetter: frameGetter, binding: binding))
    }
    
    func measureFrame(into binding: Binding<CGRect>, fromCoordinateSpaceNamed name: String) -> some View {
        self.modifier(FrameMeasurer(frameGetter: { $0.frame(in: .named(name)) }, binding: binding))
    }
    
    func measureGlobalFrame(into binding: Binding<CGRect>) -> some View {
        self.modifier(FrameMeasurer(frameGetter: { $0.frame(in: .global) }, binding: binding))
    }
    
    func measureLocalFrame(into binding: Binding<CGRect>) -> some View {
        self.modifier(FrameMeasurer(frameGetter: { $0.frame(in: .local) }, binding: binding))
    }
    
    func measureFixedSizeHidden(into binding: Binding<CGSize>) -> some View {
        self
            .modifier(SizeMeasurer(sizeGetter: { $0.frame(in: .local).size }, binding: binding))
            .hidden()
    }
    
    func constrainedToWidth(_ width: CGFloat, withPadding p: EdgeInsets) -> some View {
        self
            .padding(EdgeInsets(top: 0, leading: p.leading, bottom: 0, trailing: p.trailing))
            .frame(width: width)
            .fixedSize(horizontal: false, vertical: true)
            .padding(EdgeInsets(top: p.top, leading: 0, bottom: p.bottom, trailing: 0))
    }
}
