import SwiftUI

public struct DeepRootView<DI: DeepItemProtocol, DD: DeepDraggable, Content: View>: View {
    
    let rootItem: DI
    let draggable: (DI) -> DD
    let content: (DI) -> Content
    
    public init(rootItem: DI,
                draggable: @escaping (DI) -> DD,
                content: @escaping (DI) -> Content) {
        precondition(rootItem.isGroup)
        self.rootItem = rootItem
        self.draggable = draggable
        self.content = content
    }
    
    public var body: some View {
        
        ScrollView {
        
            DeepListView(items: rootItem.items,
                         draggable: draggable,
                         content: content)
        }
    }
}
