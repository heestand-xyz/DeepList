import SwiftUI

public struct DeepRootView<DI: DeepItemProtocol & ObservableObject, DD: DeepDraggable, Content: View>: View {
    
    let style: DeepStyle
    @ObservedObject var rootItem: DI
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    
    public init(style: DeepStyle = .default,
                rootItem: DI,
                drag: @escaping (DI) -> DD,
                drop: @escaping ([DD], DeepPlace, CGPoint) -> Bool,
                @ViewBuilder content: @escaping (DI) -> Content) {
        precondition(rootItem.isGroup)
        self.style = style
        self.rootItem = rootItem
        self.drag = drag
        self.drop = drop
        self.content = content
    }
    
    @State private var isTargetTop: Bool = false
    @State private var isTargetBottom: Bool = false
    @State private var outerHeight: CGFloat = 0.0
    @State private var innerHeight: CGFloat = 0.0
    
    private var remainingHeight: CGFloat {
        let totalHeight: CGFloat = style.scrollTopEdgeInset + innerHeight
        return max(style.scrollBottomEdgeInset, outerHeight - totalHeight)
    }
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView {
                
                VStack(spacing: 0.0) {
                    
                    Color.gray.opacity(0.001)
                        .frame(height: style.scrollTopEdgeInset)
                        .dropDestination(for: DD.self) { drops, location in
                            drop(drops, .top, location)
                        } isTargeted: { isTarget in
                            isTargetTop = isTarget
                        }
                        .overlay(alignment: .bottom) {
                            if isTargetTop {
                                DeepSeparatorView(
                                    style: style,
                                    rootItem: rootItem,
                                    parentItem: rootItem,
                                    deepPlace: .top,
                                    isGroup: false,
                                    isExpanded: false
                                )
                            }
                        }
                    
                    DeepListView(style: style,
                                 rootItem: rootItem,
                                 parentItem: rootItem,
                                 items: rootItem.items,
                                 drag: drag,
                                 drop: drop,
                                 content: content)
                    .background {
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    innerHeight = geometry.size.height
                                }
                                .onChange(of: geometry.size.height) { newHeight in
                                    innerHeight = newHeight
                                }
                        }
                    }
                    .onChange(of: rootItem.items.isEmpty) { newIsEmpty in
                        if newIsEmpty {
                            innerHeight = 0.0
                        }
                    }
                    
                    Color.gray.opacity(0.001)
                        .frame(height: remainingHeight)
                        .dropDestination(for: DD.self) { drops, location in
                            drop(drops, .bottom, location)
                        } isTargeted: { isTarget in
                            isTargetBottom = isTarget
                        }
                        .overlay(alignment: .top) {
                            if isTargetBottom {
                                DeepSeparatorView(
                                    style: style,
                                    rootItem: rootItem,
                                    parentItem: rootItem,
                                    deepPlace: .bottom,
                                    isGroup: false,
                                    isExpanded: false
                                )
                            }
                        }
                }
            }
            .onAppear {
                outerHeight = geometry.size.height
            }
            .onChange(of: geometry.size.height) { newHeight in
                outerHeight = newHeight
            }
        }
    }
}
