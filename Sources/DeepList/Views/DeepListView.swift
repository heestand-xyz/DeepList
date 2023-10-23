import SwiftUI

struct DeepListView<DI: DeepItemProtocol & ObservableObject, DD: DeepDraggable, Content: View>: View {
    
    let style: DeepStyle
    @ObservedObject var rootItem: DI
    @ObservedObject var parentItem: DI
    let items: [DI]
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    
    @State private var isTargeted: Bool = false
    
    private var showBottomSection: Bool {
        rootItem != parentItem || items.last?.isGroup == true
    }
    
    private var bottomOfGroupDeepPlace: DeepPlace {
        .below(itemID: parentItem.id, after: true)
    }
    
    var body: some View {
        
        if !items.isEmpty {

            ZStack {

                RoundedRectangle(cornerRadius: style.listCornerRadius)
                    .foregroundColor(style.backgroundColor)
                    .layoutPriority(-1)
                
                VStack(alignment: .leading, spacing: 0.0) {
                    
                    ForEach(items) { item in
                        
                        DeepItemView(style: style,
                                     rootItem: rootItem,
                                     parentItem: parentItem,
                                     item: item,
                                     drag: drag,
                                     drop: drop,
                                     content: content)
                    }
                    
                    if showBottomSection {
                        Color.gray.opacity(0.001)
                            .frame(height: style.listPadding)
                            .dropDestination(for: DD.self, action: { drops, location in
                                drop(drops, bottomOfGroupDeepPlace, location)
                            }) { isTargeted in
                                self.isTargeted = isTargeted
                            }
                            .overlay(alignment: .bottom) {
                                if isTargeted {
                                    DeepSeparatorView(
                                        style: style,
                                        rootItem: rootItem,
                                        parentItem: parentItem,
                                        deepPlace: bottomOfGroupDeepPlace,
                                        isGroup: true,
                                        isExpanded: true
                                    )
                                }
                            }
                    }
                }
            }
//            .padding(.vertical, style.listPadding)
        }
    }
}
