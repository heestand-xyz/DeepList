import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct DeepObservableListView<DI: DeepItemProtocol & Observable, DD: DeepDraggable, Content: View, DragContent: View>: View {
    
    @ObservedObject var deepList: DeepList
    let rootItem: DI
    let grandparentItem: DI?
    let parentItem: DI
    let items: [DI]
    let style: DeepStyle
    let isDragPreview: Bool
    let drag: (DI) -> DD
    let drop: ([DD], DeepPlace, CGPoint) -> Bool
    let content: (DI) -> Content
    let dragContent: (DI) -> DragContent
    
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
                        
                        DeepObservableItemView(
                            deepList: deepList,
                            rootItem: rootItem,
                            parentItem: parentItem,
                            item: item,
                            style: style,
                            isDragPreview: isDragPreview,
                            drag: drag,
                            drop: drop,
                            content: content,
                            dragContent: dragContent
                        )
                        
                        let index = items.firstIndex(of: item) ?? 0
                        if item != items.last  {
                            let nextItem = items[index + 1]
                            if item.isGroup && nextItem.isGroup {
                                
                                Color.gray.opacity(0.001)
                                    .frame(height: style.listPadding)
                                    .dropDestination(for: DD.self, action: { drops, location in
                                        deepList.drop()
                                        return drop(drops, .above(itemID: nextItem.id), location)
                                    }) { isTargeted in
                                        middleItemIDTargeted = isTargeted ? nextItem.id : nil
                                    }
                                    .overlay(alignment: .top) {
                                        if let id: UUID = middleItemIDTargeted,
                                           id == nextItem.id {
                                            DeepObservableSeparatorView(
                                                deepList: deepList,
                                                rootItem: rootItem,
                                                parentItem: parentItem,
                                                item: nextItem,
                                                deepPlace: .above(itemID: id),
                                                style: style
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
                                deepList.drop()
                                return drop(drops, bottomOfGroupDeepPlace, location)
                            }) { isTargeted in
                                self.isTargeted = isTargeted
                            }
                            .overlay(alignment: .bottom) {
                                if isTargeted {
                                    DeepObservableSeparatorView(
                                        deepList: deepList,
                                        rootItem: rootItem,
                                        parentItem: grandparentItem,
                                        item: parentItem,
                                        deepPlace: bottomOfGroupDeepPlace,
                                        style: style
                                    )
                                }
                            }
                    }
                }
            }
        }
    }
}
