import SwiftUI

public struct DeepListView<DI: DeepItemProtocol, DD: DeepDraggable, Content: View>: View {
    
    let items: [DI]
    let draggable: (DI) -> DD
    let content: (DI) -> Content
    
    public init(items: [DI],
                draggable: @escaping (DI) -> DD,
                content: @escaping (DI) -> Content) {
        self.items = items
        self.draggable = draggable
        self.content = content
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0.0) {
            
            ForEach(items) { item in
                
                DeepItemView(item: item, 
                             draggable: draggable, 
                             content: content)
            }
        }
    }
}
