import SwiftUI

struct DeepItemView<DI: DeepItemProtocol, DD: DeepDraggable, Content: View>: View {
    
    let style: DeepStyle
    let rootItem: DI
    let item: DI
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    
    @State private var isTargeted: Bool = false
    @State private var isTargetedAbove: Bool = false
    @State private var isTargetedBelow: Bool = false
    
    var body: some View {
        
        ZStack {
            
            switch item.representation {
            case .group(_, let items):
                
                VStack(alignment: .leading, spacing: 0.0) {
                    
                    target {
                        content(item)
                            .draggable(drag(item)) {
                                
                                VStack(alignment: .leading, spacing: 0.0) {
                                    
                                    content(item)
                                        .frame(height: style.rowHeight)
                                    
                                    if item.isExpanded {
                                        
                                        DeepListView(style: style,
                                                     rootItem: rootItem,
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
                                     items: items,
                                     drag: drag,
                                     drop: drop,
                                     content: content)
                    }
                }
                
            case .element:
                
                target {
                    content(item)
                        .draggable(drag(item))
                }
                .frame(height: style.rowHeight)
            }
        }
    }
    
    private func target<Content: View>(content: () -> Content) -> some View {
        
        ZStack {
            
            content()
                .dropDestination(for: DD.self, action: { _, _ in false }) { isTargeted in
                    self.isTargeted = isTargeted
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
                            drop(drops, .below(itemID: item.id), location)
                        }) { isTargeted in
                            self.isTargetedBelow = isTargeted
                        }
                }
            }
            
            VStack {
                if isTargetedAbove {
                    DeepSeparatorView(style: style, rootItem: rootItem, deepPlace: .above(itemID: item.id))
                    Spacer()
                } else if isTargetedBelow {
                    Spacer()
                    DeepSeparatorView(style: style, rootItem: rootItem, deepPlace: .below(itemID: item.id))
                }
            }
        }
    }
}
