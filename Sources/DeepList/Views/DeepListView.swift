import SwiftUI

struct DeepListView<DI: DeepItemProtocol & ObservableObject, DD: DeepDraggable, Content: View>: View {
    
    let style: DeepStyle
    @ObservedObject var rootItem: DI
    let grandparentItem: DI?
    @ObservedObject var parentItem: DI
    let items: [DI]
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    
    @State private var isTargeted: Bool = false
    @State private var middleItemIDTargeted: UUID?
    
    private var showBottomSection: Bool {
        rootItem != parentItem || items.last?.isGroup == true
    }
    
    private var bottomOfGroupDeepPlace: DeepPlace {
        .below(itemID: parentItem.id, after: true)
    }
    
    var body: some View {
        
        if !items.isEmpty {

            ZStack {

                VStack(alignment: .leading, spacing: 0.0) {
                    
                    ForEach(items) { item in
                        
                        DeepItemView(style: style,
                                     rootItem: rootItem,
                                     parentItem: parentItem,
                                     item: item,
                                     drag: drag,
                                     drop: drop,
                                     content: content)
                        
                        let index = items.firstIndex(of: item) ?? 0
                        if item != items.last  {
                            let nextItem = items[index + 1]
                            if item.isGroup && nextItem.isGroup {
                                
                                Color.gray.opacity(0.001)
                                    .frame(height: style.listPadding)
                                    .dropDestination(for: DD.self, action: { drops, location in
                                        drop(drops, .above(itemID: nextItem.id), location)
                                    }) { isTargeted in
                                        middleItemIDTargeted = isTargeted ? nextItem.id : nil
                                    }
                                    .overlay(alignment: .top) {
                                        if let id: UUID = middleItemIDTargeted,
                                           id == nextItem.id {
                                            DeepSeparatorView(
                                                style: style,
                                                rootItem: rootItem,
                                                parentItem: parentItem,
                                                item: nextItem,
                                                deepPlace: .above(itemID: id)
                                            )
                                        }
                                    }
                            }
                        }
                    }
                    
                    if showBottomSection, let grandparentItem: DI {
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
                                        parentItem: grandparentItem,
                                        item: parentItem,
                                        deepPlace: bottomOfGroupDeepPlace
                                    )
                                }
                            }
                    }
                }
            }
        }
    }
}
