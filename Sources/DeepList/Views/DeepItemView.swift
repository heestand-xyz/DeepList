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
    private var isSomeTargeted: Bool {
        isTargeted || isTargetedAbove || isTargetedBelow
    }
    
//    @State private var targetTimer: Timer?
    
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
                            content(item)
                        }
                        .draggable(drag(item)) {
                            
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: style.listCornerRadius)
                                    .foregroundColor(style.backgroundColor)
                                    .layoutPriority(-1)
                                
                                VStack(alignment: .leading, spacing: 0.0) {
                                    
                                    content(item)
                                        .padding(.leading, style.indentationPadding)
                                        .frame(height: style.rowHeight)
                                    
                                    if item.isExpanded {
                                        
                                        DeepListView(style: style,
                                                     rootItem: rootItem,
                                                     grandparentItem: parentItem,
                                                     parentItem: item,
                                                     items: items,
                                                     drag: drag,
                                                     drop: drop,
                                                     content: content)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: style.rowHeight)
                    
                    if item.isExpanded {
                        
                        DeepListView(style: style,
                                     rootItem: rootItem, 
                                     grandparentItem: parentItem,
                                     parentItem: item,
                                     items: items,
                                     drag: drag,
                                     drop: drop,
                                     content: content)
                    }
                }
            }
            .padding(.horizontal, style.indentationPadding)
            
        case .element:
            
            target {
                ZStack {
                    Color.gray.opacity(0.001)
                        .layoutPriority(-1)
                    content(item)
                }
                .draggable(drag(item)) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: style.listCornerRadius)
                            .foregroundColor(style.backgroundColor)
                            .layoutPriority(-1)
                        
                        content(item)
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
                    DeepSeparatorView(
                        style: style,
                        rootItem: rootItem,
                        parentItem: parentItem,
                        item: item,
                        deepPlace: .above(itemID: item.id)
                    )
                    Spacer()
                } else if isTargetedBelow {
                    Spacer()
                    DeepSeparatorView(
                        style: style,
                        rootItem: rootItem,
                        parentItem: parentItem,
                        item: item,
                        deepPlace: .below(itemID: item.id, after: item.isGroup && !item.isExpanded)
                    )
                }
            }
            
            if isSomeTargeted {
                
                VStack(spacing: 0.0) {
                    Color.gray.opacity(0.001)
                        .dropDestination(for: DD.self, action: { drops, location in
                            drop(drops, .above(itemID: item.id), location)
                        }) { isTargeted in
                            isTargetedAbove = isTargeted
                        }
                    Color.gray.opacity(0.001)
                        .dropDestination(for: DD.self, action: { drops, location in
                            drop(drops, .below(itemID: item.id, after: item.isGroup && !item.isExpanded), location)
                        }) { isTargeted in
                            isTargetedBelow = isTargeted
//                            didTargetBelow(isTargeted)
                        }
                }
            }
        }
    }
    
//    private func didTargetBelow(_ isTargeted: Bool) {
//        targetTimer?.invalidate()
//        targetTimer = nil
//        guard isTargeted, item.isGroup, !item.isExpanded else { return }
//        targetTimer = .scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
//            var item: DI = item
//            withAnimation {
//                item.isExpanded = true
//            }
//        }
//    }
}
