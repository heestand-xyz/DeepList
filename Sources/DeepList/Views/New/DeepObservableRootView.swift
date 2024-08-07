import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
public struct DeepObservableRootView<DI: DeepItemProtocol & Observable, DD: DeepDraggable, Content: View, DragContent: View>: View {
    
    @ObservedObject var deepList: DeepList
    let rootItem: DI
    let style: DeepStyle
    let didTapBackground: () -> ()
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    let dragContent: (DI) -> DragContent
    
    public init(
        deepList: DeepList,
        rootItem: DI,
        style: DeepStyle = .default,
        didTapBackground: @escaping () -> () = {},
        drag: @escaping (DI) -> DD,
        drop: @escaping ([DD], DeepPlace, CGPoint) -> Bool,
        @ViewBuilder content: @escaping (DI) -> Content,
        @ViewBuilder dragContent: @escaping (DI) -> DragContent
    ) {
        precondition(rootItem.isGroup)
        self.deepList = deepList
        self.rootItem = rootItem
        self.style = style
        self.didTapBackground = didTapBackground
        self.drag = drag
        self.drop = drop
        self.content = content
        self.dragContent = dragContent
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
                            deepList.drop()
                            return drop(drops, .top, location)
                        } isTargeted: { isTarget in
                            isTargetTop = isTarget
                        }
                        .overlay(alignment: .bottom) {
                            if isTargetTop {
                                DeepObservableSeparatorView(
                                    deepList: deepList,
                                    rootItem: rootItem,
                                    parentItem: rootItem,
                                    item: nil,
                                    deepPlace: .top,
                                    style: style
                                )
                            }
                        }
                    
                    DeepObservableListView(
                        deepList: deepList,
                        rootItem: rootItem,
                        grandparentItem: nil,
                        parentItem: rootItem,
                        items: rootItem.items,
                        style: style,
                        isDragPreview: false,
                        drag: drag,
                        drop: drop,
                        content: content,
                        dragContent: dragContent
                    )
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
                            deepList.drop()
                            return drop(drops, .bottom, location)
                        } isTargeted: { isTarget in
                            isTargetBottom = isTarget
                        }
                        .onTapGesture {
                            didTapBackground()
                        }
                        .overlay(alignment: .top) {
                            if isTargetBottom {
                                DeepObservableSeparatorView(
                                    deepList: deepList,
                                    rootItem: rootItem,
                                    parentItem: rootItem,
                                    item: nil,
                                    deepPlace: .bottom,
                                    style: style
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
