import SwiftUI

public struct DeepRootView<DI: DeepItemProtocol, DD: DeepDraggable, Content: View>: View {
    
    let style: DeepStyle
    let rootItem: DI
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    
    public init(style: DeepStyle = .default,
                rootItem: DI,
                drag: @escaping (DI) -> DD,
                drop: @escaping ([DD], DeepPlace, CGPoint) -> Bool,
                content: @escaping (DI) -> Content) {
        precondition(rootItem.isGroup)
        self.style = style
        self.rootItem = rootItem
        self.drag = drag
        self.drop = drop
        self.content = content
    }
    
    @State private var isTarget: Bool = false
    @State private var height: CGFloat = 0.0
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView {
                
                ZStack(alignment: .top) {
                    
                    Color.gray.opacity(0.001)
                        .frame(height: height)
                        .dropDestination(for: DD.self) { drops, location in
                            drop(drops, .bottom, location)
                        } isTargeted: { isTarget in
                            self.isTarget = isTarget
                        }
                    
                    VStack(spacing: 0.0) {
                        
                        DeepListView(style: style,
                                     rootItem: rootItem,
                                     items: rootItem.items,
                                     drag: drag,
                                     drop: drop,
                                     content: content)
                        .overlay(alignment: .bottom) {
                            if isTarget {
                                DeepSeparatorView(
                                    style: style,
                                    rootItem: rootItem,
                                    deepPlace: .bottom
                                )
                            }
                        }
                        
                        Spacer(minLength: 0.0)
                            .frame(height: style.scrollBottomEdgeInset)
                    }
                }
            }
            .onAppear {
                height = geometry.size.height
            }
            .onChange(of: geometry.size.height) { newValue in
                height = newValue
            }
        }
    }
}
