import SwiftUI

struct DeepItemView<DI: DeepItemProtocol & ObservableObject, DD: DeepDraggable, Content: View>: View {
    
    let style: DeepStyle
    @ObservedObject var rootItem: DI
    @ObservedObject var parentItem: DI
    @ObservedObject var item: DI
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    
    @State private var isTargeted: Bool = false
    @State private var isTargetedAbove: Bool = false
    @State private var isTargetedBelow: Bool = false
    
    var body: some View {
         
        switch item.representation {
        case .group(_, let items):
            
            VStack(alignment: .leading, spacing: 0.0) {
                
                target {
                    ZStack {
                        Color.gray.opacity(0.001)
                            .layoutPriority(-1)
                        content(item)
                    }
                    .draggable(drag(item)) {
                        
                        VStack(alignment: .leading, spacing: 0.0) {
                            
                            content(item)
                                .frame(height: style.rowHeight)
                            
                            if item.isExpanded {
                                
                                DeepListView(style: style,
                                             rootItem: rootItem,
                                             parentItem: item,
                                             items: items,
                                             drag: drag,
                                             drop: drop,
                                             content: content)
                            }
                        }
                    }
                }
                .frame(height: style.rowHeight)
                
                if item.isExpanded {
                    
                    DeepListView(style: style,
                                 rootItem: rootItem,
                                 parentItem: item,
                                 items: items,
                                 drag: drag,
                                 drop: drop,
                                 content: content)
                    .padding(.horizontal, style.indentationPadding)
                }
            }
            
        case .element:
            
            target {
                ZStack {
                    Color.gray.opacity(0.001)
                        .layoutPriority(-1)
                    content(item)
                }
                .draggable(drag(item))
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
                    DeepSeparatorView(
                        style: style,
                        rootItem: rootItem,
                        parentItem: parentItem,
                        deepPlace: .above(itemID: item.id),
                        isGroup: item.isGroup,
                        isExpanded: item.isExpanded
                    )
                    Spacer()
                } else if isTargetedBelow {
                    Spacer()
                    DeepSeparatorView(
                        style: style,
                        rootItem: rootItem,
                        parentItem: parentItem,
                        deepPlace: .below(itemID: item.id, after: item.isGroup && !item.isExpanded),
                        isGroup: item.isGroup,
                        isExpanded: item.isExpanded
                    )
                }
            }
            
            if isTargeted || isTargetedAbove || isTargetedBelow {
                
                VStack(spacing: 0.0) {
                    Color.gray.opacity(0.001)
                        .dropDestination(for: DD.self, action: { drops, location in
                            drop(drops, .above(itemID: item.id), location)
                        }) { isTargeted in
                            self.isTargetedAbove = isTargeted
                        }
                    Color.gray.opacity(0.001)
                        .dropDestination(for: DD.self, action: { drops, location in
                            drop(drops, .below(itemID: item.id, after: item.isGroup && !item.isExpanded), location)
                        }) { isTargeted in
                            self.isTargetedBelow = isTargeted
                        }
                }
            }
        }
    }
}
