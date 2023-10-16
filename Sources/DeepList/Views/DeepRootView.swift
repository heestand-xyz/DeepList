import SwiftUI

public struct DeepRootView<T: DeepItemProtocol, Content: View>: View {
    
    let rootItem: T
    let content: (T) -> Content
    
    public init(rootItem: T,
                content: @escaping (T) -> Content) {
        precondition(rootItem.isGroup)
        self.rootItem = rootItem
        self.content = content
    }
    
    public var body: some View {
        
        ScrollView {
        
            DeepListView(items: rootItem.items, content: content)
        }
    }
}
