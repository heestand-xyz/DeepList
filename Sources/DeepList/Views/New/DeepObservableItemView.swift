import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct DeepObservableItemView<DI: DeepItemProtocol & Observable, DD: DeepDraggable, Content: View, DragContent: View>: View {
    
    @ObservedObject var deepList: DeepList
    let rootItem: DI
    let parentItem: DI
    let item: DI
    let style: DeepStyle
    let isDragPreview: Bool
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    let dragContent: (DI) -> DragContent
    
    @State private var isTargeted: Bool = false
    @State private var isTargetedAbove: Bool = false
    @State private var isTargetedBelow: Bool = false
    private var isSomeTargeted: Bool {
        isTargeted || isTargetedAbove || isTargetedBelow
    }
    
    var body: some View {
         
        switch item.representation {
        case .group(_, let items):
            
            ZStack {
                
                RoundedRectangle(cornerRadius: style.listCornerRadius)
                    .foregroundColor(style.backgroundColor)
                    .layoutPriority(-1)
                
                VStack(alignment: .leading, spacing: 0.0) {
                    
                    target {
                        ZStack {
                            Color.gray.opacity(0.001)
                                .layoutPriority(-1)
                            if isDragPreview {
                                dragContent(item)
                            } else {
                                content(item)
                            }
                        }
                        .draggable({ () -> DD in
                            deepList.drag(itemID: item.id)
                            return drag(item)
                        }()) {
                            
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: style.listCornerRadius)
                                    .foregroundColor(style.backgroundColor)
                                    .layoutPriority(-1)
                                
                                VStack(alignment: .leading, spacing: 0.0) {
                                    
                                    dragContent(item)
                                        .padding(.leading, style.indentation == .horizontal ? style.indentationPadding : 0.0)
                                        .frame(height: style.rowHeight)
                                    
                                    if item.isExpanded {
                                        
                                        DeepObservableListView(
                                            deepList: deepList,
                                            rootItem: rootItem,
                                            grandparentItem: parentItem,
                                            parentItem: item,
                                            items: items,
                                            style: style,
                                            isDragPreview: true,
                                            drag: drag,
                                            drop: drop,
                                            content: content,
                                            dragContent: dragContent
                                        )
                                        .padding(.leading, style.indentation.isLeading ? style.indentationPadding : 0.0)
#if os(visionOS)
                                        .offset(z: style.indentation.isDepth ? style.indentationPadding : 0.0)
#endif
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: style.rowHeight)
                    
                    if item.isExpanded {
                        
                        DeepObservableListView(
                            deepList: deepList,
                            rootItem: rootItem,
                            grandparentItem: parentItem,
                            parentItem: item,
                            items: items,
                            style: style,
                            isDragPreview: isDragPreview,
                            drag: drag,
                            drop: drop,
                            content: content,
                            dragContent: dragContent
                        )
                        .padding(.leading, style.indentation.isLeading ? style.indentationPadding : 0.0)
#if os(visionOS)
                        .offset(z: style.indentation.isDepth ? style.indentationPadding : 0.0)
#endif
                    }
                }
            }
            .padding(.horizontal, style.indentation == .horizontal ? style.indentationPadding : 0.0)
            
        case .element:
            
            target {
                ZStack {
                    Color.gray.opacity(0.001)
                        .layoutPriority(-1)
                    if isDragPreview {
                        dragContent(item)
                    } else {
                        content(item)
                    }
                }
                .draggable({ () -> DD in
                    deepList.drag(itemID: item.id)
                    return drag(item)
                }()) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: style.listCornerRadius)
                            .foregroundColor(style.backgroundColor)
                            .layoutPriority(-1)
                        
                        dragContent(item)
                            .frame(height: style.rowHeight)
                    }
                }
            }
            .frame(height: style.rowHeight)
        }
    }
    
    private func target<T: View>(content: () -> T) -> some View {
        
        ZStack {
            
            content()
                .dropDestination(for: DD.self, action: { _, _ in false }) { isTargeted in
                    self.isTargeted = isTargeted
                }
            
            VStack {
                if isTargetedAbove {
                    DeepObservableSeparatorView(
                        deepList: deepList,
                        rootItem: rootItem,
                        parentItem: parentItem,
                        item: item,
                        deepPlace: .above(itemID: item.id),
                        style: style
                    )
                    Spacer()
                } else if isTargetedBelow {
                    Spacer()
                    DeepObservableSeparatorView(
                        deepList: deepList,
                        rootItem: rootItem,
                        parentItem: parentItem,
                        item: item,
                        deepPlace: .below(itemID: item.id, after: item.isGroup && !item.isExpanded),
                        style: style
                    )
                }
            }
            
            if isSomeTargeted {
                
                VStack(spacing: 0.0) {
                    Color.gray.opacity(0.001)
                        .dropDestination(for: DD.self, action: { drops, location in
                            deepList.drop()
                            return drop(drops, .above(itemID: item.id), location)
                        }) { isTargeted in
                            isTargetedAbove = isTargeted
                        }
                    Color.gray.opacity(0.001)
                        .dropDestination(for: DD.self, action: { drops, location in
                            deepList.drop()
                            return drop(drops, .below(itemID: item.id, after: item.isGroup && !item.isExpanded), location)
                        }) { isTargeted in
                            isTargetedBelow = isTargeted
                        }
                }
            }
        }
    }
}
